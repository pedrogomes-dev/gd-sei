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
        'Pendentes de avaliação',
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
        ? 'Data indisponível'
        : '${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}/${data.year} ${data.hour.toString().padLeft(2, '0')}:${data.minute.toString().padLeft(2, '0')}';
    return '${item['responsavel'] ?? 'Administrador'} · $quando';
  }

  Widget decisao(dynamic item) {
    if (item['decisao_tipo'] == 'MANTER') return const StatusTag('MANTER');
    if (item['decisao_tipo'] == 'DESCONTINUAR')
      return const StatusTag('DESCONTINUAR',
          label: 'Sugestão de descontinuação');
    return const Text('Não informada');
  }

  Widget resultadoAceite(bool recusado, bool completo,
      {bool submissao = false}) {
    if (recusado)
      return StatusTag('PENDENTE',
          label: submissao ? 'Parcialmente aceita' : 'Parcialmente aceito');
    if (completo)
      return StatusTag('AVALIADO', label: submissao ? 'Aceita' : 'Aceito');
    return const StatusTag('PENDENTE', label: 'Aceite pendente');
  }

  Widget parecer(dynamic tipo, Map<String, dynamic> avaliacao,
      {int? idAssunto}) {
    final valor = avaliacao['parecer'];
    if (valor != null) {
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        StatusTag(valor == 'ACEITO' ? 'AVALIADO' : 'INATIVO',
            label: valor == 'ACEITO' ? 'Aceito' : 'Recusado'),
        Text(dadosAvaliacao(avaliacao), style: const TextStyle(fontSize: 12)),
      ]);
    }
    return Wrap(spacing: 12, runSpacing: 8, children: [
      OutlinedButton.icon(
          onPressed: salvando
              ? null
              : () => avaliar(tipo, 'ACEITO', idAssunto: idAssunto),
          icon: const Icon(Icons.check),
          label: const Text('Aceitar')),
      OutlinedButton.icon(
          onPressed: salvando
              ? null
              : () => avaliar(tipo, 'RECUSADO', idAssunto: idAssunto),
          icon: const Icon(Icons.close),
          label: const Text('Recusar')),
    ]);
  }

  Widget processo(dynamic item) {
    final assuntos = item['assuntos'] as List? ?? [];
    return Card(
        child: ExpansionTile(
      key: PageStorageKey('avaliacao-${item['id_atribuicao']}'),
      title: Text('ID ${item['id_tipo_procedimento']} — ${item['nome']}'),
      subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SizedBox(height: 8),
        Wrap(spacing: 12, runSpacing: 8, children: [
          decisao(item),
          StatusTag(concluido(item) ? 'AVALIADO' : 'PENDENTE',
              label: concluido(item)
                  ? 'Avaliação concluída'
                  : 'Avaliação pendente'),
          resultadoAceite(
              item['resultado'] == 'PARCIALMENTE_ACEITO', concluido(item)),
        ]),
        Text(
            '${item['avaliados']} de ${item['total_avaliacoes']} decisões avaliadas'),
      ]),
      children: [
        Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('Parecer sobre a decisão do Tipo',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  if ((item['justificativa_tipo']?.toString() ?? '').isNotEmpty)
                    Text(item['justificativa_tipo'].toString()),
                  const SizedBox(height: 8),
                  parecer(item, {
                    'parecer': item['parecer_tipo'],
                    'responsavel': item['responsavel_tipo'],
                    'data_avaliacao': item['data_avaliacao_tipo']
                  }),
                  const SizedBox(height: 16),
                  if (assuntos.isEmpty)
                    const Text('Sem decisões sobre Assuntos nesta submissão.'),
                  for (final assunto in assuntos) ...[
                    const Divider(),
                    Text(
                        '${assunto['codigo_estruturado']} — ${assunto['descricao']}'),
                    const SizedBox(height: 8),
                    Align(
                        alignment: Alignment.centerLeft,
                        child: StatusTag(assunto['acao'].toString())),
                    if ((assunto['justificativa']?.toString() ?? '').isNotEmpty)
                      Text(assunto['justificativa'].toString()),
                    const SizedBox(height: 8),
                    parecer(item, Map<String, dynamic>.from(assunto as Map),
                        idAssunto: int.parse(assunto['id_assunto'].toString())),
                    const SizedBox(height: 12),
                  ],
                ])),
      ],
    ));
  }

  Widget submissao(List<dynamic> linhas) {
    final primeiro = linhas.first;
    final todos =
        itens.where((item) => grupo(item) == grupo(primeiro)).toList();
    final concluidos = todos.where(concluido).length;
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
            Text('$concluidos de ${todos.length} Tipos avaliados'),
            StatusTag(concluida ? 'AVALIADO' : 'PENDENTE',
                label: concluida
                    ? 'Processamento concluído'
                    : 'Processamento pendente'),
            resultadoAceite(
                todos.any((item) => item['resultado'] == 'PARCIALMENTE_ACEITO'),
                concluida,
                submissao: true),
            TextButton(
                onPressed: () => Navigator.pushNamed(context,
                    '/resumo?consulta=${primeiro['id_consulta']}&orgao=${primeiro['id_orgao']}'),
                child: const Text('Consultar submissão')),
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
                  'Avalie as decisões submetidas sobre cada Tipo e seus Assuntos. Conclusão e aceite são independentes. Não altera o SEI.'),
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
