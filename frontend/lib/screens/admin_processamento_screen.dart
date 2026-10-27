import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../widgets/app_shell.dart';
import '../widgets/display_fields.dart';
import '../widgets/inicio/indicador_card.dart';
import '../widgets/propriedades_processo.dart';
import '../widgets/manifestacao/informacoes_assunto_dialog.dart';

class AdminProcessamentoScreen extends StatefulWidget {
  final ApiService? api;
  const AdminProcessamentoScreen({super.key, this.api});

  @override
  State<AdminProcessamentoScreen> createState() =>
      _AdminProcessamentoScreenState();
}

class _AdminProcessamentoScreenState extends State<AdminProcessamentoScreen> {
  late final api = widget.api ?? ApiService();
  final pesquisa = TextEditingController();
  final rolagem = ScrollController();
  List<dynamic> itens = [];
  bool carregando = true;
  bool salvando = false;
  String? erro;
  String filtro = 'TODOS';
  String busca = '';
  int pagina = 0;
  static const porPagina = 20;

  @override
  void initState() {
    super.initState();
    carregar();
  }

  @override
  void dispose() {
    pesquisa.dispose();
    rolagem.dispose();
    super.dispose();
  }

  Future<void> carregar() async {
    setState(() {
      carregando = true;
      erro = null;
    });
    try {
      final resultado = await api.listarProcessamento();
      if (mounted) setState(() => itens = resultado);
    } catch (e) {
      if (mounted)
        setState(() {
          erro = e.toString();
          itens = [];
        });
    } finally {
      if (mounted) setState(() => carregando = false);
    }
  }

  Future<void> avaliar(dynamic item, String parecer, {int? idAssunto}) async {
    setState(() {
      salvando = true;
      erro = null;
    });
    try {
      await api.avaliarProcessamento(
          int.parse(item['id_atribuicao'].toString()), parecer,
          idAssunto: idAssunto);
      final resultado = await api.listarProcessamento();
      if (mounted) setState(() => itens = resultado);
    } catch (e) {
      if (mounted) setState(() => erro = e.toString());
    } finally {
      if (mounted) setState(() => salvando = false);
    }
  }

  String grupo(dynamic item) => '${item['id_consulta']}/${item['id_orgao']}';
  bool concluido(dynamic item) => item['situacao'] == 'CONCLUIDO';

  List<dynamic> pesquisados() => itens.where((item) {
        final texto =
            '${item['id_tipo_procedimento']} ${item['nome']}'.toLowerCase();
        return texto.contains(busca.toLowerCase());
      }).toList();

