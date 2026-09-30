# SalesManager CRM — Mobile App

Flutter field-rep companion app for SalesManager CRM (Android + iOS). Repository: `SalesmanagerHLD/SM_Updated_Mobile`. Consumes the same REST API as the web app (`SM_Updated_java`).

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

Start the backend with the `local` profile first (see the backend README).

## Tests

```bash
flutter test
```

## Branching

`main` is the stable branch. Feature work goes on a separate branch and merges to `main`.
