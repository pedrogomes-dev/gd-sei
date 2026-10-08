import 'dart:convert';
import 'dart:io';
import 'dart:math';
import '../config/settings.dart';
import '../models/api_error.dart';
import '../repositories/database_repository.dart';

class AuthService {
  final DatabaseRepository db;
  final Map<String, ({int userId, DateTime expires})> _sessions = {};
  final bool enabled;
  final bool secureCookie;
  AuthService(this.db) : enabled = loadSettings()['DEV_AUTH_ENABLED'] == 'true',
    secureCookie = loadSettings()['COOKIE_SECURE'] != 'false' {
    if (enabled && loadSettings()['APP_ENV'] != 'development') {
      throw StateError('Acesso temporário exige APP_ENV=development');
    }
  }
  Cookie cookie(String value, {bool expired = false}) => Cookie('sei_session', value)
    ..httpOnly = true ..secure = secureCookie ..sameSite = SameSite.lax
    ..path = '/api' ..maxAge = expired ? 0 : 28800;

  Future<void> login(HttpRequest request, Map<String, dynamic> body) async {
    if (!enabled) throw ApiError(403, 'Acesso temporário desativado');
    if (body['email'] != 'pg@setic.ro.gov.br' || body['token'] != '123456') {
      throw ApiError(401, 'E-mail ou token inválido');
    }
    final rows = await db.query('SELECT id_usuario FROM dbo.usuario WHERE email=? AND sin_ativo=?',
      params: ['pg@setic.ro.gov.br', 'S'],operation:'login_buscar_usuario');
    if (rows.isEmpty) throw ApiError(403, 'Usuário não cadastrado ou inativo');
    final userId = int.parse(rows.first['id_usuario'].toString());
    final random = Random.secure();
    final token = base64UrlEncode(List.generate(32, (_) => random.nextInt(256)));
    _sessions.removeWhere((_, s) => !s.expires.isAfter(DateTime.now().toUtc()));
    await db.query('INSERT dbo.auditoria(id_usuario,evento) VALUES(?,?)', params: [userId,'LOGIN_DEV'],operation:'login_gravar_auditoria');
    for (final c in request.cookies.where((c) => c.name == 'sei_session')) { _sessions.remove(c.value); }
    _sessions[token] = (userId: userId, expires: DateTime.now().toUtc().add(const Duration(hours: 8)));
    request.response.cookies.add(cookie(token));
  }

  Future<int> authorize(HttpRequest request) async {
    final cookies = request.cookies.where((c) => c.name == 'sei_session');
    if (cookies.isEmpty) throw ApiError(401, 'Faça login');
    final key = cookies.first.value;
    final session = _sessions[key];
    if (session == null || !session.expires.isAfter(DateTime.now().toUtc())) {
      _sessions.remove(key);
      throw ApiError(401, 'Sessão expirada');
    }
    final user = await db.query('SELECT id_usuario FROM dbo.usuario WHERE id_usuario=? AND sin_ativo=?',
      params:[session.userId,'S']);
    if (user.isEmpty) throw ApiError(401, 'Usuário inativo');
    return session.userId;
  }

  Future<Map<String, dynamic>> profile(int userId) async {
    final users = await db.query('SELECT id_usuario,email FROM dbo.usuario WHERE id_usuario=? AND sin_ativo=?', params:[userId,'S']);
    if (users.isEmpty) throw ApiError(401, 'Usuário inativo');
    final organs = await db.query('SELECT o.id_orgao,o.sigla FROM dbo.orgao o JOIN dbo.usuario_orgao u ON u.id_orgao=o.id_orgao WHERE u.id_usuario=? ORDER BY o.sigla', params:[userId]);
    return {...users.first, 'orgaos': organs};
  }

  Future<void> logout(HttpRequest request) async {
    final userId = await authorize(request);
    for (final c in request.cookies.where((c) => c.name == 'sei_session')) { _sessions.remove(c.value); }
    request.response.cookies.add(cookie('', expired: true));
    await db.query('INSERT dbo.auditoria(id_usuario,evento) VALUES(?,?)',params:[userId,'LOGOUT'],operation:'logout_gravar_auditoria');
  }
}

