import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../widgets/app_shell.dart';
import '../widgets/inicio/indicador_card.dart';
import '../widgets/inicio/tabela_orgaos.dart';

class InicioScreen extends StatefulWidget {
  const InicioScreen({super.key});

  @override
  State<InicioScreen> createState() => _InicioScreenState();
}

class _InicioScreenState extends State<InicioScreen> {
  final api = ApiService();
  final pesquisa = TextEditingController();
  List<dynamic> rodadas = [];
  int? idConsulta;
  Map<String, dynamic>? dados;
  bool carregando = true;
  String? erro;
  String filtro = 'Todos';

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
      dados = null;
    });
    try {
      final lista = await api.listarRodadas();
      var selecionada = idConsulta;
      final existe = lista.any((rodada) => int.parse(rodada['id_consulta'].toString()) == selecionada);
      if (!existe) selecionada = lista.isEmpty ? null : int.parse(lista.first['id_consulta'].toString());
      final resultado = selecionada == null ? null : await api.consultarInicio(selecionada);
      if (!mounted) return;
      setState(() {
        rodadas = lista;
        idConsulta = selecionada;
        dados = resultado;
      });
    } catch (falha) {
      if (mounted) setState(() => erro = falha.toString());
    } finally {
      if (mounted) setState(() => carregando = false);
    }
  }

  Future<void> abrirResumo(int idOrgao) async {
    await Navigator.pushNamed(context, '/resumo?consulta=$idConsulta&orgao=$idOrgao');
    if (mounted) await carregar();
  }

  List<dynamic> filtrarOrgaos() {
    final texto = pesquisa.text.trim().toLowerCase();
    return (dados!['orgaos'] as List).where((orgao) {
      if (!orgao['sigla'].toString().toLowerCase().contains(texto)) return false;
      if (filtro == 'Pendentes de análise') return orgao['pendentes'] > 0;
      if (filtro == 'Analisados') return orgao['analisados'] > 0;
      if (filtro == 'Visualizados') return orgao['visualizados'] > 0;
      if (filtro == 'Submetidos') return orgao['status'] == 'FINALIZADA';
      if (filtro == 'Pendentes de submissão') {
        return orgao['atribuidos'] > 0 && orgao['status'] != 'FINALIZADA';
      }
      return true;
    }).toList();
  }

  Widget seletorRodada() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Rodada de avaliação', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        DropdownButtonFormField<int>(
          value: idConsulta,
          isExpanded: true,
          decoration: const InputDecoration(),
          items: rodadas.map((rodada) {
            final nome = rodada['nome'];
            final versao = rodada['versao'];
            return DropdownMenuItem<int>(
              value: int.parse(rodada['id_consulta'].toString()),
              child: Text('$nome · Base versão $versao', overflow: TextOverflow.ellipsis),
            );
          }).toList(),
          onChanged: carregando ? null : (valor) {
            setState(() => idConsulta = valor);
            carregar();
          },
        ),
      ],
    );
  }

  Widget indicadores() {
    final totais = dados!['totais'] as Map;
    return LayoutBuilder(builder: (context, tamanho) {
      final colunas = tamanho.maxWidth >= 900 ? 4 : tamanho.maxWidth >= 500 ? 2 : 1;
      final largura = (tamanho.maxWidth - (colunas - 1) * 16) / colunas;
      return Wrap(spacing: 16, runSpacing: 16, children: [
        SizedBox(width: largura, child: IndicadorCard(
          titulo: 'Pendentes de análise',
          quantidade: totais['pendentes'],
          quantidadeOrgaos: totais['orgaos_pendentes_analise'],
          icone: Icons.pending_actions,
          cor: Colors.orange.shade800,
          aoSelecionar: () => selecionarFiltro('Pendentes de análise'),
        )),
        SizedBox(width: largura, child: IndicadorCard(
          titulo: 'Analisados',
          quantidade: totais['analisados'],
          quantidadeOrgaos: totais['orgaos_com_analises'],
          icone: Icons.fact_check_outlined,
          cor: Colors.blue,
          aoSelecionar: () => selecionarFiltro('Analisados'),
        )),
        SizedBox(width: largura, child: IndicadorCard(
          titulo: 'Visualizados',
          quantidade: totais['visualizados'],
          quantidadeOrgaos: totais['orgaos_com_visualizacoes'],
          icone: Icons.visibility_outlined,
          cor: Colors.blueGrey,
          aoSelecionar: () => selecionarFiltro('Visualizados'),
        )),
        SizedBox(width: largura, child: IndicadorCard(
          titulo: 'Submetidos',
          quantidade: totais['submetidos'],
          quantidadeOrgaos: totais['orgaos_submetidos'],
          icone: Icons.check_circle_outline,
          cor: Colors.green,
          aoSelecionar: () => selecionarFiltro('Submetidos'),
        )),
      ]);
    });
  }

  void selecionarFiltro(String opcao) {
    setState(() {
      pesquisa.clear();
      filtro = opcao;
    });
  }

  Widget acompanhamento() {
    final totais = dados!['totais'] as Map;
    final submetidos = totais['orgaos_submetidos'];
    final pendentes = totais['orgaos_pendentes'];
    final orgaos = filtrarOrgaos();
    final quantidade = orgaos.length;
    return SectionCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Acompanhamento dos órgãos', style: Theme.of(context).textTheme.titleLarge),
      const SizedBox(height: 12),
      Text('$submetidos órgãos submetidos · $pendentes pendentes de submissão'),
      const SizedBox(height: 24),
      SizedBox(width: 360, child: TextField(
        controller: pesquisa,
        decoration: const InputDecoration(labelText: 'Buscar órgão pela sigla', prefixIcon: Icon(Icons.search)),
        onChanged: (_) => setState(() {}),
      )),
      const SizedBox(height: 16),
      Wrap(spacing: 8, runSpacing: 8, children: [
        for (final opcao in ['Todos', 'Pendentes de análise', 'Analisados', 'Visualizados', 'Pendentes de submissão', 'Submetidos'])
          ChoiceChip(label: Text(opcao), selected: filtro == opcao, onSelected: (_) => setState(() => filtro = opcao)),
      ]),
      const SizedBox(height: 16),
      Text('$quantidade órgãos encontrados'),
      const SizedBox(height: 16),
      TabelaOrgaos(orgaos: orgaos, abrirResumo: abrirResumo),
    ]));
  }

  Widget conteudo() {
    if (carregando) return const Center(child: CircularProgressIndicator());
    if (erro != null) return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
      Text(erro!),
      const SizedBox(height: 16),
      OutlinedButton(onPressed: carregar, child: const Text('Tentar novamente')),
    ]));
    if (rodadas.isEmpty) return const Center(child: Text('Nenhuma rodada de avaliação disponível para seu acesso.'));
    final atribuidos = dados!['totais']['atribuidos'];
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        seletorRodada(),
        const SizedBox(height: 24),
        indicadores(),
        const SizedBox(height: 16),
        Text('$atribuidos atribuições de Tipos de Processo nesta rodada. A contagem considera cada órgão responsável.'),
        const SizedBox(height: 8),
        const Text('Analisado: visualizado e com todos os vínculos originais decididos. Visualizados e submetidos podem também estar contabilizados como analisados.', style: TextStyle(color: Colors.blueGrey)),
        const SizedBox(height: 24),
        acompanhamento(),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      title: 'Início',
      section: 'inicio',
      actions: [IconButton(tooltip: 'Atualizar indicadores', onPressed: carregando ? null : carregar, icon: const Icon(Icons.refresh))],
      child: conteudo(),
    );
  }
}

