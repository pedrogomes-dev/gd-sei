import 'package:flutter/material.dart';

import '../display_fields.dart';
import 'justificativa_field.dart';

class AssuntoVinculadoCard extends StatelessWidget {
  final Map<String, dynamic> assunto;
  final String? acao;
  final TextEditingController justificativa;
  final bool finalizada;
  final bool salvando;
  final ValueChanged<String?> escolherAcao;
  final VoidCallback aoAlterar;

  const AssuntoVinculadoCard({
    super.key,
    required this.assunto,
    required this.acao,
    required this.justificativa,
    required this.finalizada,
    required this.salvando,
    required this.escolherAcao,
    required this.aoAlterar,
  });

  Widget decisoes() {
    if (finalizada) return StatusTag(acao ?? 'PENDENTE');

    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: [
        ChoiceChip(
          label: const Text('Manter'),
          avatar: const Icon(Icons.check_circle_outline, size: 18, color: Colors.blue),
          selected: acao == 'MANTER',
          onSelected: salvando ? null : (marcado) => escolherAcao(marcado ? 'MANTER' : null),
        ),
        ChoiceChip(
          label: const Text('Remover'),
          avatar: const Icon(Icons.remove_circle_outline, size: 18, color: Colors.red),
          selected: acao == 'REMOVER',
          onSelected: salvando ? null : (marcado) => escolherAcao(marcado ? 'REMOVER' : null),
        ),
        if (acao == null) const StatusTag('PENDENTE'),
      ],
    );
  }

  Widget campoJustificativa() {
    return JustificativaField(
      controlador: justificativa,
      somenteLeitura: finalizada,
      salvando: salvando,
      obrigatoria: acao != 'MANTER',
      aoAlterar: aoAlterar,
    );
  }

  @override
  Widget build(BuildContext context) {
    final idAssunto = assunto['id_assunto'];
    final codigo = assunto['codigo_estruturado'];
    final exibirJustificativa = acao == 'REMOVER' || (finalizada && justificativa.text.isNotEmpty);

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xffe2e8f0)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
            Text('CÓDIGO $codigo  -  ', style: const TextStyle(fontSize: 17, color: Colors.blueGrey)),
            Text(assunto['descricao'].toString(), style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
          
          const SizedBox(height: 16),
          decisoes(),
          if (exibirJustificativa)
            Padding(padding: const EdgeInsets.only(top: 16), child: campoJustificativa()),
          if (!finalizada && acao == 'MANTER')
            ExpansionTile(
              tilePadding: EdgeInsets.zero,
              title: const Text('Adicionar justificativa opcional', style: TextStyle(fontSize: 14)),
              children: [campoJustificativa()],
            ),
          const SizedBox(height: 8),
          Column(
            children:[
            //ATENÇÃO GPT, MODIFICAR AQUI, SEGUIR AQUELA IDEIA DOS CARDS
              for (final campo in assunto.entries)
                if (campo.key != 'versao' && campo.key != 'sin_ultima') propertyTile(campo),
          ]),
        ],
      ),
    );
  }
}
