import 'dart:convert';
import '../models/api_error.dart';
import '../models/database_failure.dart';
import 'database_repository.dart';

class AdminRepository {
  final DatabaseRepository db;
  AdminRepository(this.db);
  int number(dynamic value)=>int.parse(value.toString());
  Future<void> authorize(int user) async {
    final rows=await db.query("SELECT id_usuario FROM dbo.usuario WHERE id_usuario=? AND sin_ativo='S' AND sin_admin='S'",params:[user]);
    if(rows.isEmpty)throw ApiError(403,'Acesso restrito à administração.');
  }
  Future<List<Map<String,dynamic>>> organs(int user) async {
    await authorize(user);
    // Usa sigla, compatível com bases que possuem nome ou descricao.
    return db.query('SELECT id_orgao,sigla FROM dbo.orgao ORDER BY sigla');
  }
  Future<Map<String,dynamic>> list(int user,String text,String state,int? organ,int offset) async {
    await authorize(user);
    final escaped=text.replaceAll('~','~~').replaceAll('%','~%').replaceAll('_','~_').replaceAll('[','~[');
    final where="(u.nome LIKE ? ESCAPE '~' OR u.email LIKE ? ESCAPE '~')"
      "${state=='TODOS'?'':' AND u.sin_ativo=?'}"
      '${organ==null?'':' AND EXISTS(SELECT 1 FROM dbo.usuario_orgao f WHERE f.id_usuario=u.id_usuario AND f.id_orgao=?)'}';
    final params=<Object>['%$escaped%','%$escaped%',if(state!='TODOS')state,if(organ!=null)organ];
    final count=await db.query('SELECT COUNT_BIG(*) AS total FROM dbo.usuario u WHERE $where',params:params);
    final rows=await db.query('SELECT u.id_usuario,u.nome,u.email,u.sin_ativo,u.sin_admin,u.revisao,'
      '(SELECT o.id_orgao,o.sigla FROM dbo.usuario_orgao v JOIN dbo.orgao o ON o.id_orgao=v.id_orgao '
      'WHERE v.id_usuario=u.id_usuario ORDER BY o.sigla FOR JSON PATH) AS orgaos '
      'FROM dbo.usuario u WHERE $where ORDER BY u.nome,u.id_usuario OFFSET ? ROWS FETCH NEXT 51 ROWS ONLY',params:[...params,offset]);
    return {'itens':rows.take(50).map((r)=>{...r,'orgaos':jsonDecode((r['orgaos']??'[]').toString())}).toList(),
      'total':number(count.first['total']),'mais':rows.length>50};
  }
  Future<Map<String,dynamic>> detail(int user,int id) async {
    await authorize(user);
    final rows=await db.query('SELECT id_usuario,nome,email,sin_ativo,sin_admin,revisao FROM dbo.usuario WHERE id_usuario=?',params:[id]);
    if(rows.isEmpty)throw ApiError(404,'Usuário não encontrado.');
    final organs=await db.query('SELECT id_orgao FROM dbo.usuario_orgao WHERE id_usuario=? ORDER BY id_orgao',params:[id]);
    return {...rows.first,'orgaos':organs.map((r)=>number(r['id_orgao'])).toList()};
  }
  Future<Map<String,dynamic>> history(int user,int id,int offset) async {
    await authorize(user);
    if((await db.query('SELECT id_usuario FROM dbo.usuario WHERE id_usuario=?',params:[id])).isEmpty)throw ApiError(404,'Usuário não encontrado.');
    final rows=await db.query('SELECT a.id_evento,a.data_evento,a.evento,a.antes,a.depois,'
      'a.id_usuario_responsavel,a.responsavel_nome,a.responsavel_email '
      'FROM dbo.auditoria_administrativa a '
      'WHERE a.id_usuario_alvo=? ORDER BY a.id_evento DESC OFFSET ? ROWS FETCH NEXT 51 ROWS ONLY',params:[id,offset]);
    return {'itens':rows.take(50).map((r)=>{...r,
      'data_evento':'${r['data_evento'].toString().replaceAll(' ','T').replaceAll(RegExp(r'Z$'),'')}Z',
      'antes':r['antes']==null?null:jsonDecode(r['antes'].toString()),'depois':jsonDecode(r['depois'].toString())}).toList(),'mais':rows.length>50};
  }
  Future<Map<String,dynamic>> save(int user,int id,Map<String,dynamic> body) async {
    await authorize(user);
    final name=body['nome'],email=body['email'],active=body['sin_ativo'],admin=body['sin_admin'],revision=body['revisao'],organs=body['orgaos'];
    if(name is! String || name.trim().isEmpty || name.trim().length>150 || email is! String || email.trim().length>250 ||
      !RegExp(r'^[A-Za-z0-9.!#$%&\x27*+/=?^_`{|}~-]+@[A-Za-z0-9](?:[A-Za-z0-9-]*[A-Za-z0-9])?(?:\.[A-Za-z0-9](?:[A-Za-z0-9-]*[A-Za-z0-9])?)+$').hasMatch(email.trim()) ||
      !['S','N'].contains(active) || !['S','N'].contains(admin) || revision is! int || revision<0 || revision>2147483647 ||
      organs is! List || organs.length>2000 || organs.any((o)=>o is! int || o < -2147483648 || o>2147483647) || organs.toSet().length!=organs.length) {
      throw ApiError(400,'Informe nome, e-mail válido, situação, perfil e órgãos sem duplicidades.');
    }
    try {
      final rows=await db.query('EXEC dbo.sp_salvar_usuario ?,?,?,?,?,?,?,?',params:[user,id,revision,name.trim(),email.trim().toLowerCase(),active as String,admin as String,jsonEncode(organs)],operation:'administrar_usuario');
      return rows.first;
    } on DatabaseFailure catch(error) {
      final message=switch(error.code){
        51210=>'Cadastro ou lista de órgãos inválidos.',51211=>'Acesso restrito à administração.',
        51212=>'Outro administrador alterou o cadastro. Recarregue antes de salvar.',
        51213=>'E-mail já cadastrado.',51214=>'Órgão não encontrado.',51215=>'Administração ocupada. Tente novamente.',
        51216=>'Usuário não encontrado.',2601||2627=>'E-mail já cadastrado.',_=>null,
      };
      if(message==null)rethrow;
      throw ApiError(error.code==51211?403:error.code==51216?404:[51212,51213,51215,2601,2627].contains(error.code)?409:400,message);
    }
  }
}
