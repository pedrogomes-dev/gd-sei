import 'package:flutter/material.dart';

import '../../services/api_service.dart';
import '../display_fields.dart';

class InformacoesAssuntoDialog extends StatefulWidget {
  final Map<String, dynamic> assunto;

  const InformacoesAssuntoDialog({super.key, required this.assunto});

  @override
  State<InformacoesAssuntoDialog> createState() => _InformacoesAssuntoDialogState();
}

class _InformacoesAssuntoDialogState extends State<InformacoesAssuntoDialog> {
  late Future<Map<String, dynamic>> carregamento;

  @override
  void initState() {
    super.initState();
    carregamento = carregarAssunto();
  }

  Future<Map<String, dynamic>> carregarAssunto() async {
    // O resumo já recebe as propriedades da versão autorizada pelo backend.
    if (widget.assunto.containsKey('prazo_corrente') &&
        widget.assunto.containsKey('prazo_intermediario') &&
        widget.assunto.containsKey('sta_destinacao')) {
      return widget.assunto;
    }
    final idAtribuicao = widget.assunto['id_atribuicao'].toString();
    final idAssunto = widget.assunto['id_assunto'].toString();
    final detalhes = await ApiService().tipo(idAtribuicao);
    final assuntos = <dynamic>[
      ...(detalhes['assuntos'] as List),
      ...(detalhes['decisoes'] as List),
    ];

    for (final assunto in assuntos) {
      if (assunto['id_assunto'].toString() == idAssunto) {
        return Map<String, dynamic>.from(assunto as Map);
      }
    }
    throw Exception('Assunto não encontrado na versão da consulta.');
  }

  Widget prazo(String titulo, dynamic valor) {
    return ListTile(
      leading: const Icon(Icons.schedule_outlined),
      title: Text(titulo),
      subtitle: Text(valor?.toString() ?? 'Não informado'),
    );
  }

  Widget propriedades(Map<String, dynamic> assunto) {
    const camposPrincipais = ['id_assunto', 'codigo_estruturado', 'descricao'];
    const camposGuarda = ['prazo_corrente', 'prazo_intermediario', 'sta_destinacao'];

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final campo in camposPrincipais) propertyTile(MapEntry(campo, assunto[campo])),
          const Divider(),
          const ListTile(title: Text('Prazos de guarda', style: TextStyle(fontWeight: FontWeight.w600))),
          prazo('Prazo corrente', assunto['prazo_corrente']),
          prazo('Prazo intermediário', assunto['prazo_intermediario']),
          destinationTile(assunto['sta_destinacao']),
          const Divider(),
          for (final campo in assunto.entries)
            if (propertyLabels.containsKey(campo.key) &&
                !camposPrincipais.contains(campo.key) &&
                !camposGuarda.contains(campo.key))
              propertyTile(campo),
        ],
      ),
    );
  }

  Widget conteudo() {
    return FutureBuilder<Map<String, dynamic>>(
      future: carregamento,
      builder: (context, resultado) {
        if (resultado.connectionState != ConnectionState.done) {
          return const SizedBox(height: 120, child: Center(child: CircularProgressIndicator()));
        }
        if (resultado.hasError) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(resultado.error.toString()),
              TextButton(
                onPressed: () => setState(() => carregamento = carregarAssunto()),
                child: const Text('Tentar novamente'),
              ),
            ],
          );
        }
        return propriedades(resultado.data!);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final idAssunto = widget.assunto['id_assunto'];
    return SelectionArea(
      child: AlertDialog(
        title: Text('Informações do Assunto $idAssunto'),
        content: SizedBox(width: 600, child: conteudo()),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Fechar')),
        ],
      ),
    );
  }
}


