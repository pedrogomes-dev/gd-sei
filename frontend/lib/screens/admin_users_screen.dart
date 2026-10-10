import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../widgets/app_shell.dart';
import '../widgets/admin/user_editor.dart';
import '../widgets/admin/user_filters.dart';
import '../widgets/admin/user_table.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  final api = ApiService();
  final pesquisa = TextEditingController();

  List<dynamic> orgaos = [];
  List<dynamic> usuarios = [];
  int? idOrgao;
  int idUsuarioAtual = 0;
  int inicio = 0;
  int total = 0;
  Map<String, int> quantidades = {};
  int numeroRequisicao = 0;
  String situacao = 'TODOS';
  String pesquisaAplicada = '';
  bool carregando = true;
  bool autorizado = false;
  bool temProximaPagina = false;
  String? erro;

  @override
  void initState() {
    super.initState();
    iniciar();
  }

  @override
  void dispose() {
    pesquisa.dispose();
    super.dispose();
  }

  Future<void> iniciar() async {
    setState(() {
      carregando = true;
      erro = null;
    });

    try {
      final perfil = await api.profile();
      if (perfil['sin_admin'] != 'S') {
        throw Exception('Acesso restrito à administração.');
      }

      final orgaosCadastrados = await api.listarOrgaos();
      if (!mounted) return;

      setState(() {
        idUsuarioAtual = int.parse(perfil['id_usuario'].toString());
        orgaos = orgaosCadastrados;
        autorizado = true;
      });
      await pesquisar();
    } catch (excecao) {
      if (!mounted) return;
      setState(() {
        erro = excecao.toString();
        carregando = false;
      });
    }
  }

  Future<void> pesquisar({int pagina = 0, bool paginando = false}) async {
    final requisicaoAtual = ++numeroRequisicao;
    final texto = paginando ? pesquisaAplicada : pesquisa.text.trim();

    setState(() {
      carregando = true;
      erro = null;
    });

    try {
      final resultado = await api.listarUsuarios(texto, situacao, idOrgao, pagina);
      if (!mounted || requisicaoAtual != numeroRequisicao) return;

      setState(() {
        usuarios = resultado['itens'] as List;
        quantidades = Map<String, dynamic>.from(resultado['quantidades'] as Map? ?? {})
            .map((chave, valor) => MapEntry(chave, int.parse(valor.toString())));
        total = int.parse(resultado['total'].toString());
        temProximaPagina = resultado['mais'] == true;
        inicio = pagina;
        pesquisaAplicada = texto;
      });
    } catch (excecao) {
      if (mounted && requisicaoAtual == numeroRequisicao) {
        setState(() => erro = excecao.toString());
      }
    } finally {
      if (mounted && requisicaoAtual == numeroRequisicao) {
        setState(() => carregando = false);
      }
    }
  }

  void alterarOrgao(int? valor) {
    setState(() => idOrgao = valor);
    pesquisar();
  }

  void alterarSituacao(String valor) {
    setState(() => situacao = situacao == valor ? 'TODOS' : valor);
    pesquisar();
  }

  Future<void> editarUsuario(int? idUsuario) async {
    setState(() {
      carregando = true;
      erro = null;
    });

    Map<String, dynamic>? usuario;
    try {
      if (idUsuario != null) usuario = await api.buscarUsuario(idUsuario);
    } catch (excecao) {
      if (!mounted) return;
      setState(() {
        erro = excecao.toString();
        carregando = false;
      });
      return;
    }

    if (!mounted) return;

    final resultado = await showDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: false,
      builder: (_) => UserEditor(
        usuario: usuario,
        orgaos: orgaos,
        idUsuarioAtual: idUsuarioAtual,
      ),
    );

    if (!mounted) return;
    setState(() => carregando = false);
    if (resultado == null) return;

    final idSalvo = int.parse(resultado['id_usuario'].toString());
    final sessaoRevogada = resultado['sessoes_revogadas'].toString() == '1';
    if (idSalvo == idUsuarioAtual && sessaoRevogada) {
      Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Cadastro salvo.')),
    );
    await pesquisar();
  }

  void abrirHistorico(int idUsuario) {
    Navigator.pushNamed(context, '/admin/usuarios/$idUsuario/historico');
  }

  Widget mensagemErro() {
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(erro!),
          const SizedBox(height: 12),
          TextButton(
            onPressed: carregando ? null : tentarNovamente,
            child: const Text('Tentar novamente'),
          ),
        ],
      ),
    );
  }

  void tentarNovamente() {
    if (autorizado) {
      pesquisar();
    } else {
      iniciar();
    }
  }

  Widget filtros() {
    return SectionCard(
      child: UserFilters(
        pesquisa: pesquisa,
        orgaos: orgaos,
        idOrgao: idOrgao,
        situacao: situacao,
        quantidades: quantidades,
        carregando: carregando,
        pesquisar: () => pesquisar(),
        alterarOrgao: alterarOrgao,
        alterarSituacao: alterarSituacao,
      ),
    );
  }

  Widget paginacao() {
    final primeiro = usuarios.isEmpty ? 0 : inicio + 1;
    final ultimo = inicio + usuarios.length;

    return Wrap(
      spacing: 16,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text('Exibindo $primeiro–$ultimo de $total'),
        if (inicio > 0)
          TextButton(
            onPressed: () => pesquisar(pagina: inicio - 50, paginando: true),
            child: const Text('Anterior'),
          ),
        if (temProximaPagina)
          TextButton(
            onPressed: () => pesquisar(pagina: inicio + 50, paginando: true),
            child: const Text('Próxima'),
          ),
      ],
    );
  }

  Widget resultados() {
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$total usuários encontrados'),
          const SizedBox(height: 16),
          if (usuarios.isEmpty)
            const Text('Nenhum usuário encontrado.')
          else
            UserTable(
              usuarios: usuarios,
              editar: editarUsuario,
              abrirHistorico: abrirHistorico,
            ),
          const SizedBox(height: 16),
          paginacao(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      title: 'Administração de usuários',
      section: 'admin-usuarios',
      trail: const ['Usuários'],
      actions: [
        FilledButton.icon(
          onPressed: carregando || !autorizado ? null : () => editarUsuario(null),
          icon: const Icon(Icons.person_add_outlined),
          label: const Text('Cadastrar usuário'),
        ),
      ],
      child: ListView(
        padding: const EdgeInsets.fromLTRB(32, 0, 32, 32),
        children: [
          if (erro != null) mensagemErro(),
          if (carregando) const LinearProgressIndicator(),
          if (autorizado) filtros(),
          if (autorizado && !carregando && erro == null) resultados(),
        ],
      ),
    );
  }
}

