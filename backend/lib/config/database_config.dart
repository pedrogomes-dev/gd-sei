import 'settings.dart';

class DatabaseConfig {
  final String host, database, username, password, driver;
  final int port;
  final bool encrypt, trustServerCertificate;
  DatabaseConfig({required this.host, required this.database,
    required this.username, required this.password, required this.driver,
    required this.port, required this.encrypt, required this.trustServerCertificate});

  factory DatabaseConfig.fromEnvironment() {
    final env = loadSettings();
    String requiredValue(String key) {
      final value = env[key];
      if (value == null || value.trim().isEmpty ||
          (key == 'DB_PASSWORD' && value.contains('COLOQUE_A_SENHA_AQUI'))) {
        throw FormatException('Configure $key no ambiente ou backend/.env');
      }
      if (value.contains('\u0000')) throw FormatException('$key contém caractere inválido');
      return value;
    }
    bool flag(String key, String fallback) {
      final value = (env[key] ?? fallback).toLowerCase();
      if (value != 'true' && value != 'false') throw FormatException('$key deve ser true ou false');
      return value == 'true';
    }
    final port = int.tryParse(env['DB_PORT'] ?? '1433');
    if (port == null || port < 1 || port > 65535) throw FormatException('DB_PORT inválida');
    final host = requiredValue('DB_HOST');
    if (!RegExp(r'^[a-zA-Z0-9._-]+$').hasMatch(host)) {
      throw FormatException('DB_HOST deve ser IP ou hostname, sem porta ou instância');
    }
    return DatabaseConfig(host: host, port: port,
      database: requiredValue('DB_NAME'), username: requiredValue('DB_USER'),
      password: requiredValue('DB_PASSWORD'),
      driver: env['DB_DRIVER'] ?? 'ODBC Driver 18 for SQL Server',
      encrypt: flag('DB_ENCRYPT', 'true'),
      trustServerCertificate: flag('DB_TRUST_SERVER_CERTIFICATE', 'false'));
  }

  // Escapa valores ODBC, inclusive senhas com ; ou }. Nunca registrar esta string.
  static String _quote(String value) => '{${value.replaceAll('}', '}}')}}';
  String connectionString() =>
    'DRIVER=${_quote(driver)};SERVER=${_quote('$host,$port')};'
    'DATABASE=${_quote(database)};UID=${_quote(username)};PWD=${_quote(password)};'
    'Encrypt=${encrypt ? 'yes' : 'no'};'
    'TrustServerCertificate=${trustServerCertificate ? 'yes' : 'no'};Connection Timeout=10;';
}
