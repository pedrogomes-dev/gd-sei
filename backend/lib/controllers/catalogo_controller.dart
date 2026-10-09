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
      condicoes.add("$campo LIKE ? ESCAPE '~'");
      parametros.add('%$texto%');
    }

    final id = int.tryParse(pesquisa);
    if (Validacoes.inteiroSqlValido(id)) {
      condicoes.add('$chave = ?');
      parametros.add(id!);
    }

    final pesquisaSql = condicoes.join(' OR ');
    var filtro = 'versao = ? AND ($pesquisaSql)';
    if (situacao != 'TODOS') {
      filtro += ' AND sin_ativo = ?';
      parametros.add(situacao);
    }

    final sqlQuantidade = '''
      SELECT COUNT_BIG(*) AS total
      FROM dbo.$tabela
      WHERE $filtro
    ''';
    final quantidade = await banco.query(
      sqlQuantidade, params: parametros, operation: 'contar_catalogo',
    );

    final sqlRegistros = '''
      SELECT *
      FROM dbo.$tabela
      WHERE $filtro
      ORDER BY $chave
      OFFSET ? ROWS FETCH NEXT 51 ROWS ONLY
    ''';
    final registros = await banco.query(
      sqlRegistros, params: [...parametros, inicio], operation: 'consultar_catalogo',
    );

    return {
      'itens': registros.take(50).toList(),
      'mais': registros.length > 50,
      'versao': versao,
      'total': int.parse(quantidade.first['total'].toString()),
    };
  }
}
