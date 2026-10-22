import 'dart:convert';
import 'dart:io';
import '../controllers/health_controller.dart';
import '../models/api_error.dart';
import '../repositories/consulta_repository.dart';
import '../services/auth_service.dart';
import '../controllers/manifestacao_controller.dart';
import '../controllers/catalogo_controller.dart';
import '../controllers/administracao_controller.dart';
import '../controllers/inicio_controller.dart';

class Router {
  final AuthService auth;
  final ConsultaRepository consultas;
  final ManifestacaoController manifestacoes;
  final CatalogoController catalogo;
  final AdministracaoController administracao;
  final InicioController inicio;
  Router(this.auth, this.consultas, this.manifestacoes, this.catalogo,
      this.administracao, this.inicio);
  Future<Map<String, dynamic>> body(HttpRequest request) async {
    var length = 0;
    final bytes = <int>[];
    await for (final chunk in request) {
      length += chunk.length;
      if (length > 262144) throw ApiError(413, 'Requisição muito grande');
      bytes.addAll(chunk);
    }
    try {
      final decoded = jsonDecode(utf8.decode(bytes));
      if (decoded is! Map<String, dynamic>) throw const FormatException();
      return decoded;
    } catch (_) {
      throw ApiError(400, 'JSON inválido');
    }
  }

  void json(HttpRequest request, Object value) {
    request.response.headers.contentType = ContentType.json;
    request.response.headers.set('Cache-Control', 'no-store');
    request.response.write(jsonEncode(value));
  }

  Future<void> route(HttpRequest request) async {
    final caminho = request.uri.path;
    final metodo = request.method;

    if (metodo == 'GET' && caminho == '/api/health') {
      await healthController(request);
      return;
    }
    if (metodo == 'POST' && caminho == '/api/auth/dev') {
      await auth.login(request, await body(request));
      json(request, {'ok': true});
      return;
    }
    if (metodo == 'GET' && caminho == '/api/auth/config') {
      json(request, await auth.configurarAcesso());
      return;
    }
    if (metodo == 'POST' && caminho == '/api/auth/codigo') {
      await auth.solicitarCodigo(request, await body(request));
      json(request, {
        'mensagem':
            'Se o e-mail estiver cadastrado e ativo, você receberá um código de acesso.'
      });
      return;
    }
    if (metodo == 'POST' && caminho == '/api/auth/entrar') {
      await auth.entrarEmail(request, await body(request));
      json(request, {'ok': true});
      return;
    }
    if (metodo == 'POST' && caminho == '/api/auth/logout') {
      await auth.logout(request);
      json(request, {'ok': true});
      return;
    }

    final idUsuario = await auth.authorize(request);
    if (metodo == 'GET' && caminho == '/api/auth/me') {
      json(request, await auth.profile(idUsuario));
      return;
    }
    if (metodo == 'GET' && caminho == '/api/inicio/rodadas') {
      json(request, await inicio.listarRodadas(idUsuario));
      return;
    }
    if (metodo == 'GET' && caminho == '/api/inicio') {
      final idConsulta =
          lerIdentificador(request.uri.queryParameters['consulta'] ?? '');
      json(request, await inicio.consultar(idUsuario, idConsulta));
      return;
    }
    if (caminho.startsWith('/api/admin/')) {
      await rotasAdministracao(request, idUsuario);
      return;
    }
    if (metodo == 'GET' && caminho == '/api/tipos') {
      json(request, await consultas.list(idUsuario));
      return;
    }

    final rotaCatalogo =
        RegExp(r'^/api/catalogo/(assuntos|tipos)$').firstMatch(caminho);
    if (metodo == 'GET' && rotaCatalogo != null) {
      await consultarCatalogo(request, rotaCatalogo.group(1)!);
      return;
    }

    final rotaTipo =
        RegExp(r'^/api/tipos/(\d+)(/visualizar|/manifestacao|/assuntos)?$')
            .firstMatch(caminho);
    if (rotaTipo != null) {
      await rotasTipoProcesso(request, idUsuario, rotaTipo);
      return;
    }

    final rotaConsulta =
        RegExp(r'^/api/consultas/(\d+)/orgaos/(\d+)/(resumo|finalizar)$')
            .firstMatch(caminho);
    if (rotaConsulta != null) {
      await rotasConsulta(request, idUsuario, rotaConsulta);
      return;
    }

    throw ApiError(404, 'Rota não disponível');
  }

