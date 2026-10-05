import 'database_repository.dart';
import '../models/api_error.dart';

class ConsultaRepository {
  final DatabaseRepository db;
  ConsultaRepository(this.db);
  Future<List<Map<String, dynamic>>> list(int userId) => db.query(
    "SELECT a.id_atribuicao,a.id_consulta,a.id_orgao,a.id_tipo_procedimento,a.versao,"
    "t.nome,o.sigla,c.nome AS consulta,co.status,"
    "CASE WHEN v.id_atribuicao IS NULL THEN 'N' ELSE 'S' END AS visualizado "
    'FROM dbo.consulta_orgao_tipo a '
    'JOIN dbo.usuario_orgao u ON u.id_orgao=a.id_orgao AND u.id_usuario=? '
    'JOIN dbo.orgao o ON o.id_orgao=a.id_orgao '
    'JOIN dbo.consulta c ON c.id_consulta=a.id_consulta '
    'JOIN dbo.consulta_orgao co ON co.id_consulta=a.id_consulta AND co.id_orgao=a.id_orgao '
    'JOIN dbo.tipo_procedimento t ON t.versao=a.versao AND t.id_tipo_procedimento=a.id_tipo_procedimento '
    'LEFT JOIN dbo.visualizacao_tipo v ON v.id_atribuicao=a.id_atribuicao '
    'ORDER BY c.nome,o.sigla,t.nome', params:[userId]);

  Future<Map<String,dynamic>> detail(int userId, int id) async {
    final rows = await db.query('SELECT t.*,a.id_atribuicao,a.id_consulta,a.id_orgao,co.status '
      'FROM dbo.consulta_orgao_tipo a '
      'JOIN dbo.usuario_orgao u ON u.id_orgao=a.id_orgao AND u.id_usuario=? '
      'JOIN dbo.tipo_procedimento t ON t.versao=a.versao AND t.id_tipo_procedimento=a.id_tipo_procedimento '
      'JOIN dbo.consulta_orgao co ON co.id_consulta=a.id_consulta AND co.id_orgao=a.id_orgao '
      'WHERE a.id_atribuicao=?',params:[userId,id]);
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
