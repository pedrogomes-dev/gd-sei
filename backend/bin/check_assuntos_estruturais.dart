import 'dart:convert';
import 'dart:io';

import '../lib/config/database_config.dart';
import '../lib/repositories/database_repository.dart';

// Diagnóstico somente leitura; não corrige referências, snapshots ou vínculos.
Future<void> main() async {
  final banco = DatabaseRepository(DatabaseConfig.fromEnvironment());
  for (final tabela in ['ref_assunto', 'assunto']) {
    final colunas = await banco.query(
      'SELECT COL_LENGTH(?, ?) AS tamanho',
      params: ['dbo.$tabela', 'sin_estrutural'],
    );
    stdout.writeln('$tabela.sin_estrutural: ${jsonEncode(colunas)}');
  }
  final vinculos = await banco.query('''
    SELECT r.versao, r.id_tipo_procedimento, a.id_assunto, a.codigo_estruturado
    FROM dbo.rel_tipo_procedimento_assunto r
    JOIN dbo.assunto a ON a.versao = r.versao AND a.id_assunto = r.id_assunto_proxy
    WHERE a.sin_estrutural = 'S'
    ORDER BY r.versao, r.id_tipo_procedimento, a.id_assunto
  ''');
  stdout.writeln(
      'Vínculos estruturais existentes (${vinculos.length}): ${jsonEncode(vinculos)}');
  final propostas = await banco.query('''
    SELECT m.id_atribuicao, m.versao, m.id_assunto
    FROM dbo.manifestacao_vinculo m
    JOIN dbo.assunto a ON a.versao = m.versao AND a.id_assunto = m.id_assunto
    WHERE a.sin_estrutural = 'S' AND m.acao = 'ADICIONAR'
    ORDER BY m.versao, m.id_atribuicao, m.id_assunto
  ''');
  stdout.writeln(
      'Propostas estruturais existentes (${propostas.length}): ${jsonEncode(propostas)}');
}
