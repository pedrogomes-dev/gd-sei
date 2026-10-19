import 'package:flutter/material.dart';

class TipoOrgaosEditor extends StatefulWidget {
  final String nomeTipo;
  final List<dynamic> orgaos;
  final Set<int> vinculados;
  final Future<void> Function(List<int>) salvar;

  const TipoOrgaosEditor({
    super.key,
    required this.nomeTipo,
    required this.orgaos,
    required this.vinculados,
    required this.salvar,
  });

  @override
  State<TipoOrgaosEditor> createState() => _TipoOrgaosEditorState();
}

class _TipoOrgaosEditorState extends State<TipoOrgaosEditor> {
  late final selecionados = {...widget.vinculados};
  String pesquisa = '';
  String? erro;
  bool salvando = false;

  Future<void> salvar() async {
    setState(() {
      salvando = true;
      erro = null;
    });
    try {
      await widget.salvar(selecionados.toList()..sort());
      if (mounted) Navigator.pop(context, true);
    } catch (falha) {
      if (mounted) setState(() => erro = falha.toString());
    } finally {
      if (mounted) setState(() => salvando = false);
    }
  }

  Widget opcoes() {
    final cadastrados = {
      for (final orgao in widget.orgaos)
        int.parse(orgao['id_orgao'].toString()): orgao['sigla'].toString(),
    };
    // Um vínculo órfão também precisa poder ser removido explicitamente.
    for (final id in widget.vinculados) {
      cadastrados.putIfAbsent(id, () => 'Órgão $id (não cadastrado)');
    }
    final visiveis = cadastrados.entries.where((orgao) =>
        '${orgao.key} ${orgao.value}'.toLowerCase().contains(pesquisa));
    return Column(children: [
      if (visiveis.isEmpty) const Text('Nenhum órgão encontrado.'),
      for (final orgao in visiveis)
        CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          controlAffinity: ListTileControlAffinity.leading,
          title: Text(orgao.value),
          value: selecionados.contains(orgao.key),
          onChanged: salvando
              ? null
              : (marcado) => setState(() {
                    if (marcado == true) {
                      selecionados.add(orgao.key);
                    } else {
                      selecionados.remove(orgao.key);
                    }
                  }),
        ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !salvando,
      child: AlertDialog(
        title: const Text('Vincular órgãos'),
        content: SizedBox(
          width: 640,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.nomeTipo,
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 12),
                const Text(
                    'Altera a distribuição de referência. As atribuições e avaliações das rodadas existentes são preservadas.'),
                const SizedBox(height: 16),
                TextField(
                  enabled: !salvando,
                  decoration: const InputDecoration(
                      labelText: 'Buscar órgão',
                      prefixIcon: Icon(Icons.search)),
                  onChanged: (valor) =>
                      setState(() => pesquisa = valor.trim().toLowerCase()),
                ),
                const SizedBox(height: 12),
                Text('${selecionados.length} órgãos selecionados'),
                opcoes(),
                if (erro != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(erro!,
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.error)),
                  ),
                if (salvando) const LinearProgressIndicator(),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
              onPressed: salvando ? null : () => Navigator.pop(context),
              child: const Text('Cancelar')),
          FilledButton(
              onPressed: salvando ? null : salvar, child: const Text('Salvar')),
        ],
      ),
    );
  }
}
