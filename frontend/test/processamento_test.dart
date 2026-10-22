import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sei_validacao_frontend/screens/admin_processamento_screen.dart';
import 'package:sei_validacao_frontend/services/api_service.dart';
import 'package:sei_validacao_frontend/main.dart';
import 'package:sei_validacao_frontend/widgets/app_shell.dart';
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
      'situacao': 'PENDENTE',
      'assuntos': [
        {
          'id_assunto': 10,
          'codigo_estruturado': '010',
          'descricao': 'Assunto A',
          'acao': 'MANTER'
        },
        {
          'id_assunto': 11,
          'codigo_estruturado': '011',
          'descricao': 'Assunto B',
          'acao': 'REMOVER'
        },
      ],
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
      'parecer_tipo': 'ACEITO',
      'responsavel_tipo': 'Admin',
      'data_avaliacao_tipo': '2026-10-22T12:00:00Z'
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
  Future<List<dynamic>> listarProcessamento() async => itens.map((i) {
        final assuntos = i['assuntos'] as List? ?? [];
        final avaliados = assuntos.where((s) => s['parecer'] != null).length +
            (i['parecer_tipo'] == null ? 0 : 1);
        final completo = avaliados == assuntos.length + 1;
        final parcial = i['parecer_tipo'] == 'RECUSADO' ||
            assuntos.any((s) => s['parecer'] == 'RECUSADO');
        var resultado = completo ? 'ACEITO' : 'PENDENTE';
        if (parcial) resultado = 'PARCIALMENTE_ACEITO';
        return {
          ...i,
          'avaliados': avaliados,
          'total_avaliacoes': assuntos.length + 1,
          'situacao': completo ? 'CONCLUIDO' : 'PENDENTE',
          'resultado': resultado
        };
      }).toList();
  @override
  Future<void> avaliarProcessamento(int id, String parecer,
      {int? idAssunto}) async {
    final tipo = itens.firstWhere((i) => i['id_atribuicao'] == id);
    if (idAssunto == null) {
      tipo.addAll({
        'parecer_tipo': parecer,
        'responsavel_tipo': 'Admin',
        'data_avaliacao_tipo': '2026-10-22T12:00:00Z'
      });
      return;
    }
    (tipo['assuntos'] as List)
        .firstWhere((s) => s['id_assunto'] == idAssunto)
        .addAll({
      'parecer': parecer,
      'responsavel': 'Admin',
      'data_avaliacao': '2026-10-22T12:00:00Z'
    });
  }
}

void main() {
  testWidgets('rota principal aponta para a tela de processamento',
      (tester) async {
    await tester.pumpWidget(MaterialApp(home: Builder(builder: (context) {
      final app = const SeiApp().build(context) as MaterialApp;
      final rota = app.onGenerateRoute!(
              const RouteSettings(name: '/admin/processamento'))
          as MaterialPageRoute<void>;
      final area = rota.builder(context) as SelectionArea;
      expect(area.child, isA<AdminProcessamentoScreen>());
      return const SizedBox.shrink();
    })));
  });

  testWidgets('administrador abre processamento pelo menu', (tester) async {
    final api = ApiProcessamento();
    tester.view.physicalSize = const Size(1600, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(MaterialApp(
      home: AppShell(title: 'Início', api: api, child: const SizedBox.shrink()),
      routes: {
        '/admin/processamento': (_) => AdminProcessamentoScreen(api: api)
      },
    ));
    await tester.pumpAndSettle();
    final menu = find.widgetWithText(ListTile, 'Processamento das submissões');
    await tester.ensureVisible(menu);
    await tester.tap(menu);
    await tester.pumpAndSettle();
    expect(find.byType(AdminProcessamentoScreen), findsOneWidget);
    expect(find.text('ID 7 — Processo A'), findsNWidgets(2));
  });

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
    expect(find.text('ID 7 — Processo A'), findsNWidgets(2));
    await filtrar(tester, 'Concluídos');
    expect(find.text('ID 7 — Processo A'), findsNothing);
    expect(find.text('ID 8 — Processo B'), findsOneWidget);
    expect(find.text('1 de 2 Tipos avaliados'), findsOneWidget);
    expect(find.text('Processamento pendente'), findsOneWidget);
    await filtrar(tester, 'Pendentes de avaliação');
    expect(find.text('ID 8 — Processo B'), findsNothing);
    expect(find.text('ID 7 — Processo A'), findsNWidgets(2));
    await filtrar(tester, 'Todos');
    await tester.enterText(find.byType(TextField), '8');
    await tester.pumpAndSettle();
    expect(find.text('ID 8 — Processo B'), findsOneWidget);
    expect(find.text('ID 7 — Processo A'), findsNothing);
  });
  testWidgets(
      'aceite individual conclui somente após todos os pareceres e propaga recusa',
      (tester) async {
    final api = ApiProcessamento();
    await exibir(tester, api);
    final titulo = find.text('ID 7 — Processo A').first;
    await tester.ensureVisible(titulo);
    await tester.tap(titulo);
    await tester.pumpAndSettle();
    Future<void> decidir(String texto) async {
      final botao = find.text(texto).first;
      await tester.ensureVisible(botao);
      await tester.tap(botao);
      await tester.pumpAndSettle();
    }

    await decidir('Aceitar'); // Tipo
    expect(find.text('Processamento concluído'), findsNothing);
    await decidir('Recusar'); // Assunto A
    expect(find.text('Parcialmente aceito'), findsOneWidget);
    expect(find.text('Parcialmente aceita'), findsOneWidget);
    expect(find.text('Processamento concluído'), findsNothing);
    await decidir('Aceitar'); // Assunto B
    expect(find.text('2 de 2 Tipos avaliados'), findsOneWidget);
    expect(find.text('Processamento concluído'), findsOneWidget);
    expect(find.text('Processamento pendente'), findsOneWidget);
    expect(find.text('Parcialmente aceita'), findsOneWidget);
    expect(api.itens[2]['parecer_tipo'], isNull);
    expect(find.text('Aceitar'), findsNothing);
  });
  testWidgets('largura reduzida mantém avaliação sem overflow', (tester) async {
    await exibir(tester, ApiProcessamento(), tamanho: const Size(390, 844));
    await tester.drag(find.byType(ListView).last, const Offset(0, -800));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    final titulo = find.text('ID 7 — Processo A').first;
    await tester.ensureVisible(titulo);
    await tester.tap(titulo);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.byType(ExpansionTile), findsNWidgets(3));
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
    expect(find.text('ID 120 — Tipo 20'), findsNothing);
    expect(find.text('0 de 21 Tipos avaliados'), findsOneWidget);
    await tester.dragUntilVisible(find.text('Próxima'),
        find.byType(ListView).last, const Offset(0, -600));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Próxima'));
    await tester.pumpAndSettle();
    expect(find.text('ID 120 — Tipo 20'), findsOneWidget);
    expect(find.text('0 de 21 Tipos avaliados'), findsOneWidget);
    expect(find.text('Processamento pendente'), findsOneWidget);
  });
}
