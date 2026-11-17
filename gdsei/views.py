from itertools import groupby

from django.conf import settings
from django.core.paginator import Paginator
from django.http import JsonResponse
from django.shortcuts import redirect, render
from django.views.decorators.http import require_GET, require_http_methods, require_POST

from . import administracao, autenticacao, catalogo, consultas, db
from .autenticacao import acesso


def pagina(request, template, contexto):
    contexto["aviso"] = request.session.pop("aviso", None)
    return render(request, "gdsei/" + template + ".html", contexto)


def paginar(request, itens, tamanho=20):
    return Paginator(itens, tamanho).get_page(request.GET.get("pagina", 1))


@require_http_methods(["GET", "POST"])
def login(request):
    if request.usuario:
        return redirect("inicio")
    erro = None
    if request.method == "POST":
        try:
            return realizar_login(request)
        except db.RegraError as falha:
            erro = str(falha)
    return pagina(
        request,
        "login",
        {
            "erro": erro,
            "usuarios": autenticacao.usuarios_desenvolvimento(),
            "dev": settings.DEV_AUTH_ENABLED,
            "email": request.session.get("email_login", ""),
        },
    )


def realizar_login(request):
    acao = request.POST.get("acao")
    if acao == "dev":
        autenticacao.personificar(request, request.POST.get("id_usuario"))
    elif acao == "codigo":
        email = autenticacao.email_valido(request.POST.get("email", ""))
        autenticacao.entrar_email(request, email, request.POST.get("codigo", "").strip())
    elif acao == "solicitar":
        email = autenticacao.email_valido(request.POST.get("email", ""))
        autenticacao.solicitar_codigo(email, request.META.get("REMOTE_ADDR", "desconhecido"))
        request.session["email_login"] = email
        request.session["aviso"] = (
            "Se o e-mail estiver cadastrado e ativo, você receberá um código válido por 10 minutos."
        )
        return redirect("login")
    else:
        raise db.RegraError("Ação inválida.")
    return redirect("inicio")


@require_POST
def sair(request):
    try:
        if request.usuario:
            db.query(
                "INSERT dbo.auditoria(id_usuario,evento) VALUES(?,'LOGOUT')",
                [request.usuario["id_usuario"]],
            )
    finally:
        request.session.flush()
    return redirect("login")


@require_GET
def health(request):
    return JsonResponse({"status": "ok"})


@acesso()
@require_GET
def inicio(request):
    return pagina(
        request,
        "inicio",
        consultas.inicio(request.usuario["id_usuario"], request.GET.get("consulta")),
    )


@acesso()
@require_GET
def tipos(request):
    itens = consultas.listar(request.usuario["id_usuario"])
    texto, estado = request.GET.get("q", "").strip(), request.GET.get("estado", "TODOS")
    db.pesquisa(texto)
    itens = [
        i
        for i in itens
        if texto.casefold() in f"{i['id_tipo_procedimento']} {i['nome']} {i['sigla']}".casefold()
    ]
    totais = {"TODOS": len(itens), "NAO_VISUALIZADO": 0, "EM_AVALIACAO": 0, "AVALIADO": 0}
    andamento = consultas.progresso(itens)
    for item in itens:
        chave = "AVALIADO" if item["estado"] == "DESCONTINUAR" else item["estado"]
        totais[chave] += 1
    if estado != "TODOS":
        itens = [
            i
            for i in itens
            if i["estado"] == estado or (estado == "AVALIADO" and i["estado"] == "DESCONTINUAR")
        ]
    return pagina(
        request,
        "tipos",
        {
            "itens": paginar(request, itens),
            "totais": totais,
            "estado": estado,
            "progresso": andamento,
        },
    )


def vinculos_formulario(post, dados):
    existentes = {int(v["id_assunto"]): v for v in dados["assuntos"] + dados["decisoes"]}
    vinculos = []
    for id_assunto in existentes:
        acao = post.get(f"acao_{id_assunto}")
        if acao:
            vinculos.append(
                {
                    "id_assunto": id_assunto,
                    "acao": acao,
                    "justificativa": post.get(f"justificativa_{id_assunto}", ""),
                }
            )
    for id_assunto in db.ids(post.getlist("incluir")):
        vinculos.append(
            {
                "id_assunto": id_assunto,
                "acao": "ADICIONAR",
                "justificativa": post.get(f"nova_justificativa_{id_assunto}", ""),
            }
        )
    return vinculos


