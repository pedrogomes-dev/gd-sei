import 'dart:convert';
import 'dart:io';
import 'dart:math';

import '../config/settings.dart';
import '../models/api_error.dart';
import '../repositories/database_repository.dart';
import '../utils/validacoes.dart';
import 'codigos_acesso.dart';
import 'email_service.dart';

class AuthService {
  final DatabaseRepository db;
  final EmailService emailService;
  final CodigosAcesso codigos;
  final Map<String, ({int userId, int version, DateTime expires})> _sessions = {};
  final bool enabled;
  final bool secureCookie;

  AuthService(this.db, {EmailService? email, CodigosAcesso? armazenamento})
      : emailService = email ?? EmailService(),
        codigos = armazenamento ?? CodigosAcesso(),
        enabled = loadSettings()['DEV_AUTH_ENABLED'] == 'true',
        secureCookie = loadSettings()['COOKIE_SECURE'] != 'false' {
    final desenvolvimento = loadSettings()['APP_ENV'] == 'development';
    if (enabled && !desenvolvimento) {
      throw StateError('Acesso temporário exige APP_ENV=development');
    }
    if (!secureCookie && !desenvolvimento) {
      throw StateError('Fora de desenvolvimento, configure COOKIE_SECURE=true e HTTPS.');
    }
  }

  Cookie cookie(String value, {bool expired = false}) => Cookie('sei_session', value)
    ..httpOnly = true ..secure = secureCookie ..sameSite = SameSite.lax
    ..path = '/api' ..maxAge = expired ? 0 : 28800;

  String lerEmail(Map<String, dynamic> dados) {
    final valor = dados['email'];
    if (valor is! String || valor.trim().length > 250 || !Validacoes.emailValido(valor)) {
      throw ApiError(400, 'Informe um e-mail válido.');
    }
    return valor.trim().toLowerCase();
  }

  Future<Map<String, dynamic>?> buscarUsuario(String email) async {
    const sql = '''
      SELECT id_usuario, versao_sessao
      FROM dbo.usuario
      WHERE email_normalizado = ? AND sin_ativo = 'S'
    ''';
    final usuarios = await db.query(sql, params: [email], operation: 'login_buscar_usuario');
    return usuarios.isEmpty ? null : usuarios.first;
  }

  Future<void> solicitarCodigo(HttpRequest request, Map<String, dynamic> dados) async {
    final email = lerEmail(dados);
    final ip = request.connectionInfo?.remoteAddress.address ?? 'desconhecido';
    emailService.verificarConfiguracao();
    // Reserva antes do primeiro await para serializar reenvios para o mesmo e-mail.
    codigos.reservarEnvio(email, ip);
    try {
      final usuario = await buscarUsuario(email);
      if (usuario == null) return;
      final idUsuario = int.parse(usuario['id_usuario'].toString());
      final versaoSessao = int.parse(usuario['versao_sessao'].toString());
      final codigo = codigos.criar(email, idUsuario, versaoSessao);
      await emailService.enviarCodigo(email, codigo);
      codigos.confirmarEnvio(email);
    } catch (_) {
      codigos.cancelar(email);
      rethrow;
    } finally {
      codigos.liberarEnvio(email);
    }
  }

  Future<void> entrarEmail(HttpRequest request, Map<String, dynamic> dados) async {
    final email = lerEmail(dados);
    final codigo = dados['codigo'];
    if (codigo is! String) throw ApiError(401, 'Código inválido ou expirado.');
    final registro = codigos.consumir(email, codigo.trim());
    final usuario = await buscarUsuario(email);
    if (usuario == null ||
        int.parse(usuario['id_usuario'].toString()) != registro.idUsuario ||
        int.parse(usuario['versao_sessao'].toString()) != registro.versaoSessao) {
      throw ApiError(401, 'Acesso alterado. Solicite um novo código.');
    }
    await criarSessao(request, usuario, 'LOGIN');
  }

