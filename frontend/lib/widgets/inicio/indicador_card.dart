import 'package:flutter/material.dart';

class IndicadorCard extends StatelessWidget {
  final String titulo;
  final int quantidade;
  final IconData icone;
  final Color cor;

  const IndicadorCard({
    super.key,
    required this.titulo,
    required this.quantidade,
    required this.icone,
    required this.cor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xffe2e8f0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icone, color: cor),
          const SizedBox(height: 12),
          Text('$quantidade', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 4),
          Text(titulo),
        ],
      ),
    );
  }
}
