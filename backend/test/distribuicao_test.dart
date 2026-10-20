import 'dart:convert';
import 'dart:io';

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

void conferir(bool condicao, String mensagem) {
  if (!condicao) throw StateError(mensagem);
}

class BancoDistribuicaoTeste extends DatabaseRepository {
  bool administrador = true;
  bool publicado = true;
  int? falha;
  int gravacoes = 0;
  int lotes = 0;
  List<Object> parametros = [];
  String sqlGravacao = '';
  String sqlLote = '';

  BancoDistribuicaoTeste()
      : super(DatabaseConfig(
          host: 'teste',
          database: 'teste',
          username: 'teste',
          password: 'teste',
          driver: 'teste',
          port: 1433,
          encrypt: true,
          trustServerCertificate: false,
        ));

  @override
  Future<List<Map<String, dynamic>>> query(
    String sql, {
    List<Object> params = const [],
    String operation = 'consulta',
  }) async {
    if (sql.contains("AND sin_admin = 'S'")) {
      return administrador
          ? [
              {'id_usuario': 1}
            ]
          : [];
    }
    if (operation == 'vincular_distribuicao_lote') {
      sqlLote = sql;
      parametros = params;
      if (falha != null)
        throw DatabaseFailure(stage: 'teste', kind: 'teste', code: falha);
      lotes++;
      return [
        {'vinculos_incluidos': 2, 'tipos_alterados': 2}
      ];
    }
    if (sql.contains('MAX(versao)')) {
      if (operation != 'salvar_distribuicao') {
        return [
          {'versao': publicado ? 0 : null}
        ];
      }
    }
    if (operation == 'listar_tipos_distribuicao') {
      conferir(params.single == 0, 'Consulta sem versão explícita.');
      return [
        {'id_tipo_procedimento': 7, 'nome': 'Tipo', 'sin_ativo': 'S'}
      ];
    }
    if (operation == 'listar_vinculos_distribuicao') {
      return [
        {'id_tipo_procedimento': 7, 'id_orgao': 0}
      ];
    }
    if (sql.contains('FROM dbo.orgao')) {
      if (operation != 'salvar_distribuicao')
        return [
          {'id_orgao': 0, 'sigla': 'ORG'}
        ];
    }
    if (operation == 'salvar_distribuicao') {
      sqlGravacao = sql;
      parametros = params;
      if (falha != null)
        throw DatabaseFailure(stage: 'teste', kind: 'teste', code: falha);
      gravacoes++;
      return [];
    }
    throw StateError('SQL não previsto no teste: $operation');
  }
}

class SessaoTeste extends AuthService {
  SessaoTeste(super.db);

  @override
  Future<int> authorize(HttpRequest request) async => 1;
}

