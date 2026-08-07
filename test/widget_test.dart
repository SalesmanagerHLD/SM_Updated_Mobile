import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:salesmanager_mobile/app.dart';
import 'package:salesmanager_mobile/core/network/network_providers.dart';
import 'package:salesmanager_mobile/core/storage/secure_token_store.dart';

/// Returns no stored session without touching the real platform-channel-backed
/// `flutter_secure_storage` (unavailable under `flutter test`).
class _FakeSecureTokenStore extends SecureTokenStore {
  @override
  Future<AuthState?> read() async => null;

  @override
  Future<void> write(AuthState state) async {}

  @override
  Future<void> clear() async {}
}

void main() {
  testWidgets('boots to the Login screen when there is no stored session', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [secureTokenStoreProvider.overrideWithValue(_FakeSecureTokenStore())],
        child: const SalesManagerApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Sign In'), findsWidgets);
    expect(find.text('Work email'), findsOneWidget);
  });
}
