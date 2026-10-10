import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../widgets/app_shell.dart';
import '../widgets/display_fields.dart';
import '../widgets/manifestacao/resumo_tipo_card.dart';

class ResumoScreen extends StatefulWidget {
  final String consulta;
  final String orgao;

  const ResumoScreen({super.key, required this.consulta, required this.orgao});

  @override
  State<ResumoScreen> createState() => _ResumoScreenState();
}

class _ResumoScreenState extends State<ResumoScreen> {
  final api = ApiService();
  late Future<Map<String, dynamic>> carregamento;
  bool finalizando = false;
  String? erro;

  @override
  void initState() {
    super.initState();
    carregamento = api.consultarResumo(widget.consulta, widget.orgao);
  }

  void recarregar() {
    setState(() {
      erro = null;
      carregamento = api.consultarResumo(widget.consulta, widget.orgao);
    });
  }

  Future<bool> confirmarFinalizacao() async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (context) => SelectionArea(
        child: AlertDialog(
          title: const Text('Finalizar manifestação do órgão?'),
          content: const Text(
            'A submissão abrangerá todos os Tipos de Processo desta consulta. '
            'Após finalizar, não será possível alterar ou reabrir.',
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
            FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Finalizar')),
          ],
        ),
      ),
    );
    return confirmado == true;
  }

  Future<void> finalizar(Map<String, dynamic> dados) async {
    if (!await confirmarFinalizacao() || !mounted) return;

    setState(() {
      finalizando = true;
      erro = null;
    });
    try {
      final revisao = int.parse(dados['consulta_orgao']['revisao'].toString());
      await api.finalizarManifestacao(widget.consulta, widget.orgao, revisao);
      if (mounted) recarregar();
    } catch (excecao) {
      if (mounted) setState(() => erro = excecao.toString());
    } finally {
      if (mounted) setState(() => finalizando = false);
    }
  }

  Future<void> abrirTipo(String idAtribuicao) async {
    await Navigator.pushNamed(context, '/tipos/$idAtribuicao');
    if (mounted) recarregar();
  }

  String dataFinalizacao(dynamic valor) {
    var texto = valor.toString();
    if (!texto.endsWith('Z')) texto += 'Z';
    final data = DateTime.tryParse(texto)?.toLocal();
    if (data == null) return 'Data indisponível';

    String doisDigitos(int numero) => numero.toString().padLeft(2, '0');
    final dia = doisDigitos(data.day);
    final mes = doisDigitos(data.month);
    final ano = data.year;
    final hora = doisDigitos(data.hour);
    final minuto = doisDigitos(data.minute);
    return '$dia/$mes/$ano às $hora:$minuto (horário local)';
  }

  int contarDecisoes(List<dynamic> decisoes, String acao) {
    return decisoes.where((decisao) => decisao['acao'] == acao).length;
  }

  int contarTiposPendentes(List<dynamic> tipos) {
    return tipos.where((tipo) {
      return tipo['visualizado'] != 'S' ||
          tipo['decisao_tipo'] == null ||
          int.parse(tipo['pendentes'].toString()) > 0;
    }).length;
  }

  Widget indicador(String titulo, int quantidade, String unidade, IconData icone, Color cor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xffe2e8f0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(icone, size: 20, color: cor),
            const SizedBox(width: 8),
            Expanded(child: Text(titulo, style: TextStyle(color: cor, fontWeight: FontWeight.w600))),
          ]),
          const SizedBox(height: 12),
          Text('$quantidade', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 4),
          Text(unidade, style: const TextStyle(color: Colors.blueGrey)),
        ],
      ),
    );
  }

  Widget indicadores(List<dynamic> decisoes, List<dynamic> tipos) {
    return LayoutBuilder(builder: (context, tamanho) {
      final colunas = tamanho.maxWidth >= 900 ? 4 : tamanho.maxWidth >= 450 ? 2 : 1;
      final largura = (tamanho.maxWidth - (colunas - 1) * 12) / colunas;
      return Wrap(spacing: 12, runSpacing: 12, children: [
        SizedBox(width: largura, child: indicador('Manutenções',
            contarDecisoes(decisoes, 'MANTER'), 'Vínculos', Icons.check_circle_outline, Colors.blue.shade800)),
        SizedBox(width: largura, child: indicador('Remoções',
            contarDecisoes(decisoes, 'REMOVER'), 'Vínculos', Icons.remove_circle_outline, Colors.red.shade800)),
        SizedBox(width: largura, child: indicador('Inclusões',
            contarDecisoes(decisoes, 'ADICIONAR'), 'Vínculos', Icons.add_circle_outline, Colors.green.shade800)),
        SizedBox(width: largura, child: indicador('Pendentes',
            contarTiposPendentes(tipos), 'Tipos de Processo', Icons.pending_actions, const Color(0xff9a4300))),
      ]);
    });
  }

  Widget cabecalho(Map<String, dynamic> grupo, List<dynamic> decisoes, List<dynamic> tipos) {
    final finalizada = grupo['status'] == 'FINALIZADA';
    final data = grupo['data_finalizacao'];

    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(grupo['sigla'].toString(), style: Theme.of(context).textTheme.titleLarge)),
              StatusTag(grupo['status'].toString()),
            ],
          ),
          const SizedBox(height: 12),
          Text(grupo['consulta'].toString()),
          if (data != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text('Finalizada em ' + dataFinalizacao(data), style: const TextStyle(color: Colors.blueGrey)),
            ),
          const SizedBox(height: 24),
          indicadores(decisoes, tipos),
          const SizedBox(height: 16),
          Text(
            finalizada
                ? 'Manifestação finalizada. Os dados estão disponíveis para consulta.'
                : 'Confira as decisões salvas antes de submeter a manifestação.',
            style: const TextStyle(color: Colors.blueGrey),
          ),
        ],
      ),
    );
  }

  Widget submissao(Map<String, dynamic> dados) {
    final podeFinalizar = dados['pode_finalizar'] == true;
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Submissão do órgão', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Text(
            podeFinalizar
                ? 'Todos os Tipos de Processo estão revisados. Você pode finalizar a manifestação.'
                : 'Visualize e decida todos os Tipos de Processo. Para os mantidos, decida os vínculos; para descontinuação, informe a justificativa.',
          ),
          const SizedBox(height: 20),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.icon(
              onPressed: finalizando || !podeFinalizar ? null : () => finalizar(dados),
              icon: const Icon(Icons.send_outlined),
              label: Text(finalizando ? 'Finalizando…' : 'Finalizar manifestação'),
            ),
          ),
        ],
      ),
    );
  }

  List<dynamic> decisoesDoTipo(List<dynamic> decisoes, dynamic tipo) {
    final idAtribuicao = tipo['id_atribuicao'].toString();
    final vinculos = <dynamic>[];
    for (final decisao in decisoes) {
      if (decisao['id_atribuicao'].toString() == idAtribuicao) vinculos.add(decisao);
    }
    return vinculos;
  }

  Widget conteudo(Map<String, dynamic> dados) {
    final grupo = dados['consulta_orgao'] as Map<String, dynamic>;
    final tipos = dados['tipos'] as List;
    final decisoes = dados['decisoes'] as List;
    final finalizada = grupo['status'] == 'FINALIZADA';

    return ListView(
      padding: const EdgeInsets.fromLTRB(32, 0, 32, 32),
      children: [
        cabecalho(grupo, decisoes, tipos),
        for (final tipo in tipos)
          ResumoTipoCard(
            tipo: Map<String, dynamic>.from(tipo as Map),
            decisoes: decisoesDoTipo(decisoes, tipo),
            finalizada: finalizada,
            finalizando: finalizando,
            podeRevisar: dados['pode_revisar'] == true,
            abrirTipo: () => abrirTipo(tipo['id_atribuicao'].toString()),
          ),
        if (erro != null) Padding(padding: const EdgeInsets.only(bottom: 16), child: Text(erro!)),
        if (!finalizada && dados['pode_revisar'] == true) submissao(dados),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      title: 'Resumo da manifestação',
      section: 'resumos',
      trail: const ['Resumo e submissão', 'Manifestação'],
      actions: [
        IconButton(onPressed: finalizando ? null : recarregar, tooltip: 'Atualizar', icon: const Icon(Icons.refresh)),
      ],
      child: FutureBuilder<Map<String, dynamic>>(
        future: carregamento,
        builder: (context, resultado) {
          if (resultado.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (resultado.hasError) return Center(child: Text(resultado.error.toString()));
          return conteudo(resultado.data!);
        },
      ),
    );
  }
}
