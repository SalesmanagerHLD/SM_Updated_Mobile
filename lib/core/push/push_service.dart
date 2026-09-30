import 'dart:convert';
import 'dart:io' show Platform;

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// Aliased: flutter_local_notifications also exports a `NotificationResponse`
// class (the local-notification-tap callback's argument type), which would
// otherwise collide with this app's own domain model of the same name.
import '../../features/notifications/data/notification_models.dart' as notif_models;
import '../../features/notifications/presentation/notification_format.dart';
import '../config/env.dart';
import 'device_token_repository.dart';

FirebaseOptions _firebaseOptions() => FirebaseOptions(
  apiKey: Env.firebaseApiKey,
  appId: Env.firebaseAppId,
  messagingSenderId: Env.firebaseMessagingSenderId,
  projectId: Env.firebaseProjectId,
);

const _androidChannel = AndroidNotificationChannel(
  'salesmanager_default',
  'Notifications',
  description: 'Lead, visit, and leave notifications',
  importance: Importance.high,
);

final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

/// Delivery is a **data-only** FCM message (confirmed against
/// `PushNotificationService.java` — no `notification` block), so the app
/// must build the visible notification itself in every state
/// (foreground/background/terminated) from `data['type']`/`data['payload']`
/// — exactly the same `NotificationFormat` title/description logic the
/// in-app Notifications screen uses, so a push and its corresponding
/// in-app row read identically.
///
/// Must be a top-level function (Firebase's isolate requirement for
/// background messages) — re-initializes Firebase in this background
/// isolate before touching it, since isolates don't share the foreground
/// isolate's already-initialized app instance.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (!Env.isFirebaseConfigured) return;
  await Firebase.initializeApp(options: _firebaseOptions());
  await _showLocalNotification(message);
}

Future<void> _showLocalNotification(RemoteMessage message) async {
  final type = message.data['type'] as String? ?? '';
  final payloadRaw = message.data['payload'] as String? ?? '{}';
  final notification = notif_models.NotificationResponse(
    id: message.data['notificationId'] as String? ?? '',
    type: type,
    payloadRaw: payloadRaw,
    read: false,
    createdAt: '',
  );
  final title = NotificationFormat.title(notification);
  final body = NotificationFormat.description(notification);
  final tapPayload = jsonEncode({'type': type, 'payloadRaw': payloadRaw});

  await _localNotifications.show(
    id: title.hashCode,
    title: title,
    body: body.isEmpty ? null : body,
    notificationDetails: NotificationDetails(
      android: AndroidNotificationDetails(
        _androidChannel.id,
        _androidChannel.name,
        channelDescription: _androidChannel.description,
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: const DarwinNotificationDetails(),
    ),
    payload: tapPayload,
  );
}

/// Gated end-to-end on `PUSH_NOTIFICATIONS` entitlement (checked by the
/// caller — `push_providers.dart` — before `initialize()` is ever called)
/// and on [Env.isFirebaseConfigured], mirroring the web app's
/// `isPushConfigured()` no-op guard: without real Firebase project values
/// supplied via `--dart-define` (see `env.dart`'s doc comment), this
/// silently does nothing rather than crashing the app.
class PushService {
  PushService({required DeviceTokenRepository deviceTokenRepository})
    : _deviceTokenRepository = deviceTokenRepository;

  final DeviceTokenRepository _deviceTokenRepository;

  /// Called with the target route whenever a push notification is tapped
  /// (foreground, background, or cold-start) — wired by `push_providers.dart`
  /// to `pushTapRouteProvider`, not directly to a router instance.
  void Function(String route)? onNotificationTapped;

  bool _initialized = false;
  String? _registeredToken;

  Future<void> initialize() async {
    if (_initialized || !Env.isFirebaseConfigured) return;
    _initialized = true;

    await Firebase.initializeApp(options: _firebaseOptions());
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    await _initLocalNotifications();

    final settings = await FirebaseMessaging.instance.requestPermission();
    if (settings.authorizationStatus == AuthorizationStatus.denied) return;

    final token = await FirebaseMessaging.instance.getToken();
    if (token != null) await _registerToken(token);
    FirebaseMessaging.instance.onTokenRefresh.listen(_registerToken);

    FirebaseMessaging.onMessage.listen(_showLocalNotification);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleTap);

    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) _handleTap(initialMessage);
  }

  Future<void> _initLocalNotifications() async {
    await _localNotifications.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      ),
      onDidReceiveNotificationResponse: (response) {
        final raw = response.payload;
        if (raw == null) return;
        final wrapper = jsonDecode(raw) as Map<String, dynamic>;
        _navigateFor(wrapper['type'] as String? ?? '', wrapper['payloadRaw'] as String? ?? '{}');
      },
    );
    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_androidChannel);
  }

  Future<void> _registerToken(String token) async {
    _registeredToken = token;
    final platform = Platform.isIOS ? DevicePlatform.ios : DevicePlatform.android;
    try {
      await _deviceTokenRepository.register(token: token, platform: platform);
    } catch (_) {
      // Best-effort - push registration must never block normal app usage.
    }
  }

  void _handleTap(RemoteMessage message) {
    _navigateFor(message.data['type'] as String? ?? '', message.data['payload'] as String? ?? '{}');
  }

  void _navigateFor(String type, String payloadRaw) {
    Map<String, dynamic> payload = const {};
    try {
      payload = jsonDecode(payloadRaw) as Map<String, dynamic>;
    } catch (_) {
      // Malformed payload - fall through to the generic route below.
    }
    final route = NotificationFormat.targetRouteFor(type, payload) ?? '/notifications';
    onNotificationTapped?.call(route);
  }

  Future<void> unregisterCurrentToken() async {
    if (_registeredToken != null) await _deviceTokenRepository.unregister(_registeredToken!);
  }
}
