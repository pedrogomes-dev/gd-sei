import 'dart:convert';
import 'dart:io';
import '../lib/config/environment.dart';
import '../lib/routes/router.dart';

Future<void> main() async {
  final config = Environment.fromEnvironment();
  final server = await HttpServer.bind(config.host, config.port);
  stdout.writeln('API iniciada em ${config.host}:${config.port}');
  await for (final request in server) {
    await handle(request, config);
  }
}

Future<void> handle(HttpRequest request, Environment config) async {
  try {
    final origin = request.headers.value('Origin');
    if (origin != null && origin != config.allowedOrigin) {
      request.response.statusCode = HttpStatus.forbidden;
      return;
    }
    if (origin != null) {
      request.response.headers.set('Access-Control-Allow-Origin', config.allowedOrigin);
      request.response.headers.set('Vary', 'Origin');
    }
    request.response.headers.set('X-Content-Type-Options', 'nosniff');
    if (request.method == 'OPTIONS') {
      request.response.headers.set('Access-Control-Allow-Methods', 'GET, OPTIONS');
      request.response.statusCode = HttpStatus.noContent;
      return;
    }
    await route(request);
  } catch (_) {
    request.response.statusCode = HttpStatus.internalServerError;
    request.response.headers.contentType = ContentType.json;
    request.response.write(jsonEncode({'error': 'Erro interno'}));
    stderr.writeln('Falha ao tratar requisição.');
  } finally {
    await request.response.close();
  }
}
