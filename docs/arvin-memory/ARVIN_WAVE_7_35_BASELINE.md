# ARVIN Wave 7.35 — Live Baseline and Corrective Work
**Date:** 2026-10-25  
**Repository:** `mobinpda-lab/Arvin-clean`  
**Work branch:** `fix/wave-7-34-reminder-calendar-unification`  
**Execution PR:** #2973 (Draft; not merged)  
**Release:** `BLOCKED — RELEASE: NO-GO`

## Exact evidence baseline
- Last observed work-branch SHA before Wave 7.35 edits: `42e809e4ebb62a8c244dc148a7a94a9e73277ef8`.
- The base SHA recorded in PR #2973 and related decision PRs is `18cbeecc95a03a3b301359ca5b96cfef175a3b15`; the live `main` ref SHA was not independently resolved in this pass and remains `NOT VERIFIED`.
- Build run: https://github.com/mobinpda-lab/Arvin-clean/actions/runs/40158342715 — FAIL.
- Device Smoke run: https://github.com/mobinpda-lab/Arvin-clean/actions/runs/40158342695 — Home and Quick Capture FAIL; SQL persistence and migration PASS; Calendar had no terminal result at inspection time.
- Calendar Provider Acceptance: https://github.com/mobinpda-lab/Arvin-clean/actions/runs/40158342822 — FAIL.
- Confirmed compile error: two non-exhaustive switches in `lib/task_timeline_page.dart` after adding `TaskTimelineEntryKind.due`.
- Confirmed stale acceptance fixture: `integration_test/calendar_card_interaction_test.dart` still seeded legacy FollowUp and expected a FollowUp card despite the canonical TaskReminder contract.
- Confirmed stale test expectations: release-critical-path expected a historical FollowUp to enable retired scheduling; task-list scope test treated retired legacy schedule fields as active behavior.
- Confirmed typography conflict: active theme/assets/PDF paths and workflow steps still selected/downloaded VazirHarf, while the owner now explicitly requires Vazirmatn.

## Wave 7.35 corrective scope
- Exhaustively render the Task due-date timeline entry.
- Replace the Calendar integration fixture with a canonical TaskReminder identity and verify editor cancel leaves SQLite unchanged.
- Align release-critical-path and list-scope assertions with Reminder-only scheduling while preserving historical FollowUp data.
- Pin official Vazirmatn v33.003 source revision `83629f877e8f084cc07b47030b5d3a0ff06c76ec`; bundle Regular, Medium, SemiBold and Bold TTFs at build time and retain the SIL Open Font License.
- Make Vazirmatn the only active app font and use it in the global theme, Calendar and PDF.
- Update active UI/settings typography references; preserve older decisions as history without treating them as current authority.

## Acceptance boundary
No direct-main update, PR merge, owner database mutation, owner Backup mutation or production data deletion is authorized. A commit is not proof of success. Exact-head Analyze, all test shards, Debug/Release APK, signature/package inspection, Device Smoke, Calendar Provider Acceptance, PDF/RTL checks, and physical-device acceptance must finish before any release claim. Owner acceptance is still required.
