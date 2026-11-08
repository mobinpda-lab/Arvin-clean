# Arvin — Focus / My Day and Home UX Product Contract
**Status:** APPROVED PRODUCT CONTRACT / IMPLEMENTATION NOT YET VERIFIED
**Owner directive date:** 2026-11-08
**Repository:** mobinpda-lab/Arvin-clean
**Authorized branch:** fix/recovery-calendar-device-smoke-2026-10-31
**PR:** #3052 — must remain OPEN / DRAFT / UNMERGED
**Release:** BLOCKED — RELEASE: NO-GO

This contract records the owner's cumulative directive. It supersedes older wording wherever older documents treat “کار امروز” as the manually curated Focus list. It does not claim that any listed behavior is already implemented.

## 1. Governance and baseline
- GitHub is the sole source of truth.
- All changes belong only on the authorized branch. Do not edit `main`, merge PR #3052, publish, or release.
- Do not delete, skip, weaken, or rewrite an assertion merely to make CI green.
- Owner states the app database is empty and schema changes are permitted without a heavy user-data migration. Verify actual repository/database initialization assumptions before destructive DDL; retain transactional schema safety and tests.
- Baseline audited before this contract was recorded: PR #3052 HEAD `2eb76c3e0d20e0330bda7793a10944f37feb02c5`. Every test/build result must be attributed to the exact SHA it ran against.

## 2. Canonical semantics: System Today vs Focus / My Day
These are separate concepts and must never share a predicate or persisted state.

### System Today
A derived calendar view:
- Open Tasks whose local calendar due date is today; and
- Open overdue Tasks whose local due date is before today.
- Completed Tasks are excluded from overdue precedence.
- A due date is not a Focus membership marker.

### Focus / “کارهای برگزیده امروز”
A user-curated, local-day membership:
- A Task may be explicitly added to today's Focus list independently of dueDate.
- Membership is scoped to the user's current local calendar date and must not roll forward automatically.
- At the next local day, yesterday's selection is no longer today's Focus. No automatic carry-forward or accumulation.
- A Task can simultaneously be due today and selected for Focus.
- Focus filtering returns only Tasks explicitly selected for the current local day, subject to the app's normal visibility exclusions (e.g. trash/archive/completed) as specified by the canonical list contract.

