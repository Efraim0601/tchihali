# Version web de l'application : compilée avec le Flutter officiel (branche stable), servie par nginx.
# Construite par docker-compose.web.yml, contexte = racine du dépôt (voir /.dockerignore).
FROM debian:12-slim AS build
RUN apt-get update && apt-get install -y --no-install-recommends git curl unzip xz-utils ca-certificates \
    && rm -rf /var/lib/apt/lists/*
RUN useradd -m flutter
USER flutter
RUN git clone --depth 1 --branch stable https://github.com/flutter/flutter.git /home/flutter/sdk
ENV PATH=/home/flutter/sdk/bin:$PATH
RUN flutter config --no-analytics --no-cli-animations && flutter precache --web
WORKDIR /home/flutter/app
COPY --chown=flutter pubspec.yaml pubspec.lock ./
RUN flutter pub get
COPY --chown=flutter . .
ARG API_BASE_URL
RUN test -n "$API_BASE_URL" \
    && flutter build web --release --dart-define=API_BASE_URL=$API_BASE_URL

FROM nginx:1.27-alpine
COPY backend/web/nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=build /home/flutter/app/build/web /usr/share/nginx/html
