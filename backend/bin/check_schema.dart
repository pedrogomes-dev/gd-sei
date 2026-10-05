import 'dart:io';
import '../lib/config/database_config.dart';
import '../lib/models/database_failure.dart';
import '../lib/repositories/database_repository.dart';

Future<void> main() async {
  try {
    final db=DatabaseRepository(DatabaseConfig.fromEnvironment());
    const tables=['usuario','orgao','usuario_orgao','consulta','consulta_orgao',
      'consulta_orgao_tipo','visualizacao_tipo','auditoria'];
    var missing=false;
    for(final name in tables) {
      final rows=await db.query('SELECT OBJECT_ID(?, ?) AS id',params:['dbo.$name','U']);
      final value=rows.isEmpty ? null : rows.first['id'];
      final exists=value!=null && int.tryParse(value.toString())!=null;
      stdout.writeln('$name: ${exists ? "OK" : "ausente ou sem permissão"}');
      if(!exists)missing=true;
    }
    if(missing) { exitCode=1; return; }
    final rows=await db.query('SELECT id_usuario FROM dbo.usuario WHERE email=? AND sin_ativo=?',
      params:['pg@setic.ro.gov.br','S']);
    stdout.writeln(rows.isEmpty?'Usuário de teste ausente ou inativo.':'Usuário de teste: OK');
    if(rows.isEmpty)exitCode=1;
  } on DatabaseFailure catch(error) {
    stderr.writeln(error.diagnostic);exitCode=1;
  } on FormatException catch(error) {
    stderr.writeln(error.message);exitCode=1;
  } catch(error,stack) {
    stderr.writeln(error.runtimeType);stderr.writeln(stack);exitCode=1;
  }
}
