import os
from pathlib import Path

from django.core.exceptions import ImproperlyConfigured
from dotenv import load_dotenv

BASE_DIR = Path(__file__).resolve().parent.parent
load_dotenv(BASE_DIR / ".env", override=False)


def flag(name, default=False):
    return os.getenv(name, str(default)).lower() == "true"


DEVELOPMENT = os.getenv("APP_ENV", "production") == "development"
DEBUG = DEVELOPMENT
DEV_AUTH_ENABLED = flag("DEV_AUTH_ENABLED")
SECRET_KEY = os.getenv("DJANGO_SECRET_KEY", "")
if not SECRET_KEY:
    if not DEVELOPMENT:
        raise ImproperlyConfigured("Configure DJANGO_SECRET_KEY.")
    SECRET_KEY = "gdsei-local-development-only-do-not-use-in-production"
if DEV_AUTH_ENABLED and not DEVELOPMENT:
    raise ImproperlyConfigured("Personificação exige APP_ENV=development.")
if not DEVELOPMENT and (len(SECRET_KEY) < 50 or SECRET_KEY.startswith("CONFIGURE_")):
    raise ImproperlyConfigured("Use DJANGO_SECRET_KEY aleatória com pelo menos 50 caracteres.")

ALLOWED_HOSTS = os.getenv("ALLOWED_HOSTS", "localhost,127.0.0.1,[::1]").split(",")
ROOT_URLCONF = "config.urls"
WSGI_APPLICATION = "config.wsgi.application"
INSTALLED_APPS = ["django.contrib.staticfiles", "gdsei"]
MIDDLEWARE = [
    "django.middleware.security.SecurityMiddleware",
    "whitenoise.middleware.WhiteNoiseMiddleware",
    "django.contrib.sessions.middleware.SessionMiddleware",
    "django.middleware.common.CommonMiddleware",
    "django.middleware.csrf.CsrfViewMiddleware",
    "django.middleware.clickjacking.XFrameOptionsMiddleware",
    "gdsei.autenticacao.UsuarioMiddleware",
]
TEMPLATES = [
    {
        "BACKEND": "django.template.backends.django.DjangoTemplates",
        "DIRS": [],
        "APP_DIRS": True,
        "OPTIONS": {"context_processors": ["django.template.context_processors.request"]},
    }
]
DATABASES = {
    "default": {
        "ENGINE": "mssql",
        "NAME": os.getenv("DB_NAME", ""),
        "USER": os.getenv("DB_USER", ""),
        "PASSWORD": os.getenv("DB_PASSWORD", ""),
        "HOST": os.getenv("DB_HOST", ""),
        "PORT": os.getenv("DB_PORT", "1433"),
        "OPTIONS": {
            "driver": os.getenv("DB_DRIVER", "ODBC Driver 18 for SQL Server"),
            "connection_timeout": 10,
            "extra_params": "Encrypt="
            + ("yes" if flag("DB_ENCRYPT", True) else "no")
            + ";TrustServerCertificate="
            + ("yes" if flag("DB_TRUST_SERVER_CERTIFICATE") else "no"),
        },
    }
}
# Sessões no servidor, sem novas tabelas nem migração automática do banco legado.
SESSION_ENGINE = "django.contrib.sessions.backends.file"
SESSION_FILE_PATH = BASE_DIR / ".runtime" / "sessions"
SESSION_FILE_PATH.mkdir(parents=True, exist_ok=True)
SESSION_COOKIE_NAME = "gdsei_session"
SESSION_COOKIE_AGE = 28800
SESSION_COOKIE_HTTPONLY = True
SESSION_COOKIE_SAMESITE = "Lax"
SESSION_COOKIE_SECURE = flag("COOKIE_SECURE", True)
CSRF_COOKIE_SECURE = SESSION_COOKIE_SECURE
if not SESSION_COOKIE_SECURE and not DEVELOPMENT:
    raise ImproperlyConfigured("COOKIE_SECURE=false exige desenvolvimento.")
SECURE_CONTENT_TYPE_NOSNIFF = True
SECURE_HSTS_SECONDS = 0 if DEVELOPMENT else 31536000
SECURE_HSTS_INCLUDE_SUBDOMAINS = not DEVELOPMENT
SECURE_HSTS_PRELOAD = False
SECURE_SSL_REDIRECT = not DEVELOPMENT
if flag("TRUST_PROXY_HEADERS"):
    SECURE_PROXY_SSL_HEADER = ("HTTP_X_FORWARDED_PROTO", "https")
CSRF_TRUSTED_ORIGINS = [
    origin for origin in os.getenv("CSRF_TRUSTED_ORIGINS", "").split(",") if origin
]
LANGUAGE_CODE = "pt-br"
TIME_ZONE = "America/Manaus"
USE_TZ = True
STATIC_URL = "/static/"
STATIC_ROOT = BASE_DIR / "staticfiles"
STORAGES = {"staticfiles": {"BACKEND": "whitenoise.storage.CompressedManifestStaticFilesStorage"}}
EMAIL_HOST = os.getenv("SMTP_HOST", "")
EMAIL_PORT = int(os.getenv("SMTP_PORT", "587"))
EMAIL_HOST_USER = os.getenv("SMTP_USER", "")
EMAIL_HOST_PASSWORD = os.getenv("SMTP_PASSWORD", "")
DEFAULT_FROM_EMAIL = os.getenv("SMTP_FROM", "")
EMAIL_USE_SSL = flag("SMTP_SSL")
EMAIL_USE_TLS = not EMAIL_USE_SSL
EMAIL_TIMEOUT = 20
DATA_UPLOAD_MAX_MEMORY_SIZE = 262144
DATA_UPLOAD_MAX_NUMBER_FIELDS = 10000
