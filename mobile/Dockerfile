# syntax=docker/dockerfile:1

# Stage 1 — build the release APK with the Flutter SDK (includes Android SDK).
FROM ghcr.io/cirruslabs/flutter:stable AS build
WORKDIR /app

COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get

COPY . .
RUN cp -n .env.example .env || true
RUN flutter pub get
RUN flutter build apk --release

# Stage 2 — serve the APK for download (no app store needed).
FROM nginx:alpine
COPY --from=build /app/build/app/outputs/flutter-apk/app-release.apk \
  /usr/share/nginx/html/health_app.apk
COPY docker/index.html /usr/share/nginx/html/index.html
EXPOSE 80
