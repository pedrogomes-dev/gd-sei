import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';

import '../lib/config/database_config.dart';
import '../lib/controllers/administracao_controller.dart';
import '../lib/controllers/catalogo_controller.dart';
import '../lib/controllers/inicio_controller.dart';
import '../lib/controllers/manifestacao_controller.dart';
import '../lib/models/api_error.dart';
import '../lib/models/database_failure.dart';
import '../lib/repositories/consulta_repository.dart';
import '../lib/repositories/database_repository.dart';
import '../lib/routes/router.dart';
import '../lib/services/auth_service.dart';

class BancoProcessamento extends DatabaseRepository {
  bool administrador = true;
  final atualizados = <int, int>{};
  String sqlListagem = '', sqlGravacao = '';
  final itens = [
    {
      'id_atribuicao': 1,
      'id_orgao': 0,
      'id_consulta': 1,
      'id_tipo_procedimento': 7,
      'status': 'FINALIZADA'
    },
    {
      'id_atribuicao': 2,
      'id_orgao': 9,
      'id_consulta': 1,
      'id_tipo_procedimento': 7,
      'status': 'FINALIZADA'
    },
    {
      'id_atribuicao': 3,
      'id_orgao': 9,
      'id_consulta': 2,
      'id_tipo_procedimento': 8,
      'status': 'RASCUNHO'
    },
  ];
  BancoProcessamento()
      : super(DatabaseConfig(
            host: 'teste',
            database: 'teste',
            username: 'teste',
            password: 'teste',
            driver: 'teste',
            port: 1433,
            encrypt: true,
            trustServerCertificate: false));

  @override
  Future<List<Map<String, dynamic>>> query(String sql,
      {List<Object> params = const [], String operation = 'consulta'}) async {
    if (operation == 'listar_processamento') {
      sqlListagem = sql;
      if (!sql.contains("WHERE g.status = 'FINALIZADA'") ||
          !sql.contains('t.versao = a.versao') ||
          !sql.contains('m.versao = a.versao')) {
        throw StateError('Listagem sem restrição de finalização/versão.');
      }
      return itens
          .where((i) => i['status'] == 'FINALIZADA')
          .map((i) => {
                ...i,
                'situacao': atualizados.containsKey(i['id_atribuicao'])
                    ? 'ATUALIZADO'
                    : 'PENDENTE',
              })
          .toList();
    }
    if (operation == 'atualizar_processamento') {
      sqlGravacao = sql;
      final id = params[1] as int;
      final item = itens.where((i) => i['id_atribuicao'] == id);
      if (!administrador)
        throw DatabaseFailure(stage: 'teste', kind: 'teste', code: 51500);
      if (item.isEmpty)
        throw DatabaseFailure(stage: 'teste', kind: 'teste', code: 51501);
      if (item.single['status'] != 'FINALIZADA')
        throw DatabaseFailure(stage: 'teste', kind: 'teste', code: 51502);
      atualizados.putIfAbsent(id, () => params[0] as int);
      return [];
    }
    if (!sql.contains("sin_admin = 'S'"))
      throw StateError('Autorização SQL inesperada.');
    return administrador
        ? [
            {'id_usuario': params.single}
          ]
        : [];
  }
}

class SessaoProcessamento extends AuthService {
  SessaoProcessamento(super.db);
  @override
  Future<int> authorize(HttpRequest request) async => 1;
}

Future<Future<({int status, dynamic dados})> Function(String, {bool post})>
    servidorTeste(BancoProcessamento banco) async {
  final consultas = ConsultaRepository(banco);
  final router = Router(
      SessaoProcessamento(banco),
      consultas,
      ManifestacaoController(banco, consultas),
      CatalogoController(banco),
      AdministracaoController(banco),
      InicioController(banco));
  final servidor = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
  final cliente = HttpClient();
  addTearDown(() async {
    cliente.close(force: true);
    await servidor.close(force: true);
  });
  servidor.listen((request) async {
    try {
      await router.route(request);
    } on ApiError catch (erro) {
      request.response.statusCode = erro.status;
      request.response.write(jsonEncode({'error': erro.message}));
    } finally {
      await request.response.close();
    }
  });
  return (String rota, {bool post = false}) async {
    final request = await cliente.openUrl(post ? 'POST' : 'GET',
        Uri.parse('http://127.0.0.1:${servidor.port}$rota'));
    final resposta = await request.close();
    return (
      status: resposta.statusCode,
      dados: jsonDecode(await utf8.decoder.bind(resposta).join())
    );
  };
}

void main() {
  test('não administrador recebe 403 na consulta e na marcação', () async {
    final banco = BancoProcessamento()..administrador = false;
    final chamar = await servidorTeste(banco);
    expect((await chamar('/api/admin/processamento')).status, 403);
    expect(
        (await chamar('/api/admin/processamento/1/atualizar', post: true))
            .status,
        403);
    expect(banco.atualizados, isEmpty);
  });
  test('lista finalizadas e preserva mesmo Tipo em órgãos diferentes',
      () async {
    final chamar = await servidorTeste(BancoProcessamento());
    final resposta = await chamar('/api/admin/processamento');
    expect(resposta.status, 200);
    expect((resposta.dados as List).map((i) => i['id_atribuicao']), [1, 2]);
    expect((resposta.dados as List).map((i) => i['id_orgao']), [0, 9]);
  });
  test('marca e repete sem duplicação nem troca do responsável original',
      () async {
    final banco = BancoProcessamento();
    final chamar = await servidorTeste(banco);
    expect(
        (await chamar('/api/admin/processamento/1/atualizar', post: true))
            .status,
        200);
    await AdministracaoController(banco).atualizarProcessamento(2, 1);
    expect(banco.atualizados, {1: 1});
    expect(banco.sqlGravacao, contains('WITH(UPDLOCK,HOLDLOCK)'));
    expect(banco.sqlGravacao, contains("sin_ativo = 'S' AND sin_admin = 'S'"));
    final resposta = await chamar('/api/admin/processamento');
    expect(resposta.dados.first['situacao'], 'ATUALIZADO');
  });
  test('rejeita inexistente, rascunho e IDs inválidos sem gravação', () async {
    final banco = BancoProcessamento();
    final chamar = await servidorTeste(banco);
    for (final caso in [(999, 404), (3, 409), (0, 400), (2147483648, 400)]) {
      expect(
          (await chamar('/api/admin/processamento/${caso.$1}/atualizar',
                  post: true))
              .status,
          caso.$2);
    }
    expect(banco.atualizados, isEmpty);
  });
}
