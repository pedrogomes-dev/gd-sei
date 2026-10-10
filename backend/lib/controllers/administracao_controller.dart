import 'dart:convert';

import '../models/api_error.dart';
import '../models/database_failure.dart';
import '../repositories/database_repository.dart';
import '../utils/validacoes.dart';

class AdministracaoController {
  final DatabaseRepository banco;

  AdministracaoController(this.banco);

  Future<void> verificarAdministrador(int idUsuario) async {
    const sql = '''
      SELECT id_usuario
      FROM dbo.usuario
      WHERE id_usuario = ?
        AND sin_ativo = 'S'
        AND sin_admin = 'S'
    ''';

    final usuarios = await banco.query(sql, params: [idUsuario]);

    if (usuarios.isEmpty) {
      throw ApiError(403, 'Acesso restrito à administração.');
    }
  }

  Future<List<Map<String, dynamic>>> listarOrgaos(int idAdministrador) async {
    await verificarAdministrador(idAdministrador);

    const sql = '''
      SELECT id_orgao, sigla
      FROM dbo.orgao
      ORDER BY sigla
    ''';

    return banco.query(sql);
  }

  Future<Map<String, dynamic>> listarUsuarios(
    int idAdministrador,
    String pesquisa,
    String situacao,
    int? idOrgao,
    int inicio,
  ) async {
    await verificarAdministrador(idAdministrador);

    final texto = prepararPesquisa(pesquisa);
    final parametros = <Object>[texto, texto];
    var filtro = '''
      WHERE (u.nome LIKE ? ESCAPE '~' OR u.email LIKE ? ESCAPE '~')
    ''';

    if (idOrgao != null) {
      filtro += '''
        AND EXISTS (
          SELECT 1
          FROM dbo.usuario_orgao vinculo
          WHERE vinculo.id_usuario = u.id_usuario
            AND vinculo.id_orgao = ?
        )
      ''';
      parametros.add(idOrgao);
    }

    // Contagens de toda a busca/órgão, sem o filtro de acesso ou paginação.
    final totais = await banco.query('''
      SELECT COUNT_BIG(*) AS todos,
        COUNT_BIG(CASE WHEN u.sin_ativo = 'S' THEN 1 END) AS ativos,
        COUNT_BIG(CASE WHEN u.sin_ativo = 'N' THEN 1 END) AS inativos
      FROM dbo.usuario u
      $filtro
    ''', params: [...parametros]);

    if (situacao != 'TODOS') {
      filtro += ' AND u.sin_ativo = ?';
      parametros.add(situacao);
    }

    final sqlQuantidade = '''
      SELECT COUNT_BIG(*) AS total
      FROM dbo.usuario u
      $filtro
    ''';

    final quantidade = await banco.query(sqlQuantidade, params: parametros);

    final sqlUsuarios = '''
      SELECT u.id_usuario, u.nome, u.email, u.sin_ativo, u.sin_admin, u.revisao,
        (
          SELECT orgao.id_orgao, orgao.sigla
          FROM dbo.usuario_orgao vinculo
          JOIN dbo.orgao orgao ON orgao.id_orgao = vinculo.id_orgao
          WHERE vinculo.id_usuario = u.id_usuario
          ORDER BY orgao.sigla
          FOR JSON PATH
        ) AS orgaos
      FROM dbo.usuario u
      $filtro
      ORDER BY u.nome, u.id_usuario
      OFFSET ? ROWS FETCH NEXT 51 ROWS ONLY
    ''';

    final usuarios = await banco.query(
      sqlUsuarios,
      params: [...parametros, inicio],
    );
    final pagina = <Map<String, dynamic>>[];

    for (final registro in usuarios.take(50)) {
      final usuario = Map<String, dynamic>.from(registro);
      final orgaosJson = usuario['orgaos']?.toString() ?? '[]';
      usuario['orgaos'] = jsonDecode(orgaosJson);
      pagina.add(usuario);
    }

    return {
      'itens': pagina,
      'quantidades': totais.first,
      'total': int.parse(quantidade.first['total'].toString()),
      'mais': usuarios.length > 50,
    };
  }

  String prepararPesquisa(String pesquisa) {
    var texto = pesquisa.replaceAll('~', '~~');
    texto = texto.replaceAll('%', '~%');
    texto = texto.replaceAll('_', '~_');
    texto = texto.replaceAll('[', '~[');
    return '%$texto%';
  }

  Future<Map<String, dynamic>> buscarUsuario(
    int idAdministrador,
    int idUsuario,
  ) async {
    await verificarAdministrador(idAdministrador);

    const sqlUsuario = '''
      SELECT id_usuario, nome, email, sin_ativo, sin_admin, revisao
      FROM dbo.usuario
      WHERE id_usuario = ?
    ''';
    final usuarios = await banco.query(sqlUsuario, params: [idUsuario]);

    if (usuarios.isEmpty) {
      throw ApiError(404, 'Usuário não encontrado.');
    }

    const sqlOrgaos = '''
      SELECT id_orgao
      FROM dbo.usuario_orgao
      WHERE id_usuario = ?
      ORDER BY id_orgao
    ''';
    final vinculos = await banco.query(sqlOrgaos, params: [idUsuario]);
    final orgaos = <int>[];

    for (final vinculo in vinculos) {
      orgaos.add(int.parse(vinculo['id_orgao'].toString()));
    }

    return {...usuarios.first, 'orgaos': orgaos};
  }

