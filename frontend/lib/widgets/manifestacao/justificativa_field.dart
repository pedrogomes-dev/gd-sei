import 'package:flutter/material.dart';

class JustificativaField extends StatelessWidget {
  final TextEditingController controlador;
  final bool somenteLeitura;
  final bool salvando;
  final bool obrigatoria;
  final VoidCallback aoAlterar;

  const JustificativaField({
    super.key,
    required this.controlador,
    required this.somenteLeitura,
    required this.salvando,
    required this.obrigatoria,
    required this.aoAlterar,
  });

  @override
  Widget build(BuildContext context) {
    if (somenteLeitura) {
      final texto = controlador.text;
      return Text(
        texto.isEmpty ? 'Sem justificativa informada.' : texto,
        style: const TextStyle(color: Colors.blueGrey),
      );
    }

    return TextField(
      controller: controlador,
      enabled: !salvando,
      maxLength: 2000,
      maxLines: 2,
      onChanged: (_) => aoAlterar(),
      decoration: InputDecoration(
        labelText: obrigatoria ? 'Justificativa (obrigatória)' : 'Justificativa (opcional)',
      ),
    );
  }
}
