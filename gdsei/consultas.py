import json

from . import db, sql


def listar(usuario):
    itens = db.query(sql.TIPOS, [usuario])
    for item in itens:
        item["estado"] = estado(item)
    return itens


def estado(item):
    if item["visualizado"] != "S":
        return "NAO_VISUALIZADO"
    if int(item["pendentes"]) > 0:
        return "EM_AVALIACAO"
    if item.get("decisao_tipo") == "DESCONTINUAR":
        return "DESCONTINUAR"
    return "AVALIADO"


def progresso(itens):
    total = len(itens)
    visualizados = sum(t["visualizado"] == "S" for t in itens)
    avaliados = sum(t["visualizado"] == "S" and int(t["pendentes"]) == 0 for t in itens)
    return {
        "total": total,
        "visualizados": visualizados,
        "avaliados": avaliados,
        "percentual": round(100 * avaliados / total) if total else 0,
    }


def detalhe(usuario, atribuicao):
    atribuicao = db.inteiro(atribuicao, 1)
    tipos = db.query(sql.TIPO, [usuario, atribuicao])
    if not tipos:
        raise db.RegraError("Tipo não encontrado para seus órgãos.", 404)
    tipo = tipos[0]
    assuntos = db.query(
        "SELECT s.*,r.sequencia FROM dbo.rel_tipo_procedimento_assunto r JOIN dbo.assunto s ON s.versao=r.versao AND s.id_assunto=r.id_assunto_proxy WHERE r.versao=? AND r.id_tipo_procedimento=? ORDER BY r.sequencia",
        [tipo["versao"], tipo["id_tipo_procedimento"]],
    )
    manifestacoes = db.query(sql.MANIFESTACAO, [atribuicao])
    decisoes = db.query(sql.DECISOES, [atribuicao])
    return {
        "tipo": tipo,
        "assuntos": assuntos,
        "manifestacao": manifestacoes[0] if manifestacoes else {"revisao": 0},
        "decisoes": decisoes,
    }


def visualizar(usuario, atribuicao):
    atribuicao = db.inteiro(atribuicao, 1)
    db.query(
        """SET XACT_ABORT ON; BEGIN TRY BEGIN TRANSACTION;
      IF NOT EXISTS(SELECT 1 FROM dbo.consulta_orgao_tipo a
      JOIN dbo.usuario_orgao u WITH(HOLDLOCK) ON u.id_orgao=a.id_orgao
      WHERE a.id_atribuicao=? AND u.id_usuario=?) THROW 51021,'Tipo nao autorizado',1;
      IF NOT EXISTS(SELECT 1 FROM dbo.visualizacao_tipo WITH(UPDLOCK,HOLDLOCK) WHERE id_atribuicao=?)
      INSERT dbo.visualizacao_tipo(id_atribuicao,id_usuario) VALUES(?,?);
      COMMIT; END TRY BEGIN CATCH IF XACT_STATE()<>0 ROLLBACK; THROW; END CATCH;""",
        [atribuicao, usuario, atribuicao, atribuicao, usuario],
    )


def validar_vinculos(vinculos):
    if not isinstance(vinculos, list) or len(vinculos) > 2000:
        raise db.RegraError("Lista de vínculos inválida.")
    vistos = set()
    for vinculo in vinculos:
        assunto = db.inteiro(vinculo.get("id_assunto"), -2147483648)
        if assunto in vistos or vinculo.get("acao") not in ("MANTER", "REMOVER", "ADICIONAR"):
            raise db.RegraError("Vínculo inválido ou duplicado.")
        vistos.add(assunto)
        justificativa = vinculo.get("justificativa", "")
        if not isinstance(justificativa, str) or len(justificativa) > 2000:
            raise db.RegraError("Justificativa deve ter até 2000 caracteres.")
        if vinculo["acao"] != "MANTER" and not justificativa.strip():
            raise db.RegraError("Justifique a inclusão ou remoção.")
        vinculo["justificativa"] = justificativa.strip()


def salvar(usuario, atribuicao, dados):
    atual = detalhe(usuario, atribuicao)
    revisao = db.inteiro(dados.get("revisao"))
    decisao = dados.get("decisao_tipo")
    justificativa = dados.get("justificativa_tipo", "").strip()
    observacao = dados.get("observacao", "")
    if decisao not in ("MANTER", "DESCONTINUAR"):
        raise db.RegraError("Escolha manter ou sugerir descontinuação.")
    if len(observacao) > 5000 or len(justificativa) > 2000:
        raise db.RegraError("Observação ou justificativa excede o limite.")
    if decisao == "DESCONTINUAR" and not justificativa:
        raise db.RegraError("Justifique a sugestão de descontinuação.")
    vinculos = dados.get("vinculos", []) if decisao == "MANTER" else []
    validar_vinculos(vinculos)
    inclusoes = [v for v in vinculos if v["acao"] == "ADICIONAR"]
    if inclusoes and db.query(
        sql.ESTRUTURAIS, [json.dumps(inclusoes), atual["tipo"]["versao"], atribuicao]
    ):
        raise db.RegraError("Item apenas estrutural. Não pode ser vinculado a Tipos de Processo.")
    return db.query(
        "EXEC dbo.sp_salvar_manifestacao ?,?,?,?,?,?,?",
        [usuario, atribuicao, revisao, observacao, json.dumps(vinculos), decisao, justificativa],
    )


