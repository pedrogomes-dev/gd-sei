import 'package:flutter/material.dart';

import '../display_fields.dart';

class UserTable extends StatelessWidget {
  final List<dynamic> usuarios;
  final ValueChanged<int> editar;
  final ValueChanged<int> abrirHistorico;

  const UserTable({
    super.key,
    required this.usuarios,
    required this.editar,
    required this.abrirHistorico,
  });

  Widget celula(Widget conteudo) {
    return Padding(padding: const EdgeInsets.all(12), child: conteudo);
  }

  String nomesOrgaos(List<dynamic> orgaos) {
    if (orgaos.isEmpty) return 'Sem vínculo';
    return orgaos.map((orgao) => orgao['sigla']).join(' · ');
  }

  TableRow cabecalho() {
    const titulos = ['Nome', 'E-mail', 'Órgãos', 'Acesso', 'Perfil', 'Ações'];

    return TableRow(
      decoration: const BoxDecoration(color: Color(0xfff5f7fa)),
      children: [
        for (final titulo in titulos)
          celula(Text(titulo, style: const TextStyle(fontWeight: FontWeight.w600))),
      ],
    );
  }

  TableRow linhaUsuario(dynamic usuario) {
    final idUsuario = int.parse(usuario['id_usuario'].toString());
    final situacao = usuario['sin_ativo'] == 'S' ? 'ATIVO' : 'INATIVO';
    final perfil = usuario['sin_admin'] == 'S' ? 'Administrador' : 'Avaliador';

    return TableRow(
      children: [
        celula(Text(usuario['nome']?.toString() ?? 'Nome não informado')),
        celula(Text(usuario['email'].toString())),
        celula(Text(nomesOrgaos(usuario['orgaos'] as List))),
        celula(StatusTag(situacao)),
        celula(Text(perfil)),
        celula(
          Row(
            children: [
              IconButton(
                tooltip: 'Editar usuário',
                onPressed: () => editar(idUsuario),
                icon: const Icon(Icons.edit_outlined),
              ),
              IconButton(
                tooltip: 'Histórico administrativo',
                onPressed: () => abrirHistorico(idUsuario),
                icon: const Icon(Icons.history),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, tamanho) {
        final largura = tamanho.maxWidth < 1000 ? 1000.0 : tamanho.maxWidth;

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: largura,
            child: Table(
              columnWidths: const {
                0: FlexColumnWidth(2),
                1: FlexColumnWidth(2),
                2: FlexColumnWidth(2),
                3: FixedColumnWidth(110),
                4: FixedColumnWidth(130),
                5: FixedColumnWidth(140),
              },
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              border: const TableBorder(
                horizontalInside: BorderSide(color: Color(0xffe2e8f0)),
              ),
              children: [
                cabecalho(),
                for (final usuario in usuarios) linhaUsuario(usuario),
              ],
            ),
          ),
        );
      },
    );
  }
}
