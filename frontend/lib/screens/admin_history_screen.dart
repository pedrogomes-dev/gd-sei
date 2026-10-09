import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../widgets/app_shell.dart';
import '../widgets/admin/admin_history_card.dart';

class AdminHistoryScreen extends StatefulWidget {
  final int id;

  const AdminHistoryScreen({super.key, required this.id});

  @override
  State<AdminHistoryScreen> createState() => _AdminHistoryScreenState();
}

class _AdminHistoryScreenState extends State<AdminHistoryScreen> {
  final api = ApiService();

  List<dynamic> eventos = [];
  Map<int, String> orgaos = {};
  String titulo = 'Histórico administrativo';
  String? erro;
  int inicio = 0;
  bool carregando = true;
  bool temProximaPagina = false;

  @override
  void initState() {
    super.initState();
    iniciar();
  }

  Future<void> iniciar() async {
    setState(() {
      carregando = true;
      erro = null;
    });

    try {
      final usuario = await api.buscarUsuario(widget.id);
      final orgaosCadastrados = await api.listarOrgaos();
      if (!mounted) return;

      final nomesOrgaos = <int, String>{};
      for (final orgao in orgaosCadastrados) {
        final idOrgao = int.parse(orgao['id_orgao'].toString());
        nomesOrgaos[idOrgao] = orgao['sigla'].toString();
      }

      final nome = usuario['nome'] ?? usuario['email'];
      setState(() {
        titulo = 'Histórico de $nome';
        orgaos = nomesOrgaos;
      });
      await carregarPagina(0);
    } catch (excecao) {
      if (!mounted) return;
      setState(() {
        erro = excecao.toString();
        carregando = false;
      });
    }
  }

  Future<void> carregarPagina(int pagina) async {
    setState(() {
      carregando = true;
      erro = null;
    });

    try {
      final resultado = await api.consultarHistoricoUsuario(widget.id, pagina);
      if (!mounted) return;

      setState(() {
        eventos = resultado['itens'] as List;
        temProximaPagina = resultado['mais'] == true;
        inicio = pagina;
      });
    } catch (excecao) {
      if (mounted) setState(() => erro = excecao.toString());
    } finally {
      if (mounted) setState(() => carregando = false);
    }
  }

  Widget mensagemErro() {
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(erro!),
          TextButton(
            onPressed: carregando ? null : iniciar,
            child: const Text('Tentar novamente'),
          ),
        ],
      ),
    );
  }

  Widget paginacao() {
    final pagina = inicio ~/ 50 + 1;

    return Wrap(
      spacing: 16,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text('Página $pagina'),
        if (inicio > 0)
          TextButton(
            onPressed: () => carregarPagina(inicio - 50),
            child: const Text('Anterior'),
          ),
        if (temProximaPagina)
          TextButton(
            onPressed: () => carregarPagina(inicio + 50),
            child: const Text('Próxima'),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      title: titulo,
      section: 'admin-usuarios',
      trail: const ['Usuários', 'Histórico'],
      actions: [
        TextButton.icon(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
          label: const Text('Voltar'),
        ),
      ],
      child: ListView(
        padding: const EdgeInsets.fromLTRB(32, 0, 32, 32),
        children: [
          const Text('Alterações de cadastro, acesso, perfil e vínculos. Datas no fuso do navegador.'),
          const SizedBox(height: 24),
          if (carregando) const LinearProgressIndicator(),
          if (erro != null) mensagemErro(),
          if (!carregando && erro == null) ...[
            if (eventos.isEmpty)
              const SectionCard(child: Text('Nenhum evento registrado.')),
            for (final evento in eventos)
              AdminHistoryCard(
                evento: Map<String, dynamic>.from(evento as Map),
                orgaos: orgaos,
              ),
            paginacao(),
          ],
        ],
      ),
    );
  }
}
