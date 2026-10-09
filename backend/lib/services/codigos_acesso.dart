import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

import '../models/api_error.dart';
import '../utils/validacoes.dart';

class CodigoAcesso {
  final int idUsuario;
  final int versaoSessao;
  final String hash;
  final DateTime validade;
  int tentativas = 0;
  bool enviado = false;

  CodigoAcesso(this.idUsuario, this.versaoSessao, this.hash, this.validade);
}

class CodigosAcesso {
  final _codigos = <String, CodigoAcesso>{};
  final _ultimoEnvio = <String, DateTime>{};
  final _enviosPorIp = <String, List<DateTime>>{};
  final _emEnvio = <String>{};
  final _random = Random.secure();
  final DateTime Function() agora;
  late final Hmac _hash = Hmac(sha256, List.generate(32, (_) => _random.nextInt(256)));

  CodigosAcesso({DateTime Function()? relogio})
      : agora = relogio ?? (() => DateTime.now().toUtc());

  String calcularHash(String email, String codigo) {
    return _hash.convert(utf8.encode('$email:$codigo')).toString();
  }

  void limparExpirados() {
    final instante = agora();
    _codigos.removeWhere((_, codigo) => !codigo.validade.isAfter(instante));
    _ultimoEnvio.removeWhere((_, data) => instante.difference(data).inMinutes >= 10);
    for (final envios in _enviosPorIp.values) {
      envios.removeWhere((data) => instante.difference(data).inMinutes >= 1);
    }
    _enviosPorIp.removeWhere((_, envios) => envios.isEmpty);
  }

  void reservarEnvio(String email, String ip) {
    limparExpirados();
    final instante = agora();
    final ultimo = _ultimoEnvio[email];
    if (_emEnvio.contains(email) || (ultimo != null && instante.difference(ultimo).inSeconds < 60)) {
      throw ApiError(429, 'Aguarde 60 segundos antes de solicitar outro código.');
    }
    if (_emEnvio.length >= 20 || _ultimoEnvio.length >= 10000 || _enviosPorIp.length >= 10000) {
      throw ApiError(503, 'Acesso ocupado. Tente novamente mais tarde.');
    }
    final envios = _enviosPorIp.putIfAbsent(ip, () => []);
    if (envios.length >= 60) {
      throw ApiError(429, 'Muitas solicitações. Tente novamente mais tarde.');
    }
    envios.add(instante);
    _ultimoEnvio[email] = instante;
    _emEnvio.add(email);
    _codigos.remove(email);
  }

  String criar(String email, int idUsuario, int versaoSessao) {
    final codigo = (100000 + _random.nextInt(900000)).toString();
    _codigos[email] = CodigoAcesso(
      idUsuario,
      versaoSessao,
      calcularHash(email, codigo),
      agora().add(const Duration(minutes: 10)),
    );
    return codigo;
  }

  void confirmarEnvio(String email) {
    _codigos[email]?.enviado = true;
  }

  void cancelar(String email) {
    _codigos.remove(email);
  }

  void liberarEnvio(String email) {
    _emEnvio.remove(email);
  }

  CodigoAcesso consumir(String email, String codigo) {
    limparExpirados();
    final registro = _codigos[email];
    if (registro == null || !registro.enviado) {
      throw ApiError(401, 'Código inválido ou expirado.');
    }
    registro.tentativas++;
    final valido = Validacoes.codigoAcessoValido(codigo) && calcularHash(email, codigo) == registro.hash;
    if (!valido) {
      if (registro.tentativas >= 5) _codigos.remove(email);
      throw ApiError(401, 'Código inválido ou expirado.');
    }
    // Consome antes de qualquer await, impedindo dois logins com o mesmo código.
    _codigos.remove(email);
    return registro;
  }
}
