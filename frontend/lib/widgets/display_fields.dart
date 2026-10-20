import 'package:flutter/material.dart';
import '../services/api_exception.dart';

class ApiErrorMessage extends StatelessWidget {
  final Object error;
  final VoidCallback onRetry;

  const ApiErrorMessage({super.key, required this.error, required this.onRetry});

  void tentarNovamente(BuildContext context) {
    if (error is ApiException && (error as ApiException).statusCode == 401) {
      Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
      return;
    }
    onRetry();
  }

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      Text(error.toString()),
      const SizedBox(height: 16),
      OutlinedButton(
        onPressed: () => tentarNovamente(context),
        child: const Text('Tentar novamente'),
      ),
    ]);
  }
}

// As etiquetas sempre combinam texto, ícone e cor.
class StatusTag extends StatelessWidget {
  final String status;
  final String? label;
  const StatusTag(this.status, {super.key, this.label});
  @override
  Widget build(BuildContext context) {
    final (text, color, icon) = switch (status) {
      'ATIVO' => ('Ativo', Colors.green, Icons.check_circle_outline),
      'INATIVO' => ('Inativo', Colors.red, Icons.block),
      'MANTER' => ('Manter', Colors.blue, Icons.check_circle_outline),
      'REMOVER' => ('Remover', Colors.red, Icons.remove_circle_outline),
      'ADICIONAR' => ('Incluir', Colors.green, Icons.add_circle_outline),
      'VISUALIZADO' => ('Visualizado', Colors.blue, Icons.visibility_outlined),
      'FINALIZADA' => ('Finalizada', Colors.green, Icons.lock_outline),
      'AVALIADO' => ('Avaliado', Colors.green, Icons.check_circle_outline),
      'DESCONTINUAR' => ('Descontinuar', Colors.blueGrey, Icons.cancel_outlined),
      'EM_AVALIACAO' => ('Em avaliação', Colors.amber, Icons.pending_outlined),
      'NAO_VISUALIZADO' => ('Não visualizado', Colors.red, Icons.visibility_off_outlined),
      'RASCUNHO' => ('Rascunho', Colors.amber, Icons.edit_outlined),
      _ => ('Pendente', Colors.amber, Icons.pending_outlined),
    };
    return Chip(
      visualDensity:VisualDensity.compact,
      materialTapTargetSize:MaterialTapTargetSize.shrinkWrap,
      avatar: Icon(icon, size: 18, color: color.shade800),
      label: Text(label ?? text, style: TextStyle(color: color.shade900)),
      backgroundColor: color.shade50,
      side: BorderSide(color: color.shade200),
    );
  }
}

const propertyLabels = <String, String>{
  'sin_ativo': 'Ativo',
  'id_assunto': 'ID do Assunto',
  'codigo_estruturado': 'Código estruturado',
  'descricao': 'Descrição',
  'observacao': 'Observação',
  'idx_assunto': 'Índice de pesquisa',
  'prazo_intermediario': 'Prazo intermediário',
  'prazo_corrente': 'Prazo corrente',
  'sta_destinacao': 'Destinação (código)',
  'sin_estrutural': 'Estrutural',
  'id_tabela_assuntos': 'ID da tabela de Assuntos',
  'sequencia': 'Sequência',
  'id_tipo_procedimento': 'ID do Tipo de Processo',
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
  if(entry.key=='sta_destinacao')return destinationTile(entry.value);
  final raw = entry.value?.toString() ?? '—';
  final value = entry.key.startsWith('sin_')
      ? switch (raw) { 'S' => 'Sim', 'N' => 'Não', _ => raw }
      : raw;
  return ListTile(dense: true,
    title: Text(propertyLabels[entry.key] ?? entry.key), subtitle: Text(value));
}


// SEI: E = Eliminação; G = Guarda Permanente (IBICT/Arquivo Nacional).
// https://hipatia.ibict.br/wp-content/uploads/tainacan-items/1362/3292/META-2-Entrega-1-RELATORIO-METADADOS_SEI_v5-AN.pdf
(String, IconData) destinacaoAssunto(dynamic raw) {
  final code=raw?.toString().trim().toUpperCase()??'';
  return switch(code) {
    'E'=>('Eliminação',Icons.delete_outline),
    'G'=>('Guarda permanente',Icons.archive_outlined),
    ''=>('Não informada',Icons.help_outline),
    _=>('Código $code',Icons.help_outline),
  };
}

Widget destinationTile(dynamic raw) {
  final (label, icon) = destinacaoAssunto(raw);
  return ListTile(leading:Icon(icon),title:const Text('Destinação final'),subtitle:Text(label));
}