  Future<void> login(HttpRequest request, Map<String, dynamic> body) async {
    if (!enabled) throw ApiError(403, 'Acesso temporário desativado');
    if (body['email'] != 'pg@setic.ro.gov.br' || body['token'] != '123456') {
      throw ApiError(401, 'E-mail ou token inválido');
    }
    final usuario = await buscarUsuario('pg@setic.ro.gov.br');
    if (usuario == null) throw ApiError(403, 'Usuário não cadastrado ou inativo');
    await criarSessao(request, usuario, 'LOGIN_DEV');
  }

  Future<void> criarSessao(HttpRequest request, Map<String, dynamic> usuario, String evento) async {
    final idUsuario = int.parse(usuario['id_usuario'].toString());
    final versaoSessao = int.parse(usuario['versao_sessao'].toString());
    final random = Random.secure();
    final token = base64UrlEncode(List.generate(32, (_) => random.nextInt(256)));
    _sessions.removeWhere((_, sessao) => !sessao.expires.isAfter(DateTime.now().toUtc()));
    const sql = '''
      INSERT dbo.auditoria(id_usuario, evento)
      VALUES (?, ?)
    ''';
    await db.query(sql, params: [idUsuario, evento], operation: 'login_gravar_auditoria');
    for (final anterior in request.cookies.where((item) => item.name == 'sei_session')) {
      _sessions.remove(anterior.value);
    }
    _sessions[token] = (
      userId: idUsuario,
      version: versaoSessao,
      expires: DateTime.now().toUtc().add(const Duration(hours: 8)),
    );
    request.response.cookies.add(cookie(token));
  }

  Future<int> authorize(HttpRequest request) async {
    final cookies = request.cookies.where((item) => item.name == 'sei_session');
    if (cookies.isEmpty) throw ApiError(401, 'Faça login');
    final chave = cookies.first.value;
    final sessao = _sessions[chave];
    if (sessao == null || !sessao.expires.isAfter(DateTime.now().toUtc())) {
      _sessions.remove(chave);
      throw ApiError(401, 'Sessão expirada');
    }
    const sql = '''
      SELECT id_usuario, versao_sessao
      FROM dbo.usuario
      WHERE id_usuario = ? AND sin_ativo = 'S'
    ''';
    final usuarios = await db.query(sql, params: [sessao.userId]);
    if (usuarios.isEmpty || int.parse(usuarios.first['versao_sessao'].toString()) != sessao.version) {
      _sessions.remove(chave);
      request.response.cookies.add(cookie('', expired: true));
      throw ApiError(401, 'Acesso desativado ou permissões alteradas. Faça login novamente.');
    }
    return sessao.userId;
  }

  Future<Map<String, dynamic>> profile(int userId) async {
    const sqlUsuario = '''
      SELECT id_usuario, nome, email, sin_admin
      FROM dbo.usuario
      WHERE id_usuario = ? AND sin_ativo = 'S'
    ''';
    final usuarios = await db.query(sqlUsuario, params: [userId]);
    if (usuarios.isEmpty) throw ApiError(401, 'Usuário inativo');
    const sqlOrgaos = '''
      SELECT orgao.id_orgao, orgao.sigla
      FROM dbo.orgao orgao
      JOIN dbo.usuario_orgao vinculo ON vinculo.id_orgao = orgao.id_orgao
      WHERE vinculo.id_usuario = ?
      ORDER BY orgao.sigla
    ''';
    final orgaos = await db.query(sqlOrgaos, params: [userId]);
    return {...usuarios.first, 'orgaos': orgaos};
  }

  Future<void> logout(HttpRequest request) async {
    final idUsuario = await authorize(request);
    for (final anterior in request.cookies.where((item) => item.name == 'sei_session')) {
      _sessions.remove(anterior.value);
    }
    request.response.cookies.add(cookie('', expired: true));
    const sql = '''
      INSERT dbo.auditoria(id_usuario, evento)
      VALUES (?, ?)
    ''';
    await db.query(sql, params: [idUsuario, 'LOGOUT'], operation: 'logout_gravar_auditoria');
  }
}
