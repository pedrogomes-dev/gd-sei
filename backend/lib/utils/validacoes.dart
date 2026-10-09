class Validacoes {
  static bool inteiroSqlValido(dynamic valor) {
    if (valor is! int) return false;
    return valor >= -2147483648 && valor <= 2147483647;
  }

  static final _formatoEmail = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
  static final _caracteresEmail = RegExp(r'^[\x21-\x7E]+$');
  static final _formatoCodigoAcesso = RegExp(r'^[1-9][0-9]{5}$');

  static bool codigoAcessoValido(String codigo) {
    return _formatoCodigoAcesso.hasMatch(codigo);
  }

  static bool emailValido(String email) {
    final valor = email.trim();

    if (!_caracteresEmail.hasMatch(valor)) {
      return false;
    }

    return _formatoEmail.hasMatch(valor);
  }
}


