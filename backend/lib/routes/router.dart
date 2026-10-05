import 'dart:convert';
import 'dart:io';
import '../controllers/health_controller.dart';
import '../models/api_error.dart';
import '../repositories/consulta_repository.dart';
import '../services/auth_service.dart';

class Router {
  final AuthService auth;
  final ConsultaRepository consultas;
  Router(this.auth,this.consultas);
  Future<Map<String,dynamic>> body(HttpRequest request) async {
    var length=0;
    final bytes=<int>[];
    await for(final chunk in request) {
      length+=chunk.length;
      if(length>8192) throw ApiError(413,'Requisição muito grande');
      bytes.addAll(chunk);
    }
    try {
      final decoded=jsonDecode(utf8.decode(bytes));
      if(decoded is! Map<String,dynamic>) throw const FormatException();
      return decoded;
    } catch (_) { throw ApiError(400,'JSON inválido'); }
  }
  void json(HttpRequest request,Object value) {
    request.response.headers.contentType=ContentType.json;
    request.response.headers.set('Cache-Control','no-store');
    request.response.write(jsonEncode(value));
  }
  Future<void> route(HttpRequest request) async {
    final path=request.uri.path;
    if(request.method=='GET' && path=='/api/health') { await healthController(request); return; }
    if(request.method=='POST' && path=='/api/auth/dev') {
      await auth.login(request,await body(request)); json(request,{'ok':true}); return;
    }
    if(request.method=='POST' && path=='/api/auth/logout') {
      await auth.logout(request); json(request,{'ok':true}); return;
    }
    final userId=await auth.authorize(request);
    if(request.method=='GET' && path=='/api/tipos') {
      json(request,await consultas.list(userId)); return;
    }
    final match=RegExp(r'^/api/tipos/(\d+)(/visualizar)?$').firstMatch(path);
    if(match!=null) {
      final id=int.tryParse(match.group(1)!);
      if(id==null) throw ApiError(400,'Identificador inválido');
      if(request.method=='GET' && match.group(2)==null) {
        json(request,await consultas.detail(userId,id)); return;
      }
      if(request.method=='POST' && match.group(2)!=null) {
        await consultas.detail(userId,id);
        await consultas.viewed(userId,id); json(request,{'ok':true}); return;
      }
    }
    throw ApiError(404,'Rota não disponível');
  }
}
