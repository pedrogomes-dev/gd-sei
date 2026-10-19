// Integração SQL opcional. Usa somente tabelas temporárias privadas da conexão;
// não altera tabelas/dados da aplicação nem usa sua trava de carga.
import 'dart:convert';
import 'package:dart_odbc/dart_odbc.dart';

import '../lib/config/database_config.dart';
import '../lib/controllers/administracao_controller.dart';
import '../lib/repositories/database_repository.dart';
import 'distribuicao_test.dart' show BancoDistribuicaoTeste, conferir;

Future<void> main() async {
  final fake = BancoDistribuicaoTeste();
  await AdministracaoController(fake).salvarDistribuicao(1, 7, {
    'versao': 0,
    'orgaos_anteriores': [0],
    'orgaos': [0, 9],
  });
  var sql = fake.sqlGravacao;
  for (final tabela in [
    'usuario',
    'versao_base',
    'tipo_procedimento',
    'tipo_procedimento_restricao',
    'orgao',
    'auditoria'
  ]) {
    sql = sql.replaceAll(RegExp('dbo\\.$tabela\\b'), '#$tabela');
  }
  conferir(
      !sql.contains('dbo.'), 'O teste não pode acessar tabelas persistentes.');
  sql = sql.replaceAll("@Resource='carga_atribuicoes'",
      "@Resource='teste_distribuicao_${DateTime.now().microsecondsSinceEpoch}'");
  conferir(!sql.contains("'carga_atribuicoes'"),
      'O teste não pode usar a trava de carga da aplicação.');
  final config = DatabaseConfig.fromEnvironment();
  final banco = DatabaseRepository(config);
  final client = DartOdbc();
  try {
    await client.connectWithConnectionString(config.connectionString());
    await client.execute('''
      CREATE TABLE #usuario(id_usuario int PRIMARY KEY,sin_ativo char(1),sin_admin char(1));
      CREATE TABLE #versao_base(versao int PRIMARY KEY);
      CREATE TABLE #tipo_procedimento(versao int,id_tipo_procedimento int,PRIMARY KEY(versao,id_tipo_procedimento));
      CREATE TABLE #orgao(id_orgao int PRIMARY KEY);
      CREATE TABLE #tipo_procedimento_restricao(id_tipo_procedimento int,id_orgao int,PRIMARY KEY(id_tipo_procedimento,id_orgao));
      CREATE TABLE #auditoria(id_usuario int,evento varchar(50),detalhe nvarchar(max));
      INSERT #usuario VALUES(1,'S','S'),(2,'S','N'),(3,'N','S');
      INSERT #versao_base VALUES(0);
      INSERT #tipo_procedimento VALUES(0,7),(0,8);
      INSERT #orgao VALUES(0),(9),(12);
      INSERT #tipo_procedimento_restricao VALUES(7,0),(8,12);
    ''');

    Future<void> salvar(List<int> anteriores, List<int> orgaos,
        {int administrador = 1, int versao = 0, int? erroEsperado}) async {
      try {
        await client.execute(sql, params: [
          administrador,
          7,
          versao,
          jsonEncode(anteriores),
          jsonEncode(orgaos)
        ]);
      } catch (erro) {
        final codigo = banco.failure(erro, 'teste_temporario').code;
        if (erroEsperado != null && codigo == erroEsperado) return;
        throw StateError(
            'Erro SQL inesperado: $codigo; esperado: $erroEsperado');
      }
      conferir(
          erroEsperado == null, 'Operação deveria falhar com $erroEsperado.');
    }

    await salvar([0], [0, 9]);
    await salvar([0], [12], erroEsperado: 51404);
    await salvar([0, 9], [999], erroEsperado: 51405);
    await salvar([0, 9], [], administrador: 2, erroEsperado: 51401);
    await salvar([0, 9], [], administrador: 3, erroEsperado: 51401);
    final preservados = await client.execute(
        'SELECT id_orgao FROM #tipo_procedimento_restricao WHERE id_tipo_procedimento=7 ORDER BY id_orgao');
    conferir(
        preservados.map((r) => r['id_orgao'].toString()).join(',') == '0,9',
        'Falhas alteraram os vínculos.');
    final auditoria = await client.execute('SELECT * FROM #auditoria');
    conferir(
        auditoria.length == 1, 'Falhas não foram revertidas atomicamente.');
    final detalhe = jsonDecode(auditoria.single['detalhe'].toString());
    conferir(
        detalhe['orgaos_antes'].toString() == '[0]' &&
            detalhe['orgaos_depois'].toString() == '[0, 9]',
        'Auditoria incorreta.');

    await client.execute('INSERT #versao_base VALUES(1)');
    await salvar([0, 9], [], erroEsperado: 51402);
    await salvar([0, 9], [], versao: 1, erroEsperado: 51403);
    await client.execute('INSERT #tipo_procedimento VALUES(1,7)');
    await salvar([0, 9], [], versao: 1);
    final finais = await client.execute(
        'SELECT id_tipo_procedimento,id_orgao FROM #tipo_procedimento_restricao');
    conferir(
        finais.length == 1 &&
            finais.single['id_tipo_procedimento'].toString() == '8',
        'Remoção afetou outro Tipo.');
    conferir((await client.execute('SELECT * FROM #auditoria')).length == 2,
        'Auditoria da remoção ausente.');
    print(
        'Integração SQL: múltiplos órgãos, remoção, autorização, conflitos, versão e auditoria: OK. Somente tabelas temporárias; dados da aplicação preservados.');
  } finally {
    // As tabelas temporárias são eliminadas pelo SQL Server ao desconectar.
    await client.disconnect();
  }
}
