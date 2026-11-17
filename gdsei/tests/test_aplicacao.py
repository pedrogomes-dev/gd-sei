from unittest.mock import patch

from django.template.loader import get_template
from django.test import Client, SimpleTestCase, override_settings
from django.urls import reverse

from gdsei import administracao, autenticacao, consultas, db


def tipo(atribuicao=1, orgao=0):
    return {
        "id_atribuicao": atribuicao,
        "id_tipo_procedimento": 7,
        "id_consulta": 1,
        "id_orgao": orgao,
        "nome": "Processo de teste",
        "versao": 0,
        "sigla": f"ORG{orgao}",
        "consulta": "Rodada 1",
        "status": "RASCUNHO",
        "visualizado": "S",
        "pendentes": 1,
        "sin_ativo": "S",
        "decisao_tipo": "MANTER",
        "justificativa_tipo": "",
        "parecer_tipo": None,
    }


def assunto():
    return {
        "id_assunto": 10,
        "codigo_estruturado": "085",
        "descricao": "Administração",
        "versao": 0,
        "sin_ativo": "S",
        "sin_estrutural": "N",
        "id_assunto_pai": None,
        "acao": "MANTER",
        "justificativa": "",
        "id_atribuicao": 1,
        "parecer": None,
    }


@override_settings(
    SESSION_ENGINE="django.contrib.sessions.backends.cache",
    SECURE_SSL_REDIRECT=False,
    SESSION_COOKIE_SECURE=False,
    CSRF_COOKIE_SECURE=False,
    ALLOWED_HOSTS=["testserver"],
    DEV_AUTH_ENABLED=True,
    DEVELOPMENT=True,
)
class AplicacaoTests(SimpleTestCase):
    def setUp(self):
        self.usuario = {
            "id_usuario": 1,
            "versao_sessao": 1,
            "nome": "Admin",
            "email": "admin@example.test",
            "sin_admin": "S",
        }
        self.sql = patch("gdsei.db.query", side_effect=self.consultar).start()
        self.addCleanup(patch.stopall)
        sessao = self.client.session
        sessao["id_usuario"] = 1
        sessao["versao_sessao"] = 1
        sessao.save()

    def consultar(self, sql, params=()):
        if "FROM dbo.usuario WHERE id_usuario=? AND sin_ativo='S'" in sql:
            return [dict(self.usuario)]
        if "sin_admin = 'S'" in sql and "SELECT id_usuario" in sql:
            return [{"id_usuario": 1}]
        if "FROM dbo.usuario" in sql and "sin_ativo, sin_admin, revisao" in sql:
            return [dict(self.usuario, revisao=1)]
        return []

    def test_anonimo_e_admin(self):
        self.client.cookies.clear()
        self.assertRedirects(
            self.client.get(reverse("usuarios")), reverse("login"), fetch_redirect_response=False
        )
        self.usuario["sin_admin"] = "N"
        sessao = self.client.session
        sessao.update({"id_usuario": 1, "versao_sessao": 1})
        sessao.save()
        self.assertEqual(self.client.get(reverse("processamento")).status_code, 403)

    def test_revogacao(self):
        self.usuario["versao_sessao"] = 2
        self.assertRedirects(
            self.client.get(reverse("tipos")), reverse("login"), fetch_redirect_response=False
        )
        self.assertNotIn("id_usuario", self.client.session)

    def test_logout_sem_sessao_e_post(self):
        self.client.cookies.clear()
        self.assertEqual(self.client.get(reverse("sair")).status_code, 405)
        self.assertRedirects(
            self.client.post(reverse("sair")), reverse("login"), fetch_redirect_response=False
        )

    def test_csrf_obrigatorio(self):
        cliente = Client(enforce_csrf_checks=True)
        self.assertEqual(
            cliente.post(reverse("login"), {"acao": "dev", "id_usuario": 1}).status_code, 403
        )

    def test_login_personificacao_e_bloqueio(self):
        self.client.cookies.clear()
        self.assertEqual(
            self.client.post(reverse("login"), {"acao": "dev", "id_usuario": 1}).status_code, 302
        )
        self.assertEqual(self.client.session["id_usuario"], 1)
        with override_settings(DEV_AUTH_ENABLED=False):
            with self.assertRaises(db.RegraError):
                autenticacao.personificar(self.client.request().wsgi_request, "1")

    def test_menu_e_rota_processamento(self):
        with patch("gdsei.administracao.processamento", return_value=[]):
            resposta = self.client.get(reverse("processamento"))
        self.assertContains(resposta, "Processamento das submissões")
        self.assertContains(resposta, reverse("distribuicao"))

    def test_todas_as_paginas_renderizam(self):
        cenarios = [
            (
                "inicio",
                [],
                "gdsei.consultas.inicio",
                {
                    "rodadas": [{"id_consulta": 1, "nome": "Rodada", "versao": 0}],
                    "rodada": {"id_consulta": 1},
                    "orgaos": [{"id_orgao": 0, "sigla": "ORG0", "status": "FINALIZADA"}],
                    "totais": {"pendentes": 1},
                },
            ),
            ("tipos", [], "gdsei.consultas.listar", [{**tipo(), "estado": "EM_AVALIACAO"}]),
            (
                "tipo",
                [1],
                "gdsei.consultas.detalhe",
                {
                    "tipo": tipo(),
                    "assuntos": [assunto()],
                    "manifestacao": {"revisao": 0},
                    "decisoes": [],
                },
            ),
            (
                "resumo",
                [1, 0],
                "gdsei.consultas.resumo",
                {
                    "grupo": {
                        "sigla": "ORG0",
                        "status": "RASCUNHO",
                        "pode_revisar": "S",
                        "revisao": 1,
                    },
                    "tipos": [{**tipo(), "decisoes": [assunto()]}],
                    "pode_finalizar": True,
                },
            ),
            (
                "catalogo",
                ["assuntos"],
                "gdsei.catalogo.consultar",
                {
                    "categoria": "assuntos",
                    "versao": 0,
                    "totais": {"todos": 1},
                    "itens": [{**assunto(), "vinculos": []}],
                },
            ),
            (
                "catalogo",
                ["tipos"],
                "gdsei.catalogo.consultar",
                {
                    "categoria": "tipos",
                    "versao": 0,
                    "totais": {"todos": 1},
                    "itens": [{**tipo(), "vinculos": []}],
                },
            ),
            (
                "processamento",
                [],
                "gdsei.administracao.processamento",
                [
                    {
                        **tipo(),
                        "concluido": False,
                        "resultado": "PENDENTE",
                        "avaliados": 0,
                        "total_avaliacoes": 2,
                        "assuntos": [assunto()],
                    }
                ],
            ),
            (
                "distribuicao",
                [],
                "gdsei.administracao.distribuicao",
                {
                    "versao": 0,
                    "tipos": [{**tipo(), "orgaos": [], "orgaos_nomes": []}],
                    "orgaos": [{"id_orgao": 0, "sigla": "ORG0"}],
                },
            ),
            (
                "usuarios",
                [],
                "gdsei.administracao.usuarios",
                {"itens": [{**self.usuario, "orgaos": []}], "totais": {"todos": 1}},
            ),
            (
                "usuario",
                [1],
                "gdsei.administracao.usuario",
                {**self.usuario, "revisao": 1, "orgaos": [0]},
            ),
            (
                "historico",
                [1],
                "gdsei.administracao.historico",
                [{"evento": "ALTERACAO", "antes": {}, "depois": {}}],
            ),
        ]
        for nome, args, alvo, dados in cenarios:
            with (
                self.subTest(nome=nome, args=args),
                patch(alvo, return_value=dados),
                patch("gdsei.consultas.pesquisar_assuntos", return_value=[]),
            ):
                resposta = self.client.get(reverse(nome, args=args))
                self.assertEqual(resposta.status_code, 200)

    def test_filtro_e_conclusao_independente_de_recusa(self):
        dados = [
            {
                **tipo(),
                "concluido": True,
                "resultado": "PARCIALMENTE_ACEITO",
                "avaliados": 2,
                "total_avaliacoes": 2,
                "assuntos": [{**assunto(), "parecer": "RECUSADO"}],
                "parecer_tipo": "ACEITO",
            }
        ]
        with patch("gdsei.administracao.processamento", return_value=dados):
            resposta = self.client.get(reverse("processamento"), {"estado": "CONCLUIDO"})
            self.assertContains(resposta, "Processamento concluído")
            self.assertContains(resposta, "Parcialmente aceita")
            self.assertNotContains(resposta, 'name="parecer"')
            self.assertNotContains(
                self.client.get(reverse("processamento"), {"estado": "PENDENTE"}), "ID 7"
            )

    def test_paginacao_preserva_grupo_completo(self):
        dados = [
            {
                **tipo(n),
                "concluido": False,
                "resultado": "PENDENTE",
                "avaliados": 0,
                "total_avaliacoes": 1,
                "assuntos": [],
            }
            for n in range(1, 22)
        ]
        with patch("gdsei.administracao.processamento", return_value=dados):
            resposta = self.client.get(reverse("processamento"), {"pagina": 2})
            self.assertContains(resposta, "0 de 21 Tipos avaliados")
            self.assertContains(resposta, "Página 2 de 2")

    def test_erro_ao_salvar_preserva_textos_e_inclusoes(self):
        dados = {
            "tipo": tipo(),
            "assuntos": [assunto()],
            "manifestacao": {"revisao": 1},
            "decisoes": [],
        }
        novo = {**assunto(), "id_assunto": 11, "descricao": "Novo Assunto"}
        with (
            patch("gdsei.consultas.detalhe", return_value=dados),
            patch("gdsei.consultas.pesquisar_assuntos", return_value=[novo]),
            patch("gdsei.consultas.salvar", side_effect=db.RegraError("Revisão alterada", 409)),
        ):
            resposta = self.client.post(
                reverse("tipo", args=[1]),
                {
                    "acao": "salvar",
                    "decisao_tipo": "MANTER",
                    "revisao": "1",
                    "observacao": "Texto preservado",
                    "incluir": "11",
                    "nova_justificativa_11": "Justificativa preservada",
                },
            )
        self.assertContains(resposta, "Revisão alterada")
        self.assertContains(resposta, "Texto preservado")
        self.assertContains(resposta, "Justificativa preservada")
        self.assertIn('value="11" checked', resposta.content.decode())

    def test_visualizacao_por_post_identifica_usuario_da_sessao(self):
        with patch("gdsei.consultas.visualizar") as visualizar:
            self.assertEqual(self.client.get(reverse("visualizar", args=[1])).status_code, 405)
            resposta = self.client.post(reverse("visualizar", args=[1]), {"id_usuario": 999})
        self.assertJSONEqual(resposta.content, {"visualizado": True})
        visualizar.assert_called_once_with(1, 1)

    def test_post_avaliacao_identifica_usuario_pela_sessao(self):
        with patch("gdsei.administracao.avaliar") as avaliar:
            resposta = self.client.post(
                reverse("processamento"),
                {"atribuicao": "5", "parecer": "RECUSADO", "assunto": "10", "id_usuario": "999"},
            )
        self.assertEqual(resposta.status_code, 302)
        avaliar.assert_called_once_with(1, "5", "RECUSADO", "10")

    def test_templates_compilam(self):
        from pathlib import Path

        for caminho in Path("gdsei/templates/gdsei").rglob("*.html"):
            with self.subTest(template=caminho):
                get_template(str(caminho.relative_to("gdsei/templates")).replace("\\", "/"))


