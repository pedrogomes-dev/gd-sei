from uuid import uuid4

from django import template
from django.utils.html import format_html

from gdsei.catalogo import propriedades

register = template.Library()
STATUS = {
    "AVALIADO": ("Avaliado", "verde", "✓"),
    "DESCONTINUAR": ("Descontinuação proposta", "cinza-azul", "✕"),
    "EM_AVALIACAO": ("Em avaliação", "ambar", "◷"),
    "NAO_VISUALIZADO": ("Não visualizado", "vermelho", "◉"),
    "MANTER": ("Manter", "azul", "✓"),
    "REMOVER": ("Remover", "vermelho", "⊖"),
    "ADICIONAR": ("Incluir", "verde", "⊕"),
    "RASCUNHO": ("Rascunho", "ambar", "✎"),
    "FINALIZADA": ("Finalizada", "verde", "✓"),
    "ACEITO": ("Adotado", "verde", "✓"),
    "RECUSADO": ("Recusado", "vermelho", "✕"),
    "PARCIALMENTE_ACEITO": ("Parcialmente aceita", "ambar", "◷"),
    "PENDENTE": ("Pendente", "ambar", "◷"),
    "CONCLUIDO": ("Concluído", "verde", "✓"),
}


@register.simple_tag
def status(valor, texto=None):
    label, cor, icone = STATUS.get(valor, STATUS["PENDENTE"])
    return format_html(
        '<span class="status {}"><span aria-hidden="true">{}</span> {}</span>',
        cor,
        icone,
        texto or label,
    )


@register.simple_tag(takes_context=True)
def filtro(context, **valores):
    query = context["request"].GET.copy()
    query.pop("pagina", None)
    for chave, valor in valores.items():
        query[chave] = str(valor)
    return "?" + query.urlencode()


@register.simple_tag(takes_context=True)
def numero_pagina(context, numero):
    query = context["request"].GET.copy()
    query["pagina"] = numero
    return "?" + query.urlencode()


@register.inclusion_tag("gdsei/componentes/propriedades.html")
def informacoes(item, identificador):
    item = dict(item)
    if "assunto_codigo" in item:
        item["codigo_estruturado"] = item["assunto_codigo"]
        item["descricao"] = item["assunto_descricao"]
    return {"propriedades": propriedades(item), "identificador": f"{identificador}-{uuid4().hex}"}
