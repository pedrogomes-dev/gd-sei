from . import db, sql

TABELAS = {
    "assuntos": (
        "assunto",
        "id_assunto",
        ("codigo_estruturado", "descricao", "observacao", "idx_assunto"),
    ),
    "tipos": ("tipo_procedimento", "id_tipo_procedimento", ("nome", "descricao")),
}


def consultar(categoria, texto="", situacao="TODOS", versao=None):
    if categoria not in TABELAS:
        raise db.RegraError("Catálogo inexistente.", 404)
    if situacao not in ("TODOS", "S", "N"):
        raise db.RegraError("Situação inválida.")
    if versao in (None, ""):
        versao = db.query("SELECT MAX(versao) AS versao FROM dbo.versao_base")[0]["versao"]
    else:
        versao = db.inteiro(versao)
    if versao is None or not db.query(
        "SELECT versao FROM dbo.versao_base WHERE versao=?", [versao]
    ):
        raise db.RegraError("Nenhuma base publicada nesta versão.", 404)
    tabela, chave, campos = TABELAS[categoria]
    condicoes = [f"registro.{campo} LIKE ? ESCAPE '~'" for campo in campos]
    params = [versao, *([db.pesquisa(texto)] * len(campos))]
    try:
        identificador = db.inteiro(texto, -2147483648)
    except db.RegraError:
        identificador = None
    if identificador is not None:
        condicoes.append(f"registro.{chave}=?")
        params.append(identificador)
    filtro = "registro.versao=? AND (" + " OR ".join(condicoes) + ")"
    totais = db.query(
        f"SELECT COUNT_BIG(*) AS todos,COUNT_BIG(CASE WHEN sin_ativo='S' THEN 1 END) AS ativos,COUNT_BIG(CASE WHEN sin_ativo='N' THEN 1 END) AS inativos FROM dbo.{tabela} registro WHERE {filtro}",
        params,
    )[0]
    if situacao != "TODOS":
        filtro += " AND registro.sin_ativo=?"
        params.append(situacao)
    if categoria == "assuntos":
        consulta = sql.CATALOGO_ARVORE.format(filtro=filtro).replace(
            "OFFSET ? ROWS FETCH NEXT 51 ROWS ONLY", ""
        )
        itens = db.query(consulta, [versao, *params])
    else:
        itens = db.query(
            f"SELECT registro.*,h.nome AS hipotese_legal_nome,h.base_legal AS hipotese_legal_base FROM dbo.{tabela} registro LEFT JOIN dbo.hipotese_legal h ON h.id_hipotese_legal=registro.id_hipotese_legal_sugestao WHERE {filtro} ORDER BY registro.{chave}",
            params,
        )
    vinculos = db.query(sql.CATALOGO_VINCULOS, [versao])
    orgaos = db.query(sql.CATALOGO_ORGAOS, [versao])
    associar_vinculos(itens, chave, vinculos, orgaos)
    return {"itens": itens, "totais": totais, "versao": versao, "categoria": categoria}


def associar_vinculos(itens, chave, vinculos, orgaos):
    for item in itens:
        item["vinculos"] = [v for v in vinculos if v[chave] == item[chave]]
        if chave == "id_assunto":
            item["recuo"] = min(int(item.get("nivel_hierarquia", 0)), 12) * 16
        for vinculo in item["vinculos"]:
            vinculo["orgaos"] = [
                o["sigla"]
                for o in orgaos
                if o["id_tipo_procedimento"] == vinculo["id_tipo_procedimento"]
            ]


def propriedades(item):
    labels = {
        "id_assunto": "ID do Assunto",
        "codigo_estruturado": "Código estruturado",
        "descricao": "Descrição",
        "sin_estrutural": "Item apenas estrutural",
        "prazo_corrente": "Prazo corrente",
        "prazo_intermediario": "Prazo intermediário",
        "sta_destinacao": "Destinação (código)",
        "observacao": "Observação",
        "idx_assunto": "Índice de pesquisa",
        "id_assunto_pai": "ID do Assunto pai",
        "id_tabela_assuntos": "ID da tabela de Assuntos",
        "id_hipotese_legal_sugestao": "ID da hipótese legal sugerida",
        "id_plano_trabalho": "ID do plano de trabalho",
        "id_tipo_procedimento": "ID do Tipo",
        "nome": "Nome",
        "sin_ativo": "Ativo",
        "sin_interno": "Interno",
        "sin_ouvidoria": "Ouvidoria",
        "sin_individual": "Individual",
        "sin_ouvidoria_anonimo": "Ouvidoria anônima",
        "sta_nivel_acesso_sugestao": "Nível de acesso sugerido (código)",
        "sta_grau_sigilo_sugestao": "Grau de sigilo sugerido (código)",
        "hipotese_legal_nome": "Hipótese legal",
        "hipotese_legal_base": "Base legal",
        "versao": "Versão",
    }
    return [
        (label, formatar_propriedade(key, item.get(key)))
        for key, label in labels.items()
        if key in item
    ]


def formatar_propriedade(key, valor):
    if key.startswith("sin_"):
        return {"S": "Sim", "N": "Não"}.get(valor, valor)
    if key == "sta_destinacao":
        return {
            "E": "Eliminação",
            "G": "Guarda permanente",
            None: "Não informada",
            "": "Não informada",
        }.get(valor, f"Código {valor}")
    return valor


def ordenar_assuntos(itens):
    """Pré-ordem pela relação explícita; órfãos visíveis, sem inferência do código."""
    por_id = {item["id_assunto"]: item for item in itens}
    filhos = {}
    for item in itens:
        pai = item.get("id_assunto_pai")
        filhos.setdefault(pai if pai in por_id else None, []).append(item)
    pilha = [(item, 0) for item in reversed(filhos.get(None, []))]
    vistos, ordenados = set(), []
    while pilha:
        item, nivel = pilha.pop()
        if item["id_assunto"] in vistos:
            continue
        vistos.add(item["id_assunto"])
        item["recuo"] = min(nivel, 12) * 16
        ordenados.append(item)
        pilha.extend((filho, nivel + 1) for filho in reversed(filhos.get(item["id_assunto"], [])))
    ordenados.extend(item for item in itens if item["id_assunto"] not in vistos)
    return ordenados
