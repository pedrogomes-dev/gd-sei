import 'package:flutter/material.dart';
import '../inicio/indicador_card.dart';

class UserFilters extends StatelessWidget {
  final TextEditingController pesquisa;
  final List<dynamic> orgaos;
  final int? idOrgao;
  final String situacao;
  final Map<String, int> quantidades;
  final bool carregando;
  final VoidCallback pesquisar;
  final ValueChanged<int?> alterarOrgao;
  final ValueChanged<String> alterarSituacao;

  const UserFilters({
    super.key,
    required this.pesquisa,
    required this.orgaos,
    required this.idOrgao,
    required this.situacao,
    required this.quantidades,
    required this.carregando,
    required this.pesquisar,
    required this.alterarOrgao,
    required this.alterarSituacao,
  });

  Widget filtroOrgao() {
    final opcoes = <DropdownMenuItem<int>>[
      const DropdownMenuItem(value: null, child: Text('Todos os órgãos')),
    ];

    for (final orgao in orgaos) {
      opcoes.add(
        DropdownMenuItem(
          value: int.parse(orgao['id_orgao'].toString()),
          child: Text(orgao['sigla'].toString()),
        ),
      );
    }

    return DropdownButtonFormField<int>(
      initialValue: idOrgao,
      isExpanded: true,
      decoration: const InputDecoration(labelText: 'Órgão'),
      items: opcoes,
      onChanged: carregando ? null : alterarOrgao,
    );
  }

  Widget cardSituacao(
      String codigo, String titulo, String chave, IconData icone, Color cor) {
    return IndicadorCard(
      titulo: titulo,
      quantidade: quantidades[chave],
      selecionado: situacao == codigo,
      aoSelecionar: carregando ? null : () => alterarSituacao(codigo),
      icone: icone,
      cor: cor,
    );
  }

  Widget filtroSituacao() {
    return LayoutBuilder(builder: (context, tamanho) {
      final colunas = tamanho.maxWidth >= 720 ? 3 : 1;
      final largura = (tamanho.maxWidth - 12 * (colunas - 1)) / colunas;
      return Wrap(spacing: 12, runSpacing: 12, children: [
        SizedBox(
            width: largura,
            child: cardSituacao('TODOS', 'Todos', 'todos', Icons.list_alt,
                Colors.blue.shade800)),
        SizedBox(
            width: largura,
            child: cardSituacao('S', 'Ativos', 'ativos',
                Icons.check_circle_outline, Colors.green.shade800)),
        SizedBox(
            width: largura,
            child: cardSituacao(
                'N', 'Inativos', 'inativos', Icons.block, Colors.red.shade800)),
      ]);
    });
  }

  Widget barraPesquisa() {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Expanded(
          child: TextField(
        controller: pesquisa,
        maxLength: 250,
        enabled: !carregando,
        decoration: const InputDecoration(
          labelText: 'Buscar por nome ou e-mail',
          prefixIcon: Icon(Icons.search),
        ),
        onSubmitted: (_) {
          if (!carregando) pesquisar();
        },
      )),
      const SizedBox(width: 12),
      Padding(
        padding: const EdgeInsets.only(top: 8),
        child: FilledButton.icon(
          onPressed: carregando ? null : pesquisar,
          icon: const Icon(Icons.search),
          label: const Text('Pesquisar'),
        ),
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      barraPesquisa(),
      const SizedBox(height: 16),
      filtroOrgao(),
      const SizedBox(height: 16),
      filtroSituacao(),
    ]);
  }
}
