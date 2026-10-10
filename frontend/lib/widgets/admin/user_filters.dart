import 'package:flutter/material.dart';

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
      value: idOrgao,
      isExpanded: true,
      decoration: const InputDecoration(labelText: 'Órgão'),
      items: opcoes,
      onChanged: carregando ? null : alterarOrgao,
    );
  }

  Widget cardSituacao(String codigo, String titulo, String chave, IconData icone, Color cor) {
    final selecionado = situacao == codigo;
    return Semantics(
      button: true,
      selected: selecionado,
      child: Material(
        color: selecionado ? cor.withValues(alpha: 0.08) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: selecionado ? cor : const Color(0xffe2e8f0), width: selecionado ? 2 : 1),
        ),
        child: InkWell(
          onTap: carregando ? null : () => alterarSituacao(codigo),
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(children: [
              Icon(icone, color: cor),
              const SizedBox(width: 12),
              Expanded(child: Text(titulo, style: TextStyle(color: cor, fontWeight: FontWeight.w600))),
              Text(quantidades[chave]?.toString() ?? '—', style: TextStyle(color: cor, fontSize: 24, fontWeight: FontWeight.bold)),
              if (selecionado) ...[
                const SizedBox(width: 8),
                Icon(Icons.check_circle, color: cor, size: 18),
              ],
            ]),
          ),
        ),
      ),
    );
  }

  Widget filtroSituacao() {
    return LayoutBuilder(builder: (context, tamanho) {
      final colunas = tamanho.maxWidth >= 720 ? 3 : 1;
      final largura = (tamanho.maxWidth - 12 * (colunas - 1)) / colunas;
      return Wrap(spacing: 12, runSpacing: 12, children: [
        SizedBox(width: largura, child: cardSituacao('TODOS', 'Todos', 'todos', Icons.list_alt, Colors.blue.shade800)),
        SizedBox(width: largura, child: cardSituacao('S', 'Ativos', 'ativos', Icons.check_circle_outline, Colors.green.shade800)),
        SizedBox(width: largura, child: cardSituacao('N', 'Inativos', 'inativos', Icons.block, Colors.red.shade800)),
      ]);
    });
  }

  Widget barraPesquisa() {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Expanded(child: TextField(
        controller: pesquisa,
        maxLength: 250,
        enabled: !carregando,
        decoration: const InputDecoration(
          labelText: 'Buscar por nome ou e-mail',
          prefixIcon: Icon(Icons.search),
        ),
        onSubmitted: (_) { if (!carregando) pesquisar(); },
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
