import 'package:flutter/material.dart';

import '../display_fields.dart';

class BuscaAssuntos extends StatelessWidget {
  final TextEditingController pesquisa;
  final List<dynamic> resultados;
  final Set<int> inclusoes;
  final bool carregando;
  final bool salvando;
  final bool temProximaPagina;
  final bool pesquisaRealizada;
  final String? erro;
  final ValueChanged<bool> pesquisar;
  final ValueChanged<Map<String, dynamic>> proporInclusao;

  const BuscaAssuntos({
    super.key,
    required this.pesquisa,
    required this.resultados,
    required this.inclusoes,
    required this.carregando,
    required this.salvando,
    required this.temProximaPagina,
    required this.pesquisaRealizada,
    required this.erro,
    required this.pesquisar,
    required this.proporInclusao,
  });

  Widget resultadoAssunto(dynamic registro) {
    final assunto = Map<String, dynamic>.from(registro as Map);
    final idAssunto = int.parse(assunto['id_assunto'].toString());
    final codigo = assunto['codigo_estruturado'];
    final descricao = assunto['descricao'];
    final jaIncluido = inclusoes.contains(idAssunto);

    return Card(
      child: Column(
        children: [
          ListTile(
            title: Text('ID $idAssunto · $codigo — $descricao'),
            subtitle: Text(assunto['observacao']?.toString() ?? ''),
            trailing: ElevatedButton.icon(
              icon: const Icon(Icons.add_circle_outline, color: Colors.green),
              onPressed: salvando || jaIncluido ? null : () => proporInclusao(assunto),
              label: const Text('Propor inclusão'),
            ),
          ),
          ExpansionTile(
            title: const Text('Propriedades do Assunto'),
            children: [
              for (final campo in assunto.entries)
                if (campo.key != 'versao' && campo.key != 'sin_ultima') propertyTile(campo),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: pesquisa,
          maxLength: 250,
          decoration: const InputDecoration(
            labelText: 'Pesquisar ID, código, descrição, observação ou índice',
          ),
          onSubmitted: (_) {
            if (!carregando && !salvando) pesquisar(false);
          },
        ),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: carregando || salvando ? null : () => pesquisar(false),
          child: Text(carregando ? 'Pesquisando…' : 'Pesquisar Assuntos ativos'),
        ),
        if (erro != null) Text(erro!),
        for (final assunto in resultados) resultadoAssunto(assunto),
        if (temProximaPagina)
          TextButton(
            onPressed: carregando || salvando ? null : () => pesquisar(true),
            child: const Text('Próxima página'),
          ),
        if (resultados.isEmpty && pesquisaRealizada && !carregando)
          const Text('Nenhum Assunto encontrado.'),
      ],
    );
  }
}
