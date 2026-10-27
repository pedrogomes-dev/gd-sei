import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sei_validacao_frontend/screens/admin_processamento_screen.dart';
import 'package:sei_validacao_frontend/services/api_service.dart';
import 'package:sei_validacao_frontend/main.dart';
import 'package:sei_validacao_frontend/widgets/app_shell.dart';
import 'package:sei_validacao_frontend/widgets/display_fields.dart';
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
        <String, dynamic>{
          'id_assunto': 10,
          'codigo_estruturado': '010',
          'descricao': 'Assunto A',
          'acao': 'MANTER'
        },
        <String, dynamic>{
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
    final menu = find.widgetWithText(ListTile, 'Submissões');
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
    expect(find.text('Pendente'), findsWidgets);
    await filtrar(tester, 'Pendentes');
    expect(find.text('ID 8 — Processo B'), findsNothing);
    expect(find.text('ID 7 — Processo A'), findsNWidgets(2));
    await filtrar(tester, 'Todos');
    await tester.enterText(find.byType(TextField), '8');
    await tester.pumpAndSettle();
    expect(find.text('ID 8 — Processo B'), findsOneWidget);
    expect(find.text('ID 7 — Processo A'), findsNothing);
  });
  testWidgets('pareceres consolidam pendente, aprovado, parcial e recusado',
      (tester) async {
    final api = ApiProcessamento();
    await exibir(tester, api);
    final card = find.byKey(const PageStorageKey('avaliacao-1'));
    expect(find.descendant(of: card, matching: find.text('Pendente')),
        findsOneWidget);
    await tester.ensureVisible(card);
    await tester.tap(find.text('ID 7 — Processo A').first);
    await tester.pumpAndSettle();

    void verificarBotoes(int indice, String? parecer) {
      for (final (texto, valor, cor) in [
        ('Adotado', 'ACEITO', Colors.green),
        ('Recusado', 'RECUSADO', Colors.red),
      ]) {
        final botao = tester.widget<OutlinedButton>(find
            .descendant(
                of: card, matching: find.widgetWithText(OutlinedButton, texto))
            .at(indice));
        final estados = <WidgetState>{
          if (botao.onPressed == null) WidgetState.disabled,
        };
        final selecionado = parecer == valor;
        expect(botao.style!.foregroundColor!.resolve(estados),
            selecionado ? cor.shade800 : Colors.grey.shade700);
        expect(botao.style!.backgroundColor!.resolve(estados),
            selecionado ? cor.shade50 : Colors.white);
        expect(botao.style!.side!.resolve(estados)!.color,
            selecionado ? cor.shade400 : Colors.grey.shade300);
      }
    }

    verificarBotoes(0, null);
    verificarBotoes(1, null);
    verificarBotoes(2, null);
    expect(
        find.descendant(
            of: card,
            matching:
                find.byWidgetPredicate((w) => w is StatusTag && w.neutro)),
        findsNWidgets(3));

    Future<void> decidir(String texto, int indice) async {
      final botao = find
          .descendant(
              of: card, matching: find.widgetWithText(OutlinedButton, texto))
          .at(indice);
      await tester.ensureVisible(botao);
      await tester.tap(botao);
      await tester.pumpAndSettle();
    }

    await decidir('Adotado', 0);
    verificarBotoes(0, 'ACEITO');
    verificarBotoes(1, null);
    await decidir('Recusado', 1);
    verificarBotoes(1, 'RECUSADO');
    verificarBotoes(2, null);
    expect(find.descendant(of: card, matching: find.text('Pendente')),
        findsOneWidget);
    await decidir('Adotado', 2);
    expect(find.descendant(of: card, matching: find.text('Parcial')),
        findsOneWidget);
    expect(find.text('3 de 3 avaliadas'), findsOneWidget);
    expect(api.itens.first['parecer_tipo'], 'ACEITO');
    expect((api.itens.first['assuntos'] as List)[1]['acao'], 'REMOVER');
    final selecionado = tester.widget<OutlinedButton>(find
        .descendant(
            of: card, matching: find.widgetWithText(OutlinedButton, 'Adotado'))
        .first);
    expect(selecionado.onPressed, isNull);
    expect(api.itens[2]['parecer_tipo'], isNull);

    api.itens.first['parecer_tipo'] = 'RECUSADO';
    for (final assunto in api.itens.first['assuntos'] as List) {
      assunto['parecer'] = 'RECUSADO';
    }
    await tester.ensureVisible(find.byTooltip('Atualizar'));
    await tester.tap(find.byTooltip('Atualizar'));
    await tester.pumpAndSettle();
    expect(
        find.descendant(
            of: card,
            matching: find.byWidgetPredicate(
                (w) => w is StatusTag && w.status == 'RECUSADO')),
        findsOneWidget);
    expect(
        find.byWidgetPredicate((w) => w is StatusTag && w.status == 'APROVADO'),
        findsOneWidget);
  });

  testWidgets('informações são somente leitura e não expandem o card',
      (tester) async {
    final api = ApiProcessamento();
    final assunto =
        (api.itens.first['assuntos'] as List).first as Map<String, dynamic>;
    assunto.addAll({
      'prazo_corrente': 5,
      'prazo_intermediario': 10,
      'sta_destinacao': 'G'
    });
    api.itens.first['descricao'] = 'Descrição completa do Tipo';
    await exibir(tester, api);
    final card = find.byKey(const PageStorageKey('avaliacao-1'));
    final info = find.descendant(
        of: card, matching: find.byTooltip('Informações do Tipo de Processo'));
    await tester.ensureVisible(info);
    await tester.tap(info);
    await tester.pumpAndSettle();
    expect(find.text('Descrição completa do Tipo'), findsOneWidget);
    await tester.tap(find.byTooltip('Fechar'));
    await tester.pumpAndSettle();
    expect(find.text('Decisão sobre o Tipo'), findsNothing);
    await tester.tap(find.text('ID 7 — Processo A').first);
    await tester.pumpAndSettle();
    final infoAssunto = find.byTooltip('Informações do Assunto').first;
    await tester.ensureVisible(infoAssunto);
    await tester.tap(infoAssunto);
    await tester.pumpAndSettle();
    expect(find.text('Propriedades do Assunto'), findsOneWidget);
    expect(find.text('5 anos'), findsOneWidget);
    expect(find.text('Guarda permanente'), findsOneWidget);
    await tester.tap(find.byTooltip('Fechar'));
    await tester.pumpAndSettle();
    expect(find.text('Decisão sobre o Tipo'), findsOneWidget);
    expect(api.itens.first['parecer_tipo'], isNull);
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
  for (final largura in [320.0, 800.0, 1600.0]) {
    testWidgets('alinhamento e agrupamento em $largura px', (tester) async {
      final api = ApiProcessamento();
      // Um Tipo permite inspecionar o bloco inteiro sem outros grupos.
      api.itens.removeRange(1, api.itens.length);
      api.itens.first['assuntos'] = <dynamic>[];
      api.itens.first['justificativa_tipo'] = 'Observação do órgão';
      await exibir(tester, api, tamanho: Size(largura, 1000));
      final card = find.byKey(const PageStorageKey('avaliacao-1'));
      await tester.dragUntilVisible(
          card, find.byType(ListView).last, const Offset(0, -300));
      await tester.pumpAndSettle();
      final contador =
          find.descendant(of: card, matching: find.text('0 de 1 avaliadas'));
      final status =
          find.descendant(of: card, matching: find.byType(StatusTag));
      expect(tester.getRect(status).right,
          greaterThan(tester.getRect(contador).right));
      final titulo = find.text('ID 7 — Processo A');
      await Scrollable.ensureVisible(tester.element(titulo), alignment: 0.5);
      await tester.tap(titulo);
      await tester.pumpAndSettle();
      final orgao = tester.getRect(find.text('Órgão:'));
      final parecer = tester.getRect(find.text('Parecer:'));
      if (largura >= 800) {
        expect(orgao.center.dy, closeTo(parecer.center.dy, 1));
        expect(parecer.left, greaterThan(orgao.right));
      } else {
        expect(parecer.top, greaterThan(orgao.bottom));
      }
      final adotado = find.widgetWithText(OutlinedButton, 'Adotado');
      final recusado = find.widgetWithText(OutlinedButton, 'Recusado');
      if (largura >= 800) {
        expect(tester.getRect(adotado).top, tester.getRect(recusado).top);
      }
      expect(tester.getRect(find.text('Observação do órgão')).top,
          greaterThan(tester.getRect(recusado).bottom));
      await tester.dragUntilVisible(adotado.hitTestable(),
          find.byType(ListView).last, const Offset(0, -100));
      await tester.pumpAndSettle();
      await tester.tap(adotado);
      await tester.pumpAndSettle();
      expect(api.itens.first['parecer_tipo'], 'ACEITO');
      final metadados = find.textContaining('Admin ·');
      expect(tester.widget<Text>(metadados).textAlign, TextAlign.right);
      expect(find.text('Data indisponível'), findsNothing);
      await tester.dragUntilVisible(titulo.hitTestable(),
          find.byType(ListView).last, const Offset(0, 100));
      await tester.pumpAndSettle();
      await tester.tap(titulo);
      await tester.pumpAndSettle();
      expect(find.text('Órgão:'), findsNothing);
      await tester.tap(titulo);
      await tester.pumpAndSettle();
      expect(find.text('Órgão:'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
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
    expect(find.text('Pendente'), findsWidgets);
  });
}
