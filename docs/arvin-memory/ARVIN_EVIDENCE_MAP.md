# Arvin Evidence Map

Updated: 2026-10-11 (live recheck)
Repository: https://github.com/mobinpda-lab/Arvin-clean
GitHub access: Read/Write

| Feature / gate | Evidence | Latest status | Limitation / next proof |
|---|---|---|---|
| Restore rollback: Category/Tag catalogs | [Commit 05c080e](https://github.com/mobinpda-lab/Arvin-clean/commit/05c080e706690dd3eb6a96fc5c070971a43d1354); [PR #2585](https://github.com/mobinpda-lab/Arvin-clean/pull/2585) | Code and failure-injection tests committed; PR open | Smoke backup/restore still running; review current head/checks before merge |
| Analyze + tests + APKs | [Build #38123874036](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38123874036) | Analyze, six test shards, Debug APK and Release APK succeeded on exact head 05c080e | Does not prove physical-device acceptance |
| Android smoke: Home | [Device Smoke #38123874041](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38123874041) | Success | Emulator lane only |
| Android smoke: Quick Capture | Same Device Smoke run | Success | Emulator lane only |
| Android smoke: SQL migration | Same Device Smoke run | Success | Emulator lane only |
| Android smoke: SQL persistence | Same Device Smoke run | Success | Emulator lane only |
| Android smoke: Backup/Restore | Same Device Smoke run | In progress at latest live recheck | Must finish successfully |
| Android smoke: People | Same Device Smoke run | In progress at latest live recheck | Must finish successfully |
| Calendar task actions | [P0 Issue #2535](https://github.com/mobinpda-lab/Arvin-clean/issues/2535); [PR #2587](https://github.com/mobinpda-lab/Arvin-clean/pull/2587) | Source inspection confirms Edit and phone-calendar registration actions are present but only rendered inside the expanded card action area on main; PR #2587 specifically exposes primary actions on collapsed Task cards | PR #2587 has historical green CI on its own earlier head, is open/unmerged; verify current head/checks and real installed Android behavior |
| Calendar recurrence | [P0 Issue #2535](https://github.com/mobinpda-lab/Arvin-clean/issues/2535), [architecture gate #2254](https://github.com/mobinpda-lab/Arvin-clean/issues/2254) | Existing launcher resolves occurrence IDs back to the canonical Task; no root cause for all scheduled dates has yet been proven by this recheck | Inspect current projection and count contract up to seven; do not create copied Tasks or change recurrence semantics without approval |
| Taxonomy architecture | [ADR](https://github.com/mobinpda-lab/Arvin-clean/blob/main/docs/ADR/ADR-2026-10-10-PCTADP-project-category-tag.md), [Issue #2580](https://github.com/mobinpda-lab/Arvin-clean/issues/2580) | Contract accepted; audit open | Verify remaining UI/docs/surfaces and physical Category↔Project behavior |
| Home grouping | [HomeGroupingService](https://github.com/mobinpda-lab/Arvin-clean/blob/main/lib/home/grouping/home_grouping_service.dart) | Read-only inspection confirms grouping is a presentation projection over canonical Tasks; Category and Tag are separate grouping modes | Repository-wide audit remains |
| Physical Android backup/restore | No linked device evidence | Not verified | Real system file picker/provider and before/after integrity record required |
| Calendar event identity/no duplicates | No post-restore evidence linked | Not verified | Record Task ID, external event ID and event count before/after edit/re-sync |
| Golden Flow | Release checklist | Not verified end-to-end | Create Task → time → Project → Checklist → Repeat → Tracking → Calendar → Backup → Restore |
| Release handover | No completed package evidence | Pending | Release notes, installation guide, user guide, known issues, architecture summary and evidence report |

## Calendar callback and visibility trace — Issue #2535

- lib/main.dart wires onEditTask and onRegisterTaskToDeviceCalendar into CanonicalCalendarLauncher.
- lib/widgets/canonical_calendar_launcher.dart passes these callbacks and the visible-range projection into IranianOfficialCalendarPage; the occurrence edit path resolves the occurrence suffix to the stable canonical Task ID.
- lib/official_calendar_page.dart forwards callbacks and visible-range projection to CalendarPage.
- lib/calendar_page.dart passes Edit and phone-calendar registration callbacks to _ReminderCard for recognized Task IDs (task-due:, task-reminder:, task-followup:).
- In the current main card UI, those action chips are rendered only when _expanded && _hasActions; the Task Edit and phone-calendar registration chips are therefore hidden until the card is expanded. This is concrete source evidence consistent with the user's discoverability report.
- Existing PR #2587 targets this precise visibility problem by exposing primary Task actions on collapsed cards. Keep it open until its current exact-head checks and physical-device acceptance are reviewed.
- This source trace does not yet prove why all repeat dates are not displayed in the installed APK. Recurrence projection/count remains a separate unresolved acceptance item.
- Latest exact-head smoke recheck for PR #2585: Home, Quick Capture, SQL migration, SQL persistence = success; Backup/Restore and People = in progress. Build/Analyze/test shards/Debug/Release APK passed on exact head 05c080e.
- CI/emulator success is not physical-device acceptance or release approval.
