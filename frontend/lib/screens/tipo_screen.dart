import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../widgets/app_shell.dart';
import '../widgets/display_fields.dart';
import '../widgets/propriedades_processo.dart';
import '../widgets/manifestacao/assunto_vinculado_card.dart';
import '../widgets/manifestacao/busca_assuntos.dart';
import '../widgets/manifestacao/justificativa_field.dart';

class TipoScreen extends StatefulWidget {
  final String id;

  const TipoScreen({super.key, required this.id});

  @override
  State<TipoScreen> createState() => _TipoScreenState();
}

class _TipoScreenState extends State<TipoScreen> {
  final api = ApiService();
  final observacao = TextEditingController();
  final pesquisa = TextEditingController();
  final justificativas = <int, TextEditingController>{};
  final decisoes = <int, String>{};
  final inclusoes = <int, Map<String, dynamic>>{};

  late Future<Map<String, dynamic>> carregamento;
  Map<String, dynamic>? dados;
  List<dynamic> resultados = [];
  bool carregando = true;
  bool salvando = false;
  bool pesquisando = false;
  bool alterado = false;
  bool visualizado = false;
  bool temProximaPagina = false;
  String? erro;
  String? erroPesquisa;
  String pesquisaAplicada = '';
  int inicio = 0;
  int revisao = 0;

  bool get finalizada => dados?['tipo']['status'] == 'FINALIZADA';

  @override
  void initState() {
    super.initState();
    carregamento = carregar();
  }

  void limparJustificativas() {
    for (final controlador in justificativas.values) {
      controlador.dispose();
    }
    justificativas.clear();
  }

  @override
  void dispose() {
    observacao.dispose();
    pesquisa.dispose();
    limparJustificativas();
    super.dispose();
  }

  Future<Map<String, dynamic>> carregar() async {
    final resultado = await api.tipo(widget.id);
    if (!mounted) return resultado;

    limparJustificativas();
    decisoes.clear();
    inclusoes.clear();

    dados = resultado;
    visualizado = resultado['tipo']['visualizado'] == 'S';
    final manifestacao = resultado['manifestacao'] as Map<String, dynamic>;
    revisao = int.parse(manifestacao['revisao'].toString());
    observacao.text = manifestacao['observacao']?.toString() ?? '';

    for (final assunto in resultado['assuntos'] as List) {
      final idAssunto = int.parse(assunto['id_assunto'].toString());
      justificativas[idAssunto] = TextEditingController();
    }

    for (final decisao in resultado['decisoes'] as List) {
      final idAssunto = int.parse(decisao['id_assunto'].toString());
      decisoes[idAssunto] = decisao['acao'].toString();
      justificativas.putIfAbsent(idAssunto, () => TextEditingController());
      justificativas[idAssunto]!.text = decisao['justificativa']?.toString() ?? '';

      if (decisao['acao'] == 'ADICIONAR') {
        inclusoes[idAssunto] = Map<String, dynamic>.from(decisao as Map);
      }
    }

    setState(() {
      alterado = false;
      carregando = false;
    });
    return resultado;
  }

