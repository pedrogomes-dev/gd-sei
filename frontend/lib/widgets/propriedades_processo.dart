import 'package:flutter/material.dart';

class PropriedadesProcesso extends StatelessWidget {
  final Map<String, dynamic> processo;
  final bool exibirNome;

  const PropriedadesProcesso({super.key, required this.processo, this.exibirNome = true});

  String valor(String nome) {
    final texto = processo[nome]?.toString().trim() ?? '';
    if (texto.isEmpty) return 'Não informado';
    if (nome == 'id_hipotese_legal_sugestao') return hipoteseLegal();
    if ((nome == 'sta_nivel_acesso_sugestao' || nome == 'sta_grau_sigilo_sugestao') && texto == '0') {
      return 'Não informado';
    }
    if (nome == 'sta_nivel_acesso_sugestao') {
      if (texto == '1') return 'Restrito';
      if (texto == '2') return 'Sigiloso';
      return 'Código $texto';
    }
    if (nome.startsWith('sin_')) {
      if (texto == 'S') return 'Sim';
      if (texto == 'N') return 'Não';
    }
    return texto;
  }

  String hipoteseLegal() {
    final nome = processo['hipotese_legal_nome']?.toString().trim() ?? '';
    final id = processo['id_hipotese_legal_sugestao'];
    if (nome.isEmpty) return 'ID $id — referência não cadastrada';

    final partes = <String>[nome];
    final base = processo['hipotese_legal_base']?.toString().trim() ?? '';
    if (base.isNotEmpty) partes.add(base);
    return partes.join('\n');
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
        if (exibirNome) ...[
          campo('Nome', 'nome', Icons.folder_outlined),
          const SizedBox(height: 16),
        ],
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
          campo('Hipótese legal sugerida', 'id_hipotese_legal_sugestao', Icons.gavel_outlined),
          campo('Nível de acesso sugerido', 'sta_nivel_acesso_sugestao', Icons.visibility_outlined),
          campo('Grau de sigilo sugerido (código)', 'sta_grau_sigilo_sugestao', Icons.lock_outline),
        ]),
      ],
    );
  }
}

