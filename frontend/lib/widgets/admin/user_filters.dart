import 'package:flutter/material.dart';

class UserFilters extends StatelessWidget {
  final TextEditingController pesquisa;
  final List<dynamic> orgaos;
  final int? idOrgao;
  final String situacao;
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
      value: idOrgao,
      isExpanded: true,
      decoration: const InputDecoration(labelText: 'Órgão'),
      items: opcoes,
      onChanged: carregando ? null : alterarOrgao,
    );
  }

  Widget filtroSituacao() {
    const opcoes = {'TODOS': 'Todos', 'S': 'Ativos', 'N': 'Inativos'};

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final opcao in opcoes.entries)
          ChoiceChip(
            label: Text(opcao.value),
            selected: situacao == opcao.key,
            onSelected: carregando ? null : (_) => alterarSituacao(opcao.key),
          ),
        FilledButton.icon(
          onPressed: carregando ? null : pesquisar,
          icon: const Icon(Icons.search),
          label: const Text('Pesquisar'),
        ),
      ],
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
          enabled: !carregando,
          decoration: const InputDecoration(
            labelText: 'Buscar por nome ou e-mail',
            prefixIcon: Icon(Icons.search),
          ),
          onSubmitted: (_) {
            if (!carregando) pesquisar();
          },
        ),
        const SizedBox(height: 16),
        filtroOrgao(),
        const SizedBox(height: 16),
        filtroSituacao(),
      ],
    );
  }
}
