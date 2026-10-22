import 'dart:convert';
import 'http_client.dart' if (dart.library.js_interop) 'http_client_web.dart';
import 'api_exception.dart';

class ApiService {
  static const baseUrl = String.fromEnvironment('API_BASE_URL',
      defaultValue: 'http://localhost:8080');
  static final _client = createHttpClient();
  Future<dynamic> request(String path,
      {Map<String, dynamic>? data,
      Duration timeout = const Duration(seconds: 20)}) async {
    final uri = Uri.parse('$baseUrl$path');
    final response = await (data == null
            ? _client.get(uri)
            : _client.post(uri,
                headers: {'Content-Type': 'application/json'},
                body: jsonEncode(data)))
        .timeout(timeout);
    final decoded = jsonDecode(response.body);
    if (response.statusCode != 200)
      throw ApiException(
          response.statusCode,
          decoded is Map
              ? decoded['error']?.toString() ?? 'Falha na API'
              : 'Falha na API');
    return decoded;
  }

  Future<Map<String, dynamic>> profile() async =>
      await request('/api/auth/me') as Map<String, dynamic>;
  Future<List<dynamic>> listarRodadas() async {
    return await request('/api/inicio/rodadas') as List<dynamic>;
  }

  Future<Map<String, dynamic>> consultarInicio(int idConsulta) async {
    return await request('/api/inicio?consulta=$idConsulta')
        as Map<String, dynamic>;
  }

  Future<List<dynamic>> listarOrgaos() async {
    return await request('/api/admin/orgaos') as List<dynamic>;
  }

  Future<Map<String, dynamic>> consultarDistribuicao() async {
    return await request('/api/admin/distribuicao') as Map<String, dynamic>;
  }

  Future<void> salvarDistribuicao(
    int idTipo,
    int versao,
    List<int> anteriores,
    List<int> orgaos,
  ) async {
    await request('/api/admin/distribuicao/tipos/$idTipo', data: {
      'versao': versao,
      'orgaos_anteriores': anteriores,
      'orgaos': orgaos,
    });
  }

  Future<Map<String, dynamic>> vincularDistribuicaoEmLote(
    int versao,
    List<int> tipos,
    List<int> orgaos,
  ) async {
    return await request('/api/admin/distribuicao/vincular', data: {
      'versao': versao,
      'tipos': tipos,
      'orgaos': orgaos,
    }) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> listarUsuarios(
    String pesquisa,
    String situacao,
    int? idOrgao,
    int inicio,
  ) async {
    final filtros = {
      'q': pesquisa,
      'estado': situacao,
      'offset': inicio.toString(),
    };
    if (idOrgao != null) {
      filtros['orgao'] = idOrgao.toString();
    }

    final endereco = Uri(
      path: '/api/admin/usuarios',
      queryParameters: filtros,
    );
    return await request(endereco.toString()) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> buscarUsuario(int idUsuario) async {
    return await request('/api/admin/usuarios/$idUsuario')
        as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> salvarUsuario(
    int? idUsuario,
    Map<String, dynamic> dados,
  ) async {
    var endereco = '/api/admin/usuarios';
    if (idUsuario != null) {
      endereco += '/$idUsuario';
    }
    return await request(endereco, data: dados) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> consultarHistoricoUsuario(
    int idUsuario,
    int inicio,
  ) async {
    final endereco = '/api/admin/usuarios/$idUsuario/historico?offset=$inicio';
    return await request(endereco) as Map<String, dynamic>;
  }

  Future<void> loginDesenvolvimento(int idUsuario) async {
    await request('/api/auth/dev',
        data: {'id_usuario': idUsuario, 'token': '123456'});
  }

  Future<Map<String, dynamic>> configurarAcesso() async {
    return await request('/api/auth/config') as Map<String, dynamic>;
  }

  Future<void> solicitarCodigo(String email) async {
    await request('/api/auth/codigo',
        data: {'email': email}, timeout: const Duration(seconds: 40));
  }

  Future<void> entrarEmail(String email, String codigo) async {
    await request('/api/auth/entrar', data: {'email': email, 'codigo': codigo});
  }

  Future<void> logout() async {
    await request('/api/auth/logout', data: {});
  }

  Future<List<dynamic>> tipos() async =>
      await request('/api/tipos') as List<dynamic>;
  Future<Map<String, dynamic>> tipo(String id) async =>
      await request('/api/tipos/$id') as Map<String, dynamic>;
  Future<void> visualizar(String id) async {
    await request('/api/tipos/$id/visualizar', data: {});
  }

  Future<Map<String, dynamic>> salvarManifestacao(
    String idAtribuicao,
    Map<String, dynamic> dados,
  ) async {
    final endereco = '/api/tipos/$idAtribuicao/manifestacao';
    return await request(endereco, data: dados) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> pesquisarAssuntos(
    String idAtribuicao,
    String pesquisa,
    int inicio,
  ) async {
    final endereco = Uri(
      path: '/api/tipos/$idAtribuicao/assuntos',
      queryParameters: {'q': pesquisa, 'offset': inicio.toString()},
    );
    return await request(endereco.toString()) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> consultarResumo(
      String idConsulta, String idOrgao) async {
    final endereco = '/api/consultas/$idConsulta/orgaos/$idOrgao/resumo';
    return await request(endereco) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> catalog(String kind, String text, int offset,
          {int? version, String state = 'TODOS'}) async =>
      await request(
              '/api/catalogo/$kind?estado=$state&q=${Uri.encodeQueryComponent(text)}&offset=$offset${version == null ? '' : '&versao=$version'}')
          as Map<String, dynamic>;
  Future<void> finalizarManifestacao(
      String idConsulta, String idOrgao, int revisao) async {
    final endereco = '/api/consultas/$idConsulta/orgaos/$idOrgao/finalizar';
    await request(endereco, data: {'revisao': revisao});
  }
}
