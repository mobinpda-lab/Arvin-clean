# Arvin Evidence Map

Updated: 2026-10-11 (exact-head Build result recorded)
Repository: https://github.com/mobinpda-lab/Arvin-clean
GitHub access: Read/Write

| Feature / gate | Evidence | Latest status | Limitation / next proof |
|---|---|---|---|
| Restore rollback: Category/Tag catalogs + multi-store orchestration | [PR #2585](https://github.com/mobinpda-lab/Arvin-clean/pull/2585); [latest test commit 5e0ad6d](https://github.com/mobinpda-lab/Arvin-clean/commit/5e0ad6ddd1675359b84a3ab9c351be4d8ac38a27) | BackupPage now injects failure after Task, Calendar-link and settings/schedule stages; asserts Task/Project/link/settings/schedule rollback | Exact-head Build #38124942112 SUCCESS: Analyze, six test shards, Debug and Release APK. Smoke #38124941815 SUCCESS on exact head: all six lanes passed — Home, Quick Capture, SQL Migration, SQL Persistence, Backup/Restore and People. Physical-device file-provider acceptance remains required. Physical device remains required |
| Restore Build / Analyze / tests / APKs | [Build #38123874036](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38123874036) | SUCCESS on exact head 05c080e: Analyze, six test shards, Debug APK, Release APK | Does not prove physical-device acceptance |
| Restore Device Smoke | [Smoke #38123874041](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38123874041) | ALL SIX LANES SUCCESS on exact head 05c080e: Home, Quick Capture, SQL Migration, SQL Persistence, People, Backup/Restore | Emulator lane only; physical file-provider still required |
| Calendar primary actions + recurrence test | [PR #2587](https://github.com/mobinpda-lab/Arvin-clean/pull/2587); [P0 Issue #2535](https://github.com/mobinpda-lab/Arvin-clean/issues/2535) | Latest validated head recorded in PR conversation: 4442ce450e4295e500a9db6d5dc5b4d9657b3770 | PR open; physical-device acceptance still required |
| Calendar exact-head Build | [Build #38089112669](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38089112669) | SUCCESS: Analyze, all six test shards, Debug APK, Release APK | CI only |
| Calendar exact-head Smoke | [Smoke #38089112675](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38089112675) | ALL SIX LANES SUCCESS: Home, Quick Capture, SQL Migration, SQL Persistence, People, Backup/Restore | Emulator lane only; no physical-device event-provider proof |
| Seven-occurrence limit | [Commit 4442ce4](https://github.com/mobinpda-lab/Arvin-clean/commit/4442ce450e4295e500a9db6d5dc5b4d9657b3770); PR #2587 | Regression test checks count=7 and asserts the eighth scheduled date is absent; separate later-occurrence navigation test retained | Installed-device behavior remains unproven |
| Calendar action visibility root cause | [PR #2587](https://github.com/mobinpda-lab/Arvin-clean/pull/2587) | Current main source renders Task action chips only while the card is expanded; PR exposes primary actions on collapsed cards | Stale-head merge attempt rejected; no merge occurred |
| Taxonomy architecture | [ADR](https://github.com/mobinpda-lab/Arvin-clean/blob/main/docs/ADR/ADR-2026-10-10-PCTADP-project-category-tag.md), [Issue #2580](https://github.com/mobinpda-lab/Arvin-clean/issues/2580) | Contract accepted; audit open | Verify remaining UI/docs/surfaces and physical Category↔Project behavior |
| Home grouping | [HomeGroupingService](https://github.com/mobinpda-lab/Arvin-clean/blob/main/lib/home/grouping/home_grouping_service.dart) | Grouping is a presentation projection over canonical Tasks; Category and Tag are separate modes | Repository-wide audit remains |
| Physical Android backup/restore | No linked device evidence | NOT VERIFIED | Real system file picker/provider and before/after integrity record required |
| Calendar event identity/no duplicates | No physical-device evidence after restore | NOT VERIFIED | Record Task ID, external event ID and event count before/after edit/re-sync |
| Golden Flow | Release checklist | NOT VERIFIED end-to-end | Create Task → time → Project → Checklist → Repeat → Tracking → Calendar → Backup → Restore |
| Release handover | No completed package evidence | PENDING | Release notes, installation guide, user guide, known issues, architecture summary and evidence report |

## Calendar callback and visibility trace — Issue #2535

- `lib/main.dart` wires `onEditTask` and `onRegisterTaskToDeviceCalendar` into `CanonicalCalendarLauncher`.
- `lib/widgets/canonical_calendar_launcher.dart` passes callbacks and visible-range projection into `IranianOfficialCalendarPage`; occurrence editing resolves the occurrence suffix to the stable canonical Task ID.
- `lib/official_calendar_page.dart` forwards callbacks and visible-range projection to `CalendarPage`.
- `lib/calendar_page.dart` passes Edit and phone-calendar registration callbacks to `_ReminderCard` for recognized Task IDs.
- On current main, action chips are inside the `_expanded && _hasActions` conditional. This is source evidence consistent with the user's discoverability report.
- PR #2587 targets the visibility issue. A merge attempt with stale expected head `e416f48` was rejected because the PR branch had changed; no merge occurred. The latest validated head recorded in PR comments is `4442ce4`; all Build and Smoke lanes passed for that head.
- The seven-occurrence regression test is recorded in commit `4442ce450e4295e500a9db6d5dc5b4d9657b3770`; it asserts the eighth date is not shown for count=7 and retains separate later-occurrence navigation coverage.
- PR #2585 exact head `05c080e` now has green Build and all six Device Smoke lanes. This is automated evidence only; physical device and actual file-provider validation remain open.
- Physical-device same-event edit/sync/no-duplicate, recurrence/checklist behavior, link recovery after restore, screenshot review and owner acceptance remain open. Keep both PRs unmerged until their respective acceptance gates are satisfied.


## Continuation checkpoint — BackupPage settings-stage failure
- Commit: [`5e0ad6d`](https://github.com/mobinpda-lab/Arvin-clean/commit/5e0ad6ddd1675359b84a3ab9c351be4d8ac38a27).
- Read-back of the changed integration test succeeded (blob `46571a56323ccbce8fa8d1c8f70272cec026c0c4`).
- Exact-head Build [#38124942112](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38124942112) completed SUCCESS: Analyze, six test shards, Debug APK and Release APK all passed.
- Device Smoke [#38124941815](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38124941815) remains partial: Home, Quick Capture, SQL Migration and SQL Persistence passed; Backup/Restore and People are in progress. Do not describe the full smoke suite as passed.
- The new test is automated emulator/integration coverage, not physical file-provider acceptance.


## Exact-head Build completion — 2026-10-11
- PR #2585 commit `5e0ad6ddd1675359b84a3ab9c351be4d8ac38a27` Build #38124942112 succeeded for Analyze, all six test shards, Debug APK and Release APK.
- Smoke #38124941815 remains incomplete: Home, Quick Capture, SQL Migration and SQL Persistence passed; Backup/Restore and People are in progress.
- The successful build is not physical-device validation; file-picker/provider restore and data-integrity acceptance remain open.


## Device Smoke progress — 2026-10-11
- Current run [#38124941815](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38124941815): all six lanes completed SUCCESS — Home, Quick Capture, SQL Migration, SQL Persistence, Backup/Restore and People. This is emulator smoke, not physical-device file-provider acceptance.
- Do not mark PR #2585's full emulator smoke suite green until both remaining lanes finish successfully. Physical system file-picker/provider restore remains unverified.
