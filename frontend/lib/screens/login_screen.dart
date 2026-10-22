import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/api_service.dart';

class LoginScreen extends StatefulWidget {
  final ApiService? api;
  const LoginScreen({super.key, this.api});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late final api = widget.api ?? ApiService();
  final email = TextEditingController();
  final codigo = TextEditingController();
  late final configuracao = api.configurarAcesso();
  Timer? contador;
  int segundosReenvio = 0;
  bool ocupado = false;
  bool codigoSolicitado = false;
  String? erro;
  String? mensagem;
  int? usuarioDesenvolvimento;

  @override
  void dispose() {
    contador?.cancel();
    email.dispose();
    codigo.dispose();
    super.dispose();
  }

  void iniciarContagem() {
    contador?.cancel();
    segundosReenvio = 60;
    contador = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() => segundosReenvio--);
      if (segundosReenvio == 0) timer.cancel();
    });
  }

  Future<void> solicitarCodigo() async {
    if (email.text.trim().isEmpty) {
      setState(() => erro = 'Informe seu e-mail cadastrado.');
      return;
    }
    setState(() {
      ocupado = true;
      erro = null;
      mensagem = null;
    });
    try {
      await api.solicitarCodigo(email.text.trim());
      if (!mounted) return;
      setState(() {
        codigoSolicitado = true;
        codigo.clear();
        mensagem =
            'Se o e-mail estiver cadastrado e ativo, você receberá um código válido por 10 minutos.';
        iniciarContagem();
      });
    } catch (falha) {
      if (mounted) setState(() => erro = falha.toString());
    } finally {
      if (mounted) setState(() => ocupado = false);
    }
  }

  Future<void> entrar({bool temporario = false}) async {
    if (temporario && usuarioDesenvolvimento == null) return;
    if (!temporario && codigo.text.trim().length != 6) {
      setState(
          () => erro = 'Informe o código de 6 dígitos recebido por e-mail.');
      return;
    }
    setState(() {
      ocupado = true;
      erro = null;
    });
    try {
      if (temporario) {
        await api.loginDesenvolvimento(usuarioDesenvolvimento!);
      } else {
        await api.entrarEmail(email.text.trim(), codigo.text.trim());
      }
      if (mounted) Navigator.pushReplacementNamed(context, '/inicio');
    } catch (falha) {
      if (mounted) setState(() => erro = falha.toString());
    } finally {
      if (mounted) setState(() => ocupado = false);
    }
  }

  void alterarEmail() {
    setState(() {
      codigoSolicitado = false;
      codigo.clear();
      erro = null;
      mensagem = null;
    });
  }

  Widget acessoTemporario() {
    return FutureBuilder<Map<String, dynamic>>(
      future: configuracao,
      builder: (context, resultado) {
        if (resultado.data?['acesso_temporario'] != true)
          return const SizedBox.shrink();
        final usuarios = resultado.data?['usuarios'] as List? ?? [];
        return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              const Text('Acesso de testes — desenvolvimento'),
              const SizedBox(height: 8),
              if (usuarios.isEmpty)
                const Text('Nenhum usuário ativo disponível.')
              else
                DropdownButtonFormField<int>(
                  initialValue: usuarioDesenvolvimento,
                  isExpanded: true,
                  decoration: const InputDecoration(
                      labelText: 'Personificar usuário ativo'),
                  items: [
                    for (final usuario in usuarios)
                      DropdownMenuItem(
                        value: int.parse(usuario['id_usuario'].toString()),
                        child: Text('${usuario['nome']} — ${usuario['email']}',
                            overflow: TextOverflow.ellipsis),
                      )
                  ],
                  onChanged: ocupado
                      ? null
                      : (id) => setState(() => usuarioDesenvolvimento = id),
                ),
              TextButton(
                onPressed: ocupado || usuarioDesenvolvimento == null
                    ? null
                    : () => entrar(temporario: true),
                child: const Text('Entrar como usuário selecionado'),
              ),
            ]);
      },
    );
  }

  Widget formulario() {
    final reenviar = segundosReenvio > 0
        ? 'Reenviar em $segundosReenvio s'
        : 'Reenviar código';
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Image.asset(
          'assets/images/logo.png',
          height: 72,
          fit: BoxFit.contain,
          semanticLabel: 'Gestão Documental SEI',
        ),
        const SizedBox(height: 24),
        const Text('Acesso por e-mail',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
        const SizedBox(height: 16),
        TextField(
          controller: email,
          enabled: !ocupado,
          readOnly: codigoSolicitado,
          keyboardType: TextInputType.emailAddress,
          autofillHints: const [AutofillHints.email],
          decoration: const InputDecoration(labelText: 'E-mail cadastrado'),
          onSubmitted: (_) {
            if (!ocupado && !codigoSolicitado && segundosReenvio == 0)
              solicitarCodigo();
          },
        ),
        if (codigoSolicitado) ...[
          Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                  onPressed: ocupado ? null : alterarEmail,
                  child: const Text('Alterar e-mail'))),
          TextField(
            controller: codigo,
            enabled: !ocupado,
            keyboardType: TextInputType.number,
            autofillHints: const [AutofillHints.oneTimeCode],
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(6)
            ],
            decoration: const InputDecoration(labelText: 'Código de 6 dígitos'),
            onSubmitted: (_) {
              if (!ocupado) entrar();
            },
          ),
        ],
        if (mensagem != null)
          Padding(
              padding: const EdgeInsets.only(top: 16), child: Text(mensagem!)),
        if (erro != null)
          Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text(erro!,
                  style:
                      TextStyle(color: Theme.of(context).colorScheme.error))),
        const SizedBox(height: 16),
        if (codigoSolicitado) ...[
          FilledButton(
              onPressed: ocupado ? null : () => entrar(),
              child: Text(ocupado ? 'Aguarde…' : 'Entrar')),
          TextButton(
              onPressed:
                  ocupado || segundosReenvio > 0 ? null : solicitarCodigo,
              child: Text(reenviar)),
        ] else
          FilledButton(
              onPressed:
                  ocupado || segundosReenvio > 0 ? null : solicitarCodigo,
              child: Text(ocupado
                  ? 'Enviando…'
                  : segundosReenvio > 0
                      ? reenviar
                      : 'Receber código')),
        acessoTemporario(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestão Documental SEI'),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: const Border(
          bottom: BorderSide(color: Color(0xffe2e8f0)),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: SizedBox(
              width: 450,
              child: Card(
                  child: Padding(
                      padding: const EdgeInsets.all(24), child: formulario()))),
        ),
      ),
    );
  }
}
