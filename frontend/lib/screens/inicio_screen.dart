import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../widgets/app_shell.dart';
import '../widgets/display_fields.dart';
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
  Object? erro;
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
      if (mounted) setState(() => erro = falha);
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
      if (filtro == 'Aguardando') return orgao['pendentes'] > 0;
      if (filtro == 'Analisados') return orgao['analisados'] > 0;
      if (filtro == 'Visualizados') return orgao['visualizados'] > 0;
      if (filtro == 'Submetidos') return orgao['submetidos'] > 0;
      if (filtro == 'Validando') {
        return orgao['validando'] > 0;
      }
      return true;
    }).toList();
  }

  Widget seletorRodada() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Rodada de Avaliação', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 22)),
        const SizedBox(height: 8),
        Text('Selecione uma rodada de Avaliação.', style: Theme.of(context).textTheme.titleSmall,),
          
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
      
      final colunas = tamanho.maxWidth >= 1100 ? 5 : tamanho.maxWidth >= 500 ? 2 : 1;
      final largura = (tamanho.maxWidth - (colunas - 1) * 16) / colunas;
      return 
      Column(
        children: [
          Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Text('Indicadores da avaliação', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text('Selecione um Card para filtrar as etapas. Clique novamente para remover o filtro.', style: Theme.of(context).textTheme.titleSmall, textAlign: TextAlign.left,),
            const SizedBox(height: 16),
          ]),
          
          Wrap(spacing: 16, runSpacing: 16, children: [
        
          SizedBox(width: largura, child: IndicadorCard(
            titulo: 'Aguardando',
            selecionado: filtro == 'Aguardando',
            quantidade: totais['pendentes'],
            quantidadeOrgaos: totais['orgaos_pendentes_analise'],
            icone: Icons.pending_actions,
            cor: Colors.red.shade800,
            aoSelecionar: () => selecionarFiltro('Aguardando'),
          )),
          SizedBox(width: largura, child: IndicadorCard(
            titulo: 'Visualizados',
            selecionado: filtro == 'Visualizados',
            quantidade: totais['visualizados'],
            quantidadeOrgaos: totais['orgaos_com_visualizacoes'],
            icone: Icons.visibility_outlined,
            cor: Colors.grey.shade800,
            aoSelecionar: () => selecionarFiltro('Visualizados'),
          )),
          SizedBox(width: largura, child: IndicadorCard(
            titulo: 'Analisados',
            selecionado: filtro == 'Analisados',
            quantidade: totais['analisados'],
            quantidadeOrgaos: totais['orgaos_com_analises'],
            icone: Icons.fact_check_outlined,
            cor: Colors.blue.shade800,
            aoSelecionar: () => selecionarFiltro('Analisados'),
          )),
          SizedBox(width: largura, child: IndicadorCard(
            titulo: 'Validando',
            selecionado: filtro == 'Validando',
            quantidade: totais['validando'],
            quantidadeOrgaos: totais['orgaos_validando'],
            icone: Icons.edit_outlined,
            cor: const Color(0xff9a4300),
            aoSelecionar: () => selecionarFiltro('Validando'),
          )),
          SizedBox(width: largura, child: IndicadorCard(
            titulo: 'Submetidos',
            selecionado: filtro == 'Submetidos',
            quantidade: totais['submetidos'],
            quantidadeOrgaos: totais['orgaos_submetidos'],
            icone: Icons.check_circle_outline,
            cor: Colors.green.shade800,
            aoSelecionar: () => selecionarFiltro('Submetidos'),
          )),
        ]),
      ]); 
    });
  }

  void selecionarFiltro(String opcao) {
    setState(() {
      filtro = filtro == opcao ? 'Todos' : opcao;
    });
  }

  Widget acompanhamento() {
    final totais = dados!['totais'] as Map;
    final submetidos = totais['orgaos_submetidos'];
    final pendentes = totais['orgaos_pendentes'];
    final orgaos = filtrarOrgaos();
    final quantidade = orgaos.length;
    return SectionCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      LayoutBuilder(builder: (context, tamanho) {
        final titulo = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Acompanhamento dos órgãos', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            Text('$submetidos órgãos submetidos · $pendentes com submissão pendente'),
          ],
        );
        final busca = TextField(
          controller: pesquisa,
          decoration: const InputDecoration(labelText: 'Buscar órgão pela sigla', prefixIcon: Icon(Icons.search)),
          onChanged: (_) => setState(() {}),
        );
        if (tamanho.maxWidth < 760) {
          return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            titulo,
            const SizedBox(height: 16),
            busca,
          ]);
        }
        return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(child: titulo),
          const SizedBox(width: 24),
          SizedBox(width: 360, child: busca),
        ]);
      }),
      const SizedBox(height: 24),
      Text('$quantidade órgãos encontrados'),
      const SizedBox(height: 16),
      TabelaOrgaos(orgaos: orgaos, abrirResumo: abrirResumo),
    ]));
  }

  Widget conteudo() {
    if (carregando) return const Center(child: CircularProgressIndicator());
    if (erro != null) return Center(child: ApiErrorMessage(error: erro!, onRetry: carregar));
    if (rodadas.isEmpty) return const Center(child: Text('Nenhuma rodada de avaliação disponível para seu acesso.'));
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        seletorRodada(),
        const SizedBox(height: 24),
        indicadores(),
        const SizedBox(height: 16),
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

