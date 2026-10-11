# Arvin Execution State

Updated: 2026-10-11 (exact-head Build result recorded)
Repository: https://github.com/mobinpda-lab/Arvin-clean
GitHub access: Read/Write
Authority: live GitHub refs, code, tests and exact-head workflow evidence.

## Current release state
**IN PROGRESS — RELEASE BLOCKED.**

## Current GitHub reality
- Main has moved since the previous checkpoint; latest fetched blob for `lib/calendar_page.dart` is `bca61696309f809dc9640da001fe45aabc262a65`. Re-read live branch and PR refs before any merge.
- Backup/restore [PR #2585](https://github.com/mobinpda-lab/Arvin-clean/pull/2585): OPEN / NOT MERGED; current head `5e0ad6ddd1675359b84a3ab9c351be4d8ac38a27` adds BackupPage settings-stage rollback failure injection. Validation is in progress; previous green evidence on `05c080e` is historical for that older head.
- Memory [PR #2600](https://github.com/mobinpda-lab/Arvin-clean/pull/2600): OPEN / DRAFT. Execution state/evidence map have been updated on the memory branch; check exact branch head and docs PR checks before merge.
- Calendar actions [PR #2587](https://github.com/mobinpda-lab/Arvin-clean/pull/2587): OPEN / NOT MERGED; latest validated head recorded in its conversation is `4442ce450e4295e500a9db6d5dc5b4d9657b3770`.
- Restore Build [#38123874036](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38123874036): SUCCESS on `05c080e` — Analyze, six test shards, Debug APK and Release APK.
- Restore Device Smoke [#38123874041](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38123874041): ALL SIX LANES SUCCESS on `05c080e` — Home, Quick Capture, SQL Migration, SQL Persistence, People and Backup/Restore.
- Calendar Build [#38089112669](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38089112669): SUCCESS on `4442ce4` — Analyze, six test shards, Debug APK and Release APK.
- Calendar Device Smoke [#38089112675](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38089112675): ALL SIX LANES SUCCESS on `4442ce4`.
- A merge attempt for PR #2587 with stale expected head `e416f48` was rejected because the PR head had changed. No merge occurred. PR #2587 itself says physical-device acceptance remains required.
- Green CI/emulator runs do not prove physical-device acceptance or release readiness.

## Completed in this execution
- Read the saved execution state and evidence map before continuing.
- Rechecked open PRs, P0 Calendar issue #2535, restore issue #2584, exact-head jobs and current Calendar source.
- Confirmed Task Edit and phone-calendar registration chips on main remain inside the expanded-only action section.
- Revalidated exact-head Build and all six Device Smoke lanes for PR #2587 head `4442ce4`.
- Revalidated exact-head Build and all six Device Smoke lanes for PR #2585 head `05c080e`.
- Posted live exact-head CI/emulator results to PR #2585 (comment 6107108330) and PR #2587 (comment 6107108630).
- Updated this execution state and evidence map on the memory branch.
- No code PR was merged; a stale-head merge attempt was rejected by GitHub.

## In Progress
- PR #2585: added BackupPage restore test that injects failure after settings + backup-schedule mutation and asserts Task/Project/Calendar-link/settings/schedule rollback. Current exact-head Build #38124942112 is in progress; Device Smoke #38124941815 is queued. Do not claim pass until both complete.
- Review PR #2587 current exact head and acceptance notes; preserve the collapsed-card action and seven-occurrence regressions.
- Physical Android file-provider backup/restore, restored Calendar-link identity/no-duplicate behavior, recurrence/checklist acceptance and visual review.
- Continue taxonomy audit #2580.

## Blocked / unproven
- No physical Android device + actual system file-picker/provider backup/restore evidence.
- No verified physical-device Calendar external-event same-ID/no-duplicate test after restore.
- No complete Golden Flow evidence.
- PR #2585 and PR #2587 remain open/unmerged.
- Release remains blocked despite successful exact-head builds, test shards, APKs and all emulator smoke lanes.

## Next Action — dependency-ordered checklist

### A. Restore PR #2585
- [x] Exact-head Build and all six emulator smoke lanes passed on `05c080e`.
- [x] Rechecked current PR head `5e0ad6ddd1675359b84a3ab9c351be4d8ac38a27` and exact-head Build #38124942112; Analyze, all six test shards, Debug APK and Release APK passed.
- [ ] Finish exact-head Device Smoke #38124941815; Home and Quick Capture passed, SQL Migration and SQL Persistence are in progress, Backup/Restore and People are queued.
- [x] BackupPage integration test injects failures after Task, Calendar-link and settings writes; settings-stage test asserts rollback of Task, Project, Calendar-link, settings and schedule. Exact-head Build passed on `5e0ad6d`; exact-head Device Smoke is not yet complete.
- [ ] Perform physical Android system file-picker/provider backup and restore; verify Task, Projects, Categories/Tags, settings, occurrence/history and Calendar-link metadata.
- [ ] Verify failed restore recovery, emergency-backup reference and legacy backup compatibility.

### B. Calendar P0 #2535 / PR #2587
- [x] Exact-head Build and all six emulator smoke lanes passed on `4442ce4`.
- [x] Regression test checks count=7 does not show the eighth date and retains later-occurrence navigation coverage.
- [ ] Re-fetch current PR head before any merge attempt; the previous stale-head attempt was rejected.
- [ ] On a real installed Android build verify Edit, phone-calendar register/edit, recurrence through seven occurrences, Checklist behavior, same linked external event updated without duplication, and Calendar-link recovery after restore.
- [ ] Attach evidence to #2535; merge/close only after acceptance.

### C. Final delivery
- [ ] Complete Golden Flow: Task → time → Project → Checklist → Repeat → Tracking → Calendar → Backup → Restore.
- [ ] Complete Release Notes, Installation Guide, User Guide, Known Issues, Architecture Summary and Evidence Report.

## Current bottleneck
Physical-device data-safety and Calendar acceptance, not CI/build. PR #2587 has green exact-head automated Build and emulator-smoke evidence. PR #2585 now has a green exact-head Build, while its current exact-head Device Smoke remains incomplete. Both remain intentionally unmerged pending acceptance.

## Risk rules
Task remains the only source of truth; Calendar is a projection; Repeat must not create copied Tasks; preserve stable Task ID and external event ID. No merge/release based on CI alone. Do not claim user/device acceptance without direct evidence.


## Continuation checkpoint — 2026-10-11
- GitHub Read/Write confirmed by live PR, file and workflow operations.
- PR #2585 current exact head is `5e0ad6ddd1675359b84a3ab9c351be4d8ac38a27`. Added failure injection after BackupPage settings/schedule writes and rollback assertions across Task, Project, Calendar-link, settings and schedule. Read-back verified the file at blob `46571a56323ccbce8fa8d1c8f70272cec026c0c4`.
- Exact-head Build #38124942112 is in progress; Device Smoke #38124941815 is queued. Previous green runs on `05c080e` do not validate this new head.
- PR #2585 remains open/unmerged. Physical Android file-provider acceptance remains unverified.


## Exact-head Build completion — 2026-10-11
- PR #2585 head `5e0ad6ddd1675359b84a3ab9c351be4d8ac38a27`: Build run [#38124942112](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38124942112) completed SUCCESS. Job evidence: Analyze, test-0 through test-5, Debug APK and Release APK all succeeded.
- Device Smoke [#38124941815](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38124941815) is not complete: Home and Quick Capture passed; SQL Migration and SQL Persistence in progress; Backup/Restore and People queued at last check.
- PR #2585 remains OPEN / NOT MERGED. Physical Android system file-picker/provider acceptance remains unverified.
