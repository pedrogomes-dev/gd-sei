import 'dart:convert';
import 'dart:io';

import 'package:dotenv/dotenv.dart';
import 'package:test/test.dart';

import '../lib/config/database_config.dart';
import '../lib/controllers/administracao_controller.dart';
import '../lib/controllers/catalogo_controller.dart';
import '../lib/controllers/inicio_controller.dart';
import '../lib/controllers/manifestacao_controller.dart';
import '../lib/models/api_error.dart';
import '../lib/repositories/consulta_repository.dart';
import '../lib/repositories/database_repository.dart';
import '../lib/routes/router.dart';
import '../lib/services/auth_service.dart';

DotEnv configuracao(
        {bool habilitado = true, String ambiente = 'development'}) =>
    DotEnv()
      ..addAll({
        'APP_ENV': ambiente,
        'DEV_AUTH_ENABLED': '$habilitado',
        'COOKIE_SECURE': 'true',
      });

class BancoDev extends DatabaseRepository {
  int chamadas = 0;
  final auditoria = <List<Object>>[];
  final usuarios = <Map<String, dynamic>>[
    {
      'id_usuario': 1,
      'nome': 'Comum',
      'email': 'comum@example.test',
      'sin_ativo': 'S',
      'sin_admin': 'N',
      'versao_sessao': 0
    },
    {
      'id_usuario': 2,
      'nome': 'Admin',
      'email': 'admin@example.test',
      'sin_ativo': 'S',
      'sin_admin': 'S',
      'versao_sessao': 0
    },
    {
      'id_usuario': 3,
      'nome': 'Inativo',
      'email': 'inativo@example.test',
      'sin_ativo': 'N',
      'sin_admin': 'N',
      'versao_sessao': 0
    },
  ];
  BancoDev()
      : super(DatabaseConfig(
            host: 'teste',
            database: 'teste',
            username: 'teste',
            password: 'teste',
            driver: 'teste',
            port: 1433,
            encrypt: true,
            trustServerCertificate: false));

  @override
  Future<List<Map<String, dynamic>>> query(String sql,
      {List<Object> params = const [], String operation = 'consulta'}) async {
    chamadas++;
    if (sql.contains('INSERT dbo.auditoria')) {
      auditoria.add(params);
      return [];
    }
    if (sql.contains('FROM dbo.orgao')) {
      return [
        {
          'id_orgao': params.single == 1 ? 0 : 9,
          'sigla': params.single == 1 ? 'ORG0' : 'ORG9'
        }
      ];
    }
    expect(sql, contains("sin_ativo = 'S'"));
    final ativos = usuarios.where((u) => u['sin_ativo'] == 'S');
    if (operation == 'login_dev_listar_usuarios') {
      return [
        for (final u in ativos)
          {
            for (final k in ['id_usuario', 'nome', 'email']) k: u[k]
          }
      ];
    }
    return ativos.where((u) => u['id_usuario'] == params.single).toList();
  }
}

Future<
    ({
      AuthService auth,
      Future<({int status, dynamic dados, List<Cookie> cookies})> Function(
          String,
          {Map<String, dynamic>? dados,
          List<Cookie> cookies}) chamar
    })> iniciar(BancoDev banco, {bool habilitado = true}) async {
  final auth =
      AuthService(banco, configuracao: configuracao(habilitado: habilitado));
  final consultas = ConsultaRepository(banco);
  final router = Router(
      auth,
      consultas,
      ManifestacaoController(banco, consultas),
      CatalogoController(banco),
      AdministracaoController(banco),
      InicioController(banco));
  final servidor = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
  final cliente = HttpClient();
  addTearDown(() async {
    cliente.close(force: true);
    await servidor.close(force: true);
  });
  servidor.listen((request) async {
    try {
      await router.route(request);
    } on ApiError catch (erro) {
      request.response.statusCode = erro.status;
      request.response.write(jsonEncode({'error': erro.message}));
    } finally {
      await request.response.close();
    }
  });
  Future<({int status, dynamic dados, List<Cookie> cookies})> chamar(
      String rota,
      {Map<String, dynamic>? dados,
      List<Cookie> cookies = const []}) async {
    final request = await cliente.openUrl(dados == null ? 'GET' : 'POST',
        Uri.parse('http://127.0.0.1:${servidor.port}$rota'));
    request.cookies.addAll(cookies);
    if (dados != null) request.write(jsonEncode(dados));
    final resposta = await request.close();
    return (
      status: resposta.statusCode,
      dados: jsonDecode(await utf8.decoder.bind(resposta).join()),
      cookies: resposta.cookies
    );
  }

  return (auth: auth, chamar: chamar);
}

