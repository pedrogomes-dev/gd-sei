import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sei_validacao_frontend/widgets/admin/tipo_orgaos_editor.dart';

void main() {
  const orgaos = [
    {'id_orgao': 0, 'sigla': 'ORG ZERO'},
    {'id_orgao': 9, 'sigla': 'ORG NOVE'},
    {'id_orgao': 12, 'sigla': 'ORG DOZE'},
  ];

  Future<void> abrir(
    WidgetTester tester, {
    required Future<void> Function(List<int>) salvar,
    Set<int> vinculados = const {0},
    TextScaler escala = TextScaler.noScaling,
    bool emLote = false,
  }) async {
    await tester.pumpWidget(MaterialApp(
        builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(textScaler: escala),
            child: child!),
        home: Scaffold(body: Builder(builder: (context) {
          return TextButton(
              onPressed: () => showDialog<bool>(
                    context: context,
                    barrierDismissible: false,
                    builder: (_) => TipoOrgaosEditor(
                        nomeTipo: 'Tipo de teste',
                        orgaos: orgaos,
                        vinculados: vinculados,
                        emLote: emLote,
                        salvar: salvar),
                  ),
              child: const Text('Abrir'));
        }))));
    await tester.tap(find.text('Abrir'));
    await tester.pumpAndSettle();
  }

  testWidgets('adiciona múltiplos órgãos e preserva seleção fora da busca',
      (tester) async {
    List<int>? gravados;
    await abrir(tester, salvar: (ids) async => gravados = ids);
    await tester.tap(find.text('ORG NOVE'));
    await tester.enterText(find.byType(TextField), 'DOZE');
    await tester.pump();
    await tester.tap(find.text('ORG DOZE'));
    await tester.pump();
    expect(find.text('3 órgãos selecionados'), findsOneWidget);
    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();
    expect(gravados, [0, 9, 12]);
    expect(find.byType(AlertDialog), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('permite remover todos e cancelar não grava', (tester) async {
    var chamadas = 0;
    List<int>? gravados;
    final originais = {0};
    await abrir(tester, vinculados: originais, salvar: (ids) async {
      chamadas++;
      gravados = ids;
    });
    await tester.tap(find.text('ORG ZERO'));
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();
    expect(chamadas, 0);
    expect(originais, {0});
    await tester.tap(find.text('Abrir'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('ORG ZERO'));
    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();
    expect(gravados, isEmpty);
    expect(chamadas, 1);
  });

  testWidgets('diálogo cabe em tela estreita com texto ampliado',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(360, 640));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await abrir(tester,
        escala: const TextScaler.linear(1.6), salvar: (_) async {});
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.text('Salvar'), findsOneWidget);
    expect(find.text('Cancelar'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('conflito mantém diálogo e seleção para conferência',
      (tester) async {
    await abrir(tester,
        salvar: (_) async => throw Exception(
            'Os vínculos foram alterados. Atualize a listagem.'));
    await tester.tap(find.text('ORG NOVE'));
    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Os vínculos foram alterados'), findsOneWidget);
    expect(find.text('2 órgãos selecionados'), findsOneWidget);
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('lote exige órgão e permite escolher vários sem seleção inicial',
      (tester) async {
    List<int>? gravados;
    await abrir(tester,
        emLote: true, vinculados: {}, salvar: (ids) async => gravados = ids);
    expect(find.textContaining('Os vínculos atuais serão preservados'),
        findsOneWidget);
    await tester.tap(find.text('Vincular'));
    await tester.pumpAndSettle();
    expect(find.text('Selecione ao menos um órgão.'), findsOneWidget);
    expect(gravados, isNull);
    await tester.tap(find.text('ORG ZERO'));
    await tester.tap(find.text('ORG NOVE'));
    await tester.tap(find.text('Vincular'));
    await tester.pumpAndSettle();
    expect(gravados, [0, 9]);
    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets('falha no lote mantém órgãos selecionados para nova tentativa',
      (tester) async {
    await abrir(tester,
        emLote: true,
        vinculados: {},
        salvar: (_) async => throw Exception('Lote não gravado.'));
    await tester.tap(find.text('ORG ZERO'));
    await tester.tap(find.text('Vincular'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Lote não gravado'), findsOneWidget);
    expect(find.text('1 órgãos selecionados'), findsOneWidget);
    expect(find.byType(AlertDialog), findsOneWidget);
  });
}
