# Build: contexto frontend/
FROM ghcr.io/cirruslabs/flutter:stable AS build
WORKDIR /src
COPY pubspec.* ./
RUN flutter pub get
COPY . .
# URL vazia: Flutter usa /api na mesma origem, via proxy Nginx.
RUN flutter build web --release --dart-define=API_BASE_URL=

# Nginx unprivileged já suporta OpenShift (porta não privilegiada).
FROM nginxinc/nginx-unprivileged:stable-alpine
COPY --from=build /src/build/web/ /usr/share/nginx/html/
COPY nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 8080
