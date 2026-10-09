class Validacoes {
  static final _formatoEmail = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
  static final _caracteresEmail = RegExp(r'^[\x21-\x7E]+$');

  static bool emailValido(String email) {
    final valor = email.trim();

    if (!_caracteresEmail.hasMatch(valor)) {
      return false;
    }

    return _formatoEmail.hasMatch(valor);
  }
}
