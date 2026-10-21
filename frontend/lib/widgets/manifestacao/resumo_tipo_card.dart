import 'package:flutter/material.dart';

import '../app_shell.dart';
import '../display_fields.dart';
import 'informacoes_assunto_dialog.dart';
import 'tabela_assuntos_scroll.dart';

class ResumoTipoCard extends StatelessWidget {
  final Map<String, dynamic> tipo;
  final List<dynamic> decisoes;
  final bool finalizada;
  final bool finalizando;
  final bool podeRevisar;
  final VoidCallback abrirTipo;

  const ResumoTipoCard({
    super.key,
    required this.tipo,
    required this.decisoes,
    required this.finalizada,
    required this.finalizando,
    this.podeRevisar = true,
    required this.abrirTipo,
  });

  Widget celula(Widget conteudo) {
    return Padding(padding: const EdgeInsets.all(16), child: conteudo);
  }

  void informarAssunto(BuildContext context, dynamic decisao) {
    showDialog<void>(
      context: context,
      builder: (_) => InformacoesAssuntoDialog(
        assunto: Map<String, dynamic>.from(decisao as Map),
      ),
    );
  }

  TableRow linhaDecisao(BuildContext context, dynamic decisao) {
    final codigo = decisao['codigo_estruturado'];
    final justificativa = decisao['justificativa']?.toString() ?? '';

    return TableRow(
      children: [
        IconButton(
          tooltip: 'Informações do Assunto',
          icon: const Icon(Icons.info_outline),
          onPressed: () => informarAssunto(context, decisao),
        ),
        celula(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('CÓDIGO $codigo', style: const TextStyle(fontSize: 12, color: Colors.blueGrey)),
              const SizedBox(height: 6),
              Text(decisao['descricao'].toString()),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
          child: Align(
            alignment: Alignment.centerLeft,
            child: StatusTag(decisao['acao'].toString()),
          ),
        ),
        celula(Text(justificativa.isEmpty ? '—' : justificativa)),
      ],
    );
  }

  Widget tabela(BuildContext context) {
    if (decisoes.isEmpty) return const SizedBox.shrink();

    return TabelaAssuntosScroll(
      tabela: Table(
        columnWidths: const {
          0: FixedColumnWidth(52),
          1: FlexColumnWidth(3),
          2: FixedColumnWidth(140),
          3: FlexColumnWidth(2),
        },
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        border: const TableBorder(horizontalInside: BorderSide(color: Color(0xffe2e8f0))),
        children: [
          TableRow(
            decoration: const BoxDecoration(color: Color(0xfff5f7fa)),
            children: [
              const SizedBox.shrink(),
              celula(const Text('Assunto')),
              celula(const Text('Decisão')),
              celula(const Text('Justificativa')),
            ],
          ),
          for (final decisao in decisoes) linhaDecisao(context, decisao),
        ],
      ),
    );
  }

  Widget botaoResumo(String titulo, IconData icone, Color cor) {
    return OutlinedButton.icon(
      onPressed: podeRevisar && !finalizando ? abrirTipo : null,
      icon: Icon(icone, size: 18),
      label: Text(titulo),
      style: OutlinedButton.styleFrom(
        foregroundColor: cor,
        backgroundColor: cor.withValues(alpha: 0.06),
        side: BorderSide(color: cor.withValues(alpha: 0.35)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pendentes = tipo['pendentes'].toString();
    final descontinuar = tipo['decisao_tipo'] == 'DESCONTINUAR';
    final revisao = tipo['decisao_tipo'] == null ? 'Aguardando Avaliação'
        : descontinuar ? 'Avaliação dispensada'
        : pendentes == '0' ? 'Revisão completa' : '$pendentes vínculos pendentes';
    final observacao = tipo['observacao']?.toString() ?? '';

    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(builder: (context, tamanho) {
            final titulo = Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(tipo['nome'].toString(), style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              Text(
                tipo['visualizado'] == 'S' ? 'Visualização registrada' : 'Visualização pendente',
                style: const TextStyle(color: Colors.blueGrey),
              ),
            ]);
            final botoes = Wrap(
              alignment: WrapAlignment.end,
              spacing: 12,
              runSpacing: 8,
              children: [
                if (tipo['decisao_tipo'] != null)
                  botaoResumo(
                    descontinuar ? 'Sugestão de Descontinuação' : 'Manter Tipo de Processo',
                    descontinuar ? Icons.cancel_outlined : Icons.check_circle_outline,
                    descontinuar ? Colors.red.shade800 : Colors.blue.shade800,
                  ),
                botaoResumo(
                  revisao,
                  descontinuar ? Icons.info_outline : pendentes == '0' && tipo['decisao_tipo'] != null
                      ? Icons.task_alt : Icons.pending_actions,
                  descontinuar ? Colors.blueGrey.shade700 : pendentes == '0' && tipo['decisao_tipo'] != null
                      ? Colors.green.shade800 : const Color(0xff9a4300),
                ),
              ],
            );
            if (tamanho.maxWidth < 1000) {
              return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                Row(children: [
                  titulo,
                  const Spacer(),
                  botoes,
                ],)
                
              ]);
            }
            return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(child: titulo),
              const SizedBox(width: 24),
              Flexible(child: Align(alignment: Alignment.topRight, child: botoes)),
            ]);
          }),
          if (descontinuar) ...[
            const SizedBox(height: 12),
            Text(tipo['justificativa_tipo']?.toString() ?? ''),
          ] else if (tipo['decisao_tipo'] == 'MANTER') ...[
            const SizedBox(height: 12),
            tabela(context),
          ],
          if (observacao.isNotEmpty) ...[
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 12),
            const Text('Observação sobre o Tipo de Processo', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text(observacao),
          ],
          if (podeRevisar) const SizedBox(height: 16),
          if (podeRevisar) Align(
            alignment: Alignment.centerRight,
            child: FilledButton.icon(
              onPressed: finalizando ? null : abrirTipo,
              icon: const Icon(Icons.open_in_new, size: 18),
              label: Text(finalizada ? 'Consultar Tipo de Processo' : 'Revisar Tipo de Processo'),
            ),
          ),
        ],
      ),
    );
  }
}