  int lerIdentificador(String valor, {bool permitirZero = false}) {
    final id = int.tryParse(valor);
    if (id == null || id < (permitirZero ? 0 : 1) || id > 2147483647) {
      throw ApiError(400, 'Identificador inválido');
    }
    return id;
  }

  int lerInicioPagina(HttpRequest request) {
    final inicio = int.tryParse(request.uri.queryParameters['offset'] ?? '0');
    if (inicio == null || inicio < 0 || inicio > 1000000) {
      throw ApiError(400, 'Página inválida');
    }
    return inicio;
  }

  String lerPesquisa(HttpRequest request) {
    final pesquisa = (request.uri.queryParameters['q'] ?? '').trim();
    if (pesquisa.length > 250) {
      throw ApiError(400, 'Pesquisa deve ter até 250 caracteres');
    }
    return pesquisa;
  }

  Future<void> consultarCatalogo(HttpRequest request, String categoria) async {
    final filtros = request.uri.queryParameters;
    final situacao = filtros['estado'] ?? 'TODOS';
    if (!['TODOS', 'S', 'N'].contains(situacao)) {
      throw ApiError(400, 'Estado inválido.');
    }

    int? versao;
    if (filtros.containsKey('versao')) {
      versao = int.tryParse(filtros['versao']!);
      if (versao == null || versao < 0 || versao > 2147483647) {
        throw ApiError(400, 'Versão inválida.');
      }
    }

    final pesquisa = lerPesquisa(request);
    final inicio = lerInicioPagina(request);
    final resultado =
        await catalogo.consultar(categoria, pesquisa, inicio, versao, situacao);
    json(request, resultado);
  }

  Future<void> rotasTipoProcesso(
    HttpRequest request,
    int idUsuario,
    RegExpMatch rota,
  ) async {
    final idAtribuicao = lerIdentificador(rota.group(1)!);
    final operacao = rota.group(2);
    final metodo = request.method;

    if (metodo == 'GET' && operacao == null) {
      json(request, await manifestacoes.consultar(idUsuario, idAtribuicao));
      return;
    }
    if (metodo == 'POST' && operacao == '/manifestacao') {
      final dados = await body(request);
      json(request, await manifestacoes.salvar(idUsuario, idAtribuicao, dados));
      return;
    }
    if (metodo == 'GET' && operacao == '/assuntos') {
      final pesquisa = lerPesquisa(request);
      final inicio = lerInicioPagina(request);
      final resultado = await manifestacoes.pesquisarAssuntos(
          idUsuario, idAtribuicao, pesquisa, inicio);
      json(request, resultado);
      return;
    }
    if (metodo == 'POST' && operacao == '/visualizar') {
      await consultas.detail(idUsuario, idAtribuicao);
      await consultas.viewed(idUsuario, idAtribuicao);
      json(request, {'ok': true});
      return;
    }
    throw ApiError(404, 'Rota não disponível');
  }

  Future<void> rotasConsulta(
    HttpRequest request,
    int idUsuario,
    RegExpMatch rota,
  ) async {
    final idConsulta = lerIdentificador(rota.group(1)!);
    // IDs de órgão são preservados do SEI, incluindo o órgão 0.
    final idOrgao = lerIdentificador(rota.group(2)!, permitirZero: true);
    final operacao = rota.group(3);

    if (request.method == 'GET' && operacao == 'resumo') {
      final resumo =
          await manifestacoes.consultarResumo(idUsuario, idConsulta, idOrgao);
      json(request, resumo);
      return;
    }
    if (request.method == 'POST' && operacao == 'finalizar') {
      final dados = await body(request);
      await manifestacoes.finalizar(idUsuario, idConsulta, idOrgao, dados);
      json(request, {'status': 'FINALIZADA'});
      return;
    }
    throw ApiError(404, 'Rota não disponível');
  }

