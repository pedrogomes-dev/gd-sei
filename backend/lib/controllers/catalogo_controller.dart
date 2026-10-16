import '../models/api_error.dart';
import '../repositories/database_repository.dart';
import '../utils/validacoes.dart';

class CatalogoController {
  final DatabaseRepository banco;

  CatalogoController(this.banco);

  Future<Map<String, dynamic>> consultar(
    String categoria,
    String pesquisa,
    int inicio,
    int? versaoSolicitada,
    String situacao,
  ) async {
    const sqlVersao = 'SELECT MAX(versao) AS versao FROM dbo.versao_base';
    final versoes = await banco.query(sqlVersao);
    if (versoes.first['versao'] == null) {
      throw ApiError(404, 'Nenhuma base publicada.');
    }

    final ultimaVersao = int.parse(versoes.first['versao'].toString());
    final versao = versaoSolicitada ?? ultimaVersao;
    if (versaoSolicitada != null) {
      const sql = 'SELECT versao FROM dbo.versao_base WHERE versao = ?';
      final publicacoes = await banco.query(sql, params: [versao]);
      if (publicacoes.isEmpty) throw ApiError(404, 'Versão inexistente.');
    }

    // Nomes SQL definidos aqui; não são fornecidos pelo usuário.
    String tabela = 'tipo_procedimento';
    String chave = 'id_tipo_procedimento';
    List<String> campos = ['nome', 'descricao'];
    if (categoria == 'assuntos') {
      tabela = 'assunto';
      chave = 'id_assunto';
      campos = ['codigo_estruturado', 'descricao', 'observacao', 'idx_assunto'];
    }

    var texto = pesquisa.replaceAll('~', '~~');
    texto = texto.replaceAll('%', '~%');
    texto = texto.replaceAll('_', '~_');
    texto = texto.replaceAll('[', '~[');

    final parametros = <Object>[versao];
    final condicoes = <String>[];
    for (final campo in campos) {
      condicoes.add("registro.$campo LIKE ? ESCAPE '~'");
      parametros.add('%$texto%');
    }

    final id = int.tryParse(pesquisa);
    if (Validacoes.inteiroSqlValido(id)) {
      condicoes.add('registro.$chave = ?');
      parametros.add(id!);
    }

    final pesquisaSql = condicoes.join(' OR ');
    var filtro = 'registro.versao = ? AND ($pesquisaSql)';
    // Totais da busca e versão, antes do filtro de estado e da paginação.
    final totais = await banco.query('''
      SELECT COUNT_BIG(*) AS todos,
        COUNT_BIG(CASE WHEN registro.sin_ativo = 'S' THEN 1 END) AS ativos,
        COUNT_BIG(CASE WHEN registro.sin_ativo = 'N' THEN 1 END) AS inativos
      FROM dbo.$tabela registro
      WHERE $filtro
    ''', params: [...parametros], operation: 'contar_estados_catalogo');

    if (situacao != 'TODOS') {
      filtro += ' AND registro.sin_ativo = ?';
      parametros.add(situacao);
    }

    final sqlQuantidade = '''
      SELECT COUNT_BIG(*) AS total
      FROM dbo.$tabela registro
      WHERE $filtro
    ''';
    final quantidade = await banco.query(
      sqlQuantidade, params: parametros, operation: 'contar_catalogo',
    );

    var camposHipotese = '';
    var vinculoHipotese = '';
    if (categoria != 'assuntos') {
      camposHipotese = '''
        , hipotese.nome AS hipotese_legal_nome
        , hipotese.base_legal AS hipotese_legal_base
        , hipotese.descricao AS hipotese_legal_descricao
        , hipotese.sin_ativo AS hipotese_legal_ativa
      ''';
      vinculoHipotese = '''
        LEFT JOIN dbo.hipotese_legal hipotese
          ON hipotese.id_hipotese_legal = registro.id_hipotese_legal_sugestao
      ''';
    }

    // Nos Assuntos, a ordem é pré-ordem da árvore, independente da paginação.
    // O vínculo pai/filho é sempre restrito à mesma versão publicada.
    final sqlRegistros = categoria == 'assuntos' ? '''
      WITH arvore AS (
        SELECT raiz.versao, raiz.id_assunto, 0 AS nivel_hierarquia,
          CAST(raiz.codigo_estruturado AS nvarchar(max)) AS caminho
        FROM dbo.assunto raiz
        WHERE raiz.versao = ?
          AND (raiz.id_assunto_pai IS NULL OR NOT EXISTS (
            SELECT 1 FROM dbo.assunto pai
            WHERE pai.versao = raiz.versao AND pai.id_assunto = raiz.id_assunto_pai
          ))
        UNION ALL
        SELECT filho.versao, filho.id_assunto, arvore.nivel_hierarquia + 1,
          CAST(arvore.caminho + N'/' + filho.codigo_estruturado AS nvarchar(max))
        FROM dbo.assunto filho
        JOIN arvore ON filho.versao = arvore.versao
          AND filho.id_assunto_pai = arvore.id_assunto
      )
      SELECT registro.*, arvore.nivel_hierarquia
      FROM dbo.assunto registro
      JOIN arvore ON arvore.versao = registro.versao
        AND arvore.id_assunto = registro.id_assunto
      WHERE $filtro
      ORDER BY arvore.caminho, registro.id_assunto
      OFFSET ? ROWS FETCH NEXT 51 ROWS ONLY
      OPTION (MAXRECURSION 100)
    ''' : '''
      SELECT registro.* $camposHipotese
      FROM dbo.$tabela registro
      $vinculoHipotese
      WHERE $filtro
      ORDER BY registro.$chave
      OFFSET ? ROWS FETCH NEXT 51 ROWS ONLY
    ''';
    final registros = await banco.query(
      sqlRegistros,
      params: [if (categoria == 'assuntos') versao, ...parametros, inicio],
      operation: 'consultar_catalogo',
    );

    // A base possui poucos vínculos; carregá-los de uma vez mantém a expansão
    // totalmente local no frontend e evita uma API específica por clique.
    final vinculos = await banco.query('''
      SELECT
        rel.id_tipo_procedimento,
        tipo.nome AS tipo_nome,
        tipo.sin_ativo AS tipo_sin_ativo,
        rel.id_assunto_proxy AS id_assunto,
        assunto.codigo_estruturado AS assunto_codigo,
        assunto.descricao AS assunto_descricao,
        assunto.sin_ativo AS assunto_sin_ativo
      FROM dbo.rel_tipo_procedimento_assunto rel
      JOIN dbo.tipo_procedimento tipo
        ON tipo.versao = rel.versao
       AND tipo.id_tipo_procedimento = rel.id_tipo_procedimento
      JOIN dbo.assunto assunto
        ON assunto.versao = rel.versao
       AND assunto.id_assunto = rel.id_assunto_proxy
      WHERE rel.versao = ?
      ORDER BY rel.id_tipo_procedimento, rel.sequencia
    ''', params: [versao], operation: 'consultar_vinculos_catalogo');

    return {
      'vinculos': vinculos,
      'itens': registros.take(50).toList(),
      'mais': registros.length > 50,
      'versao': versao,
      'quantidades': totais.first,
      'total': int.parse(quantidade.first['total'].toString()),
    };
  }
}

