# GD-SEI

Apoio à Gestão Documental do SEI: Tipos de Processo, Assuntos, avaliações,
submissões e processamento administrativo. Não altera diretamente o SEI.

## Stack

Python 3.12 + Django 5.2 LTS, templates HTML, CSS e JavaScript nativo.
SQL Server por mssql-django/pyodbc. Uma aplicação monolítica, sem SPA ou API
intermediária para as próprias páginas. Dart/Flutter estão no histórico Git.

## Executar localmente

```powershell
python -m venv .venv
.venv\Scripts\python -m pip install -r requirements-dev.txt
Copy-Item .env.example .env
.venv\Scripts\python manage.py check
.venv\Scripts\python manage.py runserver 127.0.0.1:8000
```

Configure o `.env` da raiz com SQL Server e SMTP reais. Não sobrescreva um `.env`
existente nem versione credenciais. Variáveis de ambiente têm precedência.
Para migrar sua configuração local antiga, copie `backend/.env` para `.env`
somente se ainda não houver arquivo na raiz. Configure uma `DJANGO_SECRET_KEY`
aleatória e estável fora de desenvolvimento. Instale o Microsoft ODBC Driver 18.

Abra http://127.0.0.1:8000/. No VS Code, use **GD-SEI: Django** (F5).
Um único servidor atende telas e formulários. Para personificar ativos:
`APP_ENV=development`, `DEV_AUTH_ENABLED=true`, `COOKIE_SECURE=false` apenas em
HTTP local. Em produção: personificação desativada, chave própria e HTTPS.

## Verificações

```powershell
.venv\Scripts\python -m ruff format --check gdsei config manage.py
.venv\Scripts\python -m ruff check gdsei config manage.py
.venv\Scripts\python manage.py check
.venv\Scripts\python manage.py collectstatic --noinput
.venv\Scripts\python manage.py test gdsei
.venv\Scripts\python manage.py check_database --pages
```

O último comando é opcional, requer acesso ao SQL Server e usa somente leitura.
Os testes automatizados padrão simulam o banco; não criam um banco de testes.
O CI mantém os nomes `backend` e `frontend` exigidos pela proteção das branches.
Não há deploy automático.

## Banco e transição

O banco existente e suas procedures continuam sendo a fonte das operações
transacionais. Não executar `manage.py migrate` no banco legado. Não há modelos
gerenciados pelo Django nem novas tabelas para esta migração. O incremental 011
continua necessário para o processamento administrativo, conforme o esquema
anterior. Referências e snapshots permanecem imutáveis e versionados.

Leia [a documentação da migração](docs/migracao_django.md) para estrutura,
cobertura, limites, instalação e homologações pendentes. Os documentos antigos
com comandos Dart/Flutter são históricos; não representam o runtime Django.

Desenvolvimento: branches de trabalho → dev → PR para main. Não fazer merge
automaticamente. Consulte AGENTS.md.
