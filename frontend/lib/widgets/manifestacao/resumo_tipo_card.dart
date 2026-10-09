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
  final VoidCallback abrirTipo;

  const ResumoTipoCard({
    super.key,
    required this.tipo,
    required this.decisoes,
    required this.finalizada,
    required this.finalizando,
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
    final idAssunto = decisao['id_assunto'];
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
              Text('ID $idAssunto · $codigo', style: const TextStyle(fontSize: 12, color: Colors.blueGrey)),
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
    if (decisoes.isEmpty) return const Text('Nenhuma decisão de vínculo salva.');

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

  @override
  Widget build(BuildContext context) {
    final pendentes = tipo['pendentes'].toString();
    final revisao = pendentes == '0' ? 'Revisão completa' : '$pendentes vínculos pendentes';
    final observacao = tipo['observacao']?.toString() ?? '';

    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(tipo['nome'].toString(), style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              Text(
                tipo['visualizado'] == 'S' ? 'Visualização registrada' : 'Visualização pendente',
                style: const TextStyle(color: Colors.blueGrey),
              ),
              Text(revisao, style: const TextStyle(color: Colors.blueGrey)),
            ],
          ),
          const SizedBox(height: 20),
          tabela(context),
          if (observacao.isNotEmpty) ...[
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 12),
            const Text('Observação sobre o Tipo de Processo', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text(observacao),
          ],
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
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
