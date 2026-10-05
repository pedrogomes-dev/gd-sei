import 'dart:convert';
import 'package:http/browser_client.dart';

class ApiService {
  static const baseUrl=String.fromEnvironment('API_BASE_URL',defaultValue:'http://localhost:8080');
  static final BrowserClient _client=BrowserClient()..withCredentials=true;
  Future<dynamic> request(String path,{Map<String,dynamic>? data}) async {
    final uri=Uri.parse('$baseUrl$path');
    final response=await (data==null ? _client.get(uri) :
      _client.post(uri,headers:{'Content-Type':'application/json'},body:jsonEncode(data)))
      .timeout(const Duration(seconds:20));
    final decoded=jsonDecode(response.body);
    if(response.statusCode!=200) throw Exception(decoded is Map ? decoded['error'] : 'Falha na API');
    return decoded;
  }
  Future<String> health() async => (await request('/api/health'))['status'] as String;
  Future<void> login(String email,String token) async { await request('/api/auth/dev',data:{'email':email,'token':token}); }
  Future<void> logout() async { await request('/api/auth/logout',data:{}); }
  Future<List<dynamic>> tipos() async => await request('/api/tipos') as List<dynamic>;
  Future<Map<String,dynamic>> tipo(String id) async => await request('/api/tipos/$id') as Map<String,dynamic>;
  Future<void> visualizar(String id) async { await request('/api/tipos/$id/visualizar',data:{}); }
  Future<Map<String,dynamic>> save(String id,Map<String,dynamic> data) async =>
    await request('/api/tipos/$id/manifestacao',data:data) as Map<String,dynamic>;
  Future<Map<String,dynamic>> search(String id,String text,int offset) async =>
    await request('/api/tipos/$id/assuntos?q=${Uri.encodeQueryComponent(text)}&offset=$offset') as Map<String,dynamic>;
  Future<Map<String,dynamic>> summary(String consulta,String orgao) async =>
    await request('/api/consultas/$consulta/orgaos/$orgao/resumo') as Map<String,dynamic>;
  Future<void> finish(String consulta,String orgao,int revision) async {
    await request('/api/consultas/$consulta/orgaos/$orgao/finalizar',data:{'revisao':revision});
  }
}
