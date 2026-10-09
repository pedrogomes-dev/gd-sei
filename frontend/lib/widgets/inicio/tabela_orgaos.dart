import 'package:flutter/material.dart';

class TabelaOrgaos extends StatelessWidget {
  final List<dynamic> orgaos;
  final void Function(int) abrirResumo;

  const TabelaOrgaos({super.key, required this.orgaos, required this.abrirResumo});

  Widget celula(Widget conteudo) {
    return Padding(padding: const EdgeInsets.all(16), child: conteudo);
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
    var texto = 'Pendente de submissão';
    var icone = Icons.schedule;
    var cor = Colors.orange.shade800;
    if (orgao['atribuidos'] == 0) {
      texto = 'Sem atribuições';
      icone = Icons.remove_circle_outline;
      cor = Colors.blueGrey;
    } else if (orgao['status'] == 'FINALIZADA') {
      texto = 'Submetido';
      icone = Icons.check_circle_outline;
      cor = Colors.green.shade700;
    } else if (orgao['pendentes'] == 0) {
      texto = 'Pronto para submeter';
      icone = Icons.task_alt;
      cor = Colors.blue.shade700;
    }
    return Row(children: [
      Icon(icone, size: 18, color: cor),
      const SizedBox(width: 8),
      Expanded(child: Text(texto, style: TextStyle(color: cor))),
    ]);
  }

  Widget progresso(dynamic orgao) {
    final atribuidos = orgao['atribuidos'] as int;
    final analisados = orgao['analisados'] as int;
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
      celula(Text(orgao['sigla'].toString(), style: const TextStyle(fontWeight: FontWeight.w600))),
      celula(Text(orgao['atribuidos'].toString())),
      celula(Text(orgao['pendentes'].toString())),
      celula(Text(orgao['analisados'].toString())),
      celula(progresso(orgao)),
      celula(situacao(orgao)),
      celula(Text(dataSubmissao(orgao['data_finalizacao']))),
      IconButton(
        tooltip: 'Abrir resumo do órgão',
        icon: const Icon(Icons.open_in_new),
        onPressed: () => abrirResumo(orgao['id_orgao'] as int),
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    if (orgaos.isEmpty) return const Padding(
      padding: EdgeInsets.all(24),
      child: Text('Nenhum órgão encontrado para os filtros selecionados.'),
    );
    return LayoutBuilder(builder: (context, tamanho) {
      final largura = tamanho.maxWidth < 1050 ? 1050.0 : tamanho.maxWidth;
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: largura,
          child: Table(
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            columnWidths: const {
              0: FlexColumnWidth(1.2),
              1: FixedColumnWidth(100),
              2: FixedColumnWidth(105),
              3: FixedColumnWidth(110),
              4: FlexColumnWidth(),
              5: FixedColumnWidth(220),
              6: FixedColumnWidth(170),
              7: FixedColumnWidth(56),
            },
            border: const TableBorder(horizontalInside: BorderSide(color: Color(0xffe2e8f0))),
            children: [
              TableRow(
                decoration: const BoxDecoration(color: Color(0xfff5f7fa)),
                children: [
                  for (final titulo in ['Órgão', 'Atribuídos', 'Pendentes', 'Analisados', 'Progresso', 'Submissão', 'Data da submissão', ''])
                    celula(Text(titulo, style: const TextStyle(fontWeight: FontWeight.w600))),
                ],
              ),
              for (final orgao in orgaos) linha(orgao),
            ],
          ),
        ),
      );
    });
  }
}
