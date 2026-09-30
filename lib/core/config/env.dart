import 'dart:io' show Platform;

/// API base URL, overridable via `--dart-define=API_BASE_URL=...` at build/run time.
///
/// Defaults assume a local backend reachable from an emulator/simulator:
/// - Android emulator routes the host loopback through 10.0.2.2.
/// - iOS simulator shares the host's network, so localhost works directly.
/// The backend itself is mounted under `/api/v1` (see `application.yml`'s
/// `server.servlet.context-path`), so that suffix is always appended here,
/// not left for callers to append per-request.
class Env {
  Env._();

  static const String _override = String.fromEnvironment('API_BASE_URL');

  static String get apiBaseUrl {
    if (_override.isNotEmpty) return _override;
    final host = Platform.isAndroid ? '10.0.2.2' : 'localhost';
    return 'http://$host:8080/api/v1';
  }

  // Firebase config — same "public config, safe to inject at build time"
  // values as the web app's `VITE_FIREBASE_*` env vars
  // (`frontend/src/firebase.ts`), just passed via `--dart-define` instead
  // of a `.env` file. Deliberately NOT read from
  // `android/app/google-services.json` / `ios/Runner/GoogleService-Info.plist`
  // — those files don't exist in this repo yet, and the Gradle
  // `google-services` plugin would hard-fail the Android build the moment
  // it's applied without one present. Passing `FirebaseOptions` explicitly
  // at runtime (see `core/push/push_service.dart`) needs neither file, so
  // the build is never blocked on Firebase being configured. Provide real
  // values via e.g. `flutter run --dart-define=FIREBASE_API_KEY=...` once
  // the mobile apps are registered in the existing Firebase project (see
  // `PushService`'s doc comment for the exact external setup needed).
  static const String firebaseApiKey = String.fromEnvironment('FIREBASE_API_KEY');
  static const String firebaseAppIdAndroid = String.fromEnvironment('FIREBASE_APP_ID_ANDROID');
  static const String firebaseAppIdIos = String.fromEnvironment('FIREBASE_APP_ID_IOS');
  static const String firebaseMessagingSenderId = String.fromEnvironment(
    'FIREBASE_MESSAGING_SENDER_ID',
  );
  static const String firebaseProjectId = String.fromEnvironment('FIREBASE_PROJECT_ID');

  static String get firebaseAppId => Platform.isIOS ? firebaseAppIdIos : firebaseAppIdAndroid;

  static bool get isFirebaseConfigured =>
      firebaseApiKey.isNotEmpty && firebaseAppId.isNotEmpty && firebaseProjectId.isNotEmpty;
}