def resumo(usuario, consulta, orgao):
    consulta, orgao = db.inteiro(consulta, 1), db.inteiro(orgao)
    grupos = db.query(sql.RESUMO, [usuario, consulta, orgao])
    if not grupos:
        raise db.RegraError("Consulta não encontrada para este órgão.", 404)
    tipos = db.query(sql.RESUMO_TIPOS, [consulta, orgao])
    decisoes = db.query(sql.RESUMO_DECISOES, [consulta, orgao])
    for tipo in tipos:
        if tipo["decisao_tipo"] == "DESCONTINUAR":
            tipo["pendentes"] = 0
        elif tipo["decisao_tipo"] is None:
            tipo["pendentes"] = int(tipo["pendentes"]) + 1
        tipo["decisoes"] = [d for d in decisoes if d["id_atribuicao"] == tipo["id_atribuicao"]]
    cabecalho = grupos[0]
    completo = bool(tipos) and all(
        t["visualizado"] == "S"
        and t["decisao_tipo"] is not None
        and int(t["pendentes"]) == 0
        and (t["decisao_tipo"] != "DESCONTINUAR" or bool(t["justificativa_tipo"]))
        for t in tipos
    )
    return {
        "grupo": cabecalho,
        "tipos": tipos,
        "progresso": progresso(tipos),
        "pode_finalizar": cabecalho["pode_revisar"] == "S"
        and cabecalho["status"] == "RASCUNHO"
        and completo,
    }


def finalizar(usuario, consulta, orgao, revisao):
    db.query(
        "EXEC dbo.sp_finalizar_manifestacao_orgao ?,?,?,?",
        [usuario, consulta, orgao, db.inteiro(revisao)],
    )


def pesquisar_assuntos(tipo, texto=""):
    termo = db.pesquisa(texto)
    return db.query(
        """SELECT assunto.* FROM dbo.assunto assunto
      WHERE assunto.versao=? AND assunto.sin_ativo='S'
      AND (assunto.codigo_estruturado LIKE ? ESCAPE '~' OR assunto.descricao LIKE ? ESCAPE '~'
        OR assunto.observacao LIKE ? ESCAPE '~' OR assunto.idx_assunto LIKE ? ESCAPE '~'
        OR CAST(assunto.id_assunto AS varchar(12))=?)
      AND NOT EXISTS(SELECT 1 FROM dbo.rel_tipo_procedimento_assunto r
        WHERE r.versao=assunto.versao AND r.id_tipo_procedimento=? AND r.id_assunto_proxy=assunto.id_assunto)
      ORDER BY assunto.codigo_estruturado,assunto.id_assunto""",
        [tipo["versao"], termo, termo, termo, termo, texto, tipo["id_tipo_procedimento"]],
    )


def inicio(usuario, consulta):
    rodadas = db.query(sql.RODADAS, [usuario])
    if not rodadas:
        return {"rodadas": [], "orgaos": [], "totais": {}}
    consulta = db.inteiro(consulta or rodadas[0]["id_consulta"], 1)
    rodada = next((r for r in rodadas if r["id_consulta"] == consulta), None)
    if rodada is None:
        raise db.RegraError("Rodada não encontrada para seu acesso.", 404)
    orgaos = db.query(sql.INICIO, [consulta, usuario, consulta])
    totais = dict.fromkeys(
        ("pendentes", "visualizados", "analisados", "validando", "submetidos"), 0
    )
    for orgao in orgaos:
        atribuidos, visualizados, analisados = (
            int(orgao[k]) for k in ("atribuidos", "visualizados", "analisados")
        )
        estados = dict.fromkeys(totais, 0)
        if orgao["status"] == "FINALIZADA":
            estados["submetidos"] = atribuidos
        elif atribuidos and analisados == atribuidos:
            estados["validando"] = atribuidos
        else:
            estados.update(
                pendentes=atribuidos - visualizados,
                visualizados=visualizados - analisados,
                analisados=analisados,
            )
        orgao.update(estados)
        orgao["revisados"] = analisados
        orgao["progresso"] = round(100 * analisados / atribuidos) if atribuidos else 0
        for chave in totais:
            totais[chave] += estados[chave]
    return {"rodadas": rodadas, "rodada": rodada, "orgaos": orgaos, "totais": totais}
