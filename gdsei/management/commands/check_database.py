from django.core.management.base import BaseCommand, CommandError
from django.db import connection
from django.test import Client, override_settings

from gdsei import db


class Command(BaseCommand):
    help = "Verifica conexão/esquema e, opcionalmente, renderiza páginas com consultas somente de leitura."

    def add_arguments(self, parser):
        parser.add_argument(
            "--pages",
            action="store_true",
            help="Confere GETs com um administrador ativo existente; não realiza login nem auditoria.",
        )

    def handle(self, *args, **options):
        try:
            db.query("SELECT 1 AS conectado")
            for tabela in (
                "usuario",
                "orgao",
                "consulta",
                "consulta_orgao",
                "consulta_orgao_tipo",
                "assunto",
                "manifestacao_tipo",
                "manifestacao_vinculo",
                "avaliacao_setic_tipo",
                "avaliacao_setic_assunto",
            ):
                if not db.query("SELECT OBJECT_ID(?, 'U') AS objeto", ["dbo." + tabela])[0][
                    "objeto"
                ]:
                    raise CommandError(f"Tabela ausente ou sem visibilidade: {tabela}.")
            self.stdout.write("Conexão e metadados: OK (SELECT).")
            if options["pages"]:
                self.check_pages()
        except db.RegraError as error:
            raise CommandError(str(error)) from None

    def check_pages(self):
        usuarios = db.query(
            "SELECT TOP 1 id_usuario,versao_sessao FROM dbo.usuario WHERE sin_ativo='S' AND sin_admin='S' ORDER BY id_usuario"
        )
        if not usuarios:
            raise CommandError("Sem administrador ativo para a conferência de leitura.")
        with override_settings(ALLOWED_HOSTS=["testserver"], SECURE_SSL_REDIRECT=False):
            cliente = Client()
            sessao = cliente.session
            sessao["id_usuario"] = int(usuarios[0]["id_usuario"])
            sessao["versao_sessao"] = int(usuarios[0]["versao_sessao"])
            sessao.save()
            try:
                with connection.execute_wrapper(self.read_only):
                    for caminho in (
                        "/",
                        "/tipos/",
                        "/catalogo/assuntos/",
                        "/catalogo/tipos/",
                        "/administracao/usuarios/",
                        "/administracao/distribuicao/",
                        "/administracao/processamento/",
                    ):
                        resposta = cliente.get(caminho)
                        if resposta.status_code != 200:
                            raise CommandError(f"GET {caminho}: HTTP {resposta.status_code}.")
                        self.stdout.write(f"GET {caminho}: HTTP 200 (somente leitura).")
                    self.check_detalhe(cliente)
            finally:
                sessao.flush()

    def check_detalhe(self, cliente):
        vinculados = db.query("""SELECT TOP 1 u.id_usuario,u.versao_sessao,a.id_atribuicao,a.id_consulta,a.id_orgao
          FROM dbo.usuario u JOIN dbo.usuario_orgao v ON v.id_usuario=u.id_usuario
          JOIN dbo.consulta_orgao_tipo a ON a.id_orgao=v.id_orgao
          WHERE u.sin_ativo='S' ORDER BY a.id_atribuicao,u.id_usuario""")
        if not vinculados:
            self.stdout.write("Detalhe/resumo: pendentes (sem usuário ativo com atribuição).")
            return
        item = vinculados[0]
        sessao = cliente.session
        sessao.update(
            {"id_usuario": int(item["id_usuario"]), "versao_sessao": int(item["versao_sessao"])}
        )
        sessao.save()
        caminhos = [
            f"/tipos/{item['id_atribuicao']}/",
            f"/resumo/{item['id_consulta']}/{item['id_orgao']}/",
        ]
        for caminho in caminhos:
            if cliente.get(caminho).status_code != 200:
                raise CommandError("Detalhe ou resumo falhou na conferência de leitura.")
        self.stdout.write("Detalhe do Tipo e resumo por órgão: HTTP 200 (somente leitura).")
        sessao.flush()

    @staticmethod
    def read_only(execute, sql, params, many, context):
        if not sql.lstrip().upper().startswith(("SELECT", "WITH", ";WITH")):
            raise CommandError("A conferência de páginas bloqueou uma operação não SELECT/WITH.")
        return execute(sql, params, many, context)
