import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sei_validacao_frontend/services/api_exception.dart';
import 'package:sei_validacao_frontend/widgets/display_fields.dart';

void main() {
  Future<void> abrir(
      WidgetTester tester, Object erro, VoidCallback repetir) async {
    await tester.pumpWidget(MaterialApp(
      initialRoute: '/origem',
      routes: {
        '/': (_) => const Scaffold(),
        '/origem': (context) => Scaffold(
                body: TextButton(
              onPressed: () => Navigator.pushNamed(context, '/erro'),
              child: const Text('Abrir'),
            )),
        '/erro': (_) => Scaffold(
            body:
                Center(child: ApiErrorMessage(error: erro, onRetry: repetir))),
        '/login': (_) => const Scaffold(body: Text('Login')),
      },
    ));
    await tester.tap(find.text('Abrir'));
    await tester.pumpAndSettle();
  }

  testWidgets('401 abre login e remove as rotas protegidas da pilha',
      (tester) async {
    var tentativas = 0;
    await abrir(
        tester, const ApiException(401, 'Faça login'), () => tentativas++);
    await tester.tap(find.text('Tentar novamente'));
    await tester.pumpAndSettle();
    expect(find.text('Login'), findsOneWidget);
    expect(tentativas, 0);
    expect(Navigator.of(tester.element(find.text('Login'))).canPop(), isFalse);
  });

  for (final erro in [
    const ApiException(403, 'Sem permissão'),
    const ApiException(500, 'Erro interno'),
    Exception('Falha de conexão')
  ]) {
    testWidgets('$erro repete a operação sem abrir login', (tester) async {
      var tentativas = 0;
      await abrir(tester, erro, () => tentativas++);
      await tester.tap(find.text('Tentar novamente'));
      await tester.pumpAndSettle();
      expect(tentativas, 1);
      expect(find.text('Login'), findsNothing);
      expect(find.text(erro.toString()), findsOneWidget);
    });
  }
}
