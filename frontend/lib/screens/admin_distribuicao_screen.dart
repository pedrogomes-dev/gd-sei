import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../widgets/admin/tipo_orgaos_editor.dart';
import '../widgets/app_shell.dart';
import '../widgets/display_fields.dart';
import '../widgets/inicio/indicador_card.dart';

class AdminDistribuicaoScreen extends StatefulWidget {
  const AdminDistribuicaoScreen({super.key});

  @override
  State<AdminDistribuicaoScreen> createState() =>
      _AdminDistribuicaoScreenState();
}

class _AdminDistribuicaoScreenState extends State<AdminDistribuicaoScreen> {
  final api = ApiService();
  final pesquisa = TextEditingController();
  List<dynamic> tipos = [];
  List<dynamic> orgaos = [];
  final vinculos = <int, Set<int>>{};
  final selecionados = <int>{};
  int? versao;
  int pagina = 0;
  String estado = 'TODOS';
  String vinculo = 'TODOS';
  String? erro;
  bool carregando = true;

  @override
  void initState() {
    super.initState();
    carregar();
  }

  @override
  void dispose() {
    pesquisa.dispose();
    super.dispose();
  }

  Future<void> carregar() async {
    setState(() {
      carregando = true;
      erro = null;
    });
    try {
      final dados = await api.consultarDistribuicao();
      if (!mounted) return;
      setState(() {
        tipos = dados['tipos'] as List;
        orgaos = dados['orgaos'] as List;
        versao = int.parse(dados['versao'].toString());
        selecionados.retainAll(tipos
            .map((tipo) => int.parse(tipo['id_tipo_procedimento'].toString())));
        vinculos.clear();
        for (final item in dados['vinculos'] as List) {
          final id = int.parse(item['id_tipo_procedimento'].toString());
          vinculos
              .putIfAbsent(id, () => {})
              .add(int.parse(item['id_orgao'].toString()));
        }
        pagina = 0;
      });
    } catch (falha) {
      if (mounted) setState(() => erro = falha.toString());
    } finally {
      if (mounted) setState(() => carregando = false);
    }
  }

  Set<int> orgaosTipo(dynamic tipo) =>
      vinculos[int.parse(tipo['id_tipo_procedimento'].toString())] ?? <int>{};

  List<dynamic> get pesquisados {
    final texto = pesquisa.text.trim().toLowerCase();
    return tipos
        .where((tipo) => '${tipo['id_tipo_procedimento']} ${tipo['nome']}'
            .toLowerCase()
            .contains(texto))
        .toList();
  }

  bool corresponde(dynamic tipo) {
    if (estado != 'TODOS' && tipo['sin_ativo'] != estado) return false;
    final vinculado = orgaosTipo(tipo).isNotEmpty;
    if (vinculo == 'VINCULADOS') return vinculado;
    if (vinculo == 'NAO_VINCULADOS') return !vinculado;
    return true;
  }

  void filtrar(String novoEstado, String novoVinculo) {
    setState(() {
      estado = novoEstado;
      vinculo = novoVinculo;
      pagina = 0;
    });
  }

