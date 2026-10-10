import '../lib/controllers/inicio_controller.dart';

void conferir(int total, int vistos, int revisados, bool enviado, List<int> esperado) {
  final estados = InicioController.classificarEstados(total, vistos, revisados, enviado);
  final valores = [
    estados['pendentes'], estados['visualizados'], estados['analisados'],
    estados['validando'], estados['submetidos'],
  ];
  for (var indice = 0; indice < valores.length; indice++) {
    if (valores[indice] != esperado[indice]) {
      throw StateError('Estado incorreto: total=$total, vistos=$vistos, revisados=$revisados, enviado=$enviado: $estados');
    }
  }
  if (estados.values.reduce((a, b) => a + b) != total) {
    throw StateError('As contagens não correspondem ao total de atribuições.');
  }
}

void main() {
  conferir(0, 0, 0, false, [0, 0, 0, 0, 0]);
  conferir(4, 0, 0, false, [4, 0, 0, 0, 0]);
  conferir(4, 2, 0, false, [2, 2, 0, 0, 0]);
  conferir(4, 3, 1, false, [1, 2, 1, 0, 0]);
  conferir(4, 4, 3, false, [0, 1, 3, 0, 0]);
  conferir(4, 4, 4, false, [0, 0, 0, 4, 0]);
  conferir(4, 4, 4, true, [0, 0, 0, 0, 4]);
  print('Estados da Home conferidos.');
}
