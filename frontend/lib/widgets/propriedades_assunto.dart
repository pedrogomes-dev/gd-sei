import 'package:flutter/material.dart';

import 'display_fields.dart';

class PropriedadesAssunto extends StatelessWidget {
  final Map<String, dynamic> assunto;

  const PropriedadesAssunto({super.key, required this.assunto});

  String valor(String nome) {
    final texto = assunto[nome]?.toString().trim() ?? '';
    if (texto.isEmpty) return 'Não informado';
    if (nome == 'sin_estrutural') {
      if (texto == 'S') return 'Sim';
      if (texto == 'N') return 'Não';
    }
    return texto;
  }

  Widget campo(String titulo, String texto, IconData icone) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xffe2e8f0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icone, size: 20, color: Colors.blueGrey),
          const SizedBox(width: 12),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(titulo, style: const TextStyle(fontSize: 12, color: Colors.blueGrey)),
              const SizedBox(height: 8),
              Text(texto),
            ],
          )),
        ],
      ),
    );
  }

  Widget linha(List<Widget> campos) {
    return LayoutBuilder(builder: (context, tamanho) {
      final largura = tamanho.maxWidth >= 600 ? (tamanho.maxWidth - 24) / 3 : tamanho.maxWidth;
      return Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [for (final item in campos) SizedBox(width: largura, child: item)],
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final (destinacao, iconeDestinacao) = destinacaoAssunto(assunto['sta_destinacao']);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        linha([
          campo('Código estruturado', valor('codigo_estruturado'), Icons.tag),
          campo('Descrição', valor('descricao'), Icons.subject),
          campo('Estrutural', valor('sin_estrutural'), Icons.account_tree_outlined),
        ]),
        const SizedBox(height: 16),
        linha([
          campo('Prazo intermediário', valor('prazo_intermediario'), Icons.hourglass_bottom),
          campo('Prazo corrente', valor('prazo_corrente'), Icons.schedule_outlined),
          campo('Destinação final', destinacao, iconeDestinacao),
        ]),
        const SizedBox(height: 24),
        campo('Observação', valor('observacao'), Icons.notes_outlined),
      ],
    );
  }
}
