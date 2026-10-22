import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sei_validacao_frontend/screens/admin_processamento_screen.dart';
import 'package:sei_validacao_frontend/services/api_service.dart';
import 'package:sei_validacao_frontend/widgets/inicio/indicador_card.dart';

class ApiProcessamento extends ApiService {
  final itens = <Map<String, dynamic>>[
    {
      'id_atribuicao': 1,
      'id_tipo_procedimento': 7,
      'nome': 'Processo A',
      'id_consulta': 1,
      'id_orgao': 0,
      'sigla': 'ORG0',
      'consulta': 'Rodada 1',
      'decisao_tipo': 'MANTER',
      'situacao': 'PENDENTE'
    },
    {
      'id_atribuicao': 2,
      'id_tipo_procedimento': 8,
      'nome': 'Processo B',
      'id_consulta': 1,
      'id_orgao': 0,
      'sigla': 'ORG0',
      'consulta': 'Rodada 1',
      'decisao_tipo': 'DESCONTINUAR',
      'situacao': 'ATUALIZADO',
      'responsavel': 'Admin',
      'data_atualizacao': '2026-10-22T12:00:00Z'
    },
    {
      'id_atribuicao': 3,
      'id_tipo_procedimento': 7,
      'nome': 'Processo A',
      'id_consulta': 1,
      'id_orgao': 9,
      'sigla': 'ORG9',
      'consulta': 'Rodada 1',
      'decisao_tipo': 'MANTER',
      'situacao': 'PENDENTE'
    },
  ];
  @override
  Future<Map<String, dynamic>> profile() async => {
        'sin_admin': 'S',
        'nome': 'Admin',
        'email': 'admin@example.test',
        'orgaos': []
      };
  @override
  Future<List<dynamic>> listarProcessamento() async =>
      itens.map((i) => Map<String, dynamic>.from(i)).toList();
  @override
  Future<void> atualizarProcessamento(int id) async {
    itens.firstWhere((i) => i['id_atribuicao'] == id).addAll({
      'situacao': 'ATUALIZADO',
      'responsavel': 'Admin',
      'data_atualizacao': '2026-10-22T12:00:00Z'
    });
  }
}

void main() {
  Future<void> exibir(WidgetTester tester, ApiProcessamento api,
      {Size tamanho = const Size(1600, 1000)}) async {
    tester.view.physicalSize = tamanho;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester
        .pumpWidget(MaterialApp(home: AdminProcessamentoScreen(api: api)));
    await tester.pumpAndSettle();
  }

  Future<void> filtrar(WidgetTester tester, String titulo) async {
    final card =
        find.byWidgetPredicate((w) => w is IndicadorCard && w.titulo == titulo);
    await tester.ensureVisible(card);
    await tester.tap(card);
    await tester.pumpAndSettle();
  }

  testWidgets('filtros e pesquisa mantêm o contexto e os totais da submissão',
      (tester) async {
    await exibir(tester, ApiProcessamento());
    expect(find.text('Processo A'), findsNWidgets(2));
    await filtrar(tester, 'Atualizados');
    expect(find.text('Processo A'), findsNothing);
    expect(find.text('Processo B'), findsOneWidget);
    expect(find.text('1 de 2 atualizados'), findsOneWidget);
    expect(find.text('Processamento pendente'), findsOneWidget);
    await filtrar(tester, 'Pendentes de atualização');
    expect(find.text('Processo B'), findsNothing);
    expect(find.text('Processo A'), findsNWidgets(2));
    await filtrar(tester, 'Todos');
    await tester.enterText(find.byType(TextField), '8');
    await tester.pumpAndSettle();
    expect(find.text('Processo B'), findsOneWidget);
    expect(find.text('Processo A'), findsNothing);
  });
  testWidgets(
      'marcar atualiza visualmente e conclui apenas a submissão correspondente',
      (tester) async {
    final api = ApiProcessamento();
    await exibir(tester, api);
    final botao = find.text('Marcar como atualizado').first;
    await tester.ensureVisible(botao);
    await tester.tap(botao);
    await tester.pumpAndSettle();
    expect(find.text('2 de 2 atualizados'), findsOneWidget);
    expect(find.text('Processamento concluído'), findsOneWidget);
    expect(find.text('Processamento pendente'), findsOneWidget);
    expect(find.text('Marcar como atualizado'), findsOneWidget);
    expect(api.itens[2]['situacao'], 'PENDENTE');
  });
  testWidgets('largura reduzida mantém tabela rolável sem overflow',
      (tester) async {
    await exibir(tester, ApiProcessamento(), tamanho: const Size(390, 844));
    await tester.drag(find.byType(ListView).last, const Offset(0, -800));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.byType(DataTable), findsNWidgets(2));
  });
  testWidgets('paginação preserva totais completos da submissão',
      (tester) async {
    final api = ApiProcessamento();
    final modelo = Map<String, dynamic>.from(api.itens.first);
    api.itens.clear();
    for (var i = 0; i < 21; i++) {
      api.itens.add({
        ...modelo,
        'id_atribuicao': i + 1,
        'id_tipo_procedimento': i + 100,
        'nome': 'Tipo $i'
      });
    }
    await exibir(tester, api);
    expect(find.text('Tipo 20'), findsNothing);
    expect(find.text('0 de 21 atualizados'), findsOneWidget);
    await tester.dragUntilVisible(find.text('Próxima'),
        find.byType(ListView).last, const Offset(0, -600));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Próxima'));
    await tester.pumpAndSettle();
    expect(find.text('Tipo 20'), findsOneWidget);
    expect(find.text('0 de 21 atualizados'), findsOneWidget);
    expect(find.text('Processamento pendente'), findsOneWidget);
  });
}