  Future<Map<String, dynamic>> consultarHistorico(
    int idAdministrador,
    int idUsuario,
    int inicio,
  ) async {
    // Também verifica se o usuário consultado existe.
    await buscarUsuario(idAdministrador, idUsuario);

    const sql = '''
      SELECT id_evento, data_evento, evento, antes, depois,
        id_usuario_responsavel, responsavel_nome, responsavel_email
      FROM dbo.auditoria_administrativa
      WHERE id_usuario_alvo = ?
      ORDER BY id_evento DESC
      OFFSET ? ROWS FETCH NEXT 51 ROWS ONLY
    ''';
    final eventos = await banco.query(sql, params: [idUsuario, inicio]);
    final pagina = <Map<String, dynamic>>[];

    for (final registro in eventos.take(50)) {
      final evento = Map<String, dynamic>.from(registro);
      final antes = evento['antes'];
      evento['antes'] = antes == null ? null : jsonDecode(antes.toString());
      evento['depois'] = jsonDecode(evento['depois'].toString());

      // datetime2 do SQL guarda UTC sem indicador de fuso.
      var data = evento['data_evento'].toString().replaceAll(' ', 'T');
      if (!data.endsWith('Z')) data += 'Z';
      evento['data_evento'] = data;
      pagina.add(evento);
    }

    return {'itens': pagina, 'mais': eventos.length > 50};
  }

  Future<Map<String, dynamic>> salvarUsuario(
    int idAdministrador,
    int idUsuario,
    Map<String, dynamic> dados,
  ) async {
    await verificarAdministrador(idAdministrador);
    validarCadastro(dados);

    final nome = (dados['nome'] as String).trim();
    final email = (dados['email'] as String).trim().toLowerCase();
    final situacao = dados['sin_ativo'] as String;
    final perfilAdministrador = dados['sin_admin'] as String;
    final revisaoEsperada = dados['revisao'] as int;
    final orgaos = dados['orgaos'] as List;

    const sql = '''
      EXEC dbo.sp_salvar_usuario ?, ?, ?, ?, ?, ?, ?, ?
    ''';

    try {
      final resultado = await banco.query(
        sql,
        params: [
          idAdministrador,
          idUsuario,
          revisaoEsperada,
          nome,
          email,
          situacao,
          perfilAdministrador,
          jsonEncode(orgaos),
        ],
        operation: 'administrar_usuario',
      );

      return resultado.first;
    } on DatabaseFailure catch (erro) {
      throw traduzirErro(erro);
    }
  }

  void validarCadastro(Map<String, dynamic> dados) {
    final nome = dados['nome'];
    if (nome is! String || nome.trim().isEmpty || nome.trim().length > 150) {
      throw ApiError(400, 'Informe um nome com até 150 caracteres.');
    }

    final email = dados['email'];
    if (email is! String || email.trim().length > 250) {
      throw ApiError(400, 'Informe um e-mail com até 250 caracteres.');
    }
    if (!Validacoes.emailValido(email)) {
      throw ApiError(400, 'Informe um e-mail válido.');
    }

    final situacao = dados['sin_ativo'];
    if (situacao != 'S' && situacao != 'N') {
      throw ApiError(400, 'Situação de acesso inválida.');
    }

    final perfilAdministrador = dados['sin_admin'];
    if (perfilAdministrador != 'S' && perfilAdministrador != 'N') {
      throw ApiError(400, 'Perfil administrativo inválido.');
    }

    final revisao = dados['revisao'];
    if (revisao is! int || revisao < 0 || revisao > 2147483647) {
      throw ApiError(400, 'Revisão do cadastro inválida.');
    }

    final orgaos = dados['orgaos'];
    if (orgaos is! List || orgaos.length > 2000) {
      throw ApiError(400, 'Lista de órgãos inválida.');
    }

    final orgaosVerificados = <int>{};
    for (final idOrgao in orgaos) {
      if (idOrgao is! int || idOrgao < -2147483648 || idOrgao > 2147483647) {
        throw ApiError(400, 'Identificador de órgão inválido.');
      }
      if (!orgaosVerificados.add(idOrgao)) {
        throw ApiError(400, 'A lista contém órgãos duplicados.');
      }
    }
  }

  Object traduzirErro(DatabaseFailure erro) {
    switch (erro.code) {
      case 51210:
        return ApiError(400, 'Cadastro ou lista de órgãos inválidos.');
      case 51211:
        return ApiError(403, 'Acesso restrito à administração.');
      case 51212:
        return ApiError(409, 'Cadastro alterado. Recarregue antes de salvar.');
      case 51213:
      case 2601:
      case 2627:
        return ApiError(409, 'E-mail já cadastrado.');
      case 51214:
        return ApiError(400, 'Órgão não encontrado.');
      case 51215:
        return ApiError(409, 'Administração ocupada. Tente novamente.');
      case 51216:
        return ApiError(404, 'Usuário não encontrado.');
      default:
        return erro;
    }
  }
}