Future<void> main() async {
  final banco = BancoDistribuicaoTeste();
  final admin = AdministracaoController(banco);
  final consultas = ConsultaRepository(banco);
  final router = Router(
    SessaoTeste(banco),
    consultas,
    ManifestacaoController(banco, consultas),
    CatalogoController(banco),
    admin,
    InicioController(banco),
  );
  final servidor = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
  final cliente = HttpClient();
  servidor.listen((request) async {
    try {
      await router.route(request);
    } on ApiError catch (erro) {
      request.response.statusCode = erro.status;
      request.response.write(jsonEncode({'error': erro.message}));
    } catch (_) {
      request.response.statusCode = 500;
    } finally {
      await request.response.close();
    }
  });

  Future<({int status, dynamic dados})> chamar(String caminho,
      {Map<String, dynamic>? dados}) async {
    final url = Uri.parse('http://127.0.0.1:${servidor.port}$caminho');
    final request = await cliente.openUrl(dados == null ? 'GET' : 'POST', url);
    if (dados != null) request.write(jsonEncode(dados));
    final resposta = await request.close();
    final texto = await utf8.decoder.bind(resposta).join();
    return (
      status: resposta.statusCode,
      dados: texto.isEmpty ? null : jsonDecode(texto)
    );
  }

  const rota = '/api/admin/distribuicao';
  const edicao = '$rota/tipos/7';
  const lote = '$rota/vincular';
  Map<String, dynamic> dadosLote() => {
        'versao': 0,
        'tipos': [8, 7],
        'orgaos': [9, 0]
      };
  Map<String, dynamic> dados() => {
        'versao': 0,
        'orgaos_anteriores': [0],
        'orgaos': [9, 0]
      };
  try {
    banco.administrador = false;
    conferir((await chamar(rota)).status == 403,
        'Usuário comum consultou a distribuição.');
    conferir((await chamar(edicao, dados: dados())).status == 403,
        'Usuário comum gravou vínculos.');
    conferir((await chamar(lote, dados: dadosLote())).status == 403,
        'Usuário comum gravou lote.');
    conferir(banco.gravacoes == 0, 'Gravação sem perfil administrador.');

    banco.administrador = true;
    final lista = await chamar(rota);
    conferir(lista.status == 200 && lista.dados['versao'] == 0,
        'Falha ao listar versão 0.');
    conferir(lista.dados['vinculos'].single['id_orgao'] == 0,
        'Órgão 0 não preservado.');
    conferir((await chamar(edicao, dados: dados())).status == 200,
        'Falha ao vincular múltiplos órgãos.');
    conferir(
        banco.parametros[0] == 1 &&
            banco.parametros[1] == 7 &&
            banco.parametros[2] == 0,
        'Identidade/versão incorretas.');
    conferir(banco.parametros[3] == '[0]' && banco.parametros[4] == '[0,9]',
        'Conjuntos de órgãos incorretos.');
    conferir(!banco.sqlGravacao.contains('DELETE FROM dbo.consulta_orgao_tipo'),
        'Altera atribuições existentes.');

    final remover = dados()..['orgaos'] = <int>[];
    conferir(
        (await chamar(edicao, dados: remover)).status == 200 &&
            banco.parametros.last == '[]',
        'Não permite remover todos os vínculos.');
    for (final invalido in [null, '0', -1, 2147483648]) {
      final entrada = dados()..['versao'] = invalido;
      conferir((await chamar(edicao, dados: entrada)).status == 400,
          'Versão inválida aceita.');
    }
    for (final campo in ['orgaos', 'orgaos_anteriores']) {
      for (final invalido in [
        null,
        '0',
        [0, 0],
        ['0'],
        [2147483648],
        List.filled(2001, 0)
      ]) {
        final entrada = dados()..[campo] = invalido;
        conferir((await chamar(edicao, dados: entrada)).status == 400,
            'Lista inválida aceita: $campo');
      }
    }
    conferir(
        (await chamar('$rota/tipos/2147483648', dados: dados())).status == 400,
        'ID fora do intervalo SQL aceito.');
    for (final caso in [
      (51400, 409),
      (51401, 403),
      (51402, 409),
      (51403, 404),
      (51404, 409),
      (51405, 400)
    ]) {
      banco.falha = caso.$1;
      conferir((await chamar(edicao, dados: dados())).status == caso.$2,
          'Erro SQL ${caso.$1} não traduzido.');
    }
    banco.falha = null;
    final inclusao = await chamar(lote, dados: dadosLote());
    conferir(
        inclusao.status == 200 && inclusao.dados['vinculos_incluidos'] == 2,
        'Falha ao acrescentar vínculos em lote.');
    conferir(banco.parametros.join('|') == '1|0|[7,8]|[0,9]',
        'Parâmetros do lote incorretos.');
    for (final campo in ['tipos', 'orgaos']) {
      for (final invalido in [
        null,
        [],
        '0',
        [7, 7],
        ['0'],
        [2147483648],
        List.filled(2001, 0)
      ]) {
        final entrada = dadosLote()..[campo] = invalido;
        conferir((await chamar(lote, dados: entrada)).status == 400,
            'Lista inválida aceita no lote: $campo');
      }
    }
    for (final versao in [null, '0', -1, 2147483648]) {
      conferir(
          (await chamar(lote, dados: dadosLote()..['versao'] = versao))
                  .status ==
              400,
          'Versão inválida aceita no lote.');
    }
    for (final caso in [
      (51400, 409),
      (51401, 403),
      (51402, 409),
      (51403, 404),
      (51405, 400)
    ]) {
      banco.falha = caso.$1;
      conferir((await chamar(lote, dados: dadosLote())).status == caso.$2,
          'Erro SQL do lote não traduzido.');
    }
    banco.falha = null;
    conferir(
        banco.lotes == 1, 'Entradas inválidas chegaram à gravação em lote.');
    banco.publicado = false;
    conferir((await chamar(rota)).status == 404,
        'Base não publicada não foi tratada.');
    conferir(banco.gravacoes == 2, 'Entradas inválidas chegaram à gravação.');
    print(
        'Distribuição individual e em lote: autorização HTTP, versão/órgão 0, parâmetros, remoção e conflitos: OK (banco simulado).');
  } finally {
    cliente.close(force: true);
    await servidor.close(force: true);
  }
}
