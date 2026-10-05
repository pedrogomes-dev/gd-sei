import 'package:dart_odbc/dart_odbc.dart';
import '../config/database_config.dart';

class DatabaseRepository {
  final DatabaseConfig config;
  DatabaseRepository(this.config);

  // Uma conexão por operação nesta etapa; não compartilhar transações entre requisições.
  Future<List<Map<String, dynamic>>> query(String sql, {List<Object> params = const []}) async {
    final connection = DartOdbc();
    try {
      await connection.connectWithConnectionString(config.connectionString());
      return await connection.execute(sql, params: params);
    } finally {
      await connection.disconnect();
    }
  }
}