  Future<void> rotasAdministracao(
      HttpRequest request, int idAdministrador) async {
    await administracao.verificarAdministrador(idAdministrador);

    final caminho = request.uri.path;
    final metodo = request.method;
    final filtros = request.uri.queryParameters;

    if (metodo == 'GET' && caminho == '/api/admin/distribuicao') {
      json(request, await administracao.consultarDistribuicao(idAdministrador));
      return;
    }
    if (metodo == 'POST' && caminho == '/api/admin/distribuicao/vincular') {
      json(
          request,
          await administracao.vincularDistribuicaoEmLote(
              idAdministrador, await body(request)));
      return;
    }
    final rotaDistribuicao =
        RegExp(r'^/api/admin/distribuicao/tipos/(\d+)$').firstMatch(caminho);
    if (metodo == 'POST' && rotaDistribuicao != null) {
      final idTipo =
          lerIdentificador(rotaDistribuicao.group(1)!, permitirZero: true);
      await administracao.salvarDistribuicao(
          idAdministrador, idTipo, await body(request));
      json(request, {'ok': true});
      return;
    }

    if (metodo == 'GET' && caminho == '/api/admin/orgaos') {
      final orgaos = await administracao.listarOrgaos(idAdministrador);
      json(request, orgaos);
      return;
    }

    if (metodo == 'POST' && caminho == '/api/admin/usuarios') {
      final dados = await body(request);
      final usuario =
          await administracao.salvarUsuario(idAdministrador, 0, dados);
      json(request, usuario);
      return;
    }

    final inicio = int.tryParse(filtros['offset'] ?? '0');
    if (inicio == null || inicio < 0 || inicio > 1000000) {
      throw ApiError(400, 'Página inválida.');
    }

    if (metodo == 'GET' && caminho == '/api/admin/usuarios') {
      final pesquisa = (filtros['q'] ?? '').trim();
      if (pesquisa.length > 250) {
        throw ApiError(400, 'Pesquisa deve ter até 250 caracteres.');
      }

      final situacao = filtros['estado'] ?? 'TODOS';
      if (!['TODOS', 'S', 'N'].contains(situacao)) {
        throw ApiError(400, 'Situação de acesso inválida.');
      }

      int? idOrgao;
      if (filtros.containsKey('orgao')) {
        idOrgao = int.tryParse(filtros['orgao']!);
        if (idOrgao == null || idOrgao < -2147483648 || idOrgao > 2147483647) {
          throw ApiError(400, 'Órgão inválido.');
        }
      }

      final usuarios = await administracao.listarUsuarios(
        idAdministrador,
        pesquisa,
        situacao,
        idOrgao,
        inicio,
      );
      json(request, usuarios);
      return;
    }

    final rotaUsuario = RegExp(r'^/api/admin/usuarios/(\d+)(/historico)?$');
    final resultado = rotaUsuario.firstMatch(caminho);
    if (resultado == null) {
      throw ApiError(404, 'Rota administrativa não disponível.');
    }

    final idUsuario = int.tryParse(resultado.group(1)!);
    if (idUsuario == null || idUsuario < 1 || idUsuario > 2147483647) {
      throw ApiError(400, 'Usuário inválido.');
    }

    final historico = resultado.group(2) == '/historico';
    if (metodo == 'GET' && historico) {
      final eventos = await administracao.consultarHistorico(
          idAdministrador, idUsuario, inicio);
      json(request, eventos);
      return;
    }

    if (metodo == 'GET' && !historico) {
      final usuario =
          await administracao.buscarUsuario(idAdministrador, idUsuario);
      json(request, usuario);
      return;
    }

    if (metodo == 'POST' && !historico) {
      final dados = await body(request);
      final usuario =
          await administracao.salvarUsuario(idAdministrador, idUsuario, dados);
      json(request, usuario);
      return;
    }

    throw ApiError(404, 'Rota administrativa não disponível.');
  }
}
