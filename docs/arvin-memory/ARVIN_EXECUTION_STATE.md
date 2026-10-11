# Arvin Execution State

Updated: 2026-10-11
Repository: https://github.com/mobinpda-lab/Arvin-clean
GitHub access: Read/Write
Authority: live GitHub refs, code, tests and exact-head workflow evidence.

## Current release state
**IN PROGRESS — RELEASE BLOCKED.**

## Current GitHub reality
- `main`: `72a2f4cc24df7a38eff9856ce403461615db5280`.
- Backup/restore [PR #2585](https://github.com/mobinpda-lab/Arvin-clean/pull/2585): OPEN / NOT MERGED; head `05c080e706690dd3eb6a96fc5c070971a43d1354`. PR metadata still displays base SHA `34a6cee9ae05ad1cf632960b96e98f2a5448e128`, but GitHub compare confirms current main `72a2f4c` is an ancestor of the PR head: head is 44 commits ahead, 0 behind. Do not blindly rebase; review actual diff and mergeability before any merge.
- Memory [PR #2600](https://github.com/mobinpda-lab/Arvin-clean/pull/2600): OPEN / DRAFT; latest head `8de11b2264658b137b348e2031be9e906842ea4d`; base `72a2f4cc24df7a38eff9856ce403461615db5280`.
- Exact-head Build [#38123874036](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38123874036): **SUCCESS** on `05c080e`; Analyze, all six test shards (0–5), Debug APK and Release APK jobs succeeded.
- Exact-head Android Device Smoke [#38123874041](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38123874041): still running. Latest recheck: Home, Quick Capture, SQL migration and SQL persistence succeeded; Backup/Restore and People remain in progress.
- Production Loop [#38123874039], Orchestrator [#38123874049], Orchestrator PR Wakeup [#38123874082] and G1 lock sync [#38123874063] succeeded on exact head. These do not substitute for full device smoke or physical device acceptance.
- Older green checkpoint `07b571057c4682128d78ab2c1f39e85890041713` remains historical only.

## Completed
- Rechecked execution state, current main, PRs, open issues, ADR, data model, Home grouping code, restore patch and exact-head workflow jobs.
- Found restore rollback gap for Category/Tag catalog values after a late restore failure.
- Committed fix and failure-injection tests in [05c080e](https://github.com/mobinpda-lab/Arvin-clean/commit/05c080e706690dd3eb6a96fc5c070971a43d1354).
- Build/test/Analyze/Debug/Release exact-head gate now passes.
- Home grouping inspection confirms `HomeGroup<T>`/`HomeGroupingService` are presentation projections over canonical Tasks; category and tag grouping are separate, with no separate taxonomy persistence in these files.
- Updated memory PR #2600 with all required v8 memory documents and current exact-head evidence.

## In Progress
- Finish all six Android emulator smoke lanes on `05c080e`, especially backup/restore, SQL migration and SQL persistence.
- Taxonomy conformance audit [Issue #2580](https://github.com/mobinpda-lab/Arvin-clean/issues/2580).
- Backup/restore catalog acceptance [Issue #2584](https://github.com/mobinpda-lab/Arvin-clean/issues/2584).
- P0 Calendar user-reported regression [Issue #2535](https://github.com/mobinpda-lab/Arvin-clean/issues/2535): task Edit / phone-calendar actions missing in installed APK and recurrence occurrences not all shown. Open; real installed-device validation required.

## Blocked / unproven
- Device Smoke workflow not complete; Backup/Restore and People lanes are still running.
- No physical Android device + actual system file picker/provider backup/restore evidence.
- No verified Calendar external-event identity/no-duplicate test after restore.
- No full Golden Flow evidence.
- PR #2585 is not merged; review final diff and PR status checks before deciding merge.
- Release remains blocked despite Build success.

## Next Action — tracked checklist

### A. CI and PR #2585
- [ ] A1. Recheck all six jobs in [Android Device Smoke #38123874041](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38123874041).
- [ ] A2. Record final SQL migration and SQL persistence results.
- [ ] A3. Record Backup/Restore and People outcomes; if a lane fails, inspect logs, make a minimal safe fix, and rerun required checks on the new exact head.
- [ ] A4. Review final diff, exact head, mergeability and required checks on [PR #2585](https://github.com/mobinpda-lab/Arvin-clean/pull/2585). Do not merge before acceptance gates.

### B. Calendar P0 #2535
- [ ] B1. Trace callbacks from main.dart through OfficialCalendarPage to CalendarPage; identify where Edit/device-calendar actions are lost.
- [ ] B2. Trace visible-range recurrence projection and identify why dates beyond today are missing.
- [ ] B3. Reconcile the requested count up to 7 with architecture gate #2254; do not change recurrence semantics without approval.
- [ ] B4. Add/fix focused regression tests only for an evidenced gap; preserve canonical Task identity and stable external-event mapping.
- [ ] B5. Run focused tests, Analyze, full tests, Debug/Release and exact-head Device Smoke on any fix.
- [ ] B6. Verify on a real installed Android build: Edit, register/edit phone-calendar event, all scheduled recurrence dates through seven occurrences, and no duplicate Task/event.
- [ ] B7. Attach commit, test results and device evidence to Issue #2535; close only after acceptance.

### C. Physical acceptance and handover
- [ ] C1. Exercise restore using the real Android system file picker/provider and record evidence.
- [ ] C2. Verify Task, Category/Tag, Repeat, History and Calendar Link survive successful and failed restore paths.
- [ ] C3. Complete Golden Flow across Task, Calendar, Repeat, Checklist, Tracking, Backup and Restore.
- [ ] C4. Complete Release Notes, Installation Guide, User Guide, Known Issues, Architecture Summary and Evidence Report.

Done criteria: commit + tests + build + risk-appropriate acceptance evidence. Green CI alone is not physical-device acceptance.

## Current Bottleneck
**Android Device Smoke completion**, followed by physical-device backup/restore and Calendar acceptance.

## Risks
Partial restore; loss of unused Category/Tag catalog entries; Task/Project/settings/repeat/history/Calendar-link loss; duplicate external Calendar events; regression in Calendar task actions/recurrence projection; treating emulator CI as physical-device proof.
