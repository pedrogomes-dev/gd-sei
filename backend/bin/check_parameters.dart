import 'dart:io';
import 'dart:ffi';
import 'package:dart_odbc/dart_odbc.dart';
import '../lib/config/database_config.dart';
import '../lib/models/database_failure.dart';
import '../lib/repositories/database_repository.dart';

Future<void> main() async {
  try {
    stdout.writeln('Patch carregado: $seiOdbcPatch');
    stdout.writeln(
        'Ponteiro: ${sizeOf<IntPtr>()}; SQLLEN: ${sizeOf<SQLLEN>()}; SQLULEN: ${sizeOf<SQLULEN>()} bytes');
    if (sizeOf<SQLLEN>() != sizeOf<IntPtr>() ||
        sizeOf<SQLULEN>() != sizeOf<UintPtr>()) {
      throw StateError('Largura dos tipos ODBC incompatível');
    }
    final db = DatabaseRepository(DatabaseConfig.fromEnvironment());
    final values = [
      'pg@setic.ro.gov.br',
      'S',
      '',
      "D'Ávila",
      'Gestão documental',
      String.fromCharCode(0x1F9EA),
      List.filled(5001, 'a').join()
    ];
    for (var i = 0; i < values.length; i++) {
      final rows = await db.query('SELECT CAST(? AS nvarchar(max)) AS valor',
          params: [values[i]], operation: 'teste_texto_$i');
      if (rows.isEmpty || rows.first['valor'] != values[i]) {
        throw StateError('Parâmetro de texto $i não foi preservado');
      }
      stdout.writeln('Parâmetro de texto $i: OK');
    }
    final rows = await db.query('SELECT CAST(? AS int) AS valor',
        params: [123], operation: 'teste_inteiro');
    if (rows.isEmpty || rows.first['valor'].toString() != '123')
      throw StateError('Inteiro não preservado');
    stdout.writeln('Parâmetro inteiro: OK');
    final vazios =
        await db.query('SELECT CAST(NULL AS nvarchar(max)) AS texto_nulo, '
            'CAST(NULL AS varbinary(max)) AS binario_nulo, '
            'CAST(0x AS varbinary(max)) AS binario_vazio, '
            'CAST(0x010002 AS varbinary(max)) AS binario');
    final vazio = vazios.single;
    if (vazio['texto_nulo'] != null ||
        vazio['binario_nulo'] != null ||
        vazio['binario_vazio'] is! List<int> ||
        (vazio['binario_vazio'] as List<int>).isNotEmpty ||
        vazio['binario'] is! List<int> ||
        (vazio['binario'] as List<int>).join(',') != '1,0,2') {
      throw StateError('NULL ou valores binários não foram preservados');
    }
    stdout.writeln('NULL, binário vazio e binário com zero: OK');
  } on DatabaseFailure catch (error) {
    stderr.writeln(error.diagnostic);
    exitCode = 1;
  } on FormatException catch (error) {
    stderr.writeln(error.message);
    exitCode = 1;
  } on StateError catch (error) {
    stderr.writeln(error.message);
    exitCode = 1;
  } catch (error) {
    stderr.writeln('Falha no teste: ${error.runtimeType}');
    exitCode = 1;
  }
}
