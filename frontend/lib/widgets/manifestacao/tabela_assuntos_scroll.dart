import 'package:flutter/material.dart';

class TabelaAssuntosScroll extends StatefulWidget {
  final Widget tabela;

  const TabelaAssuntosScroll({super.key, required this.tabela});

  @override
  State<TabelaAssuntosScroll> createState() => _TabelaAssuntosScrollState();
}

class _TabelaAssuntosScrollState extends State<TabelaAssuntosScroll> {
  final rolagemVertical = ScrollController();
  final rolagemHorizontal = ScrollController();

  @override
  void dispose() {
    rolagemVertical.dispose();
    rolagemHorizontal.dispose();
    super.dispose();
  }

  Widget conteudoHorizontal(double largura, bool exibirBarra) {
    return Scrollbar(
      controller: rolagemHorizontal,
      thumbVisibility: exibirBarra,
      notificationPredicate: (evento) => evento.metrics.axis == Axis.horizontal,
      child: SingleChildScrollView(
        controller: rolagemHorizontal,
        primary: false,
        scrollDirection: Axis.horizontal,
        child: SizedBox(width: largura, child: widget.tabela),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, tamanho) {
        final janelaEstreita = tamanho.maxWidth < 640;
        final largura = janelaEstreita ? 640.0 : tamanho.maxWidth;
        final alturaJanela = MediaQuery.sizeOf(context).height;
        final altura = (alturaJanela * 0.4).clamp(180.0, 440.0).toDouble();

        return SizedBox(
          height: altura,
          child: Scrollbar(
            controller: rolagemVertical,
            thumbVisibility: true,
            notificationPredicate: (evento) => evento.metrics.axis == Axis.vertical,
            child: SingleChildScrollView(
              controller: rolagemVertical,
              primary: false,
              child: conteudoHorizontal(largura, janelaEstreita),
            ),
          ),
        );
      },
    );
  }
}
