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
  bool administrador = true, ativo = true;
  final avaliacoes = <String, Map<String, dynamic>>{};
  String sqlListagem = '', sqlAssuntos = '', sqlGravacao = '';
  final itens = <Map<String, dynamic>>[
    {
      'id_atribuicao': 1,
      'id_orgao': 0,
      'id_consulta': 1,
      'id_tipo_procedimento': 7,
      'status': 'FINALIZADA',
      'decisao_tipo': 'MANTER'
    },
    {
      'id_atribuicao': 2,
      'id_orgao': 9,
      'id_consulta': 1,
      'id_tipo_procedimento': 7,
      'status': 'FINALIZADA',
      'decisao_tipo': 'DESCONTINUAR'
    },
    {
      'id_atribuicao': 3,
      'id_orgao': 9,
      'id_consulta': 2,
      'id_tipo_procedimento': 8,
      'status': 'RASCUNHO',
      'decisao_tipo': 'MANTER'
    },
  ];
  final assuntos = <Map<String, dynamic>>[
    {'id_atribuicao': 1, 'id_assunto': 10, 'acao': 'MANTER'},
    {'id_atribuicao': 1, 'id_assunto': 11, 'acao': 'REMOVER'},
    {
      'id_atribuicao': 2,
      'id_assunto': 99,
      'acao': 'ADICIONAR'
    }, // decisão antiga fora da descontinuação submetida
    {'id_atribuicao': 3, 'id_assunto': 10, 'acao': 'MANTER'},
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
          !sql.contains('t.versao = a.versao'))
        throw StateError('Listagem sem escopo.');
      return [
        for (final i in itens.where((i) => i['status'] == 'FINALIZADA'))
          {
            ...i,
            'parecer_tipo': avaliacoes['${i['id_atribuicao']}/tipo']
                ?['parecer'],
          }
      ];
    }
    if (operation == 'listar_assuntos_processamento') {
      sqlAssuntos = sql;
      if (!sql.contains('s.versao = v.versao') ||
          !sql.contains("m.decisao_tipo = 'MANTER'"))
        throw StateError('Assuntos sem escopo.');
      return [
        for (final s in assuntos.where((s) => itens.any((i) =>
            i['id_atribuicao'] == s['id_atribuicao'] &&
            i['status'] == 'FINALIZADA' &&
            i['decisao_tipo'] == 'MANTER')))
          {
            ...s,
            'parecer': avaliacoes['${s['id_atribuicao']}/${s['id_assunto']}']
                ?['parecer'],
          }
      ];
    }
    if (operation == 'avaliar_processamento') {
      sqlGravacao = sql;
      final id = params[1] as int;
      final item = itens.where((i) => i['id_atribuicao'] == id);
      void falha(int code) {
        throw DatabaseFailure(stage: 'teste', kind: 'teste', code: code);
      }

      if (!administrador || !ativo) falha(51500);
      if (item.isEmpty) falha(51501);
      if (item.single['status'] != 'FINALIZADA') falha(51502);
      if (item.single['decisao_tipo'] == null) falha(51505);
      if (params[3] == 1 &&
          (item.single['decisao_tipo'] != 'MANTER' ||
              !assuntos.any((s) =>
                  s['id_atribuicao'] == id && s['id_assunto'] == params[4])))
        falha(51503);
      final chave = '$id/${params[3] == 1 ? params[4] : 'tipo'}';
      if (avaliacoes.containsKey(chave) &&
          avaliacoes[chave]!['parecer'] != params[2]) falha(51504);
      avaliacoes.putIfAbsent(
          chave, () => {'parecer': params[2], 'admin': params[0]});
      return [];
    }
    if (!sql.contains("sin_admin = 'S'"))
      throw StateError('Autorização SQL inesperada.');
    return administrador && ativo
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

Future<
    Future<({int status, dynamic dados})> Function(String,
        {Map<String, dynamic>? dados})> servidorTeste(
    BancoProcessamento banco) async {
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
    } on ApiError catch (e) {
      request.response.statusCode = e.status;
      request.response.write(jsonEncode({'error': e.message}));
    } finally {
      await request.response.close();
    }
  });
  return (String rota, {Map<String, dynamic>? dados}) async {
    final request = await cliente.openUrl(dados == null ? 'GET' : 'POST',
        Uri.parse('http://127.0.0.1:${servidor.port}$rota'));
    if (dados != null) request.write(jsonEncode(dados));
    final response = await request.close();
    return (
      status: response.statusCode,
      dados: jsonDecode(await utf8.decoder.bind(response).join())
    );
  };
}