  Future<void> editar(dynamic tipo) async {
    final id = int.parse(tipo['id_tipo_procedimento'].toString());
    final anteriores = orgaosTipo(tipo).toList()..sort();
    final alterou = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => TipoOrgaosEditor(
        nomeTipo: tipo['nome'].toString(),
        orgaos: orgaos,
        vinculados: anteriores.toSet(),
        salvar: (selecionados) =>
            api.salvarDistribuicao(id, versao!, anteriores, selecionados),
      ),
    );
    if (!mounted || alterou != true) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Vínculos atualizados.')));
    await carregar();
  }

  void selecionarPagina(List<dynamic> itens, bool marcado) {
    final ids =
        itens.map((tipo) => int.parse(tipo['id_tipo_procedimento'].toString()));
    setState(() {
      if (marcado) {
        selecionados.addAll(ids);
      } else {
        selecionados.removeAll(ids);
      }
    });
  }

  Future<void> vincularSelecionados() async {
    final ids = selecionados.toList()..sort();
    Map<String, dynamic>? resultado;
    final alterou = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => TipoOrgaosEditor(
        nomeTipo: '${ids.length} Tipos de Processo selecionados',
        emLote: true,
        orgaos: orgaos,
        vinculados: const {},
        salvar: (escolhidos) async {
          resultado =
              await api.vincularDistribuicaoEmLote(versao!, ids, escolhidos);
        },
      ),
    );
    if (!mounted || alterou != true) return;
    setState(() => selecionados.clear());
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
            '${resultado!['vinculos_incluidos']} vínculos acrescentados em ${resultado!['tipos_alterados']} Tipos de Processo.')));
    await carregar();
  }

  Widget acoesSelecao() {
    return Wrap(
        spacing: 12,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.start,
            
            children: [
              
              Row(
                
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('${selecionados.length} Tipos selecionados'),
                  const Spacer(),
                  TextButton(
                    onPressed: selecionados.isEmpty
                        ? null
                        : () => setState(() => selecionados.clear()),
                    child: const Text('Limpar seleção'),
                  ),
                  FilledButton.icon(
                    onPressed: selecionados.isEmpty ? null : vincularSelecionados,
                    icon: const Icon(Icons.add_link),
                    label: const Text('Vincular selecionados'),
                  ),
          
              ],
            ),
       
          
          
    ]);
  }

  Widget indicadores(List<dynamic> base) {
    final ligados = base.where((tipo) => orgaosTipo(tipo).isNotEmpty).length;
    final ativos = base.where((tipo) => tipo['sin_ativo'] == 'S').length;
    final inativos = base.where((tipo) => tipo['sin_ativo'] == 'N').length;
    final opcoes = [
      (
        'Todos',
        base.length,
        Icons.list_alt,
        Colors.blue.shade800,
        estado == 'TODOS' && vinculo == 'TODOS',
        () => filtrar('TODOS', 'TODOS')
      ),
      (
        'Vinculados',
        ligados,
        Icons.link,
        Colors.green.shade800,
        vinculo == 'VINCULADOS',
        () => filtrar(estado, vinculo == 'VINCULADOS' ? 'TODOS' : 'VINCULADOS')
      ),
      (
        'Não vinculados',
        base.length - ligados,
        Icons.link_off,
        const Color(0xff9a4300),
        vinculo == 'NAO_VINCULADOS',
        () => filtrar(
            estado, vinculo == 'NAO_VINCULADOS' ? 'TODOS' : 'NAO_VINCULADOS')
      ),
      (
        'Ativos',
        ativos,
        Icons.check_circle_outline,
        Colors.green.shade800,
        estado == 'S',
        () => filtrar(estado == 'S' ? 'TODOS' : 'S', vinculo)
      ),
      (
        'Inativos',
        inativos,
        Icons.block,
        Colors.red.shade800,
        estado == 'N',
        () => filtrar(estado == 'N' ? 'TODOS' : 'N', vinculo)
      ),
    ];
    return LayoutBuilder(builder: (context, tamanho) {
      var colunas = 1;
      if (tamanho.maxWidth >= 1100) {
        colunas = 5;
      } else if (tamanho.maxWidth >= 650) {
        colunas = 3;
      } else if (tamanho.maxWidth >= 450) {
        colunas = 2;
      }
      final largura = (tamanho.maxWidth - (colunas - 1) * 12) / colunas;
      return Wrap(spacing: 12, runSpacing: 12, children: [
        for (final opcao in opcoes)
          SizedBox(
              width: largura,
              child: IndicadorCard(
                titulo: opcao.$1,
                quantidade: opcao.$2,
                icone: opcao.$3,
                cor: opcao.$4,
                selecionado: opcao.$5,
                aoSelecionar: opcao.$6,
              )),
      ]);
    });
  }

  Widget filtros(List<dynamic> base) {
    return SectionCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      TextField(
        controller: pesquisa,
        maxLength: 250,
        decoration: const InputDecoration(
            labelText: 'Buscar por nome ou ID do Tipo de Processo',
            prefixIcon: Icon(Icons.search)),
        onChanged: (_) => setState(() => pagina = 0),
      ),
      const SizedBox(height: 16),
      indicadores(base),
      const SizedBox(height: 12),
      const Text(
          'Os totais consideram a busca. Combine os filtros de situação e vínculo selecionando os cards.'),
    ]));
  }

  Widget tabela(List<dynamic> lista) {
    final itens = lista.skip(pagina * 50).take(50).toList();
    return SectionCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('${lista.length} Tipos de Processo encontrados'),
      const SizedBox(height: 12),
      acoesSelecao(),
      const SizedBox(height: 16),
      if (itens.isEmpty)
        const Text('Nenhum Tipo de Processo encontrado.')
      else
        LayoutBuilder(builder: (context, tamanho) {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: tamanho.maxWidth < 900 ? 900 : tamanho.maxWidth,
              child: DataTable(
                onSelectAll: (marcado) =>
                    selecionarPagina(itens, marcado == true),
                headingRowColor:
                    const WidgetStatePropertyAll(Color(0xfff5f7fa)),
                columnSpacing: 24,
                horizontalMargin: 16,
                dataRowMinHeight: 64,
                dataRowMaxHeight: 96,
                columns: const [
                  DataColumn(label: Text('ID')),
                  DataColumn(label: Text('Tipo de Processo')),
                  DataColumn(label: Text('Situação')),
                  DataColumn(label: Text('Órgãos')),
                  DataColumn(label: Text('')),
                ],
                rows: [
                  for (final tipo in itens)
                    DataRow(
                        selected: selecionados.contains(
                            int.parse(tipo['id_tipo_procedimento'].toString())),
                        onSelectChanged: (marcado) =>
                            selecionarPagina([tipo], marcado == true),
                        cells: [
                          DataCell(
                              Text(tipo['id_tipo_procedimento'].toString())),
                          DataCell(SizedBox(
                              width: 300,
                              child: Text(tipo['nome'].toString(),
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis))),
                          DataCell(StatusTag(
                              tipo['sin_ativo'] == 'S' ? 'ATIVO' : 'INATIVO')),
                          DataCell(Text('${orgaosTipo(tipo).length} órgãos')),
                          DataCell(OutlinedButton.icon(
                              onPressed: () => editar(tipo),
                              icon: const Icon(Icons.account_tree_outlined),
                              label: const Text('Vincular órgãos'))),
                        ])
                ],
              ),
            ),
          );
        }),
      const SizedBox(height: 12),
      Wrap(
          spacing: 16,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(itens.isEmpty
                ? '0 resultados'
                : 'Exibindo ${pagina * 50 + 1}–${pagina * 50 + itens.length} de ${lista.length}'),
            if (pagina > 0)
              TextButton(
                  onPressed: () => setState(() => pagina--),
                  child: const Text('Anterior')),
            if ((pagina + 1) * 50 < lista.length)
              TextButton(
                  onPressed: () => setState(() => pagina++),
                  child: const Text('Próxima')),
          ]),
    ]));
  }

  @override
  Widget build(BuildContext context) {
    final base = pesquisados;
    return AppShell(
      title: 'Atribuição de Tipos de Processo',
      section: 'admin-distribuicao',
      trail: const ['Atribuição de Tipos de Processo'],
      actions: [
        IconButton(
            onPressed: carregando ? null : carregar,
            tooltip: 'Atualizar',
            icon: const Icon(Icons.refresh))
      ],
      child: ListView(
          padding: const EdgeInsets.fromLTRB(32, 0, 32, 32),
          children: [
            if (carregando) const LinearProgressIndicator(),
            if (erro != null)
              SectionCard(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text(erro!),
                    TextButton(
                        onPressed: carregando ? null : carregar,
                        child: const Text('Tentar novamente')),
                  ])),
            if (!carregando && erro == null && versao != null) ...[
              Text(
                  'Atribuição de referência · Base publicada $versao. As rodadas existentes são preservadas.'),
              const SizedBox(height: 16),
              filtros(base),
              tabela(base.where(corresponde).toList()),
            ],
          ]),
    );
  }
}
