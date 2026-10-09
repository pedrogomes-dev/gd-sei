import 'dart:convert';

import '../models/api_error.dart';
import '../models/database_failure.dart';
import '../repositories/database_repository.dart';
import '../repositories/consulta_repository.dart';
import '../utils/validacoes.dart';

class ManifestacaoController {
  final DatabaseRepository banco;
  final ConsultaRepository consultas;

  ManifestacaoController(this.banco, this.consultas);

  Future<Map<String, dynamic>> consultar(int idUsuario, int idAtribuicao) async {
    final dados = await consultas.detail(idUsuario, idAtribuicao);

    const sqlManifestacao = '''
      SELECT observacao, revisao
      FROM dbo.manifestacao_tipo
      WHERE id_atribuicao = ?
    ''';
    final manifestacoes = await banco.query(
      sqlManifestacao,
      params: [idAtribuicao],
    );

    const sqlDecisoes = '''
      SELECT assunto.*, manifestacao.acao, manifestacao.justificativa
      FROM dbo.manifestacao_vinculo manifestacao
      JOIN dbo.assunto assunto
        ON assunto.versao = manifestacao.versao
        AND assunto.id_assunto = manifestacao.id_assunto
      WHERE manifestacao.id_atribuicao = ?
      ORDER BY assunto.codigo_estruturado
    ''';
    final decisoes = await banco.query(sqlDecisoes, params: [idAtribuicao]);

    Map<String, dynamic> manifestacao = {'observacao': '', 'revisao': 0};
    if (manifestacoes.isNotEmpty) manifestacao = manifestacoes.first;

    return {...dados, 'manifestacao': manifestacao, 'decisoes': decisoes};
  }

  Future<Map<String, dynamic>> pesquisarAssuntos(
    int idUsuario,
    int idAtribuicao,
    String pesquisa,
    int inicio,
  ) async {
    final dados = await consultas.detail(idUsuario, idAtribuicao);
    final tipoProcesso = dados['tipo'] as Map<String, dynamic>;
    final versao = int.parse(tipoProcesso['versao'].toString());
    final idTipoProcesso = int.parse(tipoProcesso['id_tipo_procedimento'].toString());
    final texto = prepararPesquisa(pesquisa);

    final parametros = <Object>[versao, texto, texto, texto, texto];
    var filtroId = '';
    final idAssunto = int.tryParse(pesquisa);

    if (Validacoes.inteiroSqlValido(idAssunto)) {
      filtroId = ' OR assunto.id_assunto = ?';
      parametros.add(idAssunto!);
    }

    parametros.add(idTipoProcesso);
    parametros.add(inicio);

    final sql = '''
      SELECT assunto.*
      FROM dbo.assunto assunto
      WHERE assunto.versao = ?
        AND assunto.sin_ativo = 'S'
        AND (
          assunto.codigo_estruturado LIKE ? ESCAPE '~'
          OR assunto.descricao LIKE ? ESCAPE '~'
          OR assunto.observacao LIKE ? ESCAPE '~'
          OR assunto.idx_assunto LIKE ? ESCAPE '~'
          $filtroId
        )
        AND NOT EXISTS (
          SELECT 1
          FROM dbo.rel_tipo_procedimento_assunto vinculo
          WHERE vinculo.versao = assunto.versao
            AND vinculo.id_tipo_procedimento = ?
            AND vinculo.id_assunto_proxy = assunto.id_assunto
        )
      ORDER BY assunto.codigo_estruturado, assunto.id_assunto
      OFFSET ? ROWS FETCH NEXT 51 ROWS ONLY
    ''';

    final assuntos = await banco.query(
      sql,
      params: parametros,
      operation: 'pesquisar_assuntos',
    );

    return {
      'itens': assuntos.take(50).toList(),
      'mais': assuntos.length > 50,
      'offset': inicio,
    };
  }

  String prepararPesquisa(String pesquisa) {
    var texto = pesquisa.replaceAll('~', '~~');
    texto = texto.replaceAll('%', '~%');
    texto = texto.replaceAll('_', '~_');
    texto = texto.replaceAll('[', '~[');
    return '%$texto%';
  }

  void validarRevisao(dynamic revisao) {
    if (!Validacoes.inteiroSqlValido(revisao) || (revisao as int) < 0) {
      throw ApiError(400, 'Revisão inválida.');
    }
  }

