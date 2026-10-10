import '../models/api_error.dart';
import '../repositories/database_repository.dart';

class InicioController {
  final DatabaseRepository banco;

  InicioController(this.banco);

  Future<List<Map<String, dynamic>>> listarRodadas(int idUsuario) async {
    const sql = '''
      SELECT consulta.id_consulta, consulta.nome, consulta.versao
      FROM dbo.consulta consulta
      JOIN dbo.usuario usuario ON usuario.id_usuario = ? AND usuario.sin_ativo = 'S'
      WHERE usuario.sin_admin = 'S'
        OR EXISTS (
          SELECT 1
          FROM dbo.consulta_orgao grupo
          JOIN dbo.usuario_orgao vinculo ON vinculo.id_orgao = grupo.id_orgao
          WHERE grupo.id_consulta = consulta.id_consulta
            AND vinculo.id_usuario = usuario.id_usuario
        )
      ORDER BY consulta.id_consulta DESC
    ''';
    return banco.query(sql, params: [idUsuario]);
  }

  Future<Map<String, dynamic>> consultar(int idUsuario, int idConsulta) async {
    final rodadas = await listarRodadas(idUsuario);
    Map<String, dynamic>? rodada;
    for (final item in rodadas) {
      if (int.parse(item['id_consulta'].toString()) == idConsulta) rodada = item;
    }
    if (rodada == null) throw ApiError(404, 'Rodada não encontrada para seu acesso.');

    const sql = '''
      WITH atribuicoes AS (
        SELECT atribuicao.id_atribuicao, atribuicao.id_consulta, atribuicao.id_orgao,
          CASE WHEN visualizacao.id_atribuicao IS NULL THEN 0 ELSE 1 END AS visualizado,
          CASE WHEN visualizacao.id_atribuicao IS NOT NULL AND (
            manifestacao.decisao_tipo = 'DESCONTINUAR'
            OR (manifestacao.decisao_tipo = 'MANTER' AND NOT EXISTS (
            SELECT 1
            FROM dbo.rel_tipo_procedimento_assunto vinculo
            WHERE vinculo.versao = atribuicao.versao
              AND vinculo.id_tipo_procedimento = atribuicao.id_tipo_procedimento
              AND NOT EXISTS (
                SELECT 1
                FROM dbo.manifestacao_vinculo decisao
                WHERE decisao.id_atribuicao = atribuicao.id_atribuicao
                  AND decisao.id_assunto = vinculo.id_assunto_proxy
                  AND decisao.acao IN ('MANTER', 'REMOVER')
              )
          ))) THEN 1 ELSE 0 END AS analisado
        FROM dbo.consulta_orgao_tipo atribuicao
        LEFT JOIN dbo.visualizacao_tipo visualizacao
          ON visualizacao.id_atribuicao = atribuicao.id_atribuicao
        LEFT JOIN dbo.manifestacao_tipo manifestacao
          ON manifestacao.id_atribuicao = atribuicao.id_atribuicao
        WHERE atribuicao.id_consulta = ?
      )
      SELECT grupo.id_orgao, orgao.sigla, grupo.status, grupo.data_finalizacao,
        COUNT(atribuicao.id_atribuicao) AS atribuidos,
        COALESCE(SUM(atribuicao.visualizado), 0) AS visualizados,
        COALESCE(SUM(atribuicao.analisado), 0) AS analisados
      FROM dbo.consulta_orgao grupo
      JOIN dbo.orgao orgao ON orgao.id_orgao = grupo.id_orgao
      JOIN dbo.usuario usuario ON usuario.id_usuario = ? AND usuario.sin_ativo = 'S'
      LEFT JOIN atribuicoes atribuicao
        ON atribuicao.id_consulta = grupo.id_consulta AND atribuicao.id_orgao = grupo.id_orgao
      WHERE grupo.id_consulta = ?
        AND (
          usuario.sin_admin = 'S'
          OR EXISTS (
            SELECT 1
            FROM dbo.usuario_orgao vinculo
            WHERE vinculo.id_usuario = usuario.id_usuario AND vinculo.id_orgao = grupo.id_orgao
          )
        )
      GROUP BY grupo.id_orgao, orgao.sigla, grupo.status, grupo.data_finalizacao
      ORDER BY orgao.sigla
    ''';

    final registros = await banco.query(sql, params: [idConsulta, idUsuario, idConsulta]);
    final orgaos = <Map<String, dynamic>>[];
    final totais = {
      'atribuidos': 0,
      'pendentes': 0,
      'analisados': 0,
      'visualizados': 0,
      'submetidos': 0,
      'validando': 0,
      'orgaos_validando': 0,
      'orgaos_submetidos': 0,
      'orgaos_pendentes': 0,
      'orgaos_pendentes_analise': 0,
      'orgaos_com_analises': 0,
      'orgaos_com_visualizacoes': 0,
    };

    for (final registro in registros) {
      final orgao = Map<String, dynamic>.from(registro);
      orgao['id_orgao'] = int.parse(orgao['id_orgao'].toString());
      final atribuidos = int.parse(orgao['atribuidos'].toString());
      final analisados = int.parse(orgao['analisados'].toString());
      final visualizados = int.parse(orgao['visualizados'].toString());
      final estados = classificarEstados(atribuidos, visualizados, analisados, orgao['status'] == 'FINALIZADA');
      final pendentes = estados['pendentes']!;

      orgao['atribuidos'] = atribuidos;
      orgao['revisados'] = analisados;
      orgao['analisados'] = estados['analisados'];
      orgao['visualizados'] = estados['visualizados'];
      orgao['validando'] = estados['validando'];
      orgao['submetidos'] = estados['submetidos'];
      orgao['pendentes'] = pendentes;

      final data = orgao['data_finalizacao'];
      if (data != null) {
        var texto = data.toString().replaceAll(' ', 'T');
        if (!texto.endsWith('Z')) texto += 'Z';
        orgao['data_finalizacao'] = texto;
      }

      totais['atribuidos'] = totais['atribuidos']! + atribuidos;
      totais['analisados'] = totais['analisados']! + estados['analisados']!;
      totais['visualizados'] = totais['visualizados']! + estados['visualizados']!;
      totais['pendentes'] = totais['pendentes']! + pendentes;

      if (pendentes > 0) {
        totais['orgaos_pendentes_analise'] = totais['orgaos_pendentes_analise']! + 1;
      }
      if (estados['analisados']! > 0) {
        totais['orgaos_com_analises'] = totais['orgaos_com_analises']! + 1;
      }
      if (estados['visualizados']! > 0) {
        totais['orgaos_com_visualizacoes'] = totais['orgaos_com_visualizacoes']! + 1;
      }

      totais['validando'] = totais['validando']! + estados['validando']!;
      if (estados['validando']! > 0) totais['orgaos_validando'] = totais['orgaos_validando']! + 1;

      if (atribuidos > 0) {
        if (orgao['status'] == 'FINALIZADA') {
          totais['submetidos'] = totais['submetidos']! + atribuidos;
          totais['orgaos_submetidos'] = totais['orgaos_submetidos']! + 1;
        } else {
          totais['orgaos_pendentes'] = totais['orgaos_pendentes']! + 1;
        }
      }
      orgaos.add(orgao);
    }

    return {'rodada': rodada, 'totais': totais, 'orgaos': orgaos};
  }

  static Map<String, int> classificarEstados(
    int atribuidos,
    int visualizados,
    int analisados,
    bool submetido,
  ) {
    final estados = {
      'pendentes': 0,
      'visualizados': 0,
      'analisados': 0,
      'validando': 0,
      'submetidos': 0,
    };
    if (submetido) {
      estados['submetidos'] = atribuidos;
    } else if (atribuidos > 0 && analisados == atribuidos) {
      estados['validando'] = atribuidos;
    } else {
      estados['pendentes'] = atribuidos - visualizados;
      estados['visualizados'] = visualizados - analisados;
      estados['analisados'] = analisados;
    }
    return estados;
  }

}
