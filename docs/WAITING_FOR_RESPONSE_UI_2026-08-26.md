## 2026-10-13 — Navigation and active-task filter repair (Issue #2677)

- Added «دفتر پیگیری» to Home > «بیشتر» and connected it to the existing FollowUpOfficePage; users can now reach the already-implemented «فقط منتظر پاسخ» filter.
- The waiting-only filter now excludes completed, archived, and trashed Tasks, matching the existing WaitingForResponseService contract.
- Widget regression coverage checks both the navigation route and exclusion of inactive Tasks. Exact-head CI remains pending until the final branch SHA is validated.

---

## 2026-10-13 — Discoverability repair (Issue #2677)

- Root cause: `FollowUpOfficePage` and its `فقط منتظر پاسخ` filter already existed, but `lib/main.dart` never imported or navigated to the page. Users could enable «منتظر پاسخ دیگران» without a discoverable route to the list.
- Change on branch `fix/follow-up-waiting-response-discoverability-20261013`: add «دفتر پیگیری» to Home's primary «بیشتر» sheet and route it to the existing FollowUpOfficePage. No new data model, repository, storage or status field.
- Regression coverage added in `test/home_more_my_tasks_test.dart` for menu discoverability, navigation, and the waiting-filter control.
- Status: implementation committed to the branch; exact-head CI not yet run. Do not mark validated until Analyze, targeted tests, full Build and required acceptance finish.

---

# Waiting for Response — user-facing flow — 2026-08-26

## Scope
This slice advances the merged Waiting for Response contract from core stage to a real user-facing Follow-up Office flow.

## What changed
- `FollowUpEntryPage` exposes a Persian `منتظر پاسخ دیگران` switch.
- When enabled, save persists the existing canonical `waiting_for_response` token through the current FollowUp repository path.
- Existing waiting entries open with the switch enabled; disabling it allows a normal result to replace the waiting state without creating another FollowUp.
- `FollowUpOfficePage` adds a `فقط منتظر پاسخ` filter.
- The filter evaluates only each task's latest FollowUp result, so an older waiting result does not keep a task waiting after a newer resolved FollowUp exists.
- Waiting rows display a Persian `منتظر پاسخ` chip instead of exposing the internal canonical token.

## Persistence boundary
No new persistence path was created. Add/edit continues through `FollowUpRepository`, and the waiting state remains in the existing `FollowUp.result` field defined by the merged contract.

## Regression coverage
Widget tests verify:
1. UI switch → canonical token persistence.
2. Waiting result is shown as a user-friendly chip.
3. Waiting-only filter uses the latest FollowUp for each task.
4. A task with an old waiting result and a newer resolved result is excluded.
5. Editing an existing waiting FollowUp preserves stable identity and can clear waiting state into a normal result.

## Progress impact
After this slice is merged and exact-head validation is green, the official scorecard can promote roadmap feature #10 from stage 40 (core) to stage 70 (real UI wired to canonical persistence). Stage 85 still requires release/post-merge validation evidence under the official metric.

## Guardrails
- No new Task status field.
- No new database/storage/repository.
- No parallel CRM model.
- `FollowUps[]` remains the source of truth.
