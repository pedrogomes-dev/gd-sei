import 'dart:convert';
import 'dart:io';

Future<void> healthController(HttpRequest request) async {
  request.response.headers.contentType = ContentType.json;
  request.response.write(jsonEncode({'status': 'ok', 'stage': 'estrutura_inicial'}));
}
