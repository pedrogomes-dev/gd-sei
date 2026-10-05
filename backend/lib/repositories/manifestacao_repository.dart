import 'dart:convert';
import '../models/api_error.dart';
import '../models/database_failure.dart';
import 'database_repository.dart';
import 'consulta_repository.dart';

class ManifestacaoRepository {
  final DatabaseRepository db;
  final ConsultaRepository consultas;
  ManifestacaoRepository(this.db,this.consultas);
  int number(dynamic value)=>int.parse(value.toString());

  Future<Map<String,dynamic>> detail(int user,int id) async {
    final data=await consultas.detail(user,id);
    final manifest=await db.query('SELECT observacao,revisao FROM dbo.manifestacao_tipo WHERE id_atribuicao=?',params:[id]);
    final decisions=await db.query('SELECT m.id_assunto,m.acao,m.justificativa,s.codigo_estruturado,s.descricao '
      'FROM dbo.manifestacao_vinculo m JOIN dbo.assunto s ON s.versao=m.versao AND s.id_assunto=m.id_assunto '
      'WHERE m.id_atribuicao=? ORDER BY s.codigo_estruturado',params:[id]);
    return {...data,'manifestacao':manifest.isEmpty?{'observacao':'','revisao':0}:manifest.first,'decisoes':decisions};
  }

  Future<Map<String,dynamic>> search(int user,int id,String text,int offset) async {
    final data=await consultas.detail(user,id);
    final tipo=data['tipo'] as Map<String,dynamic>;
    final escaped=text.replaceAll('~','~~').replaceAll('%','~%').replaceAll('_','~_').replaceAll('[','~[');
    final pattern='%$escaped%';
    final parsedId=int.tryParse(text);
    final subjectId=parsedId!=null && parsedId>=-2147483648 && parsedId<=2147483647?parsedId:null;
    final idFilter=subjectId==null?'':' OR s.id_assunto=?';
    final rows=await db.query("SELECT s.* FROM dbo.assunto s WHERE s.versao=? AND s.sin_ativo='S' "
      "AND (s.codigo_estruturado LIKE ? ESCAPE '~' OR s.descricao LIKE ? ESCAPE '~' "
      "OR s.observacao LIKE ? ESCAPE '~' OR s.idx_assunto LIKE ? ESCAPE '~'$idFilter) "
      'AND NOT EXISTS(SELECT 1 FROM dbo.rel_tipo_procedimento_assunto r '
      'WHERE r.versao=s.versao AND r.id_tipo_procedimento=? AND r.id_assunto_proxy=s.id_assunto) '
      'ORDER BY s.codigo_estruturado,s.id_assunto OFFSET ? ROWS FETCH NEXT 51 ROWS ONLY',
      params:[number(tipo['versao']),pattern,pattern,pattern,pattern,if(subjectId!=null)subjectId,number(tipo['id_tipo_procedimento']),offset],operation:'pesquisar_assuntos');
    return {'itens':rows.take(50).toList(),'mais':rows.length>50,'offset':offset};
  }

  ApiError business(DatabaseFailure error) {
    final message=switch(error.code) {
      51030=>'Consulta, órgão ou Tipo não autorizado.',
      51031=>'A manifestação já foi finalizada e não permite alterações.',
      51032=>'Outro usuário alterou os dados. Recarregue antes de salvar ou finalizar.',
      51033=>'Lista de vínculos inválida ou duplicada.',
      51034=>'A decisão não corresponde ao vínculo original.',
      51035=>'Assunto inexistente ou inativo para inclusão.',
      51036=>'Informe justificativa para remover ou adicionar.',
      51037=>'Visualize todos os Tipos antes de finalizar.',
      51038=>'Marque manter ou remover em todos os vínculos existentes.',
      51039=>'O órgão não tem Tipos atribuídos nesta consulta.',
      51040=>'Observação ou justificativa excede o limite de caracteres.',
      _=>null,
    };
    if(message==null)throw error;
    return ApiError(error.code==51030?403:[51031,51032].contains(error.code)?409:400,message);
  }

