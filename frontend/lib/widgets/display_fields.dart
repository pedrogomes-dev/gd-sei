import 'package:flutter/material.dart';

// As etiquetas sempre combinam texto, ícone e cor.
class StatusTag extends StatelessWidget {
  final String status;
  final String? label;
  const StatusTag(this.status, {super.key, this.label});
  @override
  Widget build(BuildContext context) {
    final (text, color, icon) = switch (status) {
      'MANTER' => ('Manter', Colors.blue, Icons.check_circle_outline),
      'REMOVER' => ('Remover', Colors.red, Icons.remove_circle_outline),
      'ADICIONAR' => ('Incluir', Colors.green, Icons.add_circle_outline),
      'VISUALIZADO' => ('Visualizado', Colors.blue, Icons.visibility_outlined),
      'FINALIZADA' => ('Finalizada', Colors.green, Icons.lock_outline),
      'RASCUNHO' => ('Rascunho', Colors.amber, Icons.edit_outlined),
      _ => ('Pendente', Colors.amber, Icons.pending_outlined),
    };
    return Chip(
      avatar: Icon(icon, size: 18, color: color.shade800),
      label: Text(label ?? text, style: TextStyle(color: color.shade900)),
      backgroundColor: color.shade50,
      side: BorderSide(color: color.shade200),
    );
  }
}

const propertyLabels = <String, String>{
  'id_assunto': 'ID do Assunto',
  'codigo_estruturado': 'Código estruturado',
  'descricao': 'Descrição',
  'observacao': 'Observação',
  'idx_assunto': 'Índice de pesquisa',
  'sin_ativo': 'Ativo',
  'prazo_intermediario': 'Prazo intermediário',
  'prazo_corrente': 'Prazo corrente',
  'sta_destinacao': 'Destinação (código)',
  'sin_estrutural': 'Estrutural',
  'id_tabela_assuntos': 'ID da tabela de Assuntos',
  'sequencia': 'Sequência',
  'id_tipo_procedimento': 'ID do Tipo',
  'nome': 'Nome',
  'sta_nivel_acesso_sugestao': 'Nível de acesso sugerido (código)',
  'sin_interno': 'Interno',
  'sin_ouvidoria': 'Ouvidoria',
  'sin_individual': 'Individual',
  'id_hipotese_legal_sugestao': 'ID da hipótese legal sugerida',
  'sta_grau_sigilo_sugestao': 'Grau de sigilo sugerido (código)',
  'id_plano_trabalho': 'ID do plano de trabalho',
  'sin_ouvidoria_anonimo': 'Ouvidoria anônima',
};

Widget propertyTile(MapEntry<String, dynamic> entry) {
  final raw = entry.value?.toString() ?? '—';
  final value = entry.key.startsWith('sin_')
      ? switch (raw) { 'S' => 'Sim', 'N' => 'Não', _ => raw }
      : raw;
  return ListTile(dense: true,
    title: Text(propertyLabels[entry.key] ?? entry.key), subtitle: Text(value));
}
