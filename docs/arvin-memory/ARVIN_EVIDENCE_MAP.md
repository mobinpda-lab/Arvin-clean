# Arvin Evidence Map

Updated: 2026-10-11
Repository: https://github.com/mobinpda-lab/Arvin-clean

| Feature / gate | Evidence | Latest status | Limitation / next proof |
|---|---|---|---|
| Restore rollback: Category/Tag catalogs | [Commit 05c080e](https://github.com/mobinpda-lab/Arvin-clean/commit/05c080e706690dd3eb6a96fc5c070971a43d1354); [PR #2585](https://github.com/mobinpda-lab/Arvin-clean/pull/2585) | Code and failure-injection tests committed | Exact-head full test/build/smoke pending |
| Analyze | [Build run #38123874036](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38123874036) | Passed on exact head at latest inspection | Build run not complete |
| Test shards | Same Build run | Shards 1, 3, 4, 5 passed; 0 and 2 running | Need all six complete |
| Debug / Release APK | Same Build run | Running | Need both jobs successful |
| Android emulator smoke | [Device Smoke #38123874041](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38123874041) | Home/Quick Capture running; four lanes queued | Need all six lanes complete |
| Production Loop | [Run #38123874039](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38123874039) | Success | Does not prove product/device acceptance |
| Orchestrator | [Run #38123874049](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38123874049) | Success | Automation status only |
| Orchestrator PR Wakeup | [Run #38123874082](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38123874082) | Success | Automation status only |
| G1 lock sync | [Run #38123874063](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38123874063) | Success | Lock workflow does not replace tests |
| Physical Android backup/restore | No device evidence linked | Not verified | Use actual system picker/provider; record device/OS, steps and before/after state |
| Calendar event identity/no duplicates | No post-restore device/test evidence linked | Not verified | Record Task ID, external event ID, event count before/after edit/re-sync |
| Taxonomy ontology audit | [Issue #2580](https://github.com/mobinpda-lab/Arvin-clean/issues/2580), [ADR #2582](https://github.com/mobinpda-lab/Arvin-clean/issues/2582) | Open | Complete cross-surface audit and attach evidence |
| User-reported Calendar actions | [Memory log](ARVIN_USER_EXPERIENCE_LOG.md) | Open / not revalidated | Inspect current Calendar UI and test edit/register-in-phone-calendar actions |
| Golden Flow | Release checklist | Not verified end-to-end | Create Task → time → Project → Checklist → Repeat → Tracking → Calendar → Backup → Restore |
| Release package | Not yet evidenced | Pending | Release notes, install guide, user guide, known issues, architecture summary, evidence report |
