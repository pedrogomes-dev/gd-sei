import 'package:flutter/material.dart';

import '../../services/api_service.dart';
import '../propriedades_assunto.dart';

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
        return SingleChildScrollView(child: PropriedadesAssunto(assunto: resultado.data!));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SelectionArea(
      child: AlertDialog(
        title: Row(children: [
          const Expanded(child: Text('Propriedades do Assunto')),
          IconButton(tooltip: 'Fechar', icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
        ]),
        content: SizedBox(width: 760, child: conteudo()),
      ),
    );
  }
}




