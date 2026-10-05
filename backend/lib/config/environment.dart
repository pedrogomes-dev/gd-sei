import 'settings.dart';

class Environment {
  final String host;
  final int port;
  final String allowedOrigin;
  Environment({required this.host, required this.port, required this.allowedOrigin});
  factory Environment.fromEnvironment() {
    final env = loadSettings();
    final port = int.tryParse(env['PORT'] ?? '8080');
    if (port == null || port < 1 || port > 65535) {
      throw FormatException('PORT inválida');
    }
    return Environment(host: env['HOST'] ?? '127.0.0.1', port: port,
      allowedOrigin: env['ALLOWED_ORIGIN'] ?? 'http://localhost:3000');
  }
}