void main() {
  test('produção rejeita habilitação do bypass no início', () {
    expect(
        () => AuthService(BancoDev(),
            configuracao: configuracao(ambiente: 'production')),
        throwsStateError);
    final auth = AuthService(BancoDev(),
        configuracao: configuracao(ambiente: 'production', habilitado: false));
    expect(auth.enabled, isFalse);
  });

  test(
      'desativado não lista usuários nem aceita login mesmo com parâmetros forjados',
      () async {
    final banco = BancoDev();
    final app = await iniciar(banco, habilitado: false);
    final config = await app.chamar('/api/auth/config');
    expect(config.dados, {'acesso_temporario': false});
    expect(
        (await app.chamar('/api/auth/dev', dados: {
          'id_usuario': 2,
          'token': '123456',
          'APP_ENV': 'development'
        }))
            .status,
        403);
    expect(banco.chamadas, 0);
  });

  test(
      'lista somente ativos e cria sessão com perfil e órgão do usuário escolhido',
      () async {
    final banco = BancoDev();
    final app = await iniciar(banco);
    final config = await app.chamar('/api/auth/config');
    expect(
        (config.dados['usuarios'] as List).map((u) => u['id_usuario']), [1, 2]);
    for (final id in [1, 2]) {
      final login = await app.chamar('/api/auth/dev',
          dados: {'id_usuario': id, 'token': '123456'});
      expect(login.status, 200);
      expect(banco.auditoria.last, [id, 'LOGIN_DEV']);
      final perfil = await app.chamar('/api/auth/me', cookies: login.cookies);
      expect(perfil.status, 200);
      expect(perfil.dados['id_usuario'], id);
      expect(perfil.dados['sin_admin'], id == 1 ? 'N' : 'S');
      expect(perfil.dados['orgaos'].single['id_orgao'], id == 1 ? 0 : 9);
      banco.usuarios[id - 1]['versao_sessao'] = 1;
      expect((await app.chamar('/api/auth/me', cookies: login.cookies)).status,
          401);
    }
  });

  test(
      'recusa inativos, inexistentes, token errado e IDs inválidos sem sessão/auditoria',
      () async {
    final banco = BancoDev();
    final app = await iniciar(banco);
    for (final id in [3, 999, -1]) {
      final resposta = await app.chamar('/api/auth/dev',
          dados: {'id_usuario': id, 'token': '123456'});
      expect(resposta.status, 403);
      expect(resposta.cookies, isEmpty);
    }
    for (final id in [null, '1', 1.5, 2147483648]) {
      expect(
          (await app.chamar('/api/auth/dev',
                  dados: {'id_usuario': id, 'token': '123456'}))
              .status,
          400);
    }
    expect(
        (await app.chamar('/api/auth/dev',
                dados: {'id_usuario': 1, 'token': 'errado'}))
            .status,
        401);
    expect(banco.auditoria, isEmpty);
    await app.chamar('/api/auth/config');
    banco.usuarios[0]['sin_ativo'] = 'N';
    expect(
        (await app.chamar('/api/auth/dev',
                dados: {'id_usuario': 1, 'token': '123456'}))
            .status,
        403);
    expect(banco.auditoria, isEmpty);
  });
}
