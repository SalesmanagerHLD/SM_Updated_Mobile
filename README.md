# SalesManager CRM — Mobile App

Flutter field-rep companion app for SalesManager CRM (Android + iOS). Repository: [SalesmanagerHLD/SM_Updated_Mobile](https://github.com/SalesmanagerHLD/SM_Updated_Mobile). Consumes the same REST API as the web app ([SM_Updated_java](https://github.com/SalesmanagerHLD/SM_Updated_java)); the web frontend is [SM_Updated_React](https://github.com/SalesmanagerHLD/SM_Updated_React).

## Stack

- Flutter / Dart, Riverpod for state, `go_router` for navigation
- `dio` for HTTP, `drift` (SQLite) for the offline cache and mutation outbox, `flutter_secure_storage` for the auth session

See [docs/MOBILE_IMPLEMENTATION.md](docs/MOBILE_IMPLEMENTATION.md) for the full architecture and what has been built.

## Getting started

```bash
flutter pub get
flutter run
```

The API base URL defaults to `http://10.0.2.2:8080/api/v1` on the Android emulator and `http://localhost:8080/api/v1` on the iOS simulator. Override it for other environments:

```bash
flutter run --dart-define=API_BASE_URL=https://<host>/api/v1
```

Start the backend with the `local` profile first (see the [backend README](https://github.com/SalesmanagerHLD/SM_Updated_java#running-locally)).

## Documentation

- [MOBILE_IMPLEMENTATION.md](docs/MOBILE_IMPLEMENTATION.md) — this app's architecture and build status
- [Project docs](https://github.com/SalesmanagerHLD/SM_Updated_java/tree/main/docs) — backend/web implementation, Leave/entitlement plan, modules and workflows

## Tests

```bash
flutter test
```

## Branching

`main` is the stable branch. Feature work goes on a separate branch and merges to `main`.
