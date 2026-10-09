import 'package:flutter/material.dart';

import '../app_shell.dart';

class AdminHistoryCard extends StatelessWidget {
  final Map<String, dynamic> evento;
  final Map<int, String> orgaos;

  const AdminHistoryCard({
    super.key,
    required this.evento,
    required this.orgaos,
  });

  String tituloEvento() {
    switch (evento['evento']) {
      case 'USUARIO_CRIADO':
        return 'Usuário cadastrado';
      case 'ADMINISTRADOR_INICIAL':
        return 'Administrador inicial definido';
      default:
        return 'Cadastro atualizado';
    }
  }

  String dataEvento() {
    final valor = evento['data_evento'].toString();
    final data = DateTime.tryParse(valor)?.toLocal();
    if (data == null) return valor;

    String doisDigitos(int numero) => numero.toString().padLeft(2, '0');

    final dia = doisDigitos(data.day);
    final mes = doisDigitos(data.month);
    final ano = data.year;
    final hora = doisDigitos(data.hour);
    final minuto = doisDigitos(data.minute);
    final segundo = doisDigitos(data.second);

    return '$dia/$mes/$ano $hora:$minuto:$segundo';
  }

  String nomesOrgaos(List<dynamic> vinculos) {
    if (vinculos.isEmpty) return 'Sem vínculo';

    final nomes = <String>[];
    for (final vinculo in vinculos) {
      final idOrgao = int.parse(vinculo['id_orgao'].toString());
      nomes.add(orgaos[idOrgao] ?? 'Órgão $idOrgao');
    }
    return nomes.join(' · ');
  }

  Map<String, String> camposCadastro(dynamic cadastro) {
    if (cadastro == null) return {};

    return {
      'Nome': cadastro['nome']?.toString() ?? 'Não informado',
      'E-mail': cadastro['email'].toString(),
      'Acesso': cadastro['sin_ativo'] == 'S' ? 'Ativo' : 'Inativo',
      'Perfil': cadastro['sin_admin'] == 'S' ? 'Administrador' : 'Avaliador',
      'Órgãos': nomesOrgaos(cadastro['orgaos'] as List),
    };
  }

  Widget campoAlterado(String campo, String? antes, String depois) {
    final valorAnterior = antes ?? 'Não informado';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(campo, style: const TextStyle(fontWeight: FontWeight.w600)),
          if (evento['antes'] != null) SelectableText('Antes: $valorAnterior'),
          SelectableText('Depois: $depois'),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final antes = camposCadastro(evento['antes']);
    final depois = camposCadastro(evento['depois']);
    final alteracoes = <Widget>[];

    for (final campo in depois.keys) {
      if (antes[campo] != depois[campo]) {
        alteracoes.add(campoAlterado(campo, antes[campo], depois[campo]!));
      }
    }

    if (alteracoes.isEmpty) {
      alteracoes.add(const Text('Cadastro salvo sem alteração dos campos.'));
    }

    final email = evento['responsavel_email'].toString();
    final responsavel = evento['responsavel_nome']?.toString() ?? email;
    final data = dataEvento();

    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(tituloEvento(), style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text('$data · $responsavel ($email)'),
          const SizedBox(height: 16),
          ...alteracoes,
        ],
      ),
    );
  }
}
