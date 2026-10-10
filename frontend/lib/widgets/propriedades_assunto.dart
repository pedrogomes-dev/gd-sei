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
    if ((nome == 'prazo_corrente' || nome == 'prazo_intermediario') &&
        num.tryParse(texto.replaceAll(',', '.')) != null) {
      return '$texto anos';
    }
    return texto;
  }

  Widget campo(String titulo, String texto, IconData icone, {Color fundo = Colors.white}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: fundo,
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
      final largura = tamanho.maxWidth >= 600 ? (tamanho.maxWidth - 12 * (campos.length - 1)) / campos.length : tamanho.maxWidth;
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
        LayoutBuilder(builder: (context, tamanho) {
          final largura = tamanho.maxWidth >= 600 ? (tamanho.maxWidth - 24) / 3 : tamanho.maxWidth;
          final descricao = valor('descricao');
          final medicao = TextPainter(
            text: TextSpan(text: descricao, style: DefaultTextStyle.of(context).style),
            textDirection: Directionality.of(context),
            textScaler: MediaQuery.textScalerOf(context),
            maxLines: 2,
          )..layout(maxWidth: (largura - 64).clamp(1.0, double.infinity).toDouble());
          final separar = medicao.didExceedMaxLines;
          medicao.dispose();
          return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            linha([
              campo('Código estruturado', valor('codigo_estruturado'), Icons.tag),
              if (!separar) campo('Descrição', descricao, Icons.subject),
              campo('Estrutural', valor('sin_estrutural'), Icons.account_tree_outlined),
            ]),
            if (separar) ...[
              const SizedBox(height: 12),
              campo('Descrição', descricao, Icons.subject),
            ],
          ]);
        }),
        const SizedBox(height: 16),
        linha([
          campo('Prazo corrente', valor('prazo_corrente'), Icons.schedule_outlined),
          campo('Prazo intermediário', valor('prazo_intermediario'), Icons.hourglass_bottom),
          campo('Destinação final', destinacao, iconeDestinacao,
            fundo: assunto['sta_destinacao']?.toString().trim().toUpperCase() == 'G'
                ? const Color(0xfff0fdf4)
                : assunto['sta_destinacao']?.toString().trim().toUpperCase() == 'E'
                    ? const Color(0xfffef2f2) : Colors.white),
        ]),
        const SizedBox(height: 24),
        campo('Observação', valor('observacao'), Icons.notes_outlined),
      ],
    );
  }
}

