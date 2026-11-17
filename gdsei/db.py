import logging
import re

from django.db import DatabaseError, connection

logger = logging.getLogger(__name__)


class RegraError(Exception):
    def __init__(self, message, status=400):
        super().__init__(message)
        self.status = status


ERROS = {
    51021: (403, "Tipo não autorizado."),
    51030: (403, "Consulta, órgão ou Tipo não autorizado."),
    51031: (409, "A manifestação já foi finalizada."),
    51032: (409, "Outro usuário alterou os dados. Recarregue antes de salvar."),
    51033: (400, "Lista de vínculos inválida ou duplicada."),
    51034: (400, "Decisão incompatível com o vínculo original."),
    51035: (400, "Assunto inexistente ou inativo para inclusão."),
    51036: (400, "Justifique a remoção ou inclusão."),
    51037: (400, "Visualize todos os Tipos antes de finalizar."),
    51038: (400, "Decida todos os vínculos antes de finalizar."),
    51039: (400, "Órgão sem Tipos atribuídos nesta consulta."),
    51040: (400, "Observação ou justificativa excede o limite."),
    51041: (400, "Decida todos os Tipos antes de finalizar."),
    51042: (400, "Justifique a descontinuação."),
    51210: (400, "Cadastro ou órgãos inválidos."),
    51211: (403, "Acesso restrito à administração."),
    51212: (409, "Cadastro alterado. Recarregue antes de salvar."),
    51213: (409, "E-mail já cadastrado."),
    51214: (400, "Órgão não encontrado."),
    51215: (409, "Administração ocupada. Tente novamente."),
    51216: (404, "Usuário não encontrado."),
    51400: (409, "Distribuição ocupada. Tente novamente."),
    51401: (403, "Acesso restrito à administração."),
    51402: (409, "A base publicada mudou. Atualize a listagem."),
    51403: (404, "Tipo inexistente nesta versão."),
    51404: (409, "Vínculos alterados por outro administrador. Recarregue."),
    51405: (400, "Órgão inexistente."),
    51500: (403, "Acesso restrito à administração."),
    51501: (404, "Atribuição não encontrada."),
    51502: (409, "Manifestação ainda não submetida."),
    51503: (404, "Assunto não pertence à decisão submetida."),
    51504: (409, "Parecer já registrado. Atualize a tela."),
    51505: (409, "Decisão do Tipo não submetida."),
    2601: (409, "Registro já cadastrado."),
    2627: (409, "Registro já cadastrado."),
}


def query(sql, params=()):
    """SQL conhecido pela aplicação; valores sempre separados como parâmetros."""
    if sql.lstrip().upper().startswith("WITH "):
        sql = ";" + sql.lstrip()
    try:
        with connection.cursor() as cursor:
            cursor.execute(sql.replace("?", "%s"), params)
            while cursor.description is None:
                if not cursor.nextset():
                    return []
            columns = [column[0] for column in cursor.description]
            return [dict(zip(columns, row, strict=True)) for row in cursor.fetchall()]
    except DatabaseError as error:
        codes = re.findall(r"\((\d{4,5})\)", str(error))
        for code in codes:
            if int(code) in ERROS:
                status, message = ERROS[int(code)]
                raise RegraError(message, status) from None
        # Não registrar SQL, parâmetros, string de conexão ou mensagem do driver.
        logger.error("Falha de banco (%s).", type(error).__name__)
        raise RegraError("Banco indisponível. Tente novamente mais tarde.", 503) from None


def inteiro(value, minimo=0):
    if isinstance(value, bool):
        raise RegraError("Identificador inválido.")
    try:
        number = int(value)
    except (ValueError, TypeError):
        raise RegraError("Identificador inválido.") from None
    if str(number) != str(value) or not minimo <= number <= 2147483647:
        raise RegraError("Identificador inválido.")
    return number


def pesquisa(value):
    if len(value) > 250:
        raise RegraError("Pesquisa deve ter até 250 caracteres.")
    for char in ("~", "%", "_", "["):
        value = value.replace(char, "~" + char)
    return "%" + value + "%"


def ids(values):
    result = [inteiro(value, -2147483648) for value in values]
    if len(result) > 2000 or len(set(result)) != len(result):
        raise RegraError("Lista inválida ou duplicada.")
    return sorted(result)
