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
  await controller.avaliarProcessamento(1, 1, {'parecer': 'ACEITO'});
  String temporario(String sql) {
    for (final tabela in [
      'usuario',
      'consulta_orgao_tipo',
      'consulta_orgao',
      'consulta',
      'orgao',
      'tipo_procedimento',
      'manifestacao_tipo',
      'avaliacao_setic_tipo',
      'avaliacao_setic_assunto',
      'manifestacao_vinculo',
      'assunto'
    ]) {
      sql = sql.replaceAll(RegExp('dbo\\.$tabela\\b'), '#$tabela');
    }
    conferir(
        !sql.contains('dbo.'), 'Teste não pode acessar tabelas persistentes.');
    return sql;
  }

  final listar = temporario(captura.sqlListagem);
  final listarAssuntos = temporario(captura.sqlAssuntos);
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
      CREATE TABLE #manifestacao_tipo(id_atribuicao int PRIMARY KEY,versao int,decisao_tipo varchar(15),justificativa_tipo nvarchar(2000));
      CREATE TABLE #manifestacao_vinculo(id_atribuicao int,id_assunto int,versao int,acao varchar(15),justificativa nvarchar(2000),PRIMARY KEY(id_atribuicao,id_assunto));
      CREATE TABLE #assunto(id_assunto int,versao int,codigo_estruturado varchar(30),descricao nvarchar(100),PRIMARY KEY(id_assunto,versao));
      CREATE TABLE #avaliacao_setic_tipo(id_atribuicao int PRIMARY KEY,parecer varchar(8),id_usuario_avaliacao int NOT NULL,data_avaliacao datetime2 NOT NULL DEFAULT SYSUTCDATETIME());
      CREATE TABLE #avaliacao_setic_assunto(id_atribuicao int,id_assunto int,parecer varchar(8),id_usuario_avaliacao int NOT NULL,data_avaliacao datetime2 NOT NULL DEFAULT SYSUTCDATETIME(),PRIMARY KEY(id_atribuicao,id_assunto));
      INSERT #usuario VALUES(1,'S','S',N'Admin'),(2,'S','N',N'Comum'),(3,'N','S',N'Inativo'),(4,'S','S',N'Admin 2');
      INSERT #consulta VALUES(1,0,N'Rodada 1'),(2,1,N'Rodada 2');
      INSERT #orgao VALUES(0,'ORG0'),(9,'ORG9');
      INSERT #consulta_orgao VALUES(1,0,'FINALIZADA'),(1,9,'FINALIZADA'),(2,9,'RASCUNHO');
      INSERT #consulta_orgao_tipo VALUES(1,1,0,0,7),(2,1,9,0,7),(3,2,9,1,8);
      INSERT #tipo_procedimento VALUES(0,7,N'Tipo v0'),(1,7,N'Tipo v1'),(1,8,N'Tipo 8');
      INSERT #manifestacao_tipo VALUES(1,0,'MANTER',NULL),(2,0,'DESCONTINUAR',N'Justificativa'),(3,1,'MANTER',NULL);
      INSERT #manifestacao_vinculo VALUES(1,10,0,'MANTER',NULL),(1,11,0,'REMOVER',N'Remover'),(2,10,0,'MANTER',NULL),(3,10,1,'MANTER',NULL);
      INSERT #assunto VALUES(10,0,'010',N'Assunto v0'),(10,1,'010',N'Assunto v1'),(11,0,'011',N'Assunto 11');
    ''');
    final antes = await sql.execute(listar);
    conferir(antes.length == 2, 'Rascunho apareceu ou finalizada foi omitida.');
    conferir(
        antes.every((i) => i['nome'] == 'Tipo v0' && i['parecer_tipo'] == null),
        'Versão ou estado inicial incorreto.');
    final assuntos = await sql.execute(listarAssuntos);
    conferir(
        assuntos.length == 2 &&
            assuntos.every((s) => s['id_atribuicao'].toString() == '1') &&
            assuntos.first['descricao'] == 'Assunto v0',
        'Assuntos fora da versão/submissão.');
    Future<void> marcar(int admin, int id,
        {String parecer = 'ACEITO', int? assunto, int? erro}) async {
      try {
        await sql.execute(gravar, params: [
          admin,
          id,
          parecer,
          assunto == null ? 0 : 1,
          assunto ?? 0
        ]);
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
    await marcar(1, 2, assunto: 10, erro: 51503);
    await marcar(1, 1, assunto: 999, erro: 51503);
    await marcar(1, 1);
    final primeiro =
        (await sql.execute('SELECT * FROM #avaliacao_setic_tipo')).single;
    await marcar(4, 1);
    final repetido =
        (await sql.execute('SELECT * FROM #avaliacao_setic_tipo')).single;
    conferir(repetido['id_usuario_avaliacao'].toString() == '1',
        'Repetição mudou responsável.');
    conferir(repetido['data_avaliacao'] == primeiro['data_avaliacao'],
        'Repetição mudou a data.');
    await marcar(1, 1, parecer: 'RECUSADO', erro: 51504);
    await marcar(1, 1, parecer: 'RECUSADO', assunto: 10);
    await marcar(4, 1, parecer: 'RECUSADO', assunto: 10);
    await marcar(1, 1, assunto: 10, erro: 51504);
    await marcar(1, 1, assunto: 11);
    await marcar(1, 2);
    final depois = await sql.execute(listar);
    conferir(
        depois.length == 2 &&
            depois.every((i) => i['parecer_tipo'] == 'ACEITO'),
        'Listagem não refletiu processamento.');
    final pareceres = await sql.execute(listarAssuntos);
    conferir(
        pareceres.length == 2 &&
            pareceres.where((s) => s['parecer'] == 'RECUSADO').length == 1 &&
            pareceres.every((s) => s['responsavel'] == 'Admin'),
        'Pareceres dos Assuntos incorretos.');
    final originais = await sql
        .execute('SELECT status FROM #consulta_orgao WHERE id_consulta=1');
    conferir(originais.every((g) => g['status'] == 'FINALIZADA'),
        'Alterou status original.');
    print(
        'Avaliação SQL: autorização, versão, finalização, escopo dos Assuntos, aceite/recusa, repetição, responsável/data e rollback: OK (tabelas temporárias).');
  } finally {
    await sql.disconnect();
  }
}
