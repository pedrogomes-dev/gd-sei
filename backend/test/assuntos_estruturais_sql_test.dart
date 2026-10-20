import '../lib/config/database_config.dart';
import '../lib/controllers/manifestacao_controller.dart';
import '../lib/models/api_error.dart';
import '../lib/repositories/consulta_repository.dart';
import '../lib/repositories/database_repository.dart';

// Testa a consulta de elegibilidade real, sem chamar salvar/procedures ou gravar.
// A autorização é simulada aqui; é coberta separadamente no teste do controller.
class ConsultaVersaoTeste extends ConsultaRepository {
  final int versao;
  ConsultaVersaoTeste(super.db, this.versao);

  @override
  Future<Map<String, dynamic>> detail(int userId, int id) async => {
        'tipo': {'versao': versao},
      };
}

Future<void> main() async {
  final banco = DatabaseRepository(DatabaseConfig.fromEnvironment());
  final candidatos = await banco.query('''
    SELECT TOP (1) a.versao, a.id_assunto
    FROM dbo.assunto a
    WHERE a.sin_estrutural = 'S'
    ORDER BY a.versao DESC, a.id_assunto
  ''');
  if (candidatos.isEmpty)
    throw StateError('Sem Assunto estrutural para testar.');

  Future<void> validar(Map<String, dynamic> assunto, int atribuicao) async {
    final versao = int.parse(assunto['versao'].toString());
    final controller =
        ManifestacaoController(banco, ConsultaVersaoTeste(banco, versao));
    await controller.validarInclusoesEstruturais(0, atribuicao, [
      {
        'id_assunto': int.parse(assunto['id_assunto'].toString()),
        'acao': 'ADICIONAR'
      },
    ]);
  }

  // ID negativo não existe (atribuições usam IDENTITY); nenhuma escrita é feita.
  try {
    await validar(candidatos.first, -1);
    throw StateError('SQL aceitou nova inclusão estrutural.');
  } on ApiError catch (erro) {
    if (erro.status != 400) rethrow;
  }

  final paisClassificaveis = await banco.query('''
    SELECT TOP (1) a.versao, a.id_assunto
    FROM dbo.assunto a
    WHERE a.sin_estrutural = 'N' AND a.sin_ativo = 'S'
      AND EXISTS (SELECT 1 FROM dbo.assunto filho
        WHERE filho.versao = a.versao AND filho.id_assunto_pai = a.id_assunto)
    ORDER BY a.versao DESC, a.id_assunto
  ''');
  if (paisClassificaveis.isEmpty)
    throw StateError('Sem pai classificável para testar.');
  await validar(paisClassificaveis.first, -1);

  final propostas = await banco.query('''
    SELECT m.versao, m.id_assunto, m.id_atribuicao
    FROM dbo.manifestacao_vinculo m
    JOIN dbo.assunto a ON a.versao = m.versao AND a.id_assunto = m.id_assunto
    WHERE a.sin_estrutural = 'S' AND m.acao = 'ADICIONAR'
  ''');
  for (final proposta in propostas) {
    await validar(proposta, int.parse(proposta['id_atribuicao'].toString()));
  }
  print(
      'SQL Server somente leitura: nova inclusão estrutural rejeitada, pai N aceito, '
      '${propostas.length} propostas preexistentes preservadas. Autorização simulada.');
}
