FROM python:3.12-slim-bookworm
ENV PYTHONDONTWRITEBYTECODE=1 PYTHONUNBUFFERED=1 APP_ENV=production
RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates curl unixodbc libgssapi-krb5-2 \
 && curl -fsSL https://packages.microsoft.com/config/debian/12/packages-microsoft-prod.deb -o /tmp/msprod.deb \
 && dpkg -i /tmp/msprod.deb && rm /tmp/msprod.deb \
 && apt-get update && ACCEPT_EULA=Y apt-get install -y --no-install-recommends msodbcsql18 \
 && apt-get purge -y --auto-remove curl && rm -rf /var/lib/apt/lists/*
WORKDIR /app
COPY requirements.txt requirements.lock ./
RUN pip install --no-cache-dir -r requirements.txt
COPY manage.py ./
COPY config ./config
COPY gdsei ./gdsei
RUN APP_ENV=development COOKIE_SECURE=false python manage.py collectstatic --noinput \
 && chgrp -R 0 /app/.runtime && chmod -R g=u /app/.runtime
EXPOSE 8080
CMD ["waitress-serve", "--listen=0.0.0.0:8080", "--threads=4", "config.wsgi:application"]
