import 'dart:convert';
import 'dart:io';
import 'package:test/test.dart';

import '../lib/config/database_config.dart';
import '../lib/models/api_error.dart';
import '../lib/repositories/database_repository.dart';
import '../lib/services/auth_service.dart';
import '../lib/services/codigos_acesso.dart';
import '../lib/services/email_service.dart';

void verificar(bool condicao, String mensagem) {
  if (!condicao) throw StateError(mensagem);
}

class BancoTeste extends DatabaseRepository {
  bool ativo = true;
  int versao = 0;
  final eventos = <String>[];

  BancoTeste()
      : super(DatabaseConfig(
          host: 'teste',
          database: 'teste',
          username: 'teste',
          password: 'teste',
          driver: 'teste',
          port: 1433,
          encrypt: true,
          trustServerCertificate: false,
        ));

  @override
  Future<List<Map<String, dynamic>>> query(
    String sql, {
    List<Object> params = const [],
    String operation = 'consulta',
  }) async {
    if (sql.contains('INSERT dbo.auditoria')) {
      eventos.add(params[1] as String);
      return [];
    }
    if (ativo &&
        (params.first == 'teste@setic.ro.gov.br' || params.first == 1)) {
      return [
        {'id_usuario': 1, 'versao_sessao': versao}
      ];
    }
    return [];
  }
}

class EmailTeste extends EmailService {
  final enviados = <String>[];
  String? codigo;
  bool falhar = false;

  @override
  void verificarConfiguracao() {}

  @override
  Future<void> enviarCodigo(String destinatario, String valor) async {
    codigo = valor;
    if (falhar) throw ApiError(503, 'Falha simulada.');
    enviados.add(destinatario);
  }
}

void main() {
  test('autenticação HTTP com banco e SMTP simulados', executarCenarios);
}