@acesso()
@require_http_methods(["GET", "POST"])
def tipo(request, atribuicao):
    usuario = request.usuario["id_usuario"]
    dados = consultas.detalhe(usuario, atribuicao)
    erro = None
    if request.method == "POST":
        try:
            return salvar_tipo(request, dados, usuario, atribuicao)
        except db.RegraError as falha:
            erro = str(falha)
    decisoes = {v["id_assunto"]: v for v in dados["decisoes"]}
    assuntos = {v["id_assunto"]: dict(v) for v in dados["assuntos"]}
    assuntos.update({k: dict(v) for k, v in decisoes.items() if k not in assuntos})
    for id_assunto, assunto in assuntos.items():
        assunto.update(decisoes.get(id_assunto, {}))
        if request.method == "POST":
            assunto["acao"] = request.POST.get(f"acao_{id_assunto}")
            assunto["justificativa"] = request.POST.get(f"justificativa_{id_assunto}", "")
        assunto["inclusao"] = assunto.get("acao") == "ADICIONAR"
    candidatos = consultas.pesquisar_assuntos(dados["tipo"])
    for candidato in candidatos:
        id_assunto = str(candidato["id_assunto"])
        candidato["selecionado"] = id_assunto in request.POST.getlist("incluir")
        candidato["justificativa"] = request.POST.get(f"nova_justificativa_{id_assunto}", "")
    dados.update(
        assuntos=list(assuntos.values()),
        candidatos=catalogo.ordenar_assuntos(
            [c for c in candidatos if c["id_assunto"] not in assuntos]
        ),
        erro=erro,
        editavel=dados["tipo"]["status"] == "RASCUNHO",
    )
    if request.method == "POST":
        dados["manifestacao"].update(
            {
                k: request.POST.get(k, "")
                for k in ("decisao_tipo", "justificativa_tipo", "observacao")
            }
        )
    return pagina(request, "tipo", dados)


def salvar_tipo(request, dados, usuario, atribuicao):
    if request.POST.get("acao") == "visualizar":
        consultas.visualizar(usuario, atribuicao)
        request.session["aviso"] = "Tipo marcado como visualizado."
    elif request.POST.get("acao") == "salvar":
        if dados["tipo"]["visualizado"] != "S" and request.POST.get("decisao_tipo"):
            consultas.visualizar(usuario, atribuicao)
        consultas.salvar(
            usuario,
            atribuicao,
            {**request.POST.dict(), "vinculos": vinculos_formulario(request.POST, dados)},
        )
        request.session["aviso"] = "Decisões salvas."
    else:
        raise db.RegraError("Ação inválida.")
    return redirect("tipo", atribuicao=atribuicao)


@acesso()
@require_POST
def visualizar(request, atribuicao):
    consultas.visualizar(request.usuario["id_usuario"], atribuicao)
    return JsonResponse({"visualizado": True})


@acesso()
@require_http_methods(["GET", "POST"])
def resumo(request, consulta, orgao):
    usuario = request.usuario["id_usuario"]
    dados = consultas.resumo(usuario, consulta, orgao)
    if request.method == "POST":
        consultas.finalizar(usuario, consulta, orgao, request.POST.get("revisao"))
        request.session["aviso"] = "Manifestação submetida e finalizada."
        return redirect("resumo", consulta=consulta, orgao=orgao)
    dados["itens"] = paginar(request, dados["tipos"])
    return pagina(request, "resumo", dados)


@acesso()
@require_GET
def catalogos(request, categoria):
    dados = catalogo.consultar(
        categoria,
        request.GET.get("q", "").strip(),
        request.GET.get("estado", "TODOS"),
        request.GET.get("versao"),
    )
    dados["itens"] = paginar(request, dados["itens"], 50)
    return pagina(request, "catalogo", dados)


@acesso(admin=True)
@require_http_methods(["GET", "POST"])
def processamento(request):
    usuario = request.usuario["id_usuario"]
    if request.method == "POST":
        administracao.avaliar(
            usuario,
            request.POST.get("atribuicao"),
            request.POST.get("parecer"),
            request.POST.get("assunto"),
        )
        request.session["aviso"] = "Parecer administrativo registrado."
        return redirect("processamento")
    itens = administracao.processamento(usuario)
    grupos = {}
    for (consulta, orgao), linhas in groupby(
        sorted(itens, key=lambda t: (t["id_consulta"], t["id_orgao"])),
        key=lambda t: (t["id_consulta"], t["id_orgao"]),
    ):
        linhas = list(linhas)
        valores = [
            v for t in linhas for v in [t["parecer_tipo"], *(a["parecer"] for a in t["assuntos"])]
        ]
        grupos[(consulta, orgao)] = {
            "primeiro": linhas[0],
            "total": len(linhas),
            "concluidos": sum(t["concluido"] for t in linhas),
            "resultado": administracao.resultado(valores),
        }
    texto = request.GET.get("q", "").strip()
    db.pesquisa(texto)
    encontrados = [
        t
        for t in itens
        if texto.casefold() in f"{t['id_tipo_procedimento']} {t['nome']}".casefold()
    ]
    totais = {
        "todos": len(encontrados),
        "pendentes": sum(not t["concluido"] for t in encontrados),
        "concluidos": sum(t["concluido"] for t in encontrados),
    }
    estado = request.GET.get("estado", "TODOS")
    filtrados = [
        t for t in encontrados if estado == "TODOS" or (estado == "CONCLUIDO") == t["concluido"]
    ]
    itens_pagina = paginar(request, filtrados)
    visiveis = []
    for chave, linhas in groupby(itens_pagina, key=lambda t: (t["id_consulta"], t["id_orgao"])):
        visiveis.append({**grupos[chave], "itens": list(linhas)})
    return pagina(
        request, "processamento", {"grupos": visiveis, "itens": itens_pagina, "totais": totais}
    )


