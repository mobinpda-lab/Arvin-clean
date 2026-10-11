# Arvin Evidence Map

Updated: 2026-10-11 (fast-path live recheck)
Repository: https://github.com/mobinpda-lab/Arvin-clean
GitHub access: Read/Write

| Feature / gate | Evidence | Latest status | Limitation / next proof |
|---|---|---|---|
| Restore rollback: Category/Tag catalogs | [Commit 05c080e](https://github.com/mobinpda-lab/Arvin-clean/commit/05c080e706690dd3eb6a96fc5c070971a43d1354); [PR #2585](https://github.com/mobinpda-lab/Arvin-clean/pull/2585) | Code and failure-injection tests committed; PR open | Recheck latest Backup/Restore smoke lane; then review exact head/checks |
| Restore Build / Analyze / tests / APKs | [Build #38123874036](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38123874036) | Successful on exact head 05c080e | Does not prove physical-device acceptance |
| Restore Device Smoke | [Smoke #38123874041](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38123874041) | Home, Quick Capture, SQL migration, SQL persistence and People succeeded; Backup/Restore was still in progress at last live query | Recheck until final result |
| Calendar primary actions + recurrence test | [PR #2587](https://github.com/mobinpda-lab/Arvin-clean/pull/2587); [P0 Issue #2535](https://github.com/mobinpda-lab/Arvin-clean/issues/2535) | Latest documented head 4442ce450e4295e500a9db6d5dc5b4d9657b3770; Build #38089112669 and all six Smoke lanes in #38089112675 succeeded | PR remains open; physical-device acceptance is still required |
| Calendar exact-head Build | [Build #38089112669](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38089112669) | Analyze, all six test shards, Debug APK and Release APK succeeded | CI only |
| Calendar exact-head Smoke | [Smoke #38089112675](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38089112675) | All six lanes succeeded: Home, Quick Capture, SQL Migration, SQL Persistence, People, Backup/Restore | Emulator lane only; no physical-device event-provider proof |
| Seven-occurrence limit | [Commit 4442ce4](https://github.com/mobinpda-lab/Arvin-clean/commit/4442ce450e4295e500a9db6d5dc5b4d9657b3770); PR #2587 | Regression test checks a daily Task with count=7 and asserts the eighth scheduled date is absent; separate later-occurrence navigation test retained | Runtime/installed-device acceptance remains open |
| Calendar action visibility root cause | [PR #2587](https://github.com/mobinpda-lab/Arvin-clean/pull/2587) | Current main source renders Task action chips only when the card is expanded; PR exposes primary actions on collapsed cards | PR not merged; stale-head merge attempt was rejected by GitHub; re-fetch current head before any retry |
| Taxonomy architecture | [ADR](https://github.com/mobinpda-lab/Arvin-clean/blob/main/docs/ADR/ADR-2026-10-10-PCTADP-project-category-tag.md), [Issue #2580](https://github.com/mobinpda-lab/Arvin-clean/issues/2580) | Contract accepted; audit open | Verify remaining UI/docs/surfaces and physical Category↔Project behavior |
| Home grouping | [HomeGroupingService](https://github.com/mobinpda-lab/Arvin-clean/blob/main/lib/home/grouping/home_grouping_service.dart) | Grouping is a presentation projection over canonical Tasks; Category and Tag are separate modes | Repository-wide audit remains |
| Physical Android backup/restore | No linked device evidence | Not verified | Real system file picker/provider and before/after integrity record required |
| Calendar event identity/no duplicates | No post-restore device evidence | Not verified | Record Task ID, external event ID and event count before/after edit/re-sync |
| Golden Flow | Release checklist | Not verified end-to-end | Create Task → time → Project → Checklist → Repeat → Tracking → Calendar → Backup → Restore |
| Release handover | No completed package evidence | Pending | Release notes, installation guide, user guide, known issues, architecture summary and evidence report |

## Calendar callback and visibility trace — Issue #2535

- `lib/main.dart` wires `onEditTask` and `onRegisterTaskToDeviceCalendar` into `CanonicalCalendarLauncher`.
- `lib/widgets/canonical_calendar_launcher.dart` passes callbacks and visible-range projection into `IranianOfficialCalendarPage`; occurrence editing resolves the occurrence suffix to the stable canonical Task ID.
- `lib/official_calendar_page.dart` forwards callbacks and visible-range projection to `CalendarPage`.
- `lib/calendar_page.dart` passes Edit and phone-calendar registration callbacks to `_ReminderCard` for recognized Task IDs.
- On current main, the action chips are inside the `_expanded && _hasActions` conditional. This is source evidence consistent with the user's discoverability report.
- PR #2587 already targets this issue. A merge attempt with stale expected head `e416f48` was rejected because the branch had changed; no merge occurred. Latest recorded validated head is `4442ce4`; all build and smoke lanes passed for that exact head.
- The seven-occurrence regression test is recorded in `4442ce450e4295e500a9db6d5dc5b4d9657b3770`; it asserts the eighth date is not shown for count=7 and retains a separate later-occurrence navigation test.
- Physical-device same-event edit/sync/no-duplicate, recurrence/checklist behavior, link recovery after restore, screenshot review and owner acceptance remain open. Keep PR #2587 unmerged until those gates are satisfied.
- CI/emulator success is not physical-device acceptance or release approval.
