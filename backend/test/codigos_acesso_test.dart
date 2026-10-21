import 'package:test/test.dart';

import '../lib/models/api_error.dart';
import '../lib/services/codigos_acesso.dart';

void verificar(bool condicao, String mensagem) {
  if (!condicao) throw StateError(mensagem);
}

void deveNegar(void Function() operacao, int status) {
  try {
    operacao();
  } on ApiError catch (erro) {
    verificar(erro.status == status, 'Status inesperado.');
    return;
  }
  throw StateError('A operação deveria ter sido negada.');
}

void main() {
  test('códigos: uso único, expiração, reenvio e limites', executarCenarios);
}

void executarCenarios() {
  var instante = DateTime.utc(2026, 10, 9);
  final armazenamento = CodigosAcesso(relogio: () => instante);
  const email = 'teste@setic.ro.gov.br';
  const ip = '127.0.0.1';

  armazenamento.reservarEnvio(email, ip);
  final codigo = armazenamento.criar(email, 1, 2);
  verificar(int.parse(codigo) >= 100000 && int.parse(codigo) <= 999999,
      'Código fora da faixa.');
  deveNegar(() => armazenamento.consumir(email, codigo), 401);
  armazenamento.confirmarEnvio(email);
  armazenamento.liberarEnvio(email);
  final registro = armazenamento.consumir(email, codigo);
  verificar(registro.idUsuario == 1 && registro.versaoSessao == 2,
      'Cadastro perdido.');
  verificar(registro.hash != codigo && registro.hash.length == 64,
      'Código armazenado sem hash.');
  deveNegar(() => armazenamento.consumir(email, codigo), 401);
  deveNegar(() => armazenamento.reservarEnvio(email, ip), 429);

  instante = instante.add(const Duration(seconds: 60));
  armazenamento.reservarEnvio(email, ip);
  final expirado = armazenamento.criar(email, 1, 2);
  armazenamento.confirmarEnvio(email);
  armazenamento.liberarEnvio(email);
  instante = instante.add(const Duration(minutes: 10));
  deveNegar(() => armazenamento.consumir(email, expirado), 401);

  armazenamento.reservarEnvio(email, ip);
  final bloqueado = armazenamento.criar(email, 1, 2);
  armazenamento.confirmarEnvio(email);
  armazenamento.liberarEnvio(email);
  for (var tentativa = 0; tentativa < 5; tentativa++) {
    deveNegar(() => armazenamento.consumir(email, '000000'), 401);
  }
  deveNegar(() => armazenamento.consumir(email, bloqueado), 401);

  instante = instante.add(const Duration(minutes: 1));
  armazenamento.reservarEnvio(email, ip);
  final anterior = armazenamento.criar(email, 1, 2);
  armazenamento.confirmarEnvio(email);
  armazenamento.liberarEnvio(email);
  instante = instante.add(const Duration(minutes: 1));
  armazenamento.reservarEnvio(email, ip);
  var novo = armazenamento.criar(email, 1, 2);
  while (novo == anterior) {
    novo = armazenamento.criar(email, 1, 2);
  }
  armazenamento.confirmarEnvio(email);
  armazenamento.liberarEnvio(email);
  deveNegar(() => armazenamento.consumir(email, anterior), 401);
  armazenamento.consumir(email, novo);

  final limitado = CodigosAcesso(relogio: () => instante);
  for (var indice = 0; indice < 60; indice++) {
    final endereco = 'usuario$indice@setic.ro.gov.br';
    limitado.reservarEnvio(endereco, ip);
    limitado.liberarEnvio(endereco);
  }
  deveNegar(() => limitado.reservarEnvio('outro@setic.ro.gov.br', ip), 429);
  instante = instante.add(const Duration(minutes: 1));
  limitado.reservarEnvio('outro@setic.ro.gov.br', ip);
  limitado.liberarEnvio('outro@setic.ro.gov.br');
  print(
      'Códigos: uso único, expiração, tentativas, reenvio, hash e limite por IP verificados.');
}
