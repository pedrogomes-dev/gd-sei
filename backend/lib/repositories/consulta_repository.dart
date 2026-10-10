import 'database_repository.dart';
import '../models/api_error.dart';

class ConsultaRepository {
  final DatabaseRepository db;
  ConsultaRepository(this.db);
  Future<List<Map<String, dynamic>>> list(int userId) {
    const sql = '''
      SELECT atribuicao.id_atribuicao, atribuicao.id_consulta, atribuicao.id_orgao,
        atribuicao.id_tipo_procedimento, atribuicao.versao, tipo.nome, orgao.sigla,
        consulta.nome AS consulta, grupo.status, manifestacao.decisao_tipo,
        CASE WHEN visualizacao.id_atribuicao IS NULL THEN 'N' ELSE 'S' END AS visualizado,
        CASE
          WHEN manifestacao.decisao_tipo = 'DESCONTINUAR' THEN 0
          ELSE (
            SELECT COUNT(*)
            FROM dbo.rel_tipo_procedimento_assunto vinculo
            WHERE vinculo.versao = atribuicao.versao
              AND vinculo.id_tipo_procedimento = atribuicao.id_tipo_procedimento
              AND NOT EXISTS (
                SELECT 1 FROM dbo.manifestacao_vinculo decisao
                WHERE decisao.id_atribuicao = atribuicao.id_atribuicao
                  AND decisao.id_assunto = vinculo.id_assunto_proxy
                  AND decisao.acao IN ('MANTER','REMOVER')
              )
          ) + CASE WHEN manifestacao.decisao_tipo IS NULL THEN 1 ELSE 0 END
        END AS pendentes
      FROM dbo.consulta_orgao_tipo atribuicao
      JOIN dbo.usuario_orgao usuario ON usuario.id_orgao = atribuicao.id_orgao AND usuario.id_usuario = ?
      JOIN dbo.orgao orgao ON orgao.id_orgao = atribuicao.id_orgao
      JOIN dbo.consulta consulta ON consulta.id_consulta = atribuicao.id_consulta
      JOIN dbo.consulta_orgao grupo ON grupo.id_consulta = atribuicao.id_consulta AND grupo.id_orgao = atribuicao.id_orgao
      JOIN dbo.tipo_procedimento tipo ON tipo.versao = atribuicao.versao AND tipo.id_tipo_procedimento = atribuicao.id_tipo_procedimento
      LEFT JOIN dbo.visualizacao_tipo visualizacao ON visualizacao.id_atribuicao = atribuicao.id_atribuicao
      LEFT JOIN dbo.manifestacao_tipo manifestacao ON manifestacao.id_atribuicao = atribuicao.id_atribuicao
      ORDER BY consulta.nome, orgao.sigla, tipo.nome
    ''';
    return db.query(sql, params: [userId]);
  }

  Future<Map<String,dynamic>> detail(int userId, int id) async {
    const sqlTipo = '''
      SELECT tipo.*, atribuicao.id_atribuicao, atribuicao.id_consulta,
        atribuicao.id_orgao, grupo.status,
        hipotese.nome AS hipotese_legal_nome,
        hipotese.base_legal AS hipotese_legal_base,
        hipotese.descricao AS hipotese_legal_descricao,
        hipotese.sin_ativo AS hipotese_legal_ativa,
        CASE WHEN visualizacao.id_atribuicao IS NULL THEN 'N' ELSE 'S' END AS visualizado
      FROM dbo.consulta_orgao_tipo atribuicao
      JOIN dbo.usuario_orgao usuario
        ON usuario.id_orgao = atribuicao.id_orgao AND usuario.id_usuario = ?
      JOIN dbo.tipo_procedimento tipo
        ON tipo.versao = atribuicao.versao
        AND tipo.id_tipo_procedimento = atribuicao.id_tipo_procedimento
      JOIN dbo.consulta_orgao grupo
        ON grupo.id_consulta = atribuicao.id_consulta
        AND grupo.id_orgao = atribuicao.id_orgao
      LEFT JOIN dbo.visualizacao_tipo visualizacao
        ON visualizacao.id_atribuicao = atribuicao.id_atribuicao
      LEFT JOIN dbo.hipotese_legal hipotese
        ON hipotese.id_hipotese_legal = tipo.id_hipotese_legal_sugestao
      WHERE atribuicao.id_atribuicao = ?
    ''';
    final rows = await db.query(sqlTipo, params: [userId, id]);
    if (rows.isEmpty) throw ApiError(404,'Tipo não encontrado para seus órgãos');
    final row=rows.first;
    final subjects=await db.query('SELECT s.*,r.sequencia FROM dbo.rel_tipo_procedimento_assunto r '
      'JOIN dbo.assunto s ON s.versao=r.versao AND s.id_assunto=r.id_assunto_proxy '
      'WHERE r.versao=? AND r.id_tipo_procedimento=? ORDER BY r.sequencia',
      params:[int.parse(row['versao'].toString()),int.parse(row['id_tipo_procedimento'].toString())]);
    return {'tipo':row,'assuntos':subjects};
  }

  Future<void> viewed(int userId,int id) async {
    // Autoriza dentro da transação; preserva primeiro usuário e primeira data.
    await db.query('SET XACT_ABORT ON; BEGIN TRY BEGIN TRANSACTION; '
      'IF NOT EXISTS(SELECT 1 FROM dbo.consulta_orgao_tipo a '
      'JOIN dbo.usuario_orgao u WITH(HOLDLOCK) ON u.id_orgao=a.id_orgao '
      'WHERE a.id_atribuicao=? AND u.id_usuario=?) '
      "THROW 51021,'Tipo nao autorizado',1; "
      'IF NOT EXISTS(SELECT 1 FROM dbo.visualizacao_tipo WITH(UPDLOCK,HOLDLOCK) WHERE id_atribuicao=?) '
      'INSERT dbo.visualizacao_tipo(id_atribuicao,id_usuario) VALUES(?,?); '
      'COMMIT; END TRY BEGIN CATCH IF XACT_STATE()<>0 ROLLBACK; THROW; END CATCH;',
      params:[id,userId,id,id,userId]);
  }
}
