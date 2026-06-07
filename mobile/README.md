# Health App — Mobile (Flutter)

Flutter app for iOS + Android. Part of the [Health App monorepo](../README.md).

## Quickstart

```bash
flutter pub get
cp .env.example .env       # already exists; fill in Supabase keys when ready
flutter run                # picks first available device
```

Mock credentials (when `USE_MOCK_DATA=true`):

```text
email:    demo@health.app
password: demo1234
```

## Architecture

Layered, with a swappable data layer.

```
lib/
├── app/              MaterialApp, router, theme tokens
├── core/             Result<T>, Failure, env config
├── data/             models, sources (abstract + mock + supabase), repositories
├── domain/           abstract repository contracts
├── features/         auth, dashboard, activities, profile
├── shared/widgets/   reusable design-system widgets
└── di/providers.dart single place to wire repos/sources
```

Switching from mock to Supabase is a single env flag (`USE_MOCK_DATA=false` + Supabase keys). No UI code changes.

Architecture & conventions for AI agents: [`../.cursor/rules/mobile-architecture.mdc`](../.cursor/rules/mobile-architecture.mdc). Visual spec: [`../DESIGN.md`](../DESIGN.md).

## Common commands

```bash
flutter analyze
flutter test
flutter run -d "iPhone 15"
flutter run -d emulator-5554
flutter devices
```

## Stack

Flutter 3.x · Dart 3.x · Riverpod 3 · go_router · Supabase Flutter · google_fonts (Plus Jakarta Sans) · equatable · very_good_analysis.
