import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../widgets/app_shell.dart';
import '../widgets/display_fields.dart';
import '../widgets/inicio/indicador_card.dart';

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

  Future<void> atualizar(dynamic item) async {
    setState(() {
      salvando = true;
      erro = null;
    });
    try {
      await api
          .atualizarProcessamento(int.parse(item['id_atribuicao'].toString()));
      await carregar();
    } catch (e) {
      if (mounted) setState(() => erro = e.toString());
    } finally {
      if (mounted) setState(() => salvando = false);
    }
  }

  String grupo(dynamic item) => '${item['id_consulta']}/${item['id_orgao']}';
  bool atualizado(dynamic item) => item['situacao'] == 'ATUALIZADO';

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
        'Pendentes de atualização',
        encontrados.where((item) => !atualizado(item)).length,
        Icons.pending_actions,
        Colors.amber.shade900
      ),
      (
        'ATUALIZADO',
        'Atualizados',
        encontrados.where(atualizado).length,
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

  String dadosAtualizacao(dynamic item) {
    final data = DateTime.tryParse(item['data_atualizacao']?.toString() ?? '')
        ?.toLocal();
    final quando = data == null
        ? 'Data indisponível'
        : '${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}/${data.year} ${data.hour.toString().padLeft(2, '0')}:${data.minute.toString().padLeft(2, '0')}';
    return '${item['responsavel'] ?? 'Usuário ${item['id_usuario_atualizacao']}'} · $quando';
  }

  Widget decisao(dynamic item) {
    if (item['decisao_tipo'] == 'MANTER') return const StatusTag('MANTER');
    if (item['decisao_tipo'] == 'DESCONTINUAR')
      return const StatusTag('DESCONTINUAR',
          label: 'Sugestão de descontinuação');
    return const Text('Não informada');
  }

  Widget tabela(List<dynamic> linhas) {
    return LayoutBuilder(
        builder: (context, tamanho) => SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                  width: tamanho.maxWidth < 1600 ? 1600 : tamanho.maxWidth,
                  child: DataTable(
                    columnSpacing: 20,
                    dataRowMinHeight: 72,
                    dataRowMaxHeight: 100,
                    columns: const [
                      DataColumn(label: Text('ID')),
                      DataColumn(label: Text('Tipo de Processo')),
                      DataColumn(label: Text('Decisão submetida')),
                      DataColumn(label: Text('Processamento')),
                      DataColumn(label: Text('Ação'))
                    ],
                    rows: [
                      for (final item in linhas)
                        DataRow(cells: [
                          DataCell(
                              Text(item['id_tipo_procedimento'].toString())),
                          DataCell(SizedBox(
                              width: 250,
                              child: Text(item['nome'].toString(),
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis))),
                          DataCell(decisao(item)),
                          DataCell(Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                StatusTag(
                                    atualizado(item) ? 'AVALIADO' : 'PENDENTE',
                                    label: atualizado(item)
                                        ? 'Atualizado'
                                        : 'Pendente de atualização'),
                                if (atualizado(item))
                                  Text(dadosAtualizacao(item),
                                      style: const TextStyle(fontSize: 12)),
                              ])),
                          DataCell(atualizado(item)
                              ? const SizedBox.shrink()
                              : OutlinedButton(
                                  onPressed:
                                      salvando ? null : () => atualizar(item),
                                  child: const Text('Marcar como atualizado'))),
                        ])
                    ],
                  )),
            ));
  }

  Widget submissao(List<dynamic> linhas) {
    final primeiro = linhas.first;
    final todos =
        itens.where((item) => grupo(item) == grupo(primeiro)).toList();
    final concluidos = todos.where(atualizado).length;
    final concluida = concluidos == todos.length;
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
            Text('$concluidos de ${todos.length} atualizados'),
            StatusTag(concluida ? 'AVALIADO' : 'PENDENTE',
                label: concluida
                    ? 'Processamento concluído'
                    : 'Processamento pendente'),
            TextButton(
                onPressed: () => Navigator.pushNamed(context,
                    '/resumo?consulta=${primeiro['id_consulta']}&orgao=${primeiro['id_orgao']}'),
                child: const Text('Consultar submissão')),
          ]),
      Text(
          'Exibindo ${linhas.length} de ${todos.length} itens desta submissão nesta página.'),
      const SizedBox(height: 16),
      tabela(linhas),
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
        title: 'Processamento das submissões',
        section: 'admin-processamento',
        trail: const ['Processamento das submissões'],
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
                  'Controle interno da atualização realizada externamente pela SETIC. Não altera o SEI.'),
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
