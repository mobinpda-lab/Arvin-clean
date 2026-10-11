# Arvin Evidence Map

Updated: 2026-10-11
Repository: https://github.com/mobinpda-lab/Arvin-clean

| Feature / gate | Evidence | Latest status | Limitation / next proof |
|---|---|---|---|
| Restore rollback: Category/Tag catalogs | [Commit 05c080e](https://github.com/mobinpda-lab/Arvin-clean/commit/05c080e706690dd3eb6a96fc5c070971a43d1354); [PR #2585](https://github.com/mobinpda-lab/Arvin-clean/pull/2585) | Code and failure-injection tests committed | Build/emulator runs still in progress |
| Analyze | [Build run #38123874036](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38123874036) | Success on exact head | Overall build not complete |
| Test shards 0–5 | Same Build run | All six shards report success | Wait for whole Build conclusion |
| Debug APK | [Job 114424045147](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38123874036/job/114424045147) | In progress | Must finish successfully |
| Release APK | [Job 114424045355](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38123874036/job/114424045355) | In progress | Must finish successfully |
| Android emulator smoke | [Device Smoke #38123874041](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38123874041) | Home/Quick Capture running; backup/restore, people, SQL migration and SQL persistence queued | Need all six lanes complete |
| Production Loop | [Run #38123874039](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38123874039) | Success | Automation status only |
| Orchestrator | [Run #38123874049](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38123874049) | Success | Automation status only |
| Orchestrator PR Wakeup | [Run #38123874082](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38123874082) | Success | Automation status only |
| G1 lock sync | [Run #38123874063](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38123874063) | Success | Does not replace tests |
| Physical Android backup/restore | No device evidence linked | Not verified | Actual system picker/provider and before/after integrity record required |
| Calendar event identity/no duplicates | No post-restore evidence linked | Not verified | Record Task ID, external event ID and event count before/after edit/re-sync |
| Taxonomy ontology audit | [Issue #2580](https://github.com/mobinpda-lab/Arvin-clean/issues/2580), [ADR #2582](https://github.com/mobinpda-lab/Arvin-clean/issues/2582) | Open | Complete cross-surface audit |
| User-reported Calendar actions | [User Experience Log](ARVIN_USER_EXPERIENCE_LOG.md) | Open / not revalidated | Inspect current Calendar UI and verify edit/register-in-phone-calendar actions |
| Golden Flow | Release checklist | Not verified end-to-end | Create Task → time → Project → Checklist → Repeat → Tracking → Calendar → Backup → Restore |
| Release package | Not yet evidenced | Pending | Release notes, install guide, user guide, known issues, architecture summary and evidence report |