  Widget filtros(List<dynamic> encontrados) {
    final opcoes = [
      (
        'TODOS',
        'Todos',
        encontrados.length,
        Icons.list_alt,
        Colors.blue.shade800
      ),
      (
        'PENDENTE',
        'Pendentes',
        encontrados.where((item) => !concluido(item)).length,
        Icons.pending_actions,
        Colors.amber.shade900
      ),
      (
        'CONCLUIDO',
        'Concluídos',
        encontrados.where(concluido).length,
        Icons.task_alt,
        Colors.green.shade800
      ),
    ];
    return SectionCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      TextField(
          controller: pesquisa,
          maxLength: 250,
          decoration: const InputDecoration(
              labelText: 'Buscar por nome ou ID do Tipo de Processo',
              prefixIcon: Icon(Icons.search)),
          onChanged: salvando
              ? null
              : (valor) => setState(() {
                    busca = valor.trim();
                    pagina = 0;
                  })),
      const SizedBox(height: 16),
      LayoutBuilder(builder: (context, tamanho) {
        final colunas = tamanho.maxWidth >= 700 ? 3 : 1;
        final largura = (tamanho.maxWidth - (colunas - 1) * 12) / colunas;
        return Wrap(spacing: 12, runSpacing: 12, children: [
          for (final opcao in opcoes)
            SizedBox(
                width: largura,
                child: IndicadorCard(
                    titulo: opcao.$2,
                    quantidade: opcao.$3,
                    icone: opcao.$4,
                    cor: opcao.$5,
                    selecionado: filtro == opcao.$1,
                    aoSelecionar: salvando
                        ? null
                        : () => setState(() {
                              filtro = opcao.$1;
                              pagina = 0;
                            }))),
        ]);
      }),
    ]));
  }

  String dadosAvaliacao(dynamic item) {
    final data =
        DateTime.tryParse(item['data_avaliacao']?.toString() ?? '')?.toLocal();
    final quando = data == null
        ? ''
        : '${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}/${data.year} ${data.hour.toString().padLeft(2, '0')}:${data.minute.toString().padLeft(2, '0')}';
    return [item['responsavel']?.toString().trim() ?? '', quando]
        .where((texto) => texto.isNotEmpty)
        .join(' · ');
  }

  List<dynamic> pareceres(dynamic item) => [
        if (item['decisao_tipo'] != null) item['parecer_tipo'],
        for (final assunto in item['assuntos'] as List? ?? [])
          assunto['parecer'],
      ];

  Widget aprovacao(List<dynamic> valores) {
    if (valores.isEmpty || valores.any((valor) => valor == null)) {
      return const StatusTag('APROVACAO_PENDENTE');
    }
    if (valores.every((valor) => valor == 'ACEITO')) {
      return const StatusTag('APROVADO');
    }
    if (valores.every((valor) => valor == 'RECUSADO')) {
      return const StatusTag('RECUSADO');
    }
    return const StatusTag('PARCIAL');
  }

  Widget decisao(String? valor) {
    // Somente apresentação: os valores originais dos vínculos são preservados.
    final estado = switch (valor) {
      'REMOVER' => 'DESCONTINUAR',
      'ADICIONAR' => 'MANTER',
      _ => valor,
    };
    if (estado == null) return const Text('Decisão não informada');
    return StatusTag(estado, neutro: true);
  }

  void informar(dynamic item, {dynamic assunto}) {
    showDialog<void>(
      context: context,
      builder: (context) {
        if (assunto != null) {
          return InformacoesAssuntoDialog(
              assunto: Map<String, dynamic>.from(assunto as Map));
        }
        return SelectionArea(
          child: AlertDialog(
            title: Row(children: [
              const Expanded(child: Text('Propriedades do Tipo de Processo')),
              IconButton(
                  tooltip: 'Fechar',
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context)),
            ]),
            content: SizedBox(
              width: 760,
              child: SingleChildScrollView(
                child: PropriedadesProcesso(
                    processo: Map<String, dynamic>.from(item as Map)),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget parecer(dynamic tipo, Map<String, dynamic> avaliacao,
      {required String? decisaoOrgao, String? observacao, int? idAssunto}) {
    final valor = avaliacao['parecer'];
    final metadados = dadosAvaliacao(avaliacao);
    Widget botao(
        String opcao, String texto, MaterialColor cor, IconData icone) {
      final selecionado = valor == opcao;
      return OutlinedButton.icon(
        // O backend permite registrar, mas não substituir um parecer.
        onPressed: salvando || valor != null
            ? null
            : () => avaliar(tipo, opcao, idAssunto: idAssunto),
        icon: Icon(icone),
        label: Text(texto),
        style: OutlinedButton.styleFrom(
          foregroundColor: selecionado ? cor.shade800 : Colors.grey.shade700,
          disabledForegroundColor:
              selecionado ? cor.shade800 : Colors.grey.shade700,
          backgroundColor: selecionado ? cor.shade50 : Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          side: BorderSide(
              color: selecionado ? cor.shade400 : Colors.grey.shade300),
        ),
      );
    }

    final orgao = Wrap(
        spacing: 8,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [const Text('Órgão:'), decisao(decisaoOrgao)]);
    final botoes = [
      botao('ACEITO', 'Adotado', Colors.green, Icons.check_circle_outline),
      botao('RECUSADO', 'Recusado', Colors.red, Icons.cancel_outlined),
    ];
    final acoes = Wrap(
        alignment: WrapAlignment.end,
        spacing: 8,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          const Text('Parecer:'),
          ...botoes,
        ]);
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      LayoutBuilder(builder: (context, tamanho) {
        if (tamanho.maxWidth <
            600 * MediaQuery.textScalerOf(context).scale(1)) {
          return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                orgao,
                if (decisaoOrgao != null) ...[
                  const SizedBox(height: 8),
                  const Align(
                      alignment: Alignment.centerRight,
                      child: Text('Parecer:')),
                  const SizedBox(height: 4),
                  Wrap(
                      alignment: WrapAlignment.end,
                      spacing: 8,
                      runSpacing: 8,
                      children: botoes),
                ],
              ]);
        }
        return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: orgao),
              if (decisaoOrgao != null) ...[
                const SizedBox(width: 16),
                acoes,
              ],
            ]);
      }),
      if (observacao != null && observacao.trim().isNotEmpty) ...[
        const SizedBox(height: 8),
        Text(observacao,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade700)),
      ],
      if (valor != null && metadados.isNotEmpty) ...[
        const SizedBox(height: 8),
        Text(metadados,
            textAlign: TextAlign.right,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
      ],
    ]);
  }

  Widget processo(dynamic item) {
    final assuntos = item['assuntos'] as List? ?? [];
    final valores = pareceres(item);
    return Card(
      color: Colors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        key: PageStorageKey('avaliacao-${item['id_atribuicao']}'),
        shape: const Border(),
        collapsedShape: const Border(),
        title: LayoutBuilder(builder: (context, tamanho) {
          final identificacao = Row(children: [
            IconButton(
                tooltip: 'Informações do Tipo de Processo',
                icon: const Icon(Icons.info_outline),
                onPressed: () => informar(item)),
            Expanded(
                child: Text(
                    'ID ${item['id_tipo_procedimento']} — ${item['nome']}')),
          ]);
          final contador = Text(
              '${valores.where((valor) => valor != null).length} de ${valores.length} avaliadas',
              style: Theme.of(context).textTheme.bodySmall);
          if (tamanho.maxWidth <
              420 * MediaQuery.textScalerOf(context).scale(1)) {
            return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  identificacao,
                  Row(children: [
                    Expanded(child: contador),
                    const SizedBox(width: 8),
                    Expanded(
                        flex: 2,
                        child: Align(
                            alignment: Alignment.centerRight,
                            child: aprovacao(valores))),
                  ]),
                ]);
          }
          return Row(children: [
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  identificacao,
                  contador,
                ])),
            const SizedBox(width: 8),
            aprovacao(valores),
          ]);
        }),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Divider(height: 1),
                  const SizedBox(height: 16),
                  const Text('Decisão sobre o Tipo',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  parecer(
                      item,
                      {
                        'parecer': item['parecer_tipo'],
                        'responsavel': item['responsavel_tipo'],
                        'data_avaliacao': item['data_avaliacao_tipo'],
                      },
                      decisaoOrgao: item['decisao_tipo'] as String?,
                      observacao: item['justificativa_tipo']?.toString()),
                  const Divider(height: 32),
                  const Text('Assuntos',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  if (assuntos.isEmpty)
                    const Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: Text(
                            'Sem decisões sobre Assuntos nesta submissão.')),
                  for (var i = 0; i < assuntos.length; i++) ...[
                    if (i > 0) const Divider(height: 24),
                    Row(children: [
                      IconButton(
                          tooltip: 'Informações do Assunto',
                          icon: const Icon(Icons.info_outline),
                          onPressed: () =>
                              informar(item, assunto: assuntos[i])),
                      Expanded(
                          child: Text(
                              '${assuntos[i]['codigo_estruturado']} — ${assuntos[i]['descricao']}')),
                    ]),
                    parecer(item, Map<String, dynamic>.from(assuntos[i] as Map),
                        decisaoOrgao: assuntos[i]['acao'] as String?,
                        observacao: assuntos[i]['justificativa']?.toString(),
                        idAssunto:
                            int.parse(assuntos[i]['id_assunto'].toString())),
                  ],
                ]),
          ),
        ],
      ),
    );
  }

  Widget submissao(List<dynamic> linhas) {
    final primeiro = linhas.first;
    final todos =
        itens.where((item) => grupo(item) == grupo(primeiro)).toList();
    final concluidos = todos.where(concluido).length;

    return SectionCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('${primeiro['sigla']} — ${primeiro['consulta']}',
          style: Theme.of(context).textTheme.titleLarge),
      const SizedBox(height: 8),
      Text(
          'Submissão ${primeiro['id_consulta']}/${primeiro['id_orgao']} · Manifestação finalizada'),
      const SizedBox(height: 12),
      Wrap(
          spacing: 16,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text('$concluidos de ${todos.length} Tipos avaliados'),
            aprovacao(todos.expand(pareceres).toList()),
            TextButton(
                onPressed: () => Navigator.pushNamed(context,
                    '/resumo?consulta=${primeiro['id_consulta']}&orgao=${primeiro['id_orgao']}'),
                child: const Text('Consultar')),
          ]),
      Text(
          'Exibindo ${linhas.length} de ${todos.length} itens desta submissão nesta página.'),
      const SizedBox(height: 16),
      for (final item in linhas) processo(item),
    ]));
  }

  Widget resultados(List<dynamic> encontrados) {
    final filtrados = encontrados
        .where((item) => filtro == 'TODOS' || item['situacao'] == filtro)
        .toList();
    if (filtrados.isEmpty)
      return const Text(
          'Nenhum Tipo de Processo encontrado nas submissões finalizadas.');
    final ultima = (filtrados.length - 1) ~/ porPagina;
    final atual = pagina.clamp(0, ultima);
    final inicio = atual * porPagina;
    final visiveis = filtrados.skip(inicio).take(porPagina);
    final grupos = <String, List<dynamic>>{};
    for (final item in visiveis) {
      grupos.putIfAbsent(grupo(item), () => []).add(item);
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      for (final linhas in grupos.values) submissao(linhas),
      Wrap(
          spacing: 16,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
                'Página ${atual + 1} de ${ultima + 1} · ${filtrados.length} Tipos de Processo'),
            TextButton(
                onPressed: salvando || atual == 0
                    ? null
                    : () => mudarPagina(atual - 1),
                child: const Text('Anterior')),
            TextButton(
                onPressed: salvando || atual == ultima
                    ? null
                    : () => mudarPagina(atual + 1),
                child: const Text('Próxima')),
          ]),
    ]);
  }

  void mudarPagina(int valor) {
    setState(() => pagina = valor);
    if (rolagem.hasClients) rolagem.jumpTo(0);
  }

  @override
  Widget build(BuildContext context) => AppShell(
        api: api,
        title: 'Processamento das Submissões',
        section: 'admin-processamento',
        trail: const ['Processamento das Submissões'],
        actions: [
          IconButton(
              onPressed: carregando || salvando ? null : carregar,
              tooltip: 'Atualizar',
              icon: const Icon(Icons.refresh))
        ],
        child: ListView(
            controller: rolagem,
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            children: [
              const Text(
                  'Consulte as decisões dos órgãos e registre o parecer administrativo: Adotado ou Recusado.'),
              const SizedBox(height: 16),
              if (erro != null)
                SectionCard(
                    child: Column(children: [
                  Text(erro!),
                  TextButton(
                      onPressed: carregar,
                      child: const Text('Tentar novamente'))
                ])),
              if (carregando)
                const LinearProgressIndicator()
              else ...[filtros(pesquisados()), resultados(pesquisados())],
            ]),
      );
}
