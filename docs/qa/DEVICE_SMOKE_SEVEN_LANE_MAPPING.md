# Device Smoke — Canonical Seven-Lane Mapping

The device-smoke workflow emits the seven acceptance lane identifiers below on every PR/push run and on every manual dispatch. Every job checks out and verifies the same `TARGET_SHA` before running its integration test on an Android emulator.

| Acceptance lane | Integration test | Coverage basis |
| --- | --- | --- |
| `smoke-boot` | `integration_test/android_home_smoke_test.dart` | Cold app launch, Persian Home identity, first-run flow, canonical task creation. |
| `smoke-navigation` | `integration_test/android_people_smoke_test.dart` | Home → Calendar → Timeline → People navigation and People CRUD flow. |
| `smoke-calendar-segmented-view` | `integration_test/calendar_card_interaction_test.dart` | Calendar weekly segmented control, selected-day projection, reminder card and RTL interactions. |
| `smoke-quick-capture` | `integration_test/android_quick_capture_smoke_test.dart` | Quick Capture cancel/no-write, submit/persist and Persian date/time picker. |
| `smoke-task-lifecycle` | `integration_test/android_backup_restore_sql_smoke_test.dart` | Task persistence, edit, backup/restore and rollback lifecycle. |
| `smoke-reminder-vazirmatn` | `integration_test/calendar_card_interaction_test.dart` | Reminder create/edit/cancel behavior in Calendar. The build workflow separately verifies Vazirmatn font assets are packaged in the APK. |
| `smoke-follow-up-persistence` | `integration_test/android_sql_persistence_smoke_test.dart` | Android SQL round-trip for task fields and historical FollowUp data. |

## Evidence interpretation

- The lane names are acceptance labels; the test file is the executable scenario.
- The Calendar integration test is intentionally reused for both Calendar segmented-view and Reminder behavior because it currently exercises both contracts. This is not two independent test suites.
- Vazirmatn runtime rendering is not independently pixel-asserted by this lane. The existing APK font-packaging audit proves the required Vazirmatn font assets are bundled; it does not by itself prove visual rendering on every device.
- A seven-lane result is valid only when all seven jobs have green conclusions, each exact-checkout step prints the requested SHA, and each integration test emits its own passing summary. A successful matrix setup job alone is not acceptance evidence.