@acesso(admin=True)
@require_http_methods(["GET", "POST"])
def distribuicao(request):
    usuario = request.usuario["id_usuario"]
    if request.method == "POST":
        if request.POST.get("acao") == "lote":
            administracao.distribuir_lote(
                usuario,
                request.POST.get("versao"),
                request.POST.getlist("tipos"),
                request.POST.getlist("orgaos"),
            )
        elif request.POST.get("acao") == "salvar":
            administracao.salvar_distribuicao(
                usuario,
                request.POST.get("tipo"),
                request.POST.get("versao"),
                request.POST.getlist("anteriores"),
                request.POST.getlist("orgaos"),
            )
        else:
            raise db.RegraError("Ação inválida.")
        request.session["aviso"] = (
            "Distribuição de referência salva. Rodadas existentes foram preservadas."
        )
        return redirect("distribuicao")
    dados = administracao.distribuicao(usuario)
    selecionado = request.GET.get("tipo")
    dados["selecionado"] = None
    if selecionado is not None:
        selecionado = db.inteiro(selecionado)
        dados["selecionado"] = next(
            (t for t in dados["tipos"] if t["id_tipo_procedimento"] == selecionado), None
        )
    texto = request.GET.get("q", "").strip()
    db.pesquisa(texto)
    encontrados = [
        t
        for t in dados["tipos"]
        if texto.casefold() in f"{t['id_tipo_procedimento']} {t['nome']}".casefold()
    ]
    vinculados = sum(bool(t["orgaos"]) for t in encontrados)
    ativos = sum(t["sin_ativo"] == "S" for t in encontrados)
    dados["totais"] = {
        "todos": len(encontrados),
        "vinculados": vinculados,
        "ativos": ativos,
        "negativo_vinculados": -vinculados,
        "negativo_ativos": -ativos,
    }
    estado, vinculo = request.GET.get("estado", "TODOS"), request.GET.get("vinculo", "TODOS")
    encontrados = [
        t
        for t in encontrados
        if (estado == "TODOS" or t["sin_ativo"] == estado)
        and (vinculo == "TODOS" or bool(t["orgaos"]) == (vinculo == "S"))
    ]
    dados["itens"] = paginar(request, encontrados, 50)
    return pagina(request, "distribuicao", dados)


@acesso(admin=True)
@require_GET
def usuarios(request):
    dados = administracao.usuarios(
        request.GET.get("q", "").strip(),
        request.GET.get("estado", "TODOS"),
        request.GET.get("orgao"),
    )
    dados.update(itens=paginar(request, dados["itens"], 50), orgaos=administracao.orgaos())
    return pagina(request, "usuarios", dados)


@acesso(admin=True)
@require_http_methods(["GET", "POST"])
def usuario(request, id_usuario=0):
    item = (
        administracao.usuario(id_usuario)
        if id_usuario
        else {"revisao": 0, "orgaos": [], "sin_ativo": "S", "sin_admin": "N"}
    )
    erro = None
    if request.method == "POST":
        try:
            salvo = administracao.salvar_usuario(
                request.usuario["id_usuario"],
                id_usuario,
                {**request.POST.dict(), "orgaos": request.POST.getlist("orgaos")},
            )
            request.session["aviso"] = "Usuário salvo."
            return redirect("usuario", id_usuario=salvo.get("id_usuario", id_usuario))
        except db.RegraError as falha:
            erro = str(falha)
            item.update(request.POST.dict())
            item["orgaos"] = db.ids(request.POST.getlist("orgaos"))
    return pagina(
        request,
        "usuario",
        {"item": item, "id_usuario": id_usuario, "orgaos": administracao.orgaos(), "erro": erro},
    )


@acesso(admin=True)
@require_GET
def historico(request, id_usuario):
    return pagina(
        request,
        "historico",
        {
            "item": administracao.usuario(id_usuario),
            "itens": paginar(request, administracao.historico(id_usuario), 50),
        },
    )
