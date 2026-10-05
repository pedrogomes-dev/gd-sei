import 'dart:io';
import 'dart:ffi';
import 'package:dart_odbc/dart_odbc.dart';
import '../lib/config/database_config.dart';
import '../lib/models/database_failure.dart';
import '../lib/repositories/database_repository.dart';

Future<void> main() async {
  try {
    stdout.writeln('Patch carregado: $seiOdbcPatch');
    stdout.writeln('Ponteiro: ${sizeOf<IntPtr>()}; SQLLEN: ${sizeOf<SQLLEN>()}; SQLULEN: ${sizeOf<SQLULEN>()} bytes');
    if(sizeOf<SQLLEN>()!=sizeOf<IntPtr>() || sizeOf<SQLULEN>()!=sizeOf<UintPtr>()) {
      throw StateError('Largura dos tipos ODBC incompatível');
    }
    final db=DatabaseRepository(DatabaseConfig.fromEnvironment());
    const values=['pg@setic.ro.gov.br','S','',"D'Ávila",'Gestão documental'];
    for(var i=0;i<values.length;i++) {
      final rows=await db.query('SELECT CAST(? AS nvarchar(250)) AS valor',
        params:[values[i]],operation:'teste_texto_$i');
      if(rows.isEmpty || rows.first['valor']!=values[i]) {
        throw StateError('Parâmetro de texto $i não foi preservado');
      }
      stdout.writeln('Parâmetro de texto $i: OK');
    }
    final rows=await db.query('SELECT CAST(? AS int) AS valor',params:[123],operation:'teste_inteiro');
    if(rows.isEmpty || rows.first['valor'].toString()!='123')throw StateError('Inteiro não preservado');
    stdout.writeln('Parâmetro inteiro: OK');
  } on DatabaseFailure catch(error) {
    stderr.writeln(error.diagnostic);exitCode=1;
  } on FormatException catch(error) {
    stderr.writeln(error.message);exitCode=1;
  } on StateError catch(error) {
    stderr.writeln(error.message);exitCode=1;
  } catch(error) {
    stderr.writeln('Falha no teste: ${error.runtimeType}');exitCode=1;
  }
}
