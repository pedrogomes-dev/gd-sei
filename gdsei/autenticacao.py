import hashlib
import hmac
import secrets
import smtplib
import threading
import time
from functools import wraps

from django.conf import settings
from django.core.exceptions import ValidationError
from django.core.mail import send_mail
from django.core.validators import validate_email
from django.shortcuts import redirect, render

from . import db


def email_valido(value):
    value = value.strip().lower()
    try:
        validate_email(value)
    except ValidationError:
        raise db.RegraError("Informe um e-mail válido.") from None
    if len(value) > 250:
        raise db.RegraError("E-mail deve ter até 250 caracteres.")
    return value


class Codigos:
    """Mesmo limite do legado: uma instância/processo por implantação."""

    def __init__(self):
        self.lock = threading.Lock()
        self.secret = secrets.token_bytes(32)
        self.codigos = {}
        self.envios = {}
        self.ips = {}
        self.em_envio = set()

    def hash(self, email, codigo):
        return hmac.new(self.secret, f"{email}:{codigo}".encode(), hashlib.sha256).digest()

    def reservar(self, email, ip):
        with self.lock:
            agora = time.monotonic()
            self.codigos = {k: v for k, v in self.codigos.items() if v["expira"] > agora}
            self.envios = {k: v for k, v in self.envios.items() if agora - v < 600}
            self.ips = {k: [t for t in v if agora - t < 60] for k, v in self.ips.items()}
            self.ips = {k: v for k, v in self.ips.items() if v}
            if email in self.em_envio or agora - self.envios.get(email, -1000) < 60:
                raise db.RegraError("Aguarde 60 segundos antes de solicitar outro código.", 429)
            if len(self.em_envio) >= 20 or len(self.envios) >= 10000 or len(self.ips) >= 10000:
                raise db.RegraError("Acesso ocupado. Tente novamente mais tarde.", 503)
            if len(self.ips.get(ip, [])) >= 60:
                raise db.RegraError("Muitas solicitações. Tente novamente mais tarde.", 429)
            self.ips.setdefault(ip, []).append(agora)
            self.envios[email] = agora
            self.em_envio.add(email)
            self.codigos.pop(email, None)

    def criar(self, email, usuario):
        codigo = str(100000 + secrets.randbelow(900000))
        with self.lock:
            self.codigos[email] = {
                "usuario": usuario,
                "hash": self.hash(email, codigo),
                "expira": time.monotonic() + 600,
                "tentativas": 0,
                "enviado": False,
            }
        return codigo

    def consumir(self, email, codigo):
        with self.lock:
            item = self.codigos.get(email)
            if not item or not item["enviado"] or item["expira"] <= time.monotonic():
                self.codigos.pop(email, None)
                raise db.RegraError("Código inválido ou expirado.", 401)
            item["tentativas"] += 1
            valido = len(codigo) == 6 and codigo.isascii() and codigo.isdigit()
            valido = valido and hmac.compare_digest(item["hash"], self.hash(email, codigo))
            if valido or item["tentativas"] >= 5:
                self.codigos.pop(email, None)
            if not valido:
                raise db.RegraError("Código inválido ou expirado.", 401)
            return item["usuario"]


codigos = Codigos()


def usuario_email(email):
    usuarios = db.query(
        "SELECT id_usuario, versao_sessao FROM dbo.usuario WHERE email_normalizado=? AND sin_ativo='S'",
        [email],
    )
    return usuarios[0] if usuarios else None


def solicitar_codigo(email, ip):
    if not all(
        [
            settings.EMAIL_HOST,
            settings.EMAIL_HOST_USER,
            settings.EMAIL_HOST_PASSWORD,
            settings.DEFAULT_FROM_EMAIL,
        ]
    ):
        raise db.RegraError("O envio de e-mail ainda não está configurado.", 503)
    codigos.reservar(email, ip)
    try:
        usuario = usuario_email(email)
        if usuario:
            codigo = codigos.criar(email, usuario)
            send_mail(
                "GD-SEI: código de acesso",
                f"Seu código de acesso é: {codigo}\nVálido por 10 minutos e uso único. Não compartilhe.",
                settings.DEFAULT_FROM_EMAIL,
                [email],
            )
            with codigos.lock:
                codigos.codigos[email]["enviado"] = True
    except db.RegraError:
        raise
    except (smtplib.SMTPException, OSError):
        with codigos.lock:
            codigos.codigos.pop(email, None)
        raise db.RegraError("Não foi possível enviar o e-mail. Tente novamente.", 503) from None
    finally:
        with codigos.lock:
            codigos.em_envio.discard(email)


def iniciar_sessao(request, usuario, evento):
    db.query("INSERT dbo.auditoria(id_usuario,evento) VALUES(?,?)", [usuario["id_usuario"], evento])
    request.session.flush()
    request.session["id_usuario"] = int(usuario["id_usuario"])
    request.session["versao_sessao"] = int(usuario["versao_sessao"])


def entrar_email(request, email, codigo):
    esperado = codigos.consumir(email, codigo)
    atual = usuario_email(email)
    if atual != esperado:
        raise db.RegraError("Acesso alterado. Solicite um novo código.", 401)
    iniciar_sessao(request, atual, "LOGIN")


def usuarios_desenvolvimento():
    if not settings.DEV_AUTH_ENABLED:
        return []
    return db.query(
        "SELECT id_usuario,nome,email FROM dbo.usuario WHERE sin_ativo='S' ORDER BY nome,email,id_usuario"
    )


def personificar(request, id_usuario):
    if not settings.DEVELOPMENT or not settings.DEV_AUTH_ENABLED:
        raise db.RegraError("Acesso temporário desativado.", 403)
    usuarios = db.query(
        "SELECT id_usuario,versao_sessao FROM dbo.usuario WHERE id_usuario=? AND sin_ativo='S'",
        [db.inteiro(id_usuario)],
    )
    if not usuarios:
        raise db.RegraError("Usuário não cadastrado ou inativo.", 403)
    iniciar_sessao(request, usuarios[0], "LOGIN_DEV")


class UsuarioMiddleware:
    def __init__(self, get_response):
        self.get_response = get_response

    def __call__(self, request):
        request.usuario = None
        if request.session.get("id_usuario") is not None:
            try:
                usuarios = db.query(
                    "SELECT id_usuario,nome,email,sin_admin,versao_sessao FROM dbo.usuario WHERE id_usuario=? AND sin_ativo='S'",
                    [request.session["id_usuario"]],
                )
                if usuarios and int(usuarios[0]["versao_sessao"]) == request.session.get(
                    "versao_sessao"
                ):
                    request.usuario = usuarios[0]
                else:
                    request.session.flush()
            except db.RegraError:
                # A indisponibilidade será apresentada pela view protegida.
                request.erro_banco = True
        response = self.get_response(request)
        response["Cache-Control"] = "no-store"
        return response

    def process_exception(self, request, exception):
        if isinstance(exception, db.RegraError):
            return render(
                request, "gdsei/erro.html", {"erro": str(exception)}, status=exception.status
            )


def acesso(admin=False):
    def decorator(view):
        @wraps(view)
        def wrapped(request, *args, **kwargs):
            if getattr(request, "erro_banco", False):
                raise db.RegraError("Banco indisponível. Tente novamente.", 503)
            if not request.usuario:
                return redirect("login")
            if admin and request.usuario["sin_admin"] != "S":
                raise db.RegraError("Acesso restrito à administração.", 403)
            return view(request, *args, **kwargs)

        return wrapped

    return decorator
