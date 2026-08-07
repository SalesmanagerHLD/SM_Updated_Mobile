# SalesManager CRM Mobile — Implementation Documentation

_Snapshot as of the initial build (2026-08-07). Flutter field-rep companion app for SalesManager CRM, consuming the same backend REST API (`SM_Updated_java`) as the web app (`SM_Updated_React`). Built from scratch this session against a 10-screen Claude Design mockup (`SalesManager CRM Mobile.dc.html`). For the backend/web system this app is a client of, see the backend/frontend repos' own `CRM_IMPLEMENTATION.md`._

## 1. Architecture Overview

- **Framework**: Flutter 3.44.8 / Dart 3.12.2, targeting Android + iOS from one codebase.
- **State management**: Riverpod 2.6.1 (`flutter_riverpod`) — plain `Provider`/`FutureProvider`/`AsyncNotifier`/`Notifier`, no codegen (`riverpod_generator` deliberately not used, to keep the build_runner surface small).
- **Navigation**: `go_router` 17.x, `StatefulShellRoute.indexedStack` for the bottom-nav shell, auth-gated via a `redirect` callback bridged to Riverpod through a small `ChangeNotifier` adapter (`_AuthRefreshListenable` in `lib/app.dart`).
- **HTTP**: `dio`, base URL `http://<host>:8080/api/v1` (`10.0.2.2` on the Android emulator, `localhost` on iOS simulator, overridable via `--dart-define=API_BASE_URL=...`).
- **Local persistence**: `drift` (SQLite) for a read-through cache (Leads/Visits) and the offline mutation outbox; `flutter_secure_storage` for the auth session; `shared_preferences` for the cached resolved theme.
- **Package layout**: feature-first (`lib/features/<domain>/{data,application,presentation}`), shared infrastructure under `lib/core/{network,storage,sync,theme,design,push,config}`. See the architecture plan (`shimmying-seeking-gray.md`, "NEW CLIENT: SalesManager CRM Mobile App" section) for the full original design rationale — this document describes what was actually built, which follows that plan closely.

## 2. Auth

