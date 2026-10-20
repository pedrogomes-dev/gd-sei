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

  Future<Map<String, dynamic>> consultarDistribuicao(
      int idAdministrador) async {
    await verificarAdministrador(idAdministrador);
    final versoes =
        await banco.query('SELECT MAX(versao) AS versao FROM dbo.versao_base');
    final valor = versoes.single['versao'];
    if (valor == null) throw ApiError(404, 'Nenhuma base publicada.');
    final versao = int.parse(valor.toString());
    final tipos = await banco.query('''
      SELECT id_tipo_procedimento, nome, sin_ativo
      FROM dbo.tipo_procedimento WHERE versao = ?
      ORDER BY nome, id_tipo_procedimento
    ''', params: [versao], operation: 'listar_tipos_distribuicao');
    final vinculos = await banco.query('''
      SELECT id_tipo_procedimento, id_orgao
      FROM dbo.tipo_procedimento_restricao
      ORDER BY id_tipo_procedimento, id_orgao
    ''', operation: 'listar_vinculos_distribuicao');
    return {
      'versao': versao,
      'tipos': tipos,
      'vinculos': vinculos,
      'orgaos': await listarOrgaos(idAdministrador),
    };
  }

  List<int> validarIdsDistribuicao(dynamic valor, String campo) {
    if (valor is! List || valor.length > 2000) {
      throw ApiError(400, 'Lista de $campo inválida.');
    }
    final ids = <int>{};
    for (final id in valor) {
      if (!Validacoes.inteiroSqlValido(id) || !ids.add(id as int)) {
        throw ApiError(400, 'Lista de $campo inválida ou duplicada.');
      }
    }
    return ids.toList()..sort();
  }

  Future<void> salvarDistribuicao(
    int idAdministrador,
    int idTipo,
    Map<String, dynamic> dados,
  ) async {
    await verificarAdministrador(idAdministrador);
    final versao = dados['versao'];
    if (!Validacoes.inteiroSqlValido(versao) || (versao as int) < 0) {
      throw ApiError(400, 'Versão inválida.');
    }
    final anteriores =
        validarIdsDistribuicao(dados['orgaos_anteriores'], 'órgãos');
    final selecionados = validarIdsDistribuicao(dados['orgaos'], 'órgãos');
    const sql = '''
      SET NOCOUNT ON; SET XACT_ABORT ON;
      BEGIN TRY
        BEGIN TRANSACTION;
        DECLARE @administrador int=?, @tipo int=?, @versao int=?,
          @antes nvarchar(max)=?, @depois nvarchar(max)=?, @lock int;
        -- Mesma trava da carga 006: uma carga vê a distribuição inteira.
        EXEC @lock=sys.sp_getapplock @Resource='carga_atribuicoes',
          @LockMode='Exclusive', @LockOwner='Transaction', @LockTimeout=15000;
        IF @lock<0 THROW 51400,'Distribuicao ocupada.',1;
        IF NOT EXISTS(SELECT 1 FROM dbo.usuario WITH(HOLDLOCK)
          WHERE id_usuario=@administrador AND sin_ativo='S' AND sin_admin='S')
          THROW 51401,'Administrador nao autorizado.',1;
        IF @versao<>(SELECT MAX(versao) FROM dbo.versao_base WITH(HOLDLOCK))
          THROW 51402,'A base publicada mudou.',1;
        IF NOT EXISTS(SELECT 1 FROM dbo.tipo_procedimento WITH(HOLDLOCK)
          WHERE versao=@versao AND id_tipo_procedimento=@tipo)
          THROW 51403,'Tipo inexistente nesta versao.',1;
        DECLARE @anteriores TABLE(id_orgao int PRIMARY KEY);
        DECLARE @selecionados TABLE(id_orgao int PRIMARY KEY);
        INSERT @anteriores SELECT CONVERT(int,value) FROM OPENJSON(@antes);
        INSERT @selecionados SELECT CONVERT(int,value) FROM OPENJSON(@depois);
        IF EXISTS(SELECT id_orgao FROM @anteriores EXCEPT
          SELECT id_orgao FROM dbo.tipo_procedimento_restricao WITH(UPDLOCK,HOLDLOCK)
          WHERE id_tipo_procedimento=@tipo)
          OR EXISTS(SELECT id_orgao FROM dbo.tipo_procedimento_restricao WITH(UPDLOCK,HOLDLOCK)
          WHERE id_tipo_procedimento=@tipo EXCEPT SELECT id_orgao FROM @anteriores)
          THROW 51404,'Vinculos alterados por outro administrador.',1;
        IF EXISTS(SELECT 1 FROM @selecionados s WHERE NOT EXISTS(
          SELECT 1 FROM dbo.orgao WITH(HOLDLOCK) WHERE id_orgao=s.id_orgao))
          THROW 51405,'Orgao inexistente.',1;
        -- Somente a distribuição atual; não altera rodadas ou avaliações.
        DELETE FROM dbo.tipo_procedimento_restricao
          WHERE id_tipo_procedimento=@tipo AND id_orgao NOT IN(
            SELECT id_orgao FROM @selecionados);
        INSERT dbo.tipo_procedimento_restricao(id_tipo_procedimento,id_orgao)
          SELECT @tipo,s.id_orgao FROM @selecionados s WHERE NOT EXISTS(
            SELECT 1 FROM dbo.tipo_procedimento_restricao r
            WHERE r.id_tipo_procedimento=@tipo AND r.id_orgao=s.id_orgao);
        DECLARE @detalhe nvarchar(max)=(
            SELECT @tipo AS id_tipo_procedimento,@versao AS versao,
              JSON_QUERY(@antes) AS orgaos_antes,JSON_QUERY(@depois) AS orgaos_depois
            FOR JSON PATH,WITHOUT_ARRAY_WRAPPER);
        INSERT dbo.auditoria(id_usuario,evento,detalhe)
          VALUES(@administrador,'DISTRIBUICAO_TIPO',@detalhe);
        COMMIT;
      END TRY
      BEGIN CATCH
        IF XACT_STATE()<>0 ROLLBACK;
        THROW;
      END CATCH;
    ''';
    try {
      await banco.query(sql,
          params: [
            idAdministrador,
            idTipo,
            versao,
            jsonEncode(anteriores),
            jsonEncode(selecionados),
          ],
          operation: 'salvar_distribuicao');
    } on DatabaseFailure catch (erro) {
      throw traduzirErroDistribuicao(erro);
    }
  }

  Object traduzirErroDistribuicao(DatabaseFailure erro) {
    const mensagens = {
      51400: (409, 'Distribuição ocupada. Tente novamente.'),
      51401: (403, 'Acesso restrito à administração.'),
      51402: (409, 'A base publicada mudou. Atualize a listagem.'),
      51403: (404, 'Tipo de Processo inexistente nesta versão.'),
      51404: (
        409,
        'Os vínculos foram alterados. Atualize a listagem antes de editar.'
      ),
      51405: (400, 'Órgão inexistente.'),
    };
    final mensagem = mensagens[erro.code];
    if (mensagem == null) return erro;
    return ApiError(mensagem.$1, mensagem.$2);
  }

  Future<Map<String, dynamic>> vincularDistribuicaoEmLote(
    int idAdministrador,
    Map<String, dynamic> dados,
  ) async {
    await verificarAdministrador(idAdministrador);
    final versao = dados['versao'];
    if (!Validacoes.inteiroSqlValido(versao) || (versao as int) < 0) {
      throw ApiError(400, 'Versão inválida.');
    }
    final tipos = validarIdsDistribuicao(dados['tipos'], 'Tipos de Processo');
    final orgaos = validarIdsDistribuicao(dados['orgaos'], 'órgãos');
    if (tipos.isEmpty || orgaos.isEmpty) {
      throw ApiError(400, 'Selecione ao menos um Tipo de Processo e um órgão.');
    }
    const sql = '''
      SET NOCOUNT ON; SET XACT_ABORT ON;
      BEGIN TRY
        BEGIN TRANSACTION;
        DECLARE @administrador int=?, @versao int=?,
          @tiposJson nvarchar(max)=?, @orgaosJson nvarchar(max)=?, @lock int;
        EXEC @lock=sys.sp_getapplock @Resource='carga_atribuicoes',
          @LockMode='Exclusive', @LockOwner='Transaction', @LockTimeout=15000;
        IF @lock<0 THROW 51400,'Distribuicao ocupada.',1;
        IF NOT EXISTS(SELECT 1 FROM dbo.usuario WITH(HOLDLOCK)
          WHERE id_usuario=@administrador AND sin_ativo='S' AND sin_admin='S')
          THROW 51401,'Administrador nao autorizado.',1;
        IF @versao<>(SELECT MAX(versao) FROM dbo.versao_base WITH(HOLDLOCK))
          THROW 51402,'A base publicada mudou.',1;
        DECLARE @tipos TABLE(id_tipo_procedimento int PRIMARY KEY);
        DECLARE @orgaos TABLE(id_orgao int PRIMARY KEY);
        DECLARE @novos TABLE(id_tipo_procedimento int,id_orgao int);
        INSERT @tipos SELECT CONVERT(int,value) FROM OPENJSON(@tiposJson);
        INSERT @orgaos SELECT CONVERT(int,value) FROM OPENJSON(@orgaosJson);
        IF EXISTS(SELECT 1 FROM @tipos t WHERE NOT EXISTS(
          SELECT 1 FROM dbo.tipo_procedimento WITH(HOLDLOCK)
          WHERE versao=@versao AND id_tipo_procedimento=t.id_tipo_procedimento))
          THROW 51403,'Tipo inexistente nesta versao.',1;
        IF EXISTS(SELECT 1 FROM @orgaos o WHERE NOT EXISTS(
          SELECT 1 FROM dbo.orgao WITH(HOLDLOCK) WHERE id_orgao=o.id_orgao))
          THROW 51405,'Orgao inexistente.',1;
        -- Somente acrescenta os pares ausentes; preserva vínculos atuais.
        INSERT dbo.tipo_procedimento_restricao(id_tipo_procedimento,id_orgao)
          OUTPUT inserted.id_tipo_procedimento,inserted.id_orgao INTO @novos
          SELECT t.id_tipo_procedimento,o.id_orgao FROM @tipos t CROSS JOIN @orgaos o
          WHERE NOT EXISTS(SELECT 1 FROM dbo.tipo_procedimento_restricao r WITH(UPDLOCK,HOLDLOCK)
            WHERE r.id_tipo_procedimento=t.id_tipo_procedimento AND r.id_orgao=o.id_orgao);
        DECLARE @detalhe nvarchar(max)=(
          SELECT @versao AS versao,JSON_QUERY(@tiposJson) AS tipos,
            JSON_QUERY(@orgaosJson) AS orgaos,
            JSON_QUERY((SELECT id_tipo_procedimento,id_orgao FROM @novos
              ORDER BY id_tipo_procedimento,id_orgao FOR JSON PATH)) AS vinculos_incluidos
          FOR JSON PATH,WITHOUT_ARRAY_WRAPPER);
        INSERT dbo.auditoria(id_usuario,evento,detalhe)
          VALUES(@administrador,'DISTRIBUICAO_TIPOS',@detalhe);
        COMMIT;
        SELECT COUNT(*) AS vinculos_incluidos,
          COUNT(DISTINCT id_tipo_procedimento) AS tipos_alterados FROM @novos;
      END TRY
      BEGIN CATCH
        IF XACT_STATE()<>0 ROLLBACK;
        THROW;
      END CATCH;
    ''';
    try {
      final resultado = await banco.query(sql,
          params: [
            idAdministrador,
            versao,
            jsonEncode(tipos),
            jsonEncode(orgaos),
          ],
          operation: 'vincular_distribuicao_lote');
      return resultado.single;
    } on DatabaseFailure catch (erro) {
      throw traduzirErroDistribuicao(erro);
    }
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
