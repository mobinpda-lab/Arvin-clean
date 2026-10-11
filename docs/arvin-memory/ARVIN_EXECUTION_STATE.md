# Arvin Execution State

Updated: 2026-10-11 (live recheck)
Repository: https://github.com/mobinpda-lab/Arvin-clean
GitHub access: Read/Write
Authority: live GitHub refs, code, tests and exact-head workflow evidence.

## Current release state
**IN PROGRESS — RELEASE BLOCKED.**

## Current GitHub reality
- main: 72a2f4cc24df7a38eff9856ce403461615db5280.
- Backup/restore [PR #2585](https://github.com/mobinpda-lab/Arvin-clean/pull/2585): OPEN / NOT MERGED; exact head 05c080e706690dd3eb6a96fc5c070971a43d1354.
- Memory [PR #2600](https://github.com/mobinpda-lab/Arvin-clean/pull/2600): OPEN / DRAFT. Evidence map updated in commit [ac1eaf7](https://github.com/mobinpda-lab/Arvin-clean/commit/ac1eaf72d2416d3577b6b506b4aadeed34cb45f8); recheck branch head and docs PR checks before merge.
- Calendar actions [PR #2587](https://github.com/mobinpda-lab/Arvin-clean/pull/2587): OPEN / NOT MERGED; its documented purpose is to expose Edit and phone-calendar registration on collapsed Task cards. Historical exact-head CI was green, but current head/checks and physical-device acceptance must be rechecked.
- Exact-head Build [#38123874036](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38123874036): SUCCESS on 05c080e; Analyze, all six test shards, Debug APK and Release APK succeeded.
- Exact-head Android Device Smoke [#38123874041](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38123874041): Home, Quick Capture, SQL migration and SQL persistence succeeded. Backup/Restore and People remain IN PROGRESS at the latest live recheck.
- Green automation/orchestration runs are not a substitute for product tests or physical-device acceptance.

## Completed in this execution
- Read this execution state and evidence map before continuing.
- Rechecked open PRs, P0 Calendar issue #2535, restore issue #2584, and current exact-head Android Smoke jobs.
- Inspected Calendar card action conditions in main. Source evidence shows Task Edit and phone-calendar registration chips are inside the expanded-only action area; this matches the user's discoverability report.
- Confirmed existing PR #2587 is already aimed at exposing primary Task actions on collapsed cards. Avoid duplicate implementation; review that PR's current head/checks and acceptance.
- Updated ARVIN_EVIDENCE_MAP.md on the memory branch in commit ac1eaf72d2416d3577b6b506b4aadeed34cb45f8 with source evidence and limitations.

## In Progress
- Finish Android Smoke Backup/Restore and People lanes on exact head 05c080e.
- Review PR #2585 current diff/head/checks; preserve legacy backup compatibility and canonical Task/Project/Calendar-link/settings/history data.
- Review PR #2587 current diff/head/checks; verify collapsed primary actions and recurrence navigation tests.
- Trace recurrence projection/count contract for issue #2535; source evidence for the action visibility problem is stronger now, but the root cause for all scheduled recurrence dates is still unproven.
- Continue taxonomy audit #2580 and backup acceptance #2584.

## Blocked / unproven
- Two Android emulator smoke lanes are still running; no final all-six-lanes pass yet for head 05c080e.
- No physical Android device + actual system file-picker/provider backup/restore evidence.
- No verified Calendar external-event identity/no-duplicate test after restore.
- No full Golden Flow evidence.
- PR #2585 and PR #2587 are not merged.
- Release remains blocked despite successful Build/Analyze/tests/APKs.

## Next Action — dependency-ordered checklist

### A. CI and restore PR #2585
- [ ] Recheck all six jobs in Android Device Smoke #38123874041.
- [ ] Record final Backup/Restore and People outcomes; inspect logs and fix minimally if either fails.
- [ ] Review PR #2585 exact head, complete diff, mergeability and required checks. Do not merge before critical acceptance gates.

### B. Calendar P0 #2535 / PR #2587
- [ ] Review current PR #2587 head and required checks; do not duplicate its collapsed-card action fix.
- [ ] Trace visible-range recurrence projection and prove why planned dates may be missing.
- [ ] Reconcile the requested count up to seven with architecture gate #2254; do not change recurrence semantics without approval.
- [ ] Run focused regression tests, Analyze, full tests, Debug/Release and exact-head Device Smoke for any code change.
- [ ] On a real installed Android build verify Edit, phone-calendar register/edit, scheduled recurrence dates through seven occurrences, and no duplicate Task/event.
- [ ] Attach evidence to #2535; close only after acceptance.

### C. Physical acceptance and handover
- [ ] Use the real Android system file picker/provider for backup/restore.
- [ ] Verify Task, Category/Tag, Repeat, History and Calendar Link across successful and failed restore.
- [ ] Complete Golden Flow: Task → time → Project → Checklist → Repeat → Tracking → Calendar → Backup → Restore.
- [ ] Complete Release Notes, Installation Guide, User Guide, Known Issues, Architecture Summary and Evidence Report.

## Current bottleneck
Android Device Smoke completion, followed by physical-device backup/restore and Calendar acceptance.

## Risk rules
Task remains the only source of truth; Calendar is a projection; Repeat must not create copied Tasks; preserve stable Task ID and external event ID. No merge/release based on CI alone. Do not claim user/device acceptance without direct evidence.
