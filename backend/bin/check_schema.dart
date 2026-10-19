import 'dart:io';
import '../lib/config/database_config.dart';
import '../lib/models/database_failure.dart';
import '../lib/repositories/database_repository.dart';

Future<void> main() async {
  try {
    final db = DatabaseRepository(DatabaseConfig.fromEnvironment());
    const tables = [
      'usuario',
      'orgao',
      'usuario_orgao',
      'consulta',
      'consulta_orgao',
      'consulta_orgao_tipo',
      'visualizacao_tipo',
      'auditoria',
      'hipotese_legal',
      'tipo_procedimento_restricao'
    ];
    var missing = false;
    for (final name in tables) {
      final rows = await db
          .query('SELECT OBJECT_ID(?, ?) AS id', params: ['dbo.$name', 'U']);
      final value = rows.isEmpty ? null : rows.first['id'];
      final exists = value != null && int.tryParse(value.toString()) != null;
      stdout.writeln('$name: ${exists ? "OK" : "ausente ou sem permissão"}');
      if (!exists) missing = true;
    }
    for (final name in ['ref_assunto', 'assunto']) {
      final rows = await db.query(
        'SELECT COL_LENGTH(?, ?) AS tamanho',
        params: ['dbo.$name', 'id_assunto_pai'],
      );
      final exists =
          rows.isNotEmpty && rows.first['tamanho']?.toString() == '4';
      stdout.writeln(
          '$name.id_assunto_pai: ${exists ? "OK" : "ausente, tipo divergente ou sem permissão"}');
      if (!exists) missing = true;
    }
    if (missing) {
      exitCode = 1;
      return;
    }
    final rows = await db.query(
        'SELECT id_usuario FROM dbo.usuario WHERE email=? AND sin_ativo=?',
        params: ['pg@setic.ro.gov.br', 'S']);
    stdout.writeln(rows.isEmpty
        ? 'Usuário de teste ausente ou inativo.'
        : 'Usuário de teste: OK');
    if (rows.isEmpty) exitCode = 1;
  } on DatabaseFailure catch (error) {
    stderr.writeln(error.diagnostic);
    exitCode = 1;
  } on FormatException catch (error) {
    stderr.writeln(error.message);
    exitCode = 1;
  } catch (error, stack) {
    stderr.writeln(error.runtimeType);
    stderr.writeln(stack);
    exitCode = 1;
  }
}
