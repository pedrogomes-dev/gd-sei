import 'package:flutter/material.dart';

class IndicadorCard extends StatelessWidget {
  final String titulo;
  final int quantidade;
  final int? quantidadeOrgaos;
  final VoidCallback aoSelecionar;
  final IconData icone;
  final Color cor;
  final bool selecionado;

  const IndicadorCard({
    super.key,
    required this.titulo,
    required this.quantidade,
    this.quantidadeOrgaos,
    required this.aoSelecionar,
    required this.icone,
    required this.cor,
    this.selecionado = false,
  });

  @override
  Widget build(BuildContext context) {
    final orgaos = quantidadeOrgaos == 1 ? 'órgão' : 'órgãos';
    return Semantics(
      button: true,
      selected: selecionado,
      child: Material(
      color: selecionado ? const Color(0xffeaf2fc) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: selecionado ? cor : const Color(0xffe2e8f0), width: selecionado ? 2 : 1),
      ),
      child: InkWell(
        onTap: aoSelecionar,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Icon(icone, color: cor),
                const SizedBox(width: 8),
                Expanded(child: Text(titulo, style: TextStyle(color: cor, fontWeight: FontWeight.w600))),
                if (selecionado) Icon(Icons.check_circle, color: cor, size: 18),
              ]),
              const SizedBox(height: 12),
              Wrap(spacing: 8, crossAxisAlignment: WrapCrossAlignment.center, children: [
                Text('$quantidade', style: Theme.of(context).textTheme.headlineMedium),
                if (quantidadeOrgaos != null) Text('($quantidadeOrgaos $orgaos)'),
              ]),
            ],
          ),
        ),
      ),
      ),
    );
  }
}

