import 'dart:convert';

import '../lib/config/database_config.dart';
import '../lib/controllers/manifestacao_controller.dart';
import '../lib/models/api_error.dart';
import '../lib/repositories/consulta_repository.dart';
import '../lib/repositories/database_repository.dart';

void conferir(bool condicao, String mensagem) {
  if (!condicao) throw StateError(mensagem);
}

class BancoTeste extends DatabaseRepository {
  bool estrutural = true;
  bool propostaExistente = false;
  int gravacoes = 0;
  int validacoes = 0;

  BancoTeste()
      : super(DatabaseConfig(
            host: 'teste',
            database: 'teste',
            username: 'teste',
            password: 'teste',
            driver: 'teste',
            port: 1433,
            encrypt: true,
            trustServerCertificate: false));

  @override
  Future<List<Map<String, dynamic>>> query(
    String sql, {
    List<Object> params = const [],
    String operation = 'consulta',
  }) async {
    if (operation == 'validar_inclusoes_estruturais') {
      validacoes++;
      conferir(
          params[1] == 7 && params[2] == 42, 'Versão/atribuição incorreta.');
      conferir(
          sql.contains('assunto.versao = ?') &&
              sql.contains('existente.versao = assunto.versao') &&
              sql.contains("assunto.sin_estrutural = 'S'"),
          'Restrição SQL incompleta.');
      conferir(!sql.contains('id_assunto_pai'),
          'Descendentes não podem bloquear inclusão.');
      conferir(
          (jsonDecode(params[0] as String) as List)
              .every((v) => v['acao'] == 'ADICIONAR'),
          'Validação deve afetar apenas inclusões.');
      return estrutural && !propostaExistente
          ? [
              {'id_assunto': 3}
            ]
          : [];
    }
    if (operation == 'salvar_manifestacao') {
      gravacoes++;
      return [
        {'revisao': 1}
      ];
    }
    throw StateError('Operação inesperada: $operation');
  }
}

class ConsultasTeste extends ConsultaRepository {
  bool autorizado = true;
  ConsultasTeste(super.db);

  @override
  Future<Map<String, dynamic>> detail(int userId, int id) async {
    conferir(userId == 9 && id == 42, 'Autorização incorreta.');
    if (!autorizado)
      throw ApiError(404, 'Tipo não encontrado para seus órgãos');
    return {
      'tipo': {'versao': 7}
    };
  }
}

Future<void> main() async {
  final banco = BancoTeste();
  final consultas = ConsultasTeste(banco);
  final controller = ManifestacaoController(banco, consultas);
  Map<String, dynamic> dados(String acao) => {
        'revisao': 0,
        'observacao': '',
        'decisao_tipo': 'MANTER',
        'justificativa_tipo': '',
        'vinculos': [
          {'id_assunto': 3, 'acao': acao, 'justificativa': 'Justificativa'},
        ],
      };

  try {
    await controller.salvar(9, 42, dados('ADICIONAR'));
    throw StateError('Inclusão estrutural aceita.');
  } on ApiError catch (erro) {
    conferir(erro.status == 400, 'Esperado HTTP 400.');
  }
  conferir(banco.gravacoes == 0, 'Rejeição não pode gravar.');

  banco.estrutural = false;
  await controller.salvar(9, 42, dados('ADICIONAR'));
  conferir(banco.gravacoes == 1,
      'Assunto N deve continuar disponível, mesmo com filhos.');

  banco.estrutural = true;
  banco.propostaExistente = true;
  await controller.salvar(9, 42, dados('ADICIONAR'));
  conferir(banco.gravacoes == 2,
      'Proposta estrutural preexistente deve ser preservada.');
  final validacoes = banco.validacoes;
  await controller.salvar(9, 42, dados('MANTER'));
  await controller.salvar(9, 42, dados('REMOVER'));
  conferir(banco.validacoes == validacoes,
      'Decisões de vínculos originais não devem ser bloqueadas.');

  consultas.autorizado = false;
  final gravacoes = banco.gravacoes;
  try {
    await controller.salvar(9, 42, dados('ADICIONAR'));
    throw StateError('Inclusão sem autorização aceita.');
  } on ApiError catch (erro) {
    conferir(erro.status == 404, 'Autorização deve ser preservada.');
  }
  conferir(banco.gravacoes == gravacoes, 'Acesso negado não pode gravar.');
  print(
      'Assuntos estruturais: rejeição, versão, autorização e preservação: OK (banco simulado).');
}