  Future<Map<String,dynamic>> save(int user,int id,Map<String,dynamic> body) async {
    final revision=body['revisao'];
    final observation=body['observacao'];
    final items=body['vinculos'];
    if(revision is! int || revision<0 || revision>2147483647 || observation is! String || observation.length>5000 || items is! List || items.length>2000) {
      throw ApiError(400,'Preenchimento inválido. Observação: até 5000 caracteres.');
    }
    final normalized=<Map<String,dynamic>>[];
    final seen=<int>{};
    for(final item in items) {
      if(item is! Map<String,dynamic>)throw ApiError(400,'Vínculo inválido');
      final subject=item['id_assunto'];final action=item['acao'];final reason=item['justificativa'];
      if(subject is! int || subject < -2147483648 || subject > 2147483647 || !seen.add(subject) || !['MANTER','REMOVER','ADICIONAR'].contains(action) || reason is! String || reason.length>2000) {
        throw ApiError(400,'Vínculo inválido ou duplicado. Justificativa: até 2000 caracteres.');
      }
      if(action!='MANTER' && reason.trim().isEmpty)throw ApiError(400,'Justificativa obrigatória para remover e adicionar.');
      normalized.add({'id_assunto':subject,'acao':action,'justificativa':reason.trim()});
    }
    try {
      final rows=await db.query('EXEC dbo.sp_salvar_manifestacao ?,?,?,?,?',
        params:[user,id,revision,observation,jsonEncode(normalized)],operation:'salvar_manifestacao');
      return {'revisao':number(rows.first['revisao'])};
    } on DatabaseFailure catch(error){throw business(error);}
  }

  Future<Map<String,dynamic>> summary(int user,int consulta,int orgao) async {
    final header=await db.query('SELECT co.*,c.nome AS consulta,o.sigla FROM dbo.consulta_orgao co '
      'JOIN dbo.consulta c ON c.id_consulta=co.id_consulta JOIN dbo.orgao o ON o.id_orgao=co.id_orgao '
      'JOIN dbo.usuario_orgao u ON u.id_orgao=co.id_orgao AND u.id_usuario=? '
      'WHERE co.id_consulta=? AND co.id_orgao=?',params:[user,consulta,orgao]);
    if(header.isEmpty)throw ApiError(404,'Consulta não encontrada para este órgão');
    final types=await db.query('SELECT a.id_atribuicao,t.nome,m.observacao, '
      "CASE WHEN v.id_atribuicao IS NULL THEN 'N' ELSE 'S' END AS visualizado, "
      '(SELECT COUNT(*) FROM dbo.rel_tipo_procedimento_assunto r WHERE r.versao=a.versao '
      'AND r.id_tipo_procedimento=a.id_tipo_procedimento AND NOT EXISTS(SELECT 1 FROM dbo.manifestacao_vinculo mv '
      "WHERE mv.id_atribuicao=a.id_atribuicao AND mv.id_assunto=r.id_assunto_proxy AND mv.acao IN('MANTER','REMOVER'))) AS pendentes "
      'FROM dbo.consulta_orgao_tipo a JOIN dbo.tipo_procedimento t ON t.versao=a.versao AND t.id_tipo_procedimento=a.id_tipo_procedimento '
      'LEFT JOIN dbo.manifestacao_tipo m ON m.id_atribuicao=a.id_atribuicao LEFT JOIN dbo.visualizacao_tipo v ON v.id_atribuicao=a.id_atribuicao '
      'WHERE a.id_consulta=? AND a.id_orgao=? ORDER BY t.nome',params:[consulta,orgao]);
    final decisions=await db.query('SELECT a.id_atribuicao,s.id_assunto,s.codigo_estruturado,s.descricao,m.acao,m.justificativa '
      'FROM dbo.consulta_orgao_tipo a JOIN dbo.manifestacao_vinculo m ON m.id_atribuicao=a.id_atribuicao '
      'JOIN dbo.assunto s ON s.versao=m.versao AND s.id_assunto=m.id_assunto '
      'WHERE a.id_consulta=? AND a.id_orgao=? ORDER BY a.id_atribuicao,s.codigo_estruturado',params:[consulta,orgao]);
    return {'consulta_orgao':header.first,'tipos':types,'decisoes':decisions,
      'pode_finalizar':header.first['status']=='RASCUNHO' && types.isNotEmpty && types.every((t)=>t['visualizado']=='S' && number(t['pendentes'])==0)};
  }

  Future<void> finish(int user,int consulta,int orgao,Map<String,dynamic> body) async {
    final revision=body['revisao'];
    if(revision is! int || revision<0 || revision>2147483647)throw ApiError(400,'Revisão inválida');
    try {
      await db.query('EXEC dbo.sp_finalizar_manifestacao_orgao ?,?,?,?',params:[user,consulta,orgao,revision],operation:'finalizar_orgao');
    } on DatabaseFailure catch(error){throw business(error);}
  }
}