  List<Map<String, dynamic>> validarVinculos(dynamic vinculos) {
    if (vinculos is! List || vinculos.length > 2000) {
      throw ApiError(400, 'Lista de vínculos inválida.');
    }

    final assuntosVerificados = <int>{};
    final vinculosValidados = <Map<String, dynamic>>[];

    for (final vinculo in vinculos) {
      if (vinculo is! Map<String, dynamic>) {
        throw ApiError(400, 'Vínculo inválido.');
      }

      final idAssunto = vinculo['id_assunto'];
      if (!Validacoes.inteiroSqlValido(idAssunto)) {
        throw ApiError(400, 'Identificador de Assunto inválido.');
      }
      if (!assuntosVerificados.add(idAssunto as int)) {
        throw ApiError(400, 'A lista contém Assuntos duplicados.');
      }

      final acao = vinculo['acao'];
      if (!['MANTER', 'REMOVER', 'ADICIONAR'].contains(acao)) {
        throw ApiError(400, 'Decisão de vínculo inválida.');
      }

      final justificativa = vinculo['justificativa'];
      if (justificativa is! String || justificativa.length > 2000) {
        throw ApiError(400, 'Justificativa deve ter até 2000 caracteres.');
      }
      if (acao != 'MANTER' && justificativa.trim().isEmpty) {
        throw ApiError(400, 'Informe justificativa para remover ou adicionar.');
      }

      vinculosValidados.add({
        'id_assunto': idAssunto,
        'acao': acao,
        'justificativa': justificativa.trim(),
      });
    }

    return vinculosValidados;
  }

  Future<Map<String, dynamic>> salvar(
    int idUsuario,
    int idAtribuicao,
    Map<String, dynamic> dados,
  ) async {
    final revisao = dados['revisao'];
    validarRevisao(revisao);

    final observacao = dados['observacao'];
    if (observacao is! String || observacao.length > 5000) {
      throw ApiError(400, 'Observação deve ter até 5000 caracteres.');
    }

    final vinculos = validarVinculos(dados['vinculos']);
    const sql = 'EXEC dbo.sp_salvar_manifestacao ?, ?, ?, ?, ?';

    try {
      final resultado = await banco.query(
        sql,
        params: [idUsuario, idAtribuicao, revisao as int, observacao, jsonEncode(vinculos)],
        operation: 'salvar_manifestacao',
      );
      return {'revisao': int.parse(resultado.first['revisao'].toString())};
    } on DatabaseFailure catch (erro) {
      throw traduzirErro(erro);
    }
  }