void main() {
  test('não administrador e administrador inativo recebem 403', () async {
    for (final ativo in [true, false]) {
      final banco = BancoProcessamento()
        ..administrador = !ativo
        ..ativo = ativo;
      final chamar = await servidorTeste(banco);
      expect((await chamar('/api/admin/processamento')).status, 403);
      expect(
          (await chamar('/api/admin/processamento/1/avaliar',
                  dados: {'parecer': 'ACEITO'}))
              .status,
          403);
      expect(banco.avaliacoes, isEmpty);
    }
  });
  test(
      'somente finalizadas, órgãos separados e assuntos efetivamente submetidos',
      () async {
    final chamar = await servidorTeste(BancoProcessamento());
    final lista = (await chamar('/api/admin/processamento')).dados as List;
    expect(lista.map((i) => i['id_orgao']), [0, 9]);
    expect(lista[0]['total_avaliacoes'], 3);
    expect(lista[1]['assuntos'], isEmpty);
    expect(lista[1]['total_avaliacoes'], 1);
  });
  test(
      'recusa de assunto propaga parcial mas conclusão exige todas as decisões',
      () async {
    final chamar = await servidorTeste(BancoProcessamento());
    await chamar('/api/admin/processamento/1/avaliar',
        dados: {'parecer': 'RECUSADO', 'id_assunto': 10});
    var item = (await chamar('/api/admin/processamento')).dados.first;
    expect(item['resultado'], 'PARCIALMENTE_ACEITO');
    expect(item['situacao'], 'PENDENTE');
    await chamar('/api/admin/processamento/1/avaliar',
        dados: {'parecer': 'ACEITO'});
    await chamar('/api/admin/processamento/1/avaliar',
        dados: {'parecer': 'ACEITO', 'id_assunto': 11});
    item = (await chamar('/api/admin/processamento')).dados.first;
    expect(item['situacao'], 'CONCLUIDO');
    expect(item['resultado'], 'PARCIALMENTE_ACEITO');
  });
  test('todos recusados permanecem concluído e parcialmente aceito', () async {
    final chamar = await servidorTeste(BancoProcessamento());
    for (final dados in [
      {'parecer': 'RECUSADO'},
      {'parecer': 'RECUSADO', 'id_assunto': 10},
      {'parecer': 'RECUSADO', 'id_assunto': 11}
    ]) {
      expect(
          (await chamar('/api/admin/processamento/1/avaliar', dados: dados))
              .status,
          200);
    }
    final item = (await chamar('/api/admin/processamento')).dados.first;
    expect(item['situacao'], 'CONCLUIDO');
    expect(item['resultado'], 'PARCIALMENTE_ACEITO');
  });
  test('Tipo sem Assuntos conclui com seu parecer individual', () async {
    final chamar = await servidorTeste(BancoProcessamento());
    await chamar('/api/admin/processamento/2/avaliar',
        dados: {'parecer': 'ACEITO'});
    final item = (await chamar('/api/admin/processamento')).dados[1];
    expect(item['situacao'], 'CONCLUIDO');
    expect(item['resultado'], 'ACEITO');
  });
  test('repetição preserva responsável e tentativa de troca retorna 409',
      () async {
    final banco = BancoProcessamento();
    final controller = AdministracaoController(banco);
    await controller.avaliarProcessamento(1, 1, {'parecer': 'ACEITO'});
    await controller.avaliarProcessamento(2, 1, {'parecer': 'ACEITO'});
    expect(banco.avaliacoes, {
      '1/tipo': {'parecer': 'ACEITO', 'admin': 1}
    });
    final chamar = await servidorTeste(banco);
    expect(
        (await chamar('/api/admin/processamento/1/avaliar',
                dados: {'parecer': 'RECUSADO'}))
            .status,
        409);
  });
  test('rejeita ID, parecer, rascunho e Assunto de outro contexto', () async {
    final banco = BancoProcessamento();
    final chamar = await servidorTeste(banco);
    for (final caso in [(999, 404), (3, 409), (0, 400), (2147483648, 400)]) {
      expect(
          (await chamar('/api/admin/processamento/${caso.$1}/avaliar',
                  dados: {'parecer': 'ACEITO'}))
              .status,
          caso.$2);
    }
    for (final id in [999, 10]) {
      expect(
          (await chamar('/api/admin/processamento/2/avaliar',
                  dados: {'parecer': 'ACEITO', 'id_assunto': id}))
              .status,
          404);
    }
    for (final dados in [
      {'parecer': 'X'},
      {'parecer': 'ACEITO', 'id_assunto': null},
      {'parecer': 'ACEITO', 'id_assunto': '10'}
    ]) {
      expect(
          (await chamar('/api/admin/processamento/1/avaliar', dados: dados))
              .status,
          400);
    }
    expect(
        (await chamar('/api/admin/processamento/1/atualizar', dados: {}))
            .status,
        404);
    expect(banco.avaliacoes, isEmpty);
  });
}
