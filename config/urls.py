from django.urls import path

from gdsei import views

urlpatterns = [
    path("", views.inicio, name="inicio"),
    path("login/", views.login, name="login"),
    path("sair/", views.sair, name="sair"),
    path("health/", views.health, name="health"),
    path("api/health", views.health),
    path("tipos/", views.tipos, name="tipos"),
    path("tipos/<int:atribuicao>/", views.tipo, name="tipo"),
    path("tipos/<int:atribuicao>/visualizar/", views.visualizar, name="visualizar"),
    path("resumo/<int:consulta>/<int:orgao>/", views.resumo, name="resumo"),
    path("catalogo/<str:categoria>/", views.catalogos, name="catalogo"),
    path("administracao/processamento/", views.processamento, name="processamento"),
    path("administracao/distribuicao/", views.distribuicao, name="distribuicao"),
    path("administracao/usuarios/", views.usuarios, name="usuarios"),
    path("administracao/usuarios/novo/", views.usuario, name="novo_usuario"),
    path("administracao/usuarios/<int:id_usuario>/", views.usuario, name="usuario"),
    path("administracao/usuarios/<int:id_usuario>/historico/", views.historico, name="historico"),
]
