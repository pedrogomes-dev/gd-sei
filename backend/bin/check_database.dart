import 'dart:io';
import '../lib/config/database_config.dart';
import '../lib/repositories/database_repository.dart';

Future<void> main() async {
  try {
    final config = DatabaseConfig.fromEnvironment();
    final rows = await DatabaseRepository(config).query('SELECT 1 AS conectado');
    if (rows.isEmpty || rows.first['conectado'].toString() != '1') {
      throw StateError('Resposta inesperada do banco');
    }
    stdout.writeln('Conexão SQL Server validada.');
  } on FormatException catch (error) {
    stderr.writeln(error.message);
    exitCode = 1;
  } catch (_) {
    // Mensagens do driver podem conter dados de conexão; não imprimi-las.
    stderr.writeln('Falha na conexão. Verifique driver ODBC, rede/VPN, credenciais e certificado TLS.');
    exitCode = 1;
  }
}
