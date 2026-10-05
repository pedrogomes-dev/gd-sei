import 'dart:convert';
import 'dart:io';
import '../lib/config/environment.dart';
import '../lib/routes/router.dart';
import '../lib/config/database_config.dart';
import '../lib/repositories/database_repository.dart';
import '../lib/repositories/consulta_repository.dart';
import '../lib/services/auth_service.dart';
import '../lib/models/api_error.dart';
import '../lib/models/database_failure.dart';
import '../lib/config/settings.dart';

Future<void> main() async {
  final config = Environment.fromEnvironment();
  final db = DatabaseRepository(DatabaseConfig.fromEnvironment());
  final router = Router(AuthService(db), ConsultaRepository(db));
  final server = await HttpServer.bind(config.host, config.port);
  stdout.writeln('API iniciada em ${config.host}:${config.port}');
  await for (final request in server) {
    handle(request, config, router);
  }
}

Future<void> handle(HttpRequest request, Environment config, Router router) async {
  try {
    final origin = request.headers.value('Origin');
    if (origin != null && origin != config.allowedOrigin) {
      request.response.statusCode = HttpStatus.forbidden;
      return;
    }
    if (origin != null) {
      request.response.headers.set('Access-Control-Allow-Origin', config.allowedOrigin);
      request.response.headers.set('Vary', 'Origin');
      request.response.headers.set('Access-Control-Allow-Credentials', 'true');
    }
    request.response.headers.set('X-Content-Type-Options', 'nosniff');
    if (request.method == 'OPTIONS') {
      request.response.headers.set('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
      request.response.headers.set('Access-Control-Allow-Headers', 'Content-Type');
      request.response.statusCode = HttpStatus.noContent;
      return;
    }
    if (request.method == 'POST' && origin != config.allowedOrigin) {
      throw ApiError(403, 'Origem não autorizada');
    }
    await router.route(request);
  } on ApiError catch (error) {
    request.response.statusCode = error.status;
    request.response.headers.contentType = ContentType.json;
    request.response.write(jsonEncode({'error': error.message}));
  } on DatabaseFailure catch (error) {
    request.response.statusCode = HttpStatus.internalServerError;
    request.response.headers.contentType = ContentType.json;
    final development = loadSettings()['APP_ENV'] == 'development';
    request.response.write(jsonEncode({'error': development ? error.diagnostic : 'Erro interno'}));
    stderr.writeln('${request.method} ${request.uri.path}: ${error.diagnostic}');
  } catch (error, stack) {
    request.response.statusCode = HttpStatus.internalServerError;
    request.response.headers.contentType = ContentType.json;
    request.response.write(jsonEncode({'error': 'Erro interno'}));
    stderr.writeln('${request.method} ${request.uri.path}: ${error.runtimeType}');
    if (loadSettings()['APP_ENV'] == 'development') stderr.writeln(stack);
  } finally {
    await request.response.close();
  }
}