  Future<Map<String, dynamic>> consultarResumo(
    int idUsuario,
    int idConsulta,
    int idOrgao,
  ) async {
    const sqlCabecalho = '''
      SELECT grupo.*, consulta.nome AS consulta, orgao.sigla,
        CASE WHEN EXISTS (
          SELECT 1 FROM dbo.usuario_orgao vinculo
          WHERE vinculo.id_usuario = usuario.id_usuario AND vinculo.id_orgao = grupo.id_orgao
        ) THEN 'S' ELSE 'N' END AS pode_revisar
      FROM dbo.consulta_orgao grupo
      JOIN dbo.consulta consulta ON consulta.id_consulta = grupo.id_consulta
      JOIN dbo.orgao orgao ON orgao.id_orgao = grupo.id_orgao
      JOIN dbo.usuario usuario ON usuario.id_usuario = ? AND usuario.sin_ativo = 'S'
      WHERE grupo.id_consulta = ? AND grupo.id_orgao = ?
        AND (
          usuario.sin_admin = 'S'
          OR EXISTS (
            SELECT 1 FROM dbo.usuario_orgao vinculo
            WHERE vinculo.id_usuario = usuario.id_usuario AND vinculo.id_orgao = grupo.id_orgao
          )
        )
    ''';
    final grupos = await banco.query(sqlCabecalho, params: [idUsuario, idConsulta, idOrgao]);
    if (grupos.isEmpty) {
      throw ApiError(404, 'Consulta não encontrada para este órgão.');
    }

    const sqlTiposProcesso = '''
      SELECT atribuicao.id_atribuicao, tipo.nome, manifestacao.observacao,
        CASE WHEN visualizacao.id_atribuicao IS NULL THEN 'N' ELSE 'S' END AS visualizado,
        (
          SELECT COUNT(*)
          FROM dbo.rel_tipo_procedimento_assunto vinculo
          WHERE vinculo.versao = atribuicao.versao
            AND vinculo.id_tipo_procedimento = atribuicao.id_tipo_procedimento
            AND NOT EXISTS (
              SELECT 1
              FROM dbo.manifestacao_vinculo decisao
              WHERE decisao.id_atribuicao = atribuicao.id_atribuicao
                AND decisao.id_assunto = vinculo.id_assunto_proxy
                AND decisao.acao IN ('MANTER', 'REMOVER')
            )
        ) AS pendentes
      FROM dbo.consulta_orgao_tipo atribuicao
      JOIN dbo.tipo_procedimento tipo
        ON tipo.versao = atribuicao.versao
        AND tipo.id_tipo_procedimento = atribuicao.id_tipo_procedimento
      LEFT JOIN dbo.manifestacao_tipo manifestacao
        ON manifestacao.id_atribuicao = atribuicao.id_atribuicao
      LEFT JOIN dbo.visualizacao_tipo visualizacao
        ON visualizacao.id_atribuicao = atribuicao.id_atribuicao
      WHERE atribuicao.id_consulta = ? AND atribuicao.id_orgao = ?
      ORDER BY tipo.nome
    ''';
    final tiposProcesso = await banco.query(sqlTiposProcesso, params: [idConsulta, idOrgao]);

    const sqlDecisoes = '''
      SELECT atribuicao.id_atribuicao, assunto.*, decisao.acao, decisao.justificativa
      FROM dbo.consulta_orgao_tipo atribuicao
      JOIN dbo.manifestacao_vinculo decisao
        ON decisao.id_atribuicao = atribuicao.id_atribuicao
      JOIN dbo.assunto assunto
        ON assunto.versao = decisao.versao
        AND assunto.id_assunto = decisao.id_assunto
      WHERE atribuicao.id_consulta = ? AND atribuicao.id_orgao = ?
      ORDER BY atribuicao.id_atribuicao, assunto.codigo_estruturado
    ''';
    final decisoes = await banco.query(sqlDecisoes, params: [idConsulta, idOrgao]);
    final cabecalho = grupos.first;

    return {
      'consulta_orgao': cabecalho,
      'tipos': tiposProcesso,
      'decisoes': decisoes,
      'pode_revisar': cabecalho['pode_revisar'] == 'S',
      'pode_finalizar': cabecalho['pode_revisar'] == 'S' && podeFinalizar(cabecalho, tiposProcesso),
    };
  }

  bool podeFinalizar(Map<String, dynamic> cabecalho, List<Map<String, dynamic>> tipos) {
    if (cabecalho['status'] != 'RASCUNHO' || tipos.isEmpty) return false;

    for (final tipo in tipos) {
      if (tipo['visualizado'] != 'S') return false;
      if (int.parse(tipo['pendentes'].toString()) != 0) return false;
    }
    return true;
  }

  Future<void> finalizar(
    int idUsuario,
    int idConsulta,
    int idOrgao,
    Map<String, dynamic> dados,
  ) async {
    final revisao = dados['revisao'];
    validarRevisao(revisao);

    const sql = 'EXEC dbo.sp_finalizar_manifestacao_orgao ?, ?, ?, ?';
    try {
      await banco.query(
        sql,
        params: [idUsuario, idConsulta, idOrgao, revisao as int],
        operation: 'finalizar_orgao',
      );
    } on DatabaseFailure catch (erro) {
      throw traduzirErro(erro);
    }
  }

  Object traduzirErro(DatabaseFailure erro) {
    const mensagens = {
      51030: 'Consulta, órgão ou Tipo de Processo não autorizado.',
      51031: 'A manifestação já foi finalizada e não permite alterações.',
      51032: 'Outro usuário alterou os dados. Recarregue antes de salvar ou finalizar.',
      51033: 'Lista de vínculos inválida ou duplicada.',
      51034: 'A decisão não corresponde ao vínculo original.',
      51035: 'Assunto inexistente ou inativo para inclusão.',
      51036: 'Informe justificativa para remover ou adicionar.',
      51037: 'Visualize todos os Tipos de Processo antes de finalizar.',
      51038: 'Marque manter ou remover em todos os vínculos existentes.',
      51039: 'O órgão não tem Tipos de Processo atribuídos nesta consulta.',
      51040: 'Observação ou justificativa excede o limite de caracteres.',
    };

    final mensagem = mensagens[erro.code];
    if (mensagem == null) return erro;

    int status = 400;
    if (erro.code == 51030) status = 403;
    if (erro.code == 51031 || erro.code == 51032) status = 409;
    return ApiError(status, mensagem);
  }
}

