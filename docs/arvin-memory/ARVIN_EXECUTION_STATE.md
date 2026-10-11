# Arvin Execution State

Updated: 2026-10-11 (fast-path live recheck)
Repository: https://github.com/mobinpda-lab/Arvin-clean
GitHub access: Read/Write
Authority: live GitHub refs, code, tests and exact-head workflow evidence.

## Current release state
**IN PROGRESS — RELEASE BLOCKED.**

## Current GitHub reality
- The main branch moved since the previous checkpoint. The current fetched blob for `lib/calendar_page.dart` is `bca61696309f809dc9640da001fe45aabc262a65`; re-read branch ref before any code merge.
- Backup/restore [PR #2585](https://github.com/mobinpda-lab/Arvin-clean/pull/2585): OPEN / NOT MERGED; exact code head recorded earlier as `05c080e706690dd3eb6a96fc5c070971a43d1354`.
- Memory [PR #2600](https://github.com/mobinpda-lab/Arvin-clean/pull/2600): OPEN / DRAFT. Current execution/evidence memory branch has recent evidence updates; check exact branch head and docs PR checks before merge.
- Calendar actions [PR #2587](https://github.com/mobinpda-lab/Arvin-clean/pull/2587): OPEN / NOT MERGED. Latest validated head recorded in PR comments: `4442ce450e4295e500a9db6d5dc5b4d9657b3770`.
- Calendar Build [#38089112669](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38089112669): SUCCESS on `4442ce4`; Analyze, six test shards, Debug APK and Release APK succeeded.
- Calendar Device Smoke [#38089112675](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38089112675): all six lanes succeeded on `4442ce4` (Home, Quick Capture, SQL Migration, SQL Persistence, People, Backup/Restore).
- Restore Build [#38123874036](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38123874036): successful on `05c080e`.
- Restore Device Smoke [#38123874041](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38123874041): Home, Quick Capture, SQL migration, SQL persistence and People now succeeded; Backup/Restore was still in progress at the latest query. Recheck before reporting final status.
- A merge attempt for PR #2587 with stale expected head `e416f48` was rejected by GitHub because the PR head had changed. No merge occurred. Do not retry until current head and acceptance requirements are rechecked.
- Green automation/emulator runs are not physical-device acceptance or release approval.

## Completed in this execution
- Re-read the saved execution state and evidence map before proceeding.
- Rechecked open PRs, P0 Calendar issue #2535, restore issue #2584, and latest exact-head workflow jobs.
- Reconfirmed Calendar primary action visibility root cause in current main: action chips are inside the expanded-only card section.
- Revalidated PR #2587 latest recorded head `4442ce4`: all Analyze/test/APK jobs and all six smoke lanes passed.
- Attempted a guarded merge using the older known head; GitHub rejected it because the head changed. No code was merged.
- The seven-occurrence regression test is present in commit `4442ce450e4295e500a9db6d5dc5b4d9657b3770`; its test asserts the eighth scheduled date is absent while retaining a separate later-occurrence navigation test.
- Do not merge PR #2587 yet: its own acceptance notes explicitly require physical-device proof for same-event edit/sync/no-duplicate, recurrence/checklist behavior, link recovery after restore, visual review and owner acceptance.

## In Progress
- Recheck Restore Device Smoke #38123874041 until Backup/Restore finishes.
- Review PR #2585 current head/diff/checks and retain legacy backup compatibility and canonical Task/Project/Calendar-link/settings/history data.
- Keep PR #2587 ready for merge but open until physical-device acceptance and product-owner gate are satisfied.
- Trace recurrence projection/count contract for issue #2535; automated tests now cover seven-occurrence limit and later occurrence navigation, but installed-device behavior remains unproven.
- Continue taxonomy audit #2580 and restore acceptance #2584.

## Blocked / unproven
- No physical Android device + actual system file-picker/provider backup/restore evidence.
- No verified physical-device Calendar external-event identity/no-duplicate test after restore.
- No full Golden Flow evidence.
- PR #2585 and PR #2587 remain open/unmerged.
- Release remains blocked despite successful builds, tests, APKs and emulator lanes.

## Next Action — dependency-ordered checklist

### A. CI and restore PR #2585
- [ ] Recheck all six jobs in Android Device Smoke #38123874041; record final Backup/Restore result.
- [ ] If Backup/Restore fails, inspect its job logs and implement the smallest safe fix with regression coverage.
- [ ] Review PR #2585 exact head, complete diff, mergeability and required checks. Do not merge before critical data-safety gates.

### B. Calendar P0 #2535 / PR #2587
- [ ] Re-fetch current PR head because the stale-head merge attempt was rejected.
- [ ] Verify exact-head Build and all six Smoke jobs remain green for the current head.
- [ ] On a real installed Android build verify Edit, phone-calendar register/edit, scheduled recurrence dates through seven occurrences, Checklist behavior, and no duplicate Task/event.
- [ ] Verify same linked external event is updated, not recreated; verify Calendar Link recovery after restore.
- [ ] Attach device evidence to #2535; merge/close only after acceptance.

### C. Physical acceptance and handover
- [ ] Use the real Android system file picker/provider for backup/restore.
- [ ] Verify Task, Category/Tag, Repeat, History and Calendar Link across successful and failed restore.
- [ ] Complete Golden Flow: Task → time → Project → Checklist → Repeat → Tracking → Calendar → Backup → Restore.
- [ ] Complete Release Notes, Installation Guide, User Guide, Known Issues, Architecture Summary and Evidence Report.

## Current bottleneck
Physical-device acceptance, plus final Restore Device Smoke completion for PR #2585.

## Risk rules
Task remains the only source of truth; Calendar is a projection; Repeat must not create copied Tasks; preserve stable Task ID and external event ID. No merge/release based on CI alone. Do not claim user/device acceptance without direct evidence.
