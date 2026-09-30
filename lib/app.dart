import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'app/splash_screen.dart';
import 'core/push/push_navigation.dart';
import 'core/push/push_providers.dart';
import 'core/sync/sync_providers.dart';
import 'core/sync/sync_status_banner.dart';
import 'core/theme/app_theme_builder.dart';
import 'core/theme/theme_models.dart';
import 'core/theme/theme_provider.dart';
import 'core/widgets/coming_soon_screen.dart';
import 'features/auth/application/auth_providers.dart';
import 'features/auth/presentation/login_screen.dart';
import 'features/home/presentation/home_screen.dart';
import 'features/leads/presentation/lead_detail_screen.dart';
import 'features/leads/presentation/lead_form_screen.dart';
import 'features/leads/presentation/lead_list_screen.dart';
import 'features/leave/presentation/leave_screen.dart';
import 'features/leave/presentation/request_leave_screen.dart';
import 'features/notifications/presentation/notifications_screen.dart';
import 'features/settings/presentation/settings_screen.dart';
import 'features/team/presentation/team_member_detail_screen.dart';
import 'features/team/presentation/team_progress_screen.dart';
import 'features/visits/presentation/visit_form_screen.dart';

/// Bridges Riverpod's `authNotifierProvider` to go_router's
/// `Listenable`-based `refreshListenable` — a change here just re-runs
/// `redirect` on the CURRENT location rather than rebuilding the router
/// itself (the router is only ever constructed once, see [goRouterProvider]).
class _AuthRefreshListenable extends ChangeNotifier {
  _AuthRefreshListenable(Ref ref) {
    ref.listen(authNotifierProvider, (previous, next) => notifyListeners());
  }
}

/// Auth-gated redirect: `/` (splash) while the stored session is still
/// hydrating, `/login` when there's no session, and into the bottom-nav
/// shell (`/home`) once there is one — mirrors `ProtectedRoute.tsx`'s job
/// on the web, just expressed as go_router's `redirect` instead of a route
/// wrapper component.
final goRouterProvider = Provider<GoRouter>((ref) {
  final refreshListenable = _AuthRefreshListenable(ref);
  ref.onDispose(refreshListenable.dispose);

  return GoRouter(
    initialLocation: '/',
    refreshListenable: refreshListenable,
    redirect: (context, state) {
      final authAsync = ref.read(authNotifierProvider);
      final isHydrating = authAsync.isLoading && !authAsync.hasValue;
      final loggedIn = authAsync.valueOrNull != null;
      final atSplash = state.matchedLocation == '/';
      final atLogin = state.matchedLocation == '/login';

      if (isHydrating) return atSplash ? null : '/';
      if (!loggedIn) return atLogin ? null : '/login';
      if (atLogin || atSplash) return '/home';
      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: '/team',
        builder: (context, state) => const TeamProgressScreen(),
        routes: [
          GoRoute(
            path: ':employeeId',
            builder: (context, state) =>
                TeamMemberDetailScreen(employeeId: state.pathParameters['employeeId']!),
          ),
        ],
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [GoRoute(path: '/home', builder: (context, state) => const HomeScreen())],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/leads',
                builder: (context, state) => const LeadListScreen(),
                routes: [
                  GoRoute(
                    path: 'new',
                    builder: (context, state) => const LeadFormScreen(),
                  ),
                  GoRoute(
                    path: ':leadId',
                    builder: (context, state) =>
                        LeadDetailScreen(leadId: state.pathParameters['leadId']!),
                    routes: [
                      GoRoute(
                        path: 'edit',
                        builder: (context, state) =>
                            const ComingSoonScreen(title: 'Edit Lead', phase: 'Phase 6'),
                      ),
                      GoRoute(
                        path: 'visits/new',
                        builder: (context, state) =>
                            VisitFormScreen(leadId: state.pathParameters['leadId']!),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/leave',
                builder: (context, state) => const LeaveScreen(),
                routes: [
                  GoRoute(
                    path: 'request',
                    builder: (context, state) => const RequestLeaveScreen(),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [GoRoute(path: '/profile', builder: (context, state) => const SettingsScreen())],
          ),
        ],
      ),
    ],
  );
});

/// Bottom-nav shell: Home / Leads / Leave / Profile, matching the mockup's
/// bottom nav exactly (NOT the 5-tab layout an earlier draft of this plan
/// had guessed before the mockup was available) — Notifications and Team
/// Progress are reached as secondary routes (bell icon on Home, a row in
/// Settings), not additional tabs here.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [const SyncStatusBanner(), Expanded(child: navigationShell)],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline),
            selectedIcon: Icon(Icons.people),
            label: 'Leads',
          ),
          NavigationDestination(
            icon: Icon(Icons.event_available_outlined),
            selectedIcon: Icon(Icons.event_available),
            label: 'Leave',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class SalesManagerApp extends ConsumerWidget {
  const SalesManagerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Starts the connectivity-triggered outbox drain loop for the app's
    // whole lifetime — see SyncCoordinator's doc comment.
    ref.watch(syncCoordinatorProvider);
    // Initializes push once authenticated + entitled — see
    // PushCoordinator's doc comment. A no-op if Firebase isn't configured
    // (see Env.isFirebaseConfigured).
    ref.watch(pushCoordinatorProvider);
    final router = ref.watch(goRouterProvider);
    // A tapped push notification signals its target route here rather than
    // PushService holding a router reference directly — see
    // push_navigation.dart's doc comment.
    ref.listen<String?>(pushTapRouteProvider, (previous, next) {
      if (next != null) {
        router.push(next);
        ref.read(pushTapRouteProvider.notifier).clear();
      }
    });
    final theme = ref.watch(themeNotifierProvider).valueOrNull ?? EffectiveThemeSettings.hardcodedDefault;

    return MaterialApp.router(
      title: 'SalesManager',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(theme),
      routerConfig: router,
    );
  }
}