Suggested canonical representation: nullable date-only `focusDate` (YYYY-MM-DD in the user's local calendar) on Task, or an equivalent single canonical field with identical semantics. Do not add a second focus store or duplicate state. Serialization, deserialization, copy/update, backup/restore, SQL schema, and all canonical Task mutation pathways must agree. Decide whether completed/archived Tasks retain historical focusDate or clear it only with explicit product reasoning; never silently destroy unrelated Task data.

## 3. Swipe actions
- Add “کارهای برگزیده امروز” to both independent Task swipe action choices (left and right).
- Executing the configured swipe toggles membership for the current local day: set today's focusDate when absent/stale; clear it when already set to today.
- Preserve the existing independent left/right settings, all other actions, and current defaults when Focus is not selected.
- Provide immediate accessible visual feedback and haptic feedback where supported; unsupported haptics must not break the action.
- The toggle must persist through the canonical TaskStore path and must not alter dueDate, reminders, recurrence, completion, project, center, or follow-up history.

## 4. General filter menu
Rename the old “کار امروز” item to “کارهای برگزیده امروز” and use this exact order:
1. امروز (system calendar view: due today plus overdue open work)
2. کارهای برگزیده امروز (manual Focus for current local date only)
3. فاقد زمان
4. بایگانی
5. سطل زباله
6. پیگیری‌دار
7. بدون پیگیری
8. انجام‌شده
9. انجام‌نشده
10. Eisenhower matrix quadrants: فوری-مهم، غیرفوری-مهم، فوری-غیرمهم، غیرفوری-غیرمهم.

Focus is an exclusive membership predicate, not a dueDate shortcut. “Today” is a derived due-date predicate. Do not conflate either with move-to-today.

## 5. Home task cards
- Remove textual center, project, and tag previews from Home task cards.
- Retain Task title and category name.
- Show Eisenhower priority as a small colored dot beside category.
- Show task date centered and bold.
- Show a subtle filled-star/focus marker only when focusDate matches the current local date.
- Tapping any non-action area of the card opens only Task Details. Explicit controls, if any, must have their own hit targets and must not cause accidental navigation.
- Preserve accessibility semantics and minimum touch targets.

## 6. Five compact filters and Home header
- RTL order: Time, Center, Project, Category, Tag.
- Compact colored icons only; no visible filter title text. Display selected-count badges.
- Every target is at least 48dp.
- All five open the reusable multi-select bottom sheet from the bottom; checkbox selection uses OR within a dimension, AND across dimensions.
- Inline creation must save and select the new taxonomy value immediately.
- Time filter includes Overdue (“گذشته”) with precedence over Completed.
- Keep sort control ergonomically adjacent.
- Center the search field beneath the subtitle; remove redundant standalone search icon.
- Bring “آروین” closer to the Bismillah vector for visual balance.
- Pin the hamburger navigation drawer to the upper-left corner.

## 7. Visual and system contracts
- Vazirmatn is the global UI font.
- The exact phrases “بسم‌الله الرحمن الرحیم” and “وَأُفَوِّضُ أَمْرِي إِلَى اللَّهِ” are independent SVG vectors.
- Default accent: sky blue #3A86EF. Settings expose a stable nine-color palette; navy and dark-purple options remain excluded.
- Calendar integration has three layers: internal, local Arvin calendar with ACCOUNT_TYPE_LOCAL, and external.
- Quick Capture stays compact, without description/checklist fields.
- Date selection is followed by a round time picker dialog with a “بدون ساعت” action inside that dialog.
- Reminder All-Day contract must be consistent across UI/model/storage/provider.
- Person identity and links remain canonical and consistent across create, edit, follow-up, and reports.

## 8. Acceptance tests — no test weakening
### Focus model and local date
- Focus is independent of dueDate (no due date, future due date, overdue due date, and today's due date).
- Focus and due-today may overlap.
- Focus is true only when focusDate equals the current local date.
- Advancing the local date expires yesterday's Focus without mutating dueDate or other Task data.
- UTC/time-zone boundary tests prove date-only local semantics.
- JSON/SQL round-trip, backup/restore, copy/update, and repository persistence preserve focusDate.

### Swipe
- Both directions can be configured independently to Focus.
- Toggle adds/removes current-day membership and persists after reload.
- Existing swipe actions/defaults remain unchanged when Focus is not selected.
- No unrelated Task fields are modified.
- Feedback and touch-target behavior are tested where testable.

### Filters and cards
- Exact menu wording/order.
- System Today and Focus return different expected fixtures.
- OR within each multi-select filter and AND between filters.
- No center/project/tag text previews; category, priority dot, centered date and conditional focus marker are present.
- Card tap navigates to Task Details only.
- RTL layout is tested at 360dp, 390dp, and 412dp; no overflow/overlap/render exception.
- Each actionable control meets 48dp.

### Build/device
- Analyze, all test shards, visual/UI tests, Debug/Release/Staging builds and relevant Provider/SQLite workflows must pass on one exact candidate SHA.
- Physical-device acceptance on Samsung Galaxy A52s 5G, SM-A528B/DS, remains mandatory before release. Emulator success is not physical-device acceptance.

## 9. Initial live audit findings (HEAD 2eb76c3e0d20e0330bda7793a10944f37feb02c5)
- No `focusDate` occurrence was found by the focused repository code search; the Task model excerpt inspected does not declare a Focus field.
- Existing Task swipe enum contains archive, trash, moveToToday, complete, convertToFollowUp and none; no Focus action was present in the inspected enum.
- Existing Home today projection is a Follow-up projection, not the new Focus predicate.
- CI at this SHA: Build run 42466477910 failed (Analyze succeeded; multiple test shards and APK jobs failed). One test failure was a missing CheckboxListTile finder; another was an expected reminder count mismatch. Debug build failed on a downloaded sqlite3 native asset hash mismatch; Release build failed on an upstream Kotlin artifact HTTP 504.
- Draft Review APK run 42466477906 failed while resolving Kotlin compiler artifact (HTTP 504).
- Calendar Provider run 42466477831 failed; its uploaded evidence artifact is diagnostic-only and does not establish Provider acceptance.
- Device Smoke run 42466477992 had Boot fail and Navigation still running at the audit checkpoint; remaining lanes were queued. No physical-device result was established.
- These are observed results for this exact SHA only. They are not evidence about later commits.

## 10. Required execution order
1. Confirm branch HEAD and PR governance immediately before each write.
2. Implement Task focusDate through the canonical Task/model/store/schema/backup path and tests.
3. Implement swipe settings/action execution and feedback with regression tests.
4. Implement general menu semantics/order and time/overdue behavior.
5. Implement card presentation/navigation and five-filter/header layout.
6. Implement/verify visual/system contracts and Person integration without parallel storage.
7. Run focused tests, full CI, staging build, artifact hash/size capture, then physical SM-A528B/DS acceptance.
8. Record changed-file list, exact SHA, test evidence, APK metadata/link, and device evidence in continuity docs.
9. Keep PR OPEN / DRAFT / UNMERGED and release NO-GO until all gates and owner acceptance are satisfied.

**Current status of this document:** product contract recorded; implementation, test acceptance, staging artifact and physical-device acceptance remain NOT VERIFIED.
