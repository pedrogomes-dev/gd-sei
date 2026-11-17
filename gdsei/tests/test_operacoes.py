import json
from unittest.mock import MagicMock, patch

from django.db import DatabaseError
from django.test import SimpleTestCase, override_settings

from gdsei import administracao, autenticacao, catalogo, consultas, db, sql


class OperacoesTests(SimpleTestCase):
    @override_settings(
        EMAIL_HOST="smtp.example.test",
        EMAIL_HOST_USER="teste",
        EMAIL_HOST_PASSWORD="teste",
        DEFAULT_FROM_EMAIL="gdsei@example.test",
    )
    def test_envio_email_simulado_sem_revelar_cadastro(self):
        codigos = autenticacao.Codigos()
        with (
            patch("gdsei.autenticacao.codigos", codigos),
            patch(
                "gdsei.autenticacao.usuario_email",
                return_value={"id_usuario": 1, "versao_sessao": 1},
            ),
            patch("gdsei.autenticacao.send_mail") as enviar,
        ):
            autenticacao.solicitar_codigo("a@example.test", "127.0.0.1")
            self.assertTrue(codigos.codigos["a@example.test"]["enviado"])
            self.assertNotIn("codigo", codigos.codigos["a@example.test"])
            self.assertIn("10 minutos", enviar.call_args.args[1])
        with (
            patch("gdsei.autenticacao.codigos", autenticacao.Codigos()),
            patch("gdsei.autenticacao.usuario_email", return_value=None),
            patch("gdsei.autenticacao.send_mail") as enviar,
        ):
            autenticacao.solicitar_codigo("ausente@example.test", "127.0.0.1")
            enviar.assert_not_called()

    @override_settings(
        EMAIL_HOST="smtp.example.test",
        EMAIL_HOST_USER="teste",
        EMAIL_HOST_PASSWORD="teste",
        DEFAULT_FROM_EMAIL="gdsei@example.test",
    )
    def test_falha_smtp_nao_expoe_credenciais(self):
        codigos = autenticacao.Codigos()
        with (
            patch("gdsei.autenticacao.codigos", codigos),
            patch(
                "gdsei.autenticacao.usuario_email",
                return_value={"id_usuario": 1, "versao_sessao": 1},
            ),
            patch("gdsei.autenticacao.send_mail", side_effect=OSError("password=segredo")),
        ):
            with self.assertRaises(db.RegraError) as erro:
                autenticacao.solicitar_codigo("a@example.test", "127.0.0.1")
            self.assertNotIn("segredo", str(erro.exception))
            self.assertNotIn("a@example.test", codigos.codigos)
            self.assertNotIn("a@example.test", codigos.em_envio)

    def test_parametrizacao_e_multiplos_resultados(self):
        cursor = MagicMock()
        cursor.__enter__.return_value = cursor
        cursor.description = [("valor",)]
        cursor.fetchall.return_value = [("ok",)]
        with patch("gdsei.db.connection") as conexao:
            conexao.cursor.return_value = cursor
            self.assertEqual(db.query("SELECT ? AS valor", ["' OR 1=1 --"]), [{"valor": "ok"}])
        cursor.execute.assert_called_once_with("SELECT %s AS valor", ["' OR 1=1 --"])

    def test_cte_parametrizada(self):
        cursor = MagicMock()
        cursor.__enter__.return_value = cursor
        cursor.description = None
        cursor.nextset.return_value = False
        with patch("gdsei.db.connection") as conexao:
            conexao.cursor.return_value = cursor
            self.assertEqual(
                db.query("\n WITH dados AS (SELECT ? AS id) SELECT * FROM dados", [1]), []
            )
        self.assertTrue(cursor.execute.call_args.args[0].startswith(";WITH"))

    def test_erros_de_concorrencia_e_dados_sensiveis(self):
        for codigo, status in (
            (51030, 403),
            (51031, 409),
            (51032, 409),
            (51404, 409),
            (51504, 409),
        ):
            with self.subTest(codigo=codigo), patch("gdsei.db.connection") as conexao:
                conexao.cursor.side_effect = DatabaseError(f"Driver (SQLExecute) ({codigo})")
                with self.assertRaises(db.RegraError) as erro:
                    db.query("SELECT 1")
                self.assertEqual(erro.exception.status, status)
        with (
            patch("gdsei.db.connection") as conexao,
            self.assertLogs("gdsei.db", level="ERROR") as logs,
        ):
            conexao.cursor.side_effect = DatabaseError("password=segredo; host=privado")
            with self.assertRaises(db.RegraError) as erro:
                db.query("SELECT 1")
            self.assertNotIn("segredo", str(erro.exception))
            self.assertNotIn("segredo", " ".join(logs.output))

    def test_detalhe_de_outro_orgao_rejeitado(self):
        with patch("gdsei.db.query", return_value=[]) as query:
            with self.assertRaises(db.RegraError) as erro:
                consultas.detalhe(1, 999)
            self.assertEqual(erro.exception.status, 404)
            self.assertEqual(query.call_args.args[1], [1, 999])
            self.assertIn("usuario.id_orgao = atribuicao.id_orgao", query.call_args.args[0])

    def test_salvar_manifestacao_reutiliza_procedure_e_revisao(self):
        with (
            patch("gdsei.consultas.detalhe", return_value={"tipo": {"versao": 3}}),
            patch("gdsei.db.query", return_value=[{"revisao": 5}]) as query,
        ):
            consultas.salvar(
                1,
                2,
                {
                    "revisao": "4",
                    "decisao_tipo": "MANTER",
                    "observacao": "Texto",
                    "vinculos": [{"id_assunto": 10, "acao": "MANTER", "justificativa": ""}],
                },
            )
        comando, params = query.call_args.args
        self.assertEqual(comando, "EXEC dbo.sp_salvar_manifestacao ?,?,?,?,?,?,?")
        self.assertEqual(params[:4], [1, 2, 4, "Texto"])
        self.assertEqual(json.loads(params[4])[0]["id_assunto"], 10)

    def test_descontinuacao_exige_justificativa_e_nao_submete_assuntos(self):
        with (
            patch("gdsei.consultas.detalhe", return_value={"tipo": {"versao": 0}}),
            patch("gdsei.db.query") as query,
        ):
            with self.assertRaises(db.RegraError):
                consultas.salvar(1, 2, {"revisao": 0, "decisao_tipo": "DESCONTINUAR"})
            query.assert_not_called()
            consultas.salvar(
                1,
                2,
                {
                    "revisao": 0,
                    "decisao_tipo": "DESCONTINUAR",
                    "justificativa_tipo": "Motivo",
                    "vinculos": [None],
                },
            )
            self.assertEqual(json.loads(query.call_args.args[1][4]), [])

    def test_submissao_reutiliza_procedure(self):
        with patch("gdsei.db.query") as query:
            consultas.finalizar(1, 2, 0, "5")
        query.assert_called_once_with(
            "EXEC dbo.sp_finalizar_manifestacao_orgao ?,?,?,?", [1, 2, 0, 5]
        )

    def test_admin_rejeitado_no_dominio(self):
        with patch("gdsei.db.query", return_value=[]):
            for operacao in (
                lambda: administracao.avaliar(1, 2, "ACEITO"),
                lambda: administracao.distribuicao(1),
                lambda: administracao.distribuir_lote(1, 0, [1], [0]),
            ):
                with self.assertRaises(db.RegraError) as erro:
                    operacao()
                self.assertEqual(erro.exception.status, 403)

    def test_aceite_individual_contexto_e_idempotencia_sql(self):
        with patch("gdsei.db.query", return_value=[{"id_usuario": 1}]) as query:
            administracao.avaliar(1, "2", "RECUSADO", "10")
            self.assertEqual(query.call_args.args[1], [1, 2, "RECUSADO", 1, 10])
            comando = query.call_args.args[0]
            for regra in (
                "WITH(UPDLOCK,HOLDLOCK)",
                "@anterior <> @parecer",
                "'FINALIZADA'",
                "a.versao = v.versao",
            ):
                self.assertIn(regra, comando)

    def test_processamento_conclusao_parcial_preserva_orgaos(self):
        dados = [
            {"id_atribuicao": 1, "parecer_tipo": "ACEITO"},
            {"id_atribuicao": 2, "parecer_tipo": None},
        ]
        assunto = {"id_atribuicao": 1, "parecer": "RECUSADO"}
        with patch("gdsei.db.query", side_effect=[[{"id_usuario": 1}], dados, [assunto]]):
            itens = administracao.processamento(1)
        self.assertTrue(itens[0]["concluido"])
        self.assertEqual(itens[0]["resultado"], "PARCIALMENTE_ACEITO")
        self.assertFalse(itens[1]["concluido"])
        self.assertEqual(itens[1]["assuntos"], [])

    def test_lote_acrescenta_sem_remover(self):
        with patch(
            "gdsei.db.query", side_effect=[[{"id_usuario": 1}], [{"vinculos_incluidos": 2}]]
        ) as query:
            administracao.distribuir_lote(1, "0", ["3", "2"], ["0"])
            comando, params = query.call_args.args
        self.assertEqual(comando, sql.DISTRIBUIR_LOTE)
        self.assertNotIn("DELETE FROM", comando)
        self.assertIn("NOT EXISTS", comando)
        self.assertEqual(params, [1, 0, "[2, 3]", "[0]"])

    def test_hierarquia_por_pai_nao_por_codigo(self):
        itens = [
            {"id_assunto": 1, "codigo_estruturado": "085", "id_assunto_pai": None},
            {"id_assunto": 2, "codigo_estruturado": "085.6", "id_assunto_pai": 1},
            {"id_assunto": 3, "codigo_estruturado": "085.611.a", "id_assunto_pai": 1},
        ]
        ordenados = catalogo.ordenar_assuntos(itens)
        self.assertEqual([i["recuo"] for i in ordenados], [0, 16, 16])

    def test_email_fluxo_simulado_e_revogacao(self):
        codigos = autenticacao.Codigos()
        with (
            patch("gdsei.autenticacao.codigos", codigos),
            patch(
                "gdsei.autenticacao.usuario_email",
                return_value={"id_usuario": 1, "versao_sessao": 2},
            ),
        ):
            codigo = codigos.criar("a@example.test", {"id_usuario": 1, "versao_sessao": 1})
            codigos.codigos["a@example.test"]["enviado"] = True
            with self.assertRaisesMessage(db.RegraError, "Acesso alterado"):
                autenticacao.entrar_email(None, "a@example.test", codigo)
