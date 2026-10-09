import 'package:flutter/material.dart';

import '../../services/api_service.dart';
import '../../utils/validacoes.dart';

class UserEditor extends StatefulWidget {
  final Map<String, dynamic>? usuario;
  final List<dynamic> orgaos;
  final int idUsuarioAtual;

  const UserEditor({
    super.key,
    required this.usuario,
    required this.orgaos,
    required this.idUsuarioAtual,
  });

  @override
  State<UserEditor> createState() => _UserEditorState();
}

class _UserEditorState extends State<UserEditor> {
  final formulario = GlobalKey<FormState>();
  final nome = TextEditingController();
  final email = TextEditingController();
  final orgaosSelecionados = <int>{};

  bool acessoAtivo = true;
  bool administrador = false;
  bool salvando = false;
  String? erro;

  @override
  void initState() {
    super.initState();

    final usuario = widget.usuario;
    if (usuario == null) return;

    nome.text = usuario['nome']?.toString() ?? '';
    email.text = usuario['email'].toString();
    acessoAtivo = usuario['sin_ativo'] == 'S';
    administrador = usuario['sin_admin'] == 'S';

    for (final idOrgao in usuario['orgaos'] as List) {
      orgaosSelecionados.add(int.parse(idOrgao.toString()));
    }
  }

  @override
  void dispose() {
    nome.dispose();
    email.dispose();
    super.dispose();
  }

  String? validarNome(String? valor) {
    if (valor == null || valor.trim().isEmpty) {
      return 'Informe o nome.';
    }
    if (valor.trim().length > 150) {
      return 'Use até 150 caracteres.';
    }
    return null;
  }

  String? validarEmail(String? valor) {
    if (valor == null || !Validacoes.emailValido(valor)) {
      return 'Informe um e-mail válido.';
    }
    if (valor.trim().length > 250) {
      return 'Use até 250 caracteres.';
    }
    return null;
  }

  Future<void> salvar() async {
    if (!formulario.currentState!.validate()) return;

    setState(() {
      salvando = true;
      erro = null;
    });

    final usuario = widget.usuario;
    int? idUsuario;
    int revisao = 0;

    if (usuario != null) {
      idUsuario = int.parse(usuario['id_usuario'].toString());
      revisao = int.parse(usuario['revisao'].toString());
    }

    final orgaos = orgaosSelecionados.toList();
    orgaos.sort();

    final dados = {
      'nome': nome.text.trim(),
      'email': email.text.trim(),
      'sin_ativo': acessoAtivo ? 'S' : 'N',
      'sin_admin': administrador ? 'S' : 'N',
      'revisao': revisao,
      'orgaos': orgaos,
    };

    try {
      final resultado = await ApiService().salvarUsuario(idUsuario, dados);
      if (!mounted) return;

      setState(() => salvando = false);
      Navigator.pop(context, resultado);
    } catch (excecao) {
      if (!mounted) return;
      setState(() {
        erro = excecao.toString();
        salvando = false;
      });
    }
  }

  Widget camposCadastro() {
    return Column(
      children: [
        TextFormField(
          controller: nome,
          maxLength: 150,
          decoration: const InputDecoration(labelText: 'Nome'),
          validator: validarNome,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: email,
          maxLength: 250,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(labelText: 'E-mail'),
          validator: validarEmail,
        ),
      ],
    );
  }

  Widget permissoes() {
    return Column(
      children: [
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Acesso ativo'),
          value: acessoAtivo,
          onChanged: (valor) => setState(() => acessoAtivo = valor),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Administrador'),
          subtitle: const Text('Permite gerenciar usuários e vínculos.'),
          value: administrador,
          onChanged: (valor) => setState(() => administrador = valor),
        ),
      ],
    );
  }

  Widget vinculosOrgaos() {
    final itens = <Widget>[
      const Text('Órgãos vinculados', style: TextStyle(fontWeight: FontWeight.w600)),
      const Text('Permite avaliar os processos atribuídos a esses órgãos.'),
    ];

    if (widget.orgaos.isEmpty) {
      itens.add(const Text('Nenhum órgão cadastrado.'));
    }

    for (final orgao in widget.orgaos) {
      final idOrgao = int.parse(orgao['id_orgao'].toString());
      itens.add(
        CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          controlAffinity: ListTileControlAffinity.leading,
          title: Text(orgao['sigla'].toString()),
          value: orgaosSelecionados.contains(idOrgao),
          onChanged: (marcado) {
            setState(() {
              if (marcado == true) {
                orgaosSelecionados.add(idOrgao);
              } else {
                orgaosSelecionados.remove(idOrgao);
              }
            });
          },
        ),
      );
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: itens);
  }

  Widget avisos() {
    final editandoProprioUsuario =
        widget.usuario?['id_usuario'].toString() == widget.idUsuarioAtual.toString();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Alterações de e-mail, acesso, perfil ou órgãos encerram as sessões do usuário.'),
        if (editandoProprioUsuario)
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text('Você está editando seu cadastro. Alterar permissões exige entrar novamente.'),
          ),
        if (erro != null)
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Text(erro!, style: const TextStyle(color: Colors.red)),
          ),
        if (salvando) const LinearProgressIndicator(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !salvando,
      child: AlertDialog(
        title: Text(widget.usuario == null ? 'Cadastrar usuário' : 'Editar usuário'),
        content: SizedBox(
          width: 640,
          child: SingleChildScrollView(
            child: IgnorePointer(
              ignoring: salvando,
              child: Form(
                key: formulario,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    camposCadastro(),
                    const SizedBox(height: 12),
                    permissoes(),
                    const SizedBox(height: 16),
                    vinculosOrgaos(),
                    const SizedBox(height: 16),
                    avisos(),
                  ],
                ),
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: salvando ? null : () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: salvando ? null : salvar,
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }
}
