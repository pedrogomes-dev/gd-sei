import json

from . import db, sql
from .autenticacao import email_valido


def verificar_admin(usuario):
    if not db.query(sql.ADMIN, [usuario]):
        raise db.RegraError("Acesso restrito à administração.", 403)


def orgaos():
    return db.query(sql.ORGAOS)


def processamento(usuario):
    verificar_admin(usuario)
    tipos = db.query(sql.PROCESSAMENTO)
    assuntos = db.query(sql.PROCESSAMENTO_ASSUNTOS)
    for tipo in tipos:
        tipo["assuntos"] = [a for a in assuntos if a["id_atribuicao"] == tipo["id_atribuicao"]]
        valores = [tipo["parecer_tipo"], *(a["parecer"] for a in tipo["assuntos"])]
        tipo["avaliados"] = sum(v is not None for v in valores)
        tipo["total_avaliacoes"] = len(valores)
        tipo["concluido"] = tipo["avaliados"] == len(valores)
        tipo["resultado"] = resultado(valores)
    return tipos


def resultado(valores):
    if "RECUSADO" in valores:
        return "PARCIALMENTE_ACEITO"
    if all(valor == "ACEITO" for valor in valores):
        return "ACEITO"
    return "PENDENTE"


def avaliar(usuario, atribuicao, parecer, assunto=None):
    verificar_admin(usuario)
    if parecer not in ("ACEITO", "RECUSADO"):
        raise db.RegraError("Parecer inválido.")
    assunto_id = db.inteiro(assunto, -2147483648) if assunto is not None else 0
    db.query(
        sql.AVALIAR,
        [usuario, db.inteiro(atribuicao, 1), parecer, int(assunto is not None), assunto_id],
    )


def distribuicao(usuario):
    verificar_admin(usuario)
    versao = db.query("SELECT MAX(versao) AS versao FROM dbo.versao_base")[0]["versao"]
    if versao is None:
        raise db.RegraError("Nenhuma base publicada.", 404)
    tipos = db.query(
        "SELECT id_tipo_procedimento,nome,sin_ativo FROM dbo.tipo_procedimento WHERE versao=? ORDER BY nome,id_tipo_procedimento",
        [versao],
    )
    vinculos = db.query(
        "SELECT id_tipo_procedimento,id_orgao FROM dbo.tipo_procedimento_restricao ORDER BY id_tipo_procedimento,id_orgao"
    )
    todos_orgaos = orgaos()
    for tipo in tipos:
        tipo["orgaos"] = [
            v["id_orgao"]
            for v in vinculos
            if v["id_tipo_procedimento"] == tipo["id_tipo_procedimento"]
        ]
        tipo["orgaos_nomes"] = [o["sigla"] for o in todos_orgaos if o["id_orgao"] in tipo["orgaos"]]
    return {"versao": versao, "tipos": tipos, "orgaos": todos_orgaos}


def salvar_distribuicao(usuario, tipo, versao, antes, depois):
    verificar_admin(usuario)
    db.query(
        sql.DISTRIBUIR,
        [
            usuario,
            db.inteiro(tipo),
            db.inteiro(versao),
            json.dumps(db.ids(antes)),
            json.dumps(db.ids(depois)),
        ],
    )


def distribuir_lote(usuario, versao, tipos, selecionados):
    verificar_admin(usuario)
    tipos, selecionados = db.ids(tipos), db.ids(selecionados)
    if not tipos or not selecionados:
        raise db.RegraError("Selecione ao menos um Tipo e um órgão.")
    return db.query(
        sql.DISTRIBUIR_LOTE,
        [usuario, db.inteiro(versao), json.dumps(tipos), json.dumps(selecionados)],
    )[0]


def usuarios(texto, situacao="TODOS", orgao=None):
    filtro = "WHERE (u.nome LIKE ? ESCAPE '~' OR u.email LIKE ? ESCAPE '~')"
    termo = db.pesquisa(texto)
    params = [termo, termo]
    if orgao not in (None, ""):
        filtro += " AND EXISTS(SELECT 1 FROM dbo.usuario_orgao v WHERE v.id_usuario=u.id_usuario AND v.id_orgao=?)"
        params.append(db.inteiro(orgao, -2147483648))
    totais = db.query(
        "SELECT COUNT_BIG(*) AS todos,COUNT_BIG(CASE WHEN sin_ativo='S' THEN 1 END) AS ativos,COUNT_BIG(CASE WHEN sin_ativo='N' THEN 1 END) AS inativos FROM dbo.usuario u "
        + filtro,
        params,
    )[0]
    if situacao != "TODOS":
        if situacao not in ("S", "N"):
            raise db.RegraError("Situação inválida.")
        filtro += " AND u.sin_ativo=?"
        params.append(situacao)
    itens = db.query(
        "SELECT u.id_usuario,u.nome,u.email,u.sin_ativo,u.sin_admin,u.revisao,(SELECT o.id_orgao,o.sigla FROM dbo.usuario_orgao v JOIN dbo.orgao o ON o.id_orgao=v.id_orgao WHERE v.id_usuario=u.id_usuario ORDER BY o.sigla FOR JSON PATH) AS orgaos FROM dbo.usuario u "
        + filtro
        + " ORDER BY u.nome,u.id_usuario",
        params,
    )
    for item in itens:
        item["orgaos"] = json.loads(item["orgaos"] or "[]")
    return {"itens": itens, "totais": totais}


def usuario(id_usuario):
    itens = db.query(sql.USUARIO, [id_usuario])
    if not itens:
        raise db.RegraError("Usuário não encontrado.", 404)
    item = itens[0]
    item["orgaos"] = [v["id_orgao"] for v in db.query(sql.USUARIO_ORGAOS, [id_usuario])]
    return item


def salvar_usuario(admin, id_usuario, dados):
    verificar_admin(admin)
    nome = dados.get("nome", "").strip()
    email = email_valido(dados.get("email", ""))
    if not nome or len(nome) > 150:
        raise db.RegraError("Informe um nome com até 150 caracteres.")
    ativo, perfil = dados.get("sin_ativo"), dados.get("sin_admin")
    if ativo not in ("S", "N") or perfil not in ("S", "N"):
        raise db.RegraError("Situação ou perfil inválido.")
    return db.query(
        "EXEC dbo.sp_salvar_usuario ?,?,?,?,?,?,?,?",
        [
            admin,
            id_usuario,
            db.inteiro(dados.get("revisao")),
            nome,
            email,
            ativo,
            perfil,
            json.dumps(db.ids(dados.get("orgaos", []))),
        ],
    )[0]


def historico(id_usuario):
    usuario(id_usuario)
    itens = db.query(
        sql.HISTORICO.replace("OFFSET ? ROWS FETCH NEXT 51 ROWS ONLY", ""), [id_usuario]
    )
    for item in itens:
        item["antes"] = json.loads(item["antes"]) if item["antes"] else None
        item["depois"] = json.loads(item["depois"])
    return itens
