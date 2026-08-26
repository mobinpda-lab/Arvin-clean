# Canonical Android Widget — 2026-08-26

Gate E Vertical Slice. Refs #202 #195 #153.

## Implemented

- One Android `AppWidgetProvider` foundation is registered in the existing application Manifest.
- The widget reads Flutter's existing `FlutterSharedPreferences` entry `flutter.arvin.tasks`, which is the native representation of canonical `TaskStore.key = arvin.tasks`.
- No Widget database, JSON file, preference key, Task model, FollowUp repository or scheduler is introduced.
- The projection shows the latest chronological FollowUp for active Tasks only and displays up to three newest items.
- Each row carries the canonical Task id (`arvin_task_id`) into the app launch intent.
- Native `MainActivity` and Flutter `WidgetTaskBridge` carry only that Task id across the platform boundary for cold-start and singleTop taps.
- Home consumes the bridge, reloads the selected Task from canonical storage through `WidgetTaskSelectionService`, and opens the existing `TaskTimelinePage` for that same Task.
- Layout is RTL and declares both `home_screen` and `keyguard`; unsupported launcher/Android lock-screen placement falls back to normal home-screen widget behavior.
- Refresh uses Android AppWidget periodic update rather than a second background scheduler.

## Shared contract

`WidgetFollowUpProjection` defines the same read-only product rule in Dart and is covered by focused unit tests. Native Android mirrors that rule because a Widget must render even when the Flutter process is not running.

The tap path is canonical end-to-end:

`Widget row -> canonical Task id -> WidgetTaskBridge -> WidgetTaskSelectionService -> TaskMigrationReader/arvin.tasks -> TaskTimelinePage(same Task)`

## Validation

- Projection tests cover chronological latest FollowUp, active-state filtering, output limit and title fallback.
- Native contract tests prove canonical SharedPreferences usage, Manifest registration, RTL/keyguard configuration and Task-id intent wiring.
- Bridge/service tests cover cold-start/live-event transport and canonical Task reload behavior.
- Home wiring contract verifies initial/live bridge consumption, canonical Task resolution, existing Timeline navigation and bridge disposal.
- Exact-head Analyze/Test/APK validation is required before merge.

## Explicit remaining device evidence

Physical launcher placement, OEM lock-screen support, resize behavior and real-device row-tap behavior remain Gate E device evidence. Build/unit evidence may prove the route is wired, but device-specific launcher/keyguard behavior must not be claimed complete until exercised on a real emulator/device path.