Future<void> executarCenarios() async {
  var instante = DateTime.utc(2026, 10, 9);
  final banco = BancoTeste();
  final email = EmailTeste();
  final codigos = CodigosAcesso(relogio: () => instante);
  final auth = AuthService(banco, email: email, armazenamento: codigos);
  final servidor = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
  final cliente = HttpClient();
  servidor.listen((request) async {
    try {
      final dados = jsonDecode(await utf8.decoder.bind(request).join())
          as Map<String, dynamic>;
      switch (request.uri.path) {
        case '/codigo':
          await auth.solicitarCodigo(request, dados);
          request.response.write(jsonEncode(
              {'mensagem': 'Se cadastrado e ativo, receberá um código.'}));
          break;
        case '/entrar':
          await auth.entrarEmail(request, dados);
          request.response.write('{}');
          break;
        case '/logout':
          await auth.logout(request);
          request.response.write('{}');
          break;
        case '/sessao':
          final id = await auth.authorize(request);
          request.response.write(jsonEncode({'id': id}));
          break;
      }
    } on ApiError catch (erro) {
      request.response.statusCode = erro.status;
      request.response.write(jsonEncode({'error': erro.message}));
    } finally {
      await request.response.close();
    }
  });

  Future<({int status, String corpo, List<Cookie> cookies})> chamar(
    String rota,
    Map<String, dynamic> dados, {
    List<Cookie> cookies = const [],
  }) async {
    final request = await cliente
        .postUrl(Uri.parse('http://127.0.0.1:${servidor.port}$rota'));
    request.cookies.addAll(cookies);
    request.write(jsonEncode(dados));
    final response = await request.close();
    final corpo = await utf8.decoder.bind(response).join();
    return (
      status: response.statusCode,
      corpo: corpo,
      cookies: response.cookies
    );
  }

  const endereco = 'teste@setic.ro.gov.br';
  try {
    final desconhecido =
        await chamar('/codigo', {'email': 'outro@setic.ro.gov.br'});
    verificar(desconhecido.status == 200 && email.enviados.isEmpty,
        'Envio a usuário desconhecido.');
    final conhecido =
        await chamar('/codigo', {'email': ' TESTE@setic.ro.gov.br '});
    verificar(
        conhecido.corpo == desconhecido.corpo, 'Resposta revelou o cadastro.');
    verificar(email.enviados.single == endereco, 'E-mail não normalizado.');
    final primeiro = email.codigo!;
    final login =
        await chamar('/entrar', {'email': endereco, 'codigo': primeiro});
    verificar(login.status == 200 && banco.eventos.single == 'LOGIN',
        'Login não auditado.');
    verificar(
        login.cookies.single.httpOnly && login.cookies.single.path == '/api',
        'Cookie incorreto.');
    final repetido =
        await chamar('/entrar', {'email': endereco, 'codigo': primeiro});
    verificar(repetido.status == 401 && banco.eventos.length == 1,
        'Código reutilizado.');
    final sessao = await chamar('/sessao', {}, cookies: login.cookies);
    verificar(sessao.status == 200, 'Sessão não criada.');
    banco.versao++;
    final revogada = await chamar('/sessao', {}, cookies: login.cookies);
    verificar(revogada.status == 401, 'Sessão não revogada.');

    instante = instante.add(const Duration(minutes: 1));
    await chamar('/codigo', {'email': endereco});
    final anterior = email.codigo!;
    banco.versao++;
    final alterado =
        await chamar('/entrar', {'email': endereco, 'codigo': anterior});
    verificar(alterado.status == 401 && banco.eventos.length == 1,
        'Código aceito após alteração de permissões.');

    instante = instante.add(const Duration(minutes: 1));
    await chamar('/codigo', {'email': endereco});
    final desativado = email.codigo!;
    banco.ativo = false;
    final inativo =
        await chamar('/entrar', {'email': endereco, 'codigo': desativado});
    verificar(inativo.status == 401, 'Usuário inativo autenticado.');
    instante = instante.add(const Duration(minutes: 1));
    final quantidade = email.enviados.length;
    final semEnvio = await chamar('/codigo', {'email': endereco});
    verificar(semEnvio.status == 200 && email.enviados.length == quantidade,
        'Envio a usuário inativo.');

    banco.ativo = true;
    instante = instante.add(const Duration(minutes: 1));
    email.falhar = true;
    final falha = await chamar('/codigo', {'email': endereco});
    verificar(falha.status == 503, 'Falha de envio ignorada.');
    final cancelado =
        await chamar('/entrar', {'email': endereco, 'codigo': email.codigo!});
    verificar(
        cancelado.status == 401, 'Código do envio malsucedido foi aceito.');
    void conferirSaida(
        ({int status, String corpo, List<Cookie> cookies}) resposta) {
      verificar(resposta.status == 200, 'Logout exigiu uma sessão ativa.');
      verificar(
          resposta.cookies.single.name == 'sei_session' &&
              resposta.cookies.single.maxAge == 0 &&
              resposta.cookies.single.path == '/api',
          'Logout não limpou o cookie da sessão.');
    }

    conferirSaida(await chamar('/logout', {}));
    conferirSaida(await chamar('/logout', {},
        cookies: [Cookie('sei_session', 'sessao-desconhecida')]));
    conferirSaida(await chamar('/logout', {}, cookies: login.cookies));
    verificar(banco.eventos.length == 1,
        'Logout sem sessão gerou auditoria atribuída a usuário.');

    email.falhar = false;
    instante = instante.add(const Duration(minutes: 1));
    await chamar('/codigo', {'email': endereco});
    final novaSessao =
        await chamar('/entrar', {'email': endereco, 'codigo': email.codigo!});
    conferirSaida(await chamar('/logout', {}, cookies: novaSessao.cookies));
    verificar(banco.eventos.last == 'LOGOUT',
        'Logout de sessão válida não foi auditado.');
    verificar(
        (await chamar('/sessao', {}, cookies: novaSessao.cookies)).status ==
            401,
        'Sessão continuou válida após logout.');
    final eventosAposSaida = banco.eventos.length;
    conferirSaida(await chamar('/logout', {}, cookies: novaSessao.cookies));
    verificar(banco.eventos.length == eventosAposSaida,
        'Repetir logout duplicou auditoria.');

    instante = instante.add(const Duration(minutes: 1));
    await chamar('/codigo', {'email': endereco});
    final antesRevogacao =
        await chamar('/entrar', {'email': endereco, 'codigo': email.codigo!});
    banco.versao++;
    conferirSaida(await chamar('/logout', {}, cookies: antesRevogacao.cookies));
    print(
        'Autenticação: códigos, sessão, revogação, SMTP e logout válido/ausente/repetido/revogado: OK (banco e SMTP simulados).');
  } finally {
    cliente.close(force: true);
    await servidor.close(force: true);
  }
}
