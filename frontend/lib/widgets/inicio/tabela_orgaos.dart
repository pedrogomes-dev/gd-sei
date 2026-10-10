import 'package:flutter/material.dart';

class TabelaOrgaos extends StatefulWidget {
  final List<dynamic> orgaos;
  final void Function(int) abrirResumo;

  const TabelaOrgaos({super.key, required this.orgaos, required this.abrirResumo});

  @override
  State<TabelaOrgaos> createState() => _TabelaOrgaosState();
}

class _TabelaOrgaosState extends State<TabelaOrgaos> {
  final rolagem = ScrollController();
  double espaco = 16;

  @override
  void dispose() {
    rolagem.dispose();
    super.dispose();
  }

  Widget celula(Widget conteudo) {
    return Padding(padding: EdgeInsets.symmetric(horizontal: espaco, vertical: 16), child: conteudo);
  }

  String dataSubmissao(dynamic valor) {
    if (valor == null) return '—';
    final data = DateTime.tryParse(valor.toString())?.toLocal();
    if (data == null) return '—';
    final dia = data.day.toString().padLeft(2, '0');
    final mes = data.month.toString().padLeft(2, '0');
    final ano = data.year;
    final hora = data.hour.toString().padLeft(2, '0');
    final minuto = data.minute.toString().padLeft(2, '0');
    return '$dia/$mes/$ano $hora:$minuto';
  }

  Widget situacao(dynamic orgao) {
    var texto = 'Pendente';
    var icone = Icons.schedule;
    var cor = const Color(0xff9a4300);
    if (orgao['atribuidos'] == 0) {
      texto = 'Sem atribuições';
      icone = Icons.remove_circle_outline;
      cor = Colors.grey.shade800;
    } else if (orgao['status'] == 'FINALIZADA') {
      texto = dataSubmissao(orgao['data_finalizacao']);
      if (texto == '—') texto = 'Submetido';
      icone = Icons.check_circle_outline;
      cor = Colors.green.shade800;
    }
    return Semantics(
      label: orgao['status'] == 'FINALIZADA' ? 'Submetido em $texto' : texto,
      excludeSemantics: true,
      child: Row(children: [
        Icon(icone, size: 18, color: cor),
        const SizedBox(width: 8),
        Expanded(child: Text(texto, style: TextStyle(color: cor))),
      ]),
    );
  }

  Widget nomeOrgao(dynamic orgao) {
    return Row(children: [
      Flexible(child: Text(orgao['sigla'].toString(), style: const TextStyle(fontWeight: FontWeight.w600))),
      const SizedBox(width: 4),
      IconButton(
        tooltip: 'Abrir resumo do órgão',
        icon: const Icon(Icons.open_in_new, size: 18),
        onPressed: () => widget.abrirResumo(orgao['id_orgao'] as int),
      ),
    ]);
  }

  Widget progresso(dynamic orgao) {
    final atribuidos = orgao['atribuidos'] as int;
    final analisados = orgao['revisados'] as int;
    if (atribuidos == 0) return const Text('—');
    final fracao = analisados / atribuidos;
    final percentual = (fracao * 100).round();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('$percentual%'),
      const SizedBox(height: 8),
      LinearProgressIndicator(value: fracao),
    ]);
  }

  TableRow linha(dynamic orgao) {
    return TableRow(children: [
      celula(nomeOrgao(orgao)),
      celula(Text(orgao['atribuidos'].toString())),
      celula(Text(orgao['pendentes'].toString())),
      celula(Text(orgao['revisados'].toString())),
      celula(progresso(orgao)),
      celula(situacao(orgao)),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.orgaos.isEmpty) return const Padding(
      padding: EdgeInsets.all(24),
      child: Text('Nenhum órgão encontrado para os filtros selecionados.'),
    );
    return LayoutBuilder(builder: (context, tamanho) {
      espaco = tamanho.maxWidth < 1000 ? 8 : 16;
      final largura = tamanho.maxWidth < 760 ? 760.0 : tamanho.maxWidth;
      return Scrollbar(
        controller: rolagem,
        thumbVisibility: tamanho.maxWidth < largura,
        notificationPredicate: (evento) => evento.metrics.axis == Axis.horizontal,
        child: SingleChildScrollView(
          controller: rolagem,
          primary: false,
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: largura,
            child: Table(
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              columnWidths: const {
                0: FlexColumnWidth(1.6),
                1: FlexColumnWidth(),
                2: FlexColumnWidth(),
                3: FlexColumnWidth(),
                4: FlexColumnWidth(),
                5: FlexColumnWidth(1.8),
              },
              border: const TableBorder(horizontalInside: BorderSide(color: Color(0xffe2e8f0))),
              children: [
                TableRow(
                  decoration: const BoxDecoration(color: Color(0xfff5f7fa)),
                  children: [
                    for (final titulo in ['Órgão', 'Atribuídos', 'Aguardando', 'Revisados', 'Progresso', 'Submissão'])
                      celula(Text(titulo, style: const TextStyle(fontWeight: FontWeight.w600))),
                  ],
                ),
                for (final orgao in widget.orgaos) linha(orgao),
              ],
            ),
          ),
        ),
      );
    });
  }
}
