import 'dart:convert';
import 'dart:io';
import '../controllers/health_controller.dart';

Future<void> route(HttpRequest request) async {
  if (request.method == 'GET' && request.uri.path == '/api/health') {
    await healthController(request);
    return;
  }
  request.response.statusCode = HttpStatus.notFound;
  request.response.headers.contentType = ContentType.json;
  request.response.write(jsonEncode({'error': 'Rota não disponível nesta etapa'}));
}
