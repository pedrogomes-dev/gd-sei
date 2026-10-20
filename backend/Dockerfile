# Build: contexto backend/
FROM dart:3.9-sdk AS build
WORKDIR /src
COPY pubspec.* ./
COPY vendor/dart_odbc ./vendor/dart_odbc
RUN dart pub get
COPY . .
RUN dart compile exe bin/server.dart -o /out/gd-sei-server

# Runtime Linux: unixODBC + Microsoft ODBC Driver 18
FROM debian:bookworm-slim
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates curl gnupg unixodbc libgssapi-krb5-2 \
 && curl -fsSL https://packages.microsoft.com/config/debian/12/packages-microsoft-prod.deb -o /tmp/msprod.deb \
 && dpkg -i /tmp/msprod.deb \
 && rm /tmp/msprod.deb \
 && apt-get update \
 && ACCEPT_EULA=Y apt-get install -y --no-install-recommends msodbcsql18 \
 && apt-get purge -y --auto-remove curl gnupg \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY --from=build --chmod=0555 /out/gd-sei-server /app/gd-sei-server
ENV HOST=0.0.0.0 PORT=8080 APP_ENV=production
EXPOSE 8080
# OpenShift injeta UID arbitrário; não definir USER fixo.
CMD ["/app/gd-sei-server"]