- `POST /auth/login` only — no self-registration in the mobile app (accounts are admin-provisioned, matching the mockup's Sign In screen copy).
- `core/storage/secure_token_store.dart` — `AuthState{accessToken, refreshToken, employeeId, orgId, role}`, persisted as one JSON blob via `flutter_secure_storage` (Keychain/Keystore-backed).
- `core/network/auth_interceptor.dart` — ports the web app's `axiosInstance.ts` refresh flow exactly: attaches `Authorization: Bearer` on every request; on a 401, shares **one** in-flight refresh call across concurrent requests; retries the original request once; force-clears the session on refresh failure. Refresh/logout calls use a bare `Dio` instance with no interceptor (`plainDioProvider`) to avoid recursing into the same 401 handling.
- `features/auth/application/auth_providers.dart` — `AuthNotifier extends AsyncNotifier<AuthState?>`, hydrated from secure storage at boot; `null` means logged out. Listens to `core/network/session_controller.dart`'s `sessionExpiredProvider` (a plain tick counter bumped by the interceptor) rather than importing feature code directly from `core/network` — keeps the dependency one-directional.
- JWT is decoded client-side (`jwt_decoder`) **only** for display (e.g. showing the signed-in user's email on Settings) — never for access-control decisions, matching the web app's own documented discipline.

## 3. Theme

- `core/theme/theme_models.dart` — `EffectiveThemeSettings{primaryColor, mode, density, uiStyle}`, same 4 dimensions as the web app's `createAppTheme.ts`.
- Merge precedence: personal preference ?? org default ?? hardcoded fallback (`ThemeNotifier` in `core/theme/theme_provider.dart`), fetched from `GET /organizations/me/theme` + `GET /employees/me/theme-preference`, cached per-org in `shared_preferences` for instant paint on a warm start.
- **Hardcoded fallback deliberately differs from the web app's**: `primaryColor #3547E0` (indigo) and **light** mode, matching the Claude Design mockup's own default/light rendering — the web app's fallback is `#6366f1`/dark (as of its 2026-07-29 reskin). These are independently-configurable per-org values; not required to match.
- `core/theme/app_theme_builder.dart` maps `density` → `VisualDensity`, `uiStyle=minimalist` → 0-elevation cards/buttons + 4px radius (vs 12px standard), `mode`/`primaryColor` → a seeded `ColorScheme`. Typography is Manrope throughout (`google_fonts`), matching the mockup's deliberate brand-consistency choice across both platforms.
- `core/design/colors.dart` — the mockup's semantic color system (Lead status chips, interest-level dots, Leave status chips, notification type accents) as named constants, independent of the dynamic org theme — mirrors the web app's `LEAD_STATUS_COLORS`/`ACTIVITY_TYPE_COLORS` maps.

## 4. Navigation

Bottom nav: **Home / Leads / Leave / Profile** (`lib/app.dart`'s `AppShell`) — matches the mockup's actual chrome, not a guessed layout. Notifications and Team Progress are secondary routes (bell icon on Home; a conditional row in Settings), not additional tabs.

```
/                              splash (session hydration)
/login
/notifications                 pushed from Home's bell icon
/team                          TEAM_VISIBILITY-gated, pushed from Settings
/team/:employeeId              read-only member drill-down
/home                          [shell]
/leads                         [shell]
  /leads/new
  /leads/:leadId
    /leads/:leadId/edit          (placeholder — Phase 6+ item, not built)
    /leads/:leadId/visits/new
/leave                         [shell] — EMPLOYEE_LEAVE_MANAGEMENT-gated content
  /leave/request
/profile                       [shell] (= Settings)
```

## 5. Offline Sync — the outbox/SyncEngine

The one genuinely novel piece of this app (no direct web-app equivalent). Full design lives in `core/sync/`:

- **`core/storage/app_database.dart`** (Drift) — `LeadsCache`/`VisitsCache` (read-through cache; `raw` JSON blob is the source of truth, other columns exist only for offline filtering) + `OutboxEntries` (queued mutations: `entityType, operation, localId, payloadJson, status, attemptCount, lastError`).
- **Read path**: every repository (`LeadRepository`, `VisitRepository`) is network-first — on success it upserts into Drift; on a network error it falls back to the cached rows, tagging the result `fromCache: true` (`core/network/paged.dart`'s `Paged<T>`) so the UI can show a staleness caption.
- **Write path**: `createQueued()`/`updateStatusQueued()` always route through the outbox, even when online — one code path regardless of connectivity. A locally-created Lead/Visit gets a `local-<uuid>` temp id (`core/sync/outbox_models.dart`) until it syncs.
- **`core/sync/sync_engine.dart`** — drains the outbox in `createdAt` order. On a Lead create success, `AppDatabase.reconcileLeadId()` rewrites the cache row's primary key from the temp id to the server UUID **and** any dependent Visit rows' `leadId` in the same transaction; an in-memory map (`_reconciledLeadIds`) also rewrites a not-yet-dispatched Visit's queued payload if it still references the old temp id. **Known v1 limitation**: this in-memory reconciliation only spans one `drainOnce()` run — if the app is killed between a Lead's create syncing and its dependent Visit's create syncing, the Visit's payload still references the stale id and that create fails, surfacing as a conflict rather than corrupting data. Documented as acceptable for v1 in the file's own doc comment.
- **Conflict policy** (confirmed scope, not an oversight): **server wins, surface a banner** — no field-level merge/CRDT. A network error reverts the entry to `pending` and stops the drain; any other failure marks the entry `failed` and the cached record's `syncState = 'conflict'`.
- **Triggers**: connectivity restored (`core/sync/connectivity_service.dart`'s `isOnlineProvider`, watched by `SyncCoordinator` in `core/sync/sync_providers.dart`), app startup, and manual "Sync now" (tapping the global banner).
- **UI**: `core/sync/sync_status_banner.dart` (global "N changes waiting to sync" / "Some changes need attention" bar, shown app-wide above the bottom nav) + `core/sync/sync_state_chip.dart` (per-record "Syncing…"/"Needs attention" pill on Lead list rows and the Lead Detail header), both driven by **reactive Drift streams** (`watchPendingOutboxCount()`, `watchLeadSyncState()`, etc.) — no manual cache invalidation needed.
- **Deliberate carve-out**: Attendance clock-in/clock-out is the one write that **never** goes through the outbox — the server stamps the timestamp at request-receipt time, so queuing-and-replaying would silently record the wrong time. It fails fast with an error message if offline instead (`features/leave/data/attendance_repository.dart`'s doc comment).
- Leave request submission **does** go through the outbox (no timing dependency), but has no local read-cache/optimistic-display table of its own — a queued request is safely durable (it will sync) but isn't shown in "My Requests" until it does; the global sync banner is the visibility mechanism for it in v1.

## 6. Screens Built (all 10 mockup screens)

| # | Screen | File(s) | Notes |
|---|---|---|---|
| 1 | Sign In | `features/auth/presentation/login_screen.dart` | |
| 2 | Home — Today's Follow-ups | `features/home/presentation/home_screen.dart`, `features/home/application/home_providers.dart` | Reproduces the web app's exact 3-call composition (`GET /visits/today`, `GET /leads?status=LAPSED`, `GET /visits?status=PLANNED&dateFrom=&dateTo=`) — confirmed no aggregate dashboard endpoint exists server-side. First stat card is "Today's Follow-ups" rather than the mockup's "Open Leads" (that count isn't available from any endpoint this composition uses — see the file's comment). |
| 3 | Leads list | `features/leads/presentation/lead_list_screen.dart` | Status filter chips, search, sync-state chip per row. |
| 4 | Lead Detail | `features/leads/presentation/lead_detail_screen.dart` | Required/Additional Details, Attachments (upload/delete), Activity timeline, Mark as Lost dialog, Log Visit action. |
| 5 | New Lead | `features/leads/presentation/lead_form_screen.dart` | 2-step wizard (Company/Contact/City/Lead Source/Industry + log-as-visit-today, then everything else) — deliberately the web app's *original* two-step progressive-capture field split, not its later single-page "Required Details" reorder (a wizard fits a phone screen better; matches what the mockup itself shows). Master-data fields are pick-only in v1 (no free-text "creatable" fallback yet). |
| 6 | Log Visit | `features/visits/presentation/visit_form_screen.dart` | Pre-filled from the parent Lead's contact/qualification fields. |
| 7 | My Leave & Attendance | `features/leave/presentation/leave_screen.dart`, `request_leave_screen.dart` | Clock in/out card, leave balance mini-cards, request list + submission form. |
| 8 | Notifications | `features/notifications/presentation/notifications_screen.dart`, `notification_format.dart` | Title/description text is generated from the exact payload keys each backend write site actually sends (`LeadService#buildReassignmentPayload`, `MissedVisitJob`/`LapsedLeadJob#buildPayload`, `LeaveRequestService#buildPayload` — grounded by reading the Java source, not guessed). |
| 9 | Team Progress | `features/team/presentation/team_progress_screen.dart` | `TEAM_VISIBILITY`-gated. |
| 10 | Settings | `features/settings/presentation/settings_screen.dart` | Profile + theme snapshot (read-only in v1 — no UI Style/Primary Color edit controls yet), Team & Permissions row (conditional), Log Out. |

## 7. Push Notifications

Code-complete, gated on `PUSH_NOTIFICATIONS` entitlement, but **inert until real Firebase config is supplied** (see §9).

- `core/push/push_service.dart` — `Firebase.initializeApp(options: FirebaseOptions(...))` built from `--dart-define` values (`core/config/env.dart`), **not** from `google-services.json`/`GoogleService-Info.plist` — deliberately avoided so the Android build never hard-fails just because Firebase isn't configured yet (the Gradle `google-services` plugin would do exactly that if applied without a JSON file present).
- Delivery is data-only FCM (confirmed against `PushNotificationService.java` — no `notification` block), so the visible notification is built client-side via `flutter_local_notifications` in all three states (foreground/background/terminated), using the exact same `NotificationFormat` title/description logic as the in-app Notifications screen.
- Registration: `POST /device-tokens {token, platform: "ANDROID"|"IOS"}` — confirmed server-side to already accept native platform values with zero backend changes needed.
- Tap-to-navigate routes through `core/push/push_navigation.dart` (a tiny Riverpod event-bus provider) rather than `PushService` holding a router reference directly, keeping `core/push` free of any dependency on `app.dart`.

## 8. Backend API Surface Used

Base path `/api/v1` on every request. Full endpoint-by-endpoint mapping was grounded directly against the backend Java source (controllers + DTOs), not assumed — see the architecture plan's mobile section for the complete reference table. Endpoints consumed: `/auth/{login,refresh,logout}`, `/leads*`, `/visits*`, `/notifications*`, `/activity`, `/masters/{type}`, `/organizations/me/{theme,entitlements}`, `/employees/{id}`, `/employees/me/theme-preference`, `/device-tokens`, `/leads/{id}/attachments`, `/attachments/{id}`, `/leave-balances/mine`, `/leave-requests*`, `/leave-types`, `/attendance/{clock-in,clock-out,mine}`, `/reports/team-progress`.

## 9. External Dependencies — Needs the User's Action

These are genuinely blocked on setup only the account/console owner can do — not something achievable from this environment:

1. **Firebase mobile app registration**: register Android + iOS apps inside the *existing* Firebase project (the one already backing web push — service account already exists at `.deploy/firebase-service-account.json` in the outer repo), then supply `FIREBASE_API_KEY`, `FIREBASE_APP_ID_ANDROID`, `FIREBASE_APP_ID_IOS`, `FIREBASE_MESSAGING_SENDER_ID`, `FIREBASE_PROJECT_ID` via `--dart-define` (see `core/config/env.dart`'s doc comment for exact flag names). Until then, `PushService` no-ops silently — the app works normally, just without push.
2. **iOS builds**: this environment is Windows-only. Building/running on an iOS simulator or device, code signing, and any App Store distribution all need a Mac or a cloud Mac CI (Codemagic, etc.). The Dart code is already platform-agnostic; only the *build step* is blocked.
3. **App icon / branding**: still Flutter's default icon — no logo asset was available to generate a real one (`flutter_launcher_icons` is the standard tool for this once a source image exists).
4. **Master-data "creatable" (pick-or-type) fields**: the New Lead/Log Visit forms currently only let a rep pick from existing master data, not type a free-text fallback like the web app's `CreatableMasterAutocomplete`. Scoped out of v1 for time; a real gap if reps commonly need values not yet in the org's master list.

## 10. Build Environment Notes (Windows-specific)

Encountered and fixed during this build — recorded so a future session doesn't have to rediscover them:

- **Flutter SDK / Android SDK must live on a path with no spaces.** The default Android SDK location under a Windows username containing a space (`C:\Users\<name with space>\AppData\Local\Android\sdk`) breaks NDK tooling. SDK was relocated to `C:\Android\sdk`; `ANDROID_HOME`/`ANDROID_SDK_ROOT` and `PATH` updated accordingly (user-level env vars).
- **`compileSdk` bumped to 37** (`android/app/build.gradle.kts`) — `flutter_secure_storage` 11.x requires it, above Flutter 3.44.8's own default of 36.
- **Core library desugaring enabled** (`isCoreLibraryDesugaringEnabled = true` + `coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")`) — required by `flutter_local_notifications`.
- **`kotlin.incremental=false`** in `android/gradle.properties` — works around a genuine Kotlin/Gradle bug on Windows when the pub cache and the project directory are on different drive letters (throws `IllegalArgumentException: this and base files have different roots` trying to relativize paths across drives). Costs some build speed; safe to remove if your machine doesn't hit this (e.g. everything on one drive).
- A first-time `flutter build apk --debug` triggers substantial one-off downloads (Gradle distribution, Android SDK components matching plugin requirements, Kotlin/AGP artifacts) — expect it to take several minutes longer than subsequent builds.

## 11. Testing

- `flutter analyze` — clean (only `prefer_initializing_formals`/`use_null_aware_elements` info-level style suggestions, no errors/warnings).
- `flutter test` — the scaffolded widget test (boots to Login with no stored session, using a fake `SecureTokenStore` override to avoid touching the real platform-channel-backed secure storage under `flutter test`) passes.
- `flutter build apk --debug` — verified end-to-end successful (real native compilation, not just static analysis).
- **Not yet done**: unit tests for `SyncEngine`'s drain/reconciliation/conflict logic (the highest-value target given its complexity), widget tests for form validation, an actual on-device/emulator smoke test against the live backend, iOS build verification (blocked on Mac access per §9).

## 12. Deliberately Deferred (not built, not forgotten)

- Master-data "creatable" free-text fields on Lead/Visit forms (§9.4).
- Edit Lead (route exists as a placeholder, `/leads/:leadId/edit`).
- Settings screen's UI Style/Primary Color edit controls (currently read-only display).
- Local read-cache + optimistic display for queued Leave requests (works reliably via the outbox, just not shown until synced — §5).
- Unit/widget test coverage beyond the one boot smoke test (§11).
- App icon/splash branding, iOS build/signing pipeline.
