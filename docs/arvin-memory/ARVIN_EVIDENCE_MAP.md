# Arvin Evidence Map

Updated: 2026-10-11 (latest smoke recheck)
Repository: https://github.com/mobinpda-lab/Arvin-clean

| Feature / gate | Evidence | Latest status | Limitation / next proof |
|---|---|---|---|
| Restore rollback: Category/Tag catalogs | [Commit 05c080e](https://github.com/mobinpda-lab/Arvin-clean/commit/05c080e706690dd3eb6a96fc5c070971a43d1354); [PR #2585](https://github.com/mobinpda-lab/Arvin-clean/pull/2585) | Code and failure-injection tests committed | Device Smoke backup/restore lane pending |
| Analyze + tests | [Build run #38123874036](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38123874036) | Analyze and all six test shards succeeded on exact head | Full device acceptance still required |
| Debug APK | [Job 114424045147](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38123874036/job/114424045147) | Success | Does not establish installed-device UX acceptance |
| Release APK | [Job 114424045355](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38123874036/job/114424045355) | Success | Does not establish physical-device acceptance |
| Android smoke: Home | [Device Smoke #38123874041](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38123874041) | Success | Emulator lane only |
| Android smoke: Quick Capture | Same Device Smoke run | Success | Emulator lane only |
| Android smoke: SQL migration | Same Device Smoke run | Success | Exact-head emulator lane; physical acceptance still required |
| Android smoke: SQL persistence | Same Device Smoke run | Success | Exact-head emulator lane; physical acceptance still required |
| Android smoke: Backup/Restore | Same Device Smoke run | In progress | Must pass to validate this change's critical path |
| Android smoke: People | Same Device Smoke run | In progress | Need all six lanes green |
| Production Loop | [Run #38123874039](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38123874039) | Success | Automation status only |
| Orchestrator | [Run #38123874049](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38123874049) | Success | Automation status only |
| Orchestrator PR Wakeup | [Run #38123874082](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38123874082) | Success | Automation status only |
| G1 lock sync | [Run #38123874063](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38123874063) | Success | Does not replace product tests |
| Taxonomy architecture | [ADR](https://github.com/mobinpda-lab/Arvin-clean/blob/main/docs/ADR/ADR-2026-10-10-PCTADP-project-category-tag.md), [Issue #2580](https://github.com/mobinpda-lab/Arvin-clean/issues/2580) | Contract accepted; audit open | Verify remaining UI/docs/surfaces and physical Category↔Project behavior without assuming a foreign key |
| Home grouping model | [HomeGroupingService](https://github.com/mobinpda-lab/Arvin-clean/blob/main/lib/home/grouping/home_grouping_service.dart) | Read-only inspection confirms presentation projection; Category and Tag remain separate grouping modes | Complete repository-wide audit |
| Calendar actions and recurrence | [P0 Issue #2535](https://github.com/mobinpda-lab/Arvin-clean/issues/2535) | Open / not accepted | Installed APK must show Edit and manual phone-calendar actions; recurrence dates and no-duplicate behavior need validation |
| Physical Android backup/restore | No linked device evidence | Not verified | Real system picker/provider and before/after integrity record required |
| Calendar event identity/no duplicates | No post-restore evidence linked | Not verified | Record Task ID, external event ID and event count before/after edit/re-sync |
| Golden Flow | Release checklist | Not verified end-to-end | Create Task → time → Project → Checklist → Repeat → Tracking → Calendar → Backup → Restore |
| Release handover | No completed package evidence | Pending | Release notes, install guide, user guide, known issues, architecture summary and evidence report |


## Calendar callback trace — Issue #2535
- Main route `lib/main.dart` wires `onEditTask` and `onRegisterTaskToDeviceCalendar` into `CanonicalCalendarLauncher`.
- `lib/widgets/canonical_calendar_launcher.dart` passes these callbacks and `visibleReminderProjection` into `IranianOfficialCalendarPage`.
- `lib/official_calendar_page.dart` forwards callbacks and visible-range projection to `CalendarPage`.
- `test/canonical_calendar_launcher_test.dart` already contains recurring-task callback coverage; `test/calendar_runtime_actions_fast_track_test.dart` already asserts Edit and phone-calendar actions in a widget scenario.
- These checks establish a callback path in source/tests, not installed-device acceptance or root cause. Next inspect task-row action conditions and recurrence range projection before changing code.
- Latest exact-head smoke recheck: Home, Quick Capture, SQL migration, SQL persistence = success; Backup/Restore and People = in progress.
