import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

import '../config/settings.dart';
import '../models/api_error.dart';

class EmailService {
  void verificarConfiguracao() {
    final configuracao = loadSettings();
    for (final campo in ['SMTP_HOST', 'SMTP_USER', 'SMTP_PASSWORD', 'SMTP_FROM']) {
      if ((configuracao[campo] ?? '').trim().isEmpty) {
        throw ApiError(503, 'O envio de e-mail ainda não está configurado.');
      }
    }
    final porta = int.tryParse(configuracao['SMTP_PORT'] ?? '587');
    if (porta == null || porta < 1 || porta > 65535) {
      throw ApiError(503, 'Configuração de e-mail inválida.');
    }
    final ssl = configuracao['SMTP_SSL'] ?? 'false';
    if (ssl != 'true' && ssl != 'false') {
      throw ApiError(503, 'Configuração de e-mail inválida.');
    }
  }

  Future<void> enviarCodigo(String destinatario, String codigo) async {
    verificarConfiguracao();
    final configuracao = loadSettings();
    final servidor = SmtpServer(
      configuracao['SMTP_HOST']!,
      port: int.parse(configuracao['SMTP_PORT'] ?? '587'),
      username: configuracao['SMTP_USER'],
      password: configuracao['SMTP_PASSWORD'],
      ssl: configuracao['SMTP_SSL'] == 'true',
      allowInsecure: false,
      ignoreBadCertificate: false,
    );
    final mensagem = Message()
      ..from = Address(configuracao['SMTP_FROM']!, 'GD-SEI')
      ..recipients.add(destinatario)
      ..subject = 'GD-SEI: código de acesso'
      ..text = 'Seu código de acesso é: $codigo\n\n'
          'Ele é válido por 10 minutos e pode ser usado uma única vez.\n'
          'Não compartilhe este código.\n'
          'Se você não solicitou acesso, ignore esta mensagem.';

    try {
      await send(mensagem, servidor, timeout: const Duration(seconds: 15))
          .timeout(const Duration(seconds: 20));
    } catch (_) {
      // Não expor respostas SMTP, senha, destinatário ou código nos logs.
      throw ApiError(503, 'Não foi possível enviar o e-mail. Tente novamente mais tarde.');
    }
  }
}
