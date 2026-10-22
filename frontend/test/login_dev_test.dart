import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sei_validacao_frontend/screens/login_screen.dart';
import 'package:sei_validacao_frontend/services/api_service.dart';

class ApiTeste extends ApiService {
  final bool habilitado;
  final List<dynamic> usuarios;
  int? escolhido;
  ApiTeste(
      {this.habilitado = true,
      this.usuarios = const [
        {'id_usuario': 1, 'nome': 'Comum', 'email': 'comum@example.test'},
        {'id_usuario': 2, 'nome': 'Admin', 'email': 'admin@example.test'},
      ]});
  @override
  Future<Map<String, dynamic>> configurarAcesso() async => {
        'acesso_temporario': habilitado,
        if (habilitado) 'usuarios': usuarios,
      };
  @override
  Future<void> loginDesenvolvimento(int idUsuario) async {
    escolhido = idUsuario;
  }
}

class ApiContrato extends ApiService {
  String? caminho;
  Map<String, dynamic>? dados;

  @override
  Future<dynamic> request(String path,
      {Map<String, dynamic>? data,
      Duration timeout = const Duration(seconds: 20)}) async {
    caminho = path;
    dados = data;
    return {};
  }
}

void main() {
  test('cliente envia o usuário selecionado para o login de desenvolvimento',
      () async {
    final api = ApiContrato();
    await api.loginDesenvolvimento(2);
    expect(api.caminho, '/api/auth/dev');
    expect(api.dados, {'id_usuario': 2, 'token': '123456'});
  });

  Future<void> exibir(WidgetTester tester, ApiTeste api) async {
    await tester.pumpWidget(MaterialApp(home: LoginScreen(api: api), routes: {
      '/inicio': (_) => const Scaffold(body: Text('Início do teste')),
    }));
    await tester.pumpAndSettle();
  }

  testWidgets('ambiente normal mantém e-mail e não mostra personificação',
      (tester) async {
    await exibir(tester, ApiTeste(habilitado: false));
    expect(find.text('E-mail cadastrado'), findsOneWidget);
    expect(find.text('Receber código'), findsOneWidget);
    expect(find.byType(DropdownButtonFormField<int>), findsNothing);
    expect(find.text('Entrar como usuário selecionado'), findsNothing);
  });
  testWidgets('exige escolha e envia o ID selecionado', (tester) async {
    final api = ApiTeste();
    await exibir(tester, api);
    final entrar =
        find.widgetWithText(TextButton, 'Entrar como usuário selecionado');
    expect(tester.widget<TextButton>(entrar).onPressed, isNull);
    await tester.ensureVisible(find.byType(DropdownButtonFormField<int>));
    await tester.tap(find.byType(DropdownButtonFormField<int>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Admin — admin@example.test').last);
    await tester.pumpAndSettle();
    await tester.ensureVisible(entrar);
    await tester.tap(entrar);
    await tester.pumpAndSettle();
    expect(api.escolhido, 2);
    expect(find.text('Início do teste'), findsOneWidget);
  });
  testWidgets('lista vazia não permite entrar', (tester) async {
    await exibir(tester, ApiTeste(usuarios: const []));
    expect(find.text('Nenhum usuário ativo disponível.'), findsOneWidget);
    expect(
        tester
            .widget<TextButton>(find.widgetWithText(
                TextButton, 'Entrar como usuário selecionado'))
            .onPressed,
        isNull);
  });
}
