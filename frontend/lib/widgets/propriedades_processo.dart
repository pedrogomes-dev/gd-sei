import 'package:flutter/material.dart';

class PropriedadesProcesso extends StatelessWidget {
  final Map<String, dynamic> processo;

  const PropriedadesProcesso({super.key, required this.processo});

  String valor(String nome) {
    final texto = processo[nome]?.toString().trim() ?? '';
    if (texto.isEmpty) return 'Não informado';
    if (nome.startsWith('sin_')) {
      if (texto == 'S') return 'Sim';
      if (texto == 'N') return 'Não';
    }
    return texto;
  }

  Widget campo(String titulo, String nome, IconData icone) {
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
              Text(valor(nome)),
            ],
          )),
        ],
      ),
    );
  }

  Widget linha(List<Widget> campos) {
    return LayoutBuilder(builder: (context, tamanho) {
      final largura = tamanho.maxWidth >= 720
          ? (tamanho.maxWidth - 12 * (campos.length - 1)) / campos.length
          : tamanho.maxWidth;
      return Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [for (final item in campos) SizedBox(width: largura, child: item)],
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        campo('Nome', 'nome', Icons.folder_outlined),
        const SizedBox(height: 16),
        campo('Descrição', 'descricao', Icons.subject),
        const SizedBox(height: 24),
        linha([
          campo('Interno', 'sin_interno', Icons.business_outlined),
          campo('Ouvidoria', 'sin_ouvidoria', Icons.support_agent),
          campo('Individual', 'sin_individual', Icons.person_outline),
          campo('Ouvidoria anônima', 'sin_ouvidoria_anonimo', Icons.person_off_outlined),
        ]),
        const SizedBox(height: 16),
        linha([
          campo('Hipótese legal sugerida (ID)', 'id_hipotese_legal_sugestao', Icons.gavel_outlined),
          campo('Nível de acesso sugerido (código)', 'sta_nivel_acesso_sugestao', Icons.visibility_outlined),
          campo('Grau de sigilo sugerido (código)', 'sta_grau_sigilo_sugestao', Icons.lock_outline),
        ]),
      ],
    );
  }
}