class RegrasTests(SimpleTestCase):
    def test_estados_mutuamente_exclusivos(self):
        self.assertEqual(consultas.estado({"visualizado": "N", "pendentes": 0}), "NAO_VISUALIZADO")
        self.assertEqual(consultas.estado({"visualizado": "S", "pendentes": 1}), "EM_AVALIACAO")
        self.assertEqual(consultas.estado({"visualizado": "S", "pendentes": 0}), "AVALIADO")

    def test_qualquer_recusa_parcial_inclusive_todos(self):
        for valores in (["RECUSADO", "ACEITO"], ["RECUSADO", "RECUSADO"], ["RECUSADO", None]):
            self.assertEqual(administracao.resultado(valores), "PARCIALMENTE_ACEITO")
        self.assertEqual(administracao.resultado(["ACEITO", "ACEITO"]), "ACEITO")
        self.assertEqual(administracao.resultado([None, "ACEITO"]), "PENDENTE")

    def test_parametros_invalidos(self):
        for valor in (None, "abc", True, 1.5, "2147483648", "-1"):
            with self.subTest(valor=valor), self.assertRaises(db.RegraError):
                db.inteiro(valor)
        with self.assertRaises(db.RegraError):
            db.ids([0, 0])
        self.assertEqual(db.ids([0, "2"]), [0, 2])

    def test_wildcards_escapados(self):
        self.assertEqual(db.pesquisa("%_~["), "%~%~_~~~[%")

    def test_vinculos_duplicados_e_justificativa(self):
        for vinculos in (
            [{"id_assunto": 1, "acao": "REMOVER", "justificativa": ""}],
            [{"id_assunto": 1, "acao": "MANTER"}] * 2,
        ):
            with self.assertRaises(db.RegraError):
                consultas.validar_vinculos(vinculos)

    def test_assunto_estrutural_bloqueado_no_servidor(self):
        with (
            patch("gdsei.consultas.detalhe", return_value={"tipo": {"versao": 0}}),
            patch("gdsei.db.query", return_value=[{"id_assunto": 10}]) as query,
        ):
            with self.assertRaisesMessage(db.RegraError, "Item apenas estrutural"):
                consultas.salvar(
                    1,
                    2,
                    {
                        "revisao": 0,
                        "decisao_tipo": "MANTER",
                        "vinculos": [
                            {"id_assunto": 10, "acao": "ADICIONAR", "justificativa": "Motivo"}
                        ],
                    },
                )
            self.assertIn("sin_estrutural = 'S'", query.call_args.args[0])
            self.assertIn("existente.versao = assunto.versao", query.call_args.args[0])

    def test_codigo_uso_unico_e_limites(self):
        codigos = autenticacao.Codigos()
        codigos.reservar("a@example.test", "127.0.0.1")
        with self.assertRaises(db.RegraError):
            codigos.reservar("a@example.test", "127.0.0.1")
        codigo = codigos.criar("a@example.test", {"id_usuario": 1})
        codigos.codigos["a@example.test"]["enviado"] = True
        self.assertEqual(codigos.consumir("a@example.test", codigo), {"id_usuario": 1})
        with self.assertRaises(db.RegraError):
            codigos.consumir("a@example.test", codigo)

    def test_codigo_cinco_tentativas_e_expiracao(self):
        codigos = autenticacao.Codigos()
        codigos.criar("a", {})
        codigos.codigos["a"]["enviado"] = True
        for _ in range(5):
            with self.assertRaises(db.RegraError):
                codigos.consumir("a", "errado")
        self.assertNotIn("a", codigos.codigos)
        codigos.criar("a", {})
        codigos.codigos["a"].update(expira=0, enviado=True)
        with self.assertRaises(db.RegraError):
            codigos.consumir("a", "000000")
