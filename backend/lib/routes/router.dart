import 'dart:convert';
import 'dart:io';
import '../controllers/health_controller.dart';
import '../models/api_error.dart';
import '../repositories/consulta_repository.dart';
import '../services/auth_service.dart';
import '../repositories/manifestacao_repository.dart';
import '../controllers/administracao_controller.dart';

class Router {
  final AuthService auth;
  final ConsultaRepository consultas;
  final ManifestacaoRepository manifestacoes;
  final AdministracaoController administracao;
  Router(this.auth,this.consultas,this.manifestacoes,this.administracao);
  Future<Map<String,dynamic>> body(HttpRequest request) async {
    var length=0;
    final bytes=<int>[];
    await for(final chunk in request) {
      length+=chunk.length;
      if(length>262144) throw ApiError(413,'Requisição muito grande');
      bytes.addAll(chunk);
    }
    try {
      final decoded=jsonDecode(utf8.decode(bytes));
      if(decoded is! Map<String,dynamic>) throw const FormatException();
      return decoded;
    } catch (_) { throw ApiError(400,'JSON inválido'); }
  }
  void json(HttpRequest request,Object value) {
    request.response.headers.contentType=ContentType.json;
    request.response.headers.set('Cache-Control','no-store');
    request.response.write(jsonEncode(value));
  }
  Future<void> route(HttpRequest request) async {
    final path=request.uri.path;
    if(request.method=='GET' && path=='/api/health') { await healthController(request); return; }
    if(request.method=='POST' && path=='/api/auth/dev') {
      await auth.login(request,await body(request)); json(request,{'ok':true}); return;
    }
    if(request.method=='POST' && path=='/api/auth/logout') {
      await auth.logout(request); json(request,{'ok':true}); return;
    }
    final userId=await auth.authorize(request);
    if(request.method=='GET' && path=='/api/auth/me') {
      json(request,await auth.profile(userId)); return;
    }
    if (path.startsWith('/api/admin/')) {
      await rotasAdministracao(request, userId);
      return;
    }
    if(request.method=='GET' && path=='/api/tipos') {
      json(request,await consultas.list(userId)); return;
    }
    final catalog=RegExp(r'^/api/catalogo/(assuntos|tipos)$').firstMatch(path);
    if(request.method=='GET' && catalog!=null) {
      final state=request.uri.queryParameters['estado']??'TODOS';
      if(!['TODOS','S','N'].contains(state))throw ApiError(400,'Estado inválido.');
      final rawVersion=request.uri.queryParameters['versao'];
      final version=rawVersion==null?null:int.tryParse(rawVersion);
      final text=(request.uri.queryParameters['q']??'').trim();
      final offset=int.tryParse(request.uri.queryParameters['offset']??'0');
      if((rawVersion!=null&&(version==null||version<0||version>2147483647)) || text.length>250 || offset==null || offset<0 || offset>1000000)throw ApiError(400,'Pesquisa inválida');
      json(request,await manifestacoes.catalog(catalog.group(1)!,text,offset,version,state));return;
    }
    final match=RegExp(r'^/api/tipos/(\d+)(/visualizar|/manifestacao|/assuntos)?$').firstMatch(path);
    if(match!=null) {
      final id=int.tryParse(match.group(1)!);
      if(id==null || id<1 || id>2147483647) throw ApiError(400,'Identificador inválido');
      if(request.method=='GET' && match.group(2)==null) {
        json(request,await manifestacoes.detail(userId,id)); return;
      }
      if(request.method=='POST' && match.group(2)=='/manifestacao') {
        json(request,await manifestacoes.save(userId,id,await body(request))); return;
      }
      if(request.method=='GET' && match.group(2)=='/assuntos') {
        final text=(request.uri.queryParameters['q']??'').trim();
        final offset=int.tryParse(request.uri.queryParameters['offset']??'0');
        if(text.length>250 || offset==null || offset<0 || offset>1000000)throw ApiError(400,'Pesquisa inválida');
        json(request,await manifestacoes.search(userId,id,text,offset)); return;
      }
      if(request.method=='POST' && match.group(2)=='/visualizar') {
        await consultas.detail(userId,id);
        await consultas.viewed(userId,id); json(request,{'ok':true}); return;
      }
    }
    final group=RegExp(r'^/api/consultas/(\d+)/orgaos/(\d+)/(resumo|finalizar)$').firstMatch(path);
    if(group!=null) {
      final consulta=int.tryParse(group.group(1)!);final orgao=int.tryParse(group.group(2)!);
      if(consulta==null||orgao==null||consulta<1||orgao<1||consulta>2147483647||orgao>2147483647)throw ApiError(400,'Identificador inválido');
      if(request.method=='GET' && group.group(3)=='resumo') {
        json(request,await manifestacoes.summary(userId,consulta,orgao));return;
      }
      if(request.method=='POST' && group.group(3)=='finalizar') {
        await manifestacoes.finish(userId,consulta,orgao,await body(request));json(request,{'status':'FINALIZADA'});return;
      }
    }
    throw ApiError(404,'Rota não disponível');
  }
  Future<void> rotasAdministracao(HttpRequest request, int idAdministrador) async {
    await administracao.verificarAdministrador(idAdministrador);

    final caminho = request.uri.path;
    final metodo = request.method;
    final filtros = request.uri.queryParameters;

    if (metodo == 'GET' && caminho == '/api/admin/orgaos') {
      final orgaos = await administracao.listarOrgaos(idAdministrador);
      json(request, orgaos);
      return;
    }

    if (metodo == 'POST' && caminho == '/api/admin/usuarios') {
      final dados = await body(request);
      final usuario = await administracao.salvarUsuario(idAdministrador, 0, dados);
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
        idAdministrador, pesquisa, situacao, idOrgao, inicio,
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
      final eventos = await administracao.consultarHistorico(idAdministrador, idUsuario, inicio);
      json(request, eventos);
      return;
    }

    if (metodo == 'GET' && !historico) {
      final usuario = await administracao.buscarUsuario(idAdministrador, idUsuario);
      json(request, usuario);
      return;
    }

    if (metodo == 'POST' && !historico) {
      final dados = await body(request);
      final usuario = await administracao.salvarUsuario(idAdministrador, idUsuario, dados);
      json(request, usuario);
      return;
    }

    throw ApiError(404, 'Rota administrativa não disponível.');
  }

}