  Future<bool> confirmarDescarte() async {
    if (!alterado) return true;

    final confirmado = await showDialog<bool>(
      context: context,
      builder: (context) => SelectionArea(
        child: AlertDialog(
          title: const Text('Descartar alterações não salvas?'),
          content: const Text('O preenchimento desde o último salvamento será perdido.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Continuar editando'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Descartar'),
            ),
          ],
        ),
      ),
    );
    return confirmado == true;
  }

  Future<void> recarregar() async {
    if (!await confirmarDescarte() || !mounted) return;
    setState(() {
      erro = null;
      carregando = true;
      carregamento = carregar();
    });
  }

  List<Map<String, dynamic>> montarVinculos() {
    final vinculos = <Map<String, dynamic>>[];
    for (final decisao in decisoes.entries) {
      vinculos.add({
        'id_assunto': decisao.key,
        'acao': decisao.value,
        'justificativa': justificativas[decisao.key]!.text.trim(),
      });
    }
    return vinculos;
  }

  Future<void> salvar() async {
    final vinculos = montarVinculos();
    for (final vinculo in vinculos) {
      if (vinculo['acao'] != 'MANTER' && vinculo['justificativa'] == '') {
        setState(() => erro = 'Preencha a justificativa de todas as remoções e inclusões.');
        return;
      }
    }

    setState(() {
      salvando = true;
      erro = null;
    });
    try {
      final resultado = await api.salvarManifestacao(widget.id, {
        'revisao': revisao,
        'observacao': observacao.text,
        'vinculos': vinculos,
      });
      if (!mounted) return;

      setState(() {
        revisao = int.parse(resultado['revisao'].toString());
        alterado = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Rascunho salvo.')),
      );
    } catch (excecao) {
      if (mounted) setState(() => erro = excecao.toString());
    } finally {
      if (mounted) setState(() => salvando = false);
    }
  }

  Future<void> confirmarVisualizacao() async {
    setState(() {
      salvando = true;
      erro = null;
    });
    try {
      await api.visualizar(widget.id);
      if (mounted) setState(() => visualizado = true);
    } catch (excecao) {
      if (mounted) setState(() => erro = excecao.toString());
    } finally {
      if (mounted) setState(() => salvando = false);
    }
  }

  Future<void> pesquisarAssuntos(bool proximaPagina) async {
    final texto = proximaPagina ? pesquisaAplicada : pesquisa.text.trim();
    final pagina = proximaPagina ? inicio + 50 : 0;
    setState(() {
      pesquisando = true;
      erroPesquisa = null;
    });

    try {
      final resultado = await api.pesquisarAssuntos(widget.id, texto, pagina);
      if (!mounted) return;
      setState(() {
        resultados = resultado['itens'] as List;
        temProximaPagina = resultado['mais'] == true;
        pesquisaAplicada = texto;
        inicio = pagina;
      });
    } catch (excecao) {
      if (mounted) setState(() => erroPesquisa = excecao.toString());
    } finally {
      if (mounted) setState(() => pesquisando = false);
    }
  }

  void marcarAlteracao() {
    setState(() => alterado = true);
  }

  void escolherAcao(int idAssunto, String? acao) {
    setState(() {
      if (acao == null) {
        decisoes.remove(idAssunto);
      } else {
        decisoes[idAssunto] = acao;
      }
      alterado = true;
    });
  }

  void proporInclusao(Map<String, dynamic> assunto) {
    final idAssunto = int.parse(assunto['id_assunto'].toString());
    setState(() {
      inclusoes[idAssunto] = assunto;
      decisoes[idAssunto] = 'ADICIONAR';
      justificativas.putIfAbsent(idAssunto, () => TextEditingController());
      alterado = true;
    });
  }

  void retirarInclusao(int idAssunto) {
    setState(() {
      decisoes.remove(idAssunto);
      inclusoes.remove(idAssunto);
      alterado = true;
    });
  }

  Widget cabecalho(Map<String, dynamic> tipo) {
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(tipo['nome'].toString(), style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              StatusTag(tipo['status'].toString()),
              StatusTag(
                visualizado ? 'VISUALIZADO' : 'PENDENTE',
                label: visualizado ? 'Visualizado' : 'Visualização pendente',
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(finalizada ? 'Manifestação finalizada — somente leitura.' : 'Rascunho compartilhado pelo órgão.'),
          ExpansionTile(
            title: const Text('Propriedades do Tipo de Processo'),
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: PropriedadesProcesso(processo: tipo),
              ),
            ],
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            icon: const Icon(Icons.visibility_outlined),
            onPressed: salvando || visualizado || finalizada ? null : confirmarVisualizacao,
            label: Text(visualizado ? 'Visualização registrada' : 'Confirmar visualização'),
          ),
        ],
      ),
    );
  }

  Widget assuntosVinculados(List<dynamic> assuntos) {
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Assuntos atualmente vinculados', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 20),
          if (assuntos.isEmpty) const Text('Nenhum vínculo existente.'),
          for (final registro in assuntos)
            AssuntoVinculadoCard(
              assunto: Map<String, dynamic>.from(registro as Map),
              acao: decisoes[int.parse(registro['id_assunto'].toString())],
              justificativa: justificativas[int.parse(registro['id_assunto'].toString())]!,
              finalizada: finalizada,
              salvando: salvando,
              escolherAcao: (acao) => escolherAcao(int.parse(registro['id_assunto'].toString()), acao),
              aoAlterar: marcarAlteracao,
            ),
        ],
      ),
    );
  }

  Widget propostaInclusao(int idAssunto, Map<String, dynamic> assunto) {
    final codigo = assunto['codigo_estruturado'];
    final descricao = assunto['descricao'];
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const StatusTag('ADICIONAR'),
            const SizedBox(height: 12),
            Text('ID $idAssunto · $codigo — $descricao'),
            const SizedBox(height: 16),
            JustificativaField(
              controlador: justificativas[idAssunto]!,
              somenteLeitura: finalizada,
              salvando: salvando,
              obrigatoria: true,
              aoAlterar: marcarAlteracao,
            ),
            if (!finalizada)
              TextButton(
                onPressed: salvando ? null : () => retirarInclusao(idAssunto),
                child: const Text('Retirar proposta de inclusão'),
              ),
          ],
        ),
      ),
    );
  }

  Widget inclusoesPropostas() {
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Inclusões propostas', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 20),
          if (inclusoes.isEmpty) const Text('Nenhuma inclusão proposta.'),
          for (final inclusao in inclusoes.entries)
            propostaInclusao(inclusao.key, inclusao.value),
          if (!finalizada) ...[
            const SizedBox(height: 20),
            BuscaAssuntos(
              pesquisa: pesquisa,
              resultados: resultados,
              inclusoes: inclusoes.keys.toSet(),
              carregando: pesquisando,
              salvando: salvando,
              temProximaPagina: temProximaPagina,
              pesquisaRealizada: pesquisaAplicada.isNotEmpty,
              erro: erroPesquisa,
              pesquisar: pesquisarAssuntos,
              proporInclusao: proporInclusao,
            ),
          ],
        ],
      ),
    );
  }

  Widget observacaoGeral() {
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Observação geral sobre o Tipo de Processo', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          TextField(
            controller: observacao,
            maxLength: 5000,
            maxLines: 4,
            enabled: !finalizada && !salvando,
            onChanged: (_) => marcarAlteracao(),
            decoration: const InputDecoration(labelText: 'Observação geral sobre o Tipo de Processo'),
          ),
          if (erro != null) Text(erro!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
        ],
      ),
    );
  }

  Widget barraSalvamento() {
    String mensagem = 'Sem alterações pendentes';
    if (alterado) mensagem = 'Alterações não salvas';
    if (finalizada) mensagem = 'Manifestação finalizada · somente leitura';

    return Row(
      children: [
        if (dados != null && !finalizada && !carregando)
          FilledButton.icon(
            onPressed: salvando ? null : salvar,
            icon: const Icon(Icons.save_outlined),
            label: Text(salvando ? 'Salvando…' : 'Salvar rascunho'),
          ),
        const SizedBox(width: 16),
        Expanded(child: Text(mensagem, style: const TextStyle(color: Colors.blueGrey))),
      ],
    );
  }

  Widget conteudo() {
    return FutureBuilder<Map<String, dynamic>>(
      future: carregamento,
      builder: (context, resultado) {
        if (resultado.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (resultado.hasError) return Center(child: Text(resultado.error.toString()));

        final tipo = resultado.data!['tipo'] as Map<String, dynamic>;
        final assuntos = resultado.data!['assuntos'] as List;
        return ListView(
          padding: const EdgeInsets.fromLTRB(32, 0, 32, 32),
          children: [
            cabecalho(tipo),
            assuntosVinculados(assuntos),
            inclusoesPropostas(),
            observacaoGeral(),
          ],
        );
      },
    );
  }

  Future<void> aoVoltar(bool saiu, Object? resultado) async {
    if (saiu || salvando) return;
    if (!await confirmarDescarte() || !mounted) return;
    setState(() => alterado = false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) Navigator.pop(context);
    });
  }

  Future<bool> antesDeSair() async {
    if (salvando) return false;
    return confirmarDescarte();
  }

  @override
  Widget build(BuildContext context) {
    final nomeTipo = dados?['tipo']['nome']?.toString() ?? 'Revisão';
    return PopScope<Object?>(
      canPop: !alterado && !salvando,
      onPopInvokedWithResult: aoVoltar,
      child: AppShell(
        title: 'Revisão do Tipo de Processo',
        beforeLogout: antesDeSair,
        trail: ['Tipos de Processo atribuídos', nomeTipo],
        actions: [
          IconButton(onPressed: salvando ? null : recarregar, tooltip: 'Recarregar', icon: const Icon(Icons.refresh)),
        ],
        footer: barraSalvamento(),
        child: conteudo(),
      ),
    );
  }
}

