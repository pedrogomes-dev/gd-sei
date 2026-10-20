import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sei_validacao_frontend/widgets/manifestacao/busca_assuntos.dart';

void main() {
  const mensagem =
      'Item apenas estrutural. Não pode ser vinculado a Tipos de Processo.';

  for (final estrutural in ['S', 'N']) {
    testWidgets('Assunto $estrutural: seleção, propriedades e informação',
        (tester) async {
      var inclusoes = 0;
      final pesquisa = TextEditingController();
      await tester.pumpWidget(MaterialApp(
          home: Scaffold(
              body: SingleChildScrollView(
        child: BuscaAssuntos(
          pesquisa: pesquisa,
          resultados: [
            {
              'id_assunto': 1,
              'codigo_estruturado': '085',
              'descricao': 'Assunto pai',
              'sin_estrutural': estrutural,
              'id_assunto_pai': null,
              'observacao': 'Observação',
            }
          ],
          inclusoes: {},
          carregando: false,
          salvando: false,
          temProximaPagina: true,
          pesquisaRealizada: true,
          erro: null,
          pesquisar: (_) {},
          proporInclusao: (_) => inclusoes++,
        ),
      ))));

      final botao = tester.widget<ElevatedButton>(
          find.widgetWithText(ElevatedButton, 'Propor inclusão'));
      if (estrutural == 'S') {
        expect(botao.onPressed, isNull);
        expect(find.byIcon(Icons.account_tree_outlined), findsOneWidget);
        await tester.tap(find.byIcon(Icons.account_tree_outlined));
        await tester.pumpAndSettle();
        expect(find.text(mensagem), findsOneWidget);
      } else {
        expect(botao.onPressed, isNotNull);
        expect(find.byIcon(Icons.account_tree_outlined), findsNothing);
        await tester.tap(find.text('Propor inclusão'));
        expect(inclusoes, 1);
      }
      // O título continua expandindo mesmo quando o ícone é estrutural.
      await tester.tap(find.text('Propriedades do Assunto'));
      await tester.pumpAndSettle();
      expect(find.text('Estrutural'), findsOneWidget);
      expect(find.text('Próxima página'), findsOneWidget);
      await tester.pumpWidget(const SizedBox.shrink());
      pesquisa.dispose();
    });
  }
}
