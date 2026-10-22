// Integração opcional: somente tabelas temporárias privadas; não aplica a migração.
import 'package:dart_odbc/dart_odbc.dart';

import '../lib/config/database_config.dart';
import '../lib/controllers/administracao_controller.dart';
import '../lib/repositories/database_repository.dart';
import 'processamento_test.dart' show BancoProcessamento;

void conferir(bool valor, String mensagem) {
  if (!valor) throw StateError(mensagem);
}

Future<void> main() async {
  final captura = BancoProcessamento();
  final controller = AdministracaoController(captura);
  await controller.listarProcessamento(1);
  await controller.atualizarProcessamento(1, 1);
  String temporario(String sql) {
    for (final tabela in [
      'usuario',
      'consulta_orgao_tipo',
      'consulta_orgao',
      'consulta',
      'orgao',
      'tipo_procedimento',
      'manifestacao_tipo',
      'processamento_submissao'
    ]) {
      sql = sql.replaceAll(RegExp('dbo\\.$tabela\\b'), '#$tabela');
    }
    conferir(
        !sql.contains('dbo.'), 'Teste não pode acessar tabelas persistentes.');
    return sql;
  }

  final listar = temporario(captura.sqlListagem);
  final gravar = temporario(captura.sqlGravacao);
  final config = DatabaseConfig.fromEnvironment();
  final db = DatabaseRepository(config);
  final sql = DartOdbc();
  try {
    await sql.connectWithConnectionString(config.connectionString());
    await sql.execute('''
      CREATE TABLE #usuario(id_usuario int PRIMARY KEY, sin_ativo char(1), sin_admin char(1), nome nvarchar(100));
      CREATE TABLE #consulta(id_consulta int PRIMARY KEY, versao int, nome nvarchar(100));
      CREATE TABLE #orgao(id_orgao int PRIMARY KEY, sigla varchar(30));
      CREATE TABLE #consulta_orgao(id_consulta int, id_orgao int, status varchar(12), PRIMARY KEY(id_consulta,id_orgao));
      CREATE TABLE #consulta_orgao_tipo(id_atribuicao int PRIMARY KEY, id_consulta int, id_orgao int, versao int, id_tipo_procedimento int);
      CREATE TABLE #tipo_procedimento(versao int,id_tipo_procedimento int,nome nvarchar(100),PRIMARY KEY(versao,id_tipo_procedimento));
      CREATE TABLE #manifestacao_tipo(id_atribuicao int PRIMARY KEY,versao int,decisao_tipo varchar(15));
      CREATE TABLE #processamento_submissao(id_atribuicao int PRIMARY KEY,id_usuario_atualizacao int NOT NULL,data_atualizacao datetime2 NOT NULL DEFAULT SYSUTCDATETIME());
      INSERT #usuario VALUES(1,'S','S',N'Admin'),(2,'S','N',N'Comum'),(3,'N','S',N'Inativo'),(4,'S','S',N'Admin 2');
      INSERT #consulta VALUES(1,0,N'Rodada 1'),(2,1,N'Rodada 2');
      INSERT #orgao VALUES(0,'ORG0'),(9,'ORG9');
      INSERT #consulta_orgao VALUES(1,0,'FINALIZADA'),(1,9,'FINALIZADA'),(2,9,'RASCUNHO');
      INSERT #consulta_orgao_tipo VALUES(1,1,0,0,7),(2,1,9,0,7),(3,2,9,1,8);
      INSERT #tipo_procedimento VALUES(0,7,N'Tipo v0'),(1,7,N'Tipo v1'),(1,8,N'Tipo 8');
      INSERT #manifestacao_tipo VALUES(1,0,'MANTER'),(2,0,'DESCONTINUAR'),(3,1,'MANTER');
    ''');
    final antes = await sql.execute(listar);
    conferir(antes.length == 2, 'Rascunho apareceu ou finalizada foi omitida.');
    conferir(
        antes.every(
            (i) => i['nome'] == 'Tipo v0' && i['situacao'] == 'PENDENTE'),
        'Versão ou estado inicial incorreto.');
    Future<void> marcar(int admin, int id, {int? erro}) async {
      try {
        await sql.execute(gravar, params: [admin, id]);
      } catch (e) {
        if (erro != null && db.failure(e, 'teste_temporario').code == erro)
          return;
        rethrow;
      }
      conferir(erro == null, 'Operação inválida foi aceita.');
    }

    await marcar(2, 1, erro: 51500);
    await marcar(3, 1, erro: 51500);
    await marcar(1, 999, erro: 51501);
    await marcar(1, 3, erro: 51502);
    await marcar(1, 1);
    final primeiro =
        (await sql.execute('SELECT * FROM #processamento_submissao')).single;
    await marcar(4, 1);
    final repetido =
        (await sql.execute('SELECT * FROM #processamento_submissao')).single;
    conferir(repetido['id_usuario_atualizacao'].toString() == '1',
        'Repetição mudou responsável.');
    conferir(repetido['data_atualizacao'] == primeiro['data_atualizacao'],
        'Repetição mudou a data.');
    await marcar(1, 2);
    final depois = await sql.execute(listar);
    conferir(
        depois.length == 2 &&
            depois.every((i) => i['situacao'] == 'ATUALIZADO'),
        'Listagem não refletiu processamento.');
    final originais = await sql
        .execute('SELECT status FROM #consulta_orgao WHERE id_consulta=1');
    conferir(originais.every((g) => g['status'] == 'FINALIZADA'),
        'Alterou status original.');
    print(
        'Processamento SQL: autorização, versão, finalização, repetição, responsável/data e rollback: OK (tabelas temporárias).');
  } finally {
    await sql.disconnect();
  }
}
