import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const baseUrl = String.fromEnvironment('API_BASE_URL',
      defaultValue: 'http://localhost:8080');
  Future<String> health() async {
    final response = await http.get(Uri.parse('$baseUrl/api/health'))
        .timeout(const Duration(seconds: 10));
    if (response.statusCode != 200) throw Exception('API indisponível');
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    return body['status'] as String;
  }
}
