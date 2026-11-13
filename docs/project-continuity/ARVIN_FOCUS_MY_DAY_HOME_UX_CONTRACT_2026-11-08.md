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
- Home header uses `assets/images/branding/bismillah.svg` for «بسم‌الله الرحمن الرحیم», centered above the product name «آروین». The Home header must not use `tafweez.svg` or the phrase «وَأُفَوِّضُ أَمْرِي إِلَى اللَّهِ».
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

## 11. Additional owner decisions — filters, Follow-ups, and visual reference (2026-11-08)

These decisions supplement the Home UX contract and are product requirements, not evidence of implementation.

### 11.1 Primary filter row and independent filter icon
- Preserve the five primary filters in this exact right-to-left order: **زمان، مرکز، پروژه، دسته‌بندی، برچسب**.
- Preserve the separate filter icon at the upper-left area of the Home screen. It is an independent filter affordance and must not be removed or conflated with search or the navigation menu.

### 11.2 Follow-up time filtering
- The Follow-up filter must be available both on the Home screen and in Reports.
- Its date choices must include **امروز**, **دیروز**, and **محدودهٔ تاریخی دلخواه**.
- Filtering is based on the Follow-up record's own recorded/created timestamp. It must not use the linked Task's due date or task scheduling date as a substitute.
- Date-range boundaries must follow the app's local-calendar semantics consistently in Home and Reports.

### 11.3 Follow-ups as a core product capability
- Follow-ups and Follow-up reports are core Arvin capabilities, not secondary or optional metadata.
- Product design must cover Follow-up capture and history in Task Details, and provide coherent Follow-up reporting in the Reports area.
- Home filtering, Task Details history, and Reports must refer to the same canonical Follow-up records and timestamp semantics; do not create parallel or derived duplicate histories.

### 11.4 Protected visual-reference detail
- Preserve the line/detail at the **upper-right corner** of the approved visual reference.
- Do not remove or redesign that detail as part of Home/header/filter redesign unless a later explicit product-owner decision supersedes this requirement.

**Acceptance note:** This section records product decisions only. It does not assert that the UI, filter behavior, data model, or reports have been implemented or tested. No tests may be deleted, skipped, weakened, or bypassed to satisfy these requirements.

## 12. Final owner-approved funnel, card, Person, and Follow-up Hero contract — 2026-11-08

This section consolidates the final Home funnel and the connected Task Details / Follow-up / Person decisions. It is authoritative where older Home notes describe a different menu or card presentation. It is a product contract only; it does not assert implementation or test acceptance.

### 12.1 Separate global funnel from the five quick filters

- Keep the **global funnel/filter icon** as an independent control at the physical upper-left of the Home screen. It opens the general 13-item filter menu below; it is not one of the five quick filters, not search, and not sort.
- Preserve the separate five-filter quick row in exact RTL order: **زمان، مرکز، پروژه، دسته، برچسب**. Keep it as one compact row, with no «همه» chip and no horizontal scrolling; each actionable target is at least 48dp.
- The quick-filter row and global funnel serve different scopes and must not be merged or substituted for one another.
- Keep the approved line/detail at the upper-right corner of the visual reference unchanged; do not delete, simplify away, or redesign it.

### 12.2 Exact 13-item global funnel menu

The general funnel menu contains exactly these 13 items in this order:

1. **امروز** — system calendar view: open Tasks due today plus overdue open Tasks, using the canonical local due-date/overdue rules.
2. **کارهای برگزیده امروز** — manually selected Focus membership for the current local day only; independent of dueDate and not carried forward to the next day.
3. **فاقد زمان** — Tasks without a canonical due date/time.
4. **بایگانی** — archived Tasks.
5. **سطل زباله** — trashed Tasks.
6. **پیگیری‌دار** — Tasks with at least one persisted, canonical historical Follow-up record linked to that Task.
7. **بدون پیگیری** — Tasks with no persisted canonical historical Follow-up record linked to that Task.
8. **انجام‌شده** — completed Tasks.
9. **انجام‌نشده** — incomplete Tasks.
10. **فوری-مهم** — Eisenhower urgent + important.
11. **غیرفوری-مهم** — Eisenhower not urgent + important.
12. **فوری-غیرمهم** — Eisenhower urgent + not important.
13. **غیرفوری-غیرمهم** — Eisenhower not urgent + not important.

**Canonical «پیگیری‌دار» predicate:**
- A Task is Follow-up-bearing if and only if one or more real, persisted historical Follow-up records are linked to it.
- The predicate is based on the existence of historical Follow-up records, not on Task dueDate, Reminder date, legacy followUpEnabled / followUpDate, a future Next Follow-up value, or a merely enabled UI toggle.
- A TaskReminder does not count as a Follow-up. A future reminder remains a Reminder, not a Follow-up.
- «بدون پیگیری» is the inverse of that same canonical record-existence predicate.
- When the Follow-up date filter is also applied, the matching record must additionally fall within the selected local-calendar date interval; use the Follow-up record's canonical timestamp, never the Task due date.
- Follow-up records are historical only. Future scheduling belongs to independent TaskReminder records; do not create or revive Next Follow-up scheduling state.

### 12.3 Shared multi-select and cross-filter semantics

- Reuse ReusableMultiSelectFilterBottomSheet wherever the relevant filter dimension is available.
- Checkbox multi-select: **OR** among selected values inside one dimension; **AND** between different dimensions.
- Inline creation saves the new taxonomy/person value through its canonical boundary and selects it immediately.
- Active selection-count badges belong to the filter controls; this does not authorize decorative status/follow-up badges on Task cards.
- The five quick filters remain Time, Center, Project, Category, Tag. Sort remains a separate control and is not a sixth filter.
- Follow-up time filtering is available on Home and Reports with **امروز، دیروز، محدودهٔ تاریخی دلخواه**. Its source is the Follow-up record's canonical historical timestamp (FollowUp.dateTime; completedAt is only a compatibility alias where applicable), with consistent local-calendar half-open date boundaries.

### 12.4 Task cards and badge removal

- Remove decorative status/follow-up badges from Home Task cards. Do not show a redundant badge stack or duplicate status metadata on the card.
- Home cards retain the Task title, category, the compact Eisenhower priority dot, centered bold task date, and the subtle Focus marker only when Focus membership is true for the current local day.
- Do not restore textual Center, Project, or Tag previews on Home cards.
- A non-action tap anywhere on the card opens Task Details only; independent controls retain separate hit targets.
- In Task Details, remove the redundant status/follow-up badge from the top summary area. The canonical identity section remains the place for the actual Task status and priority; this decision removes duplication, not the underlying status/priority data.
- Do not remove selected-count badges from filter controls or count badges from collapsible time-group headings; those are separate navigation/grouping affordances, not Task-card status badges.

### 12.5 Unified Person Entity contract

- Person is one canonical entity/directory with stable persistent IDs; do not create screen-specific people lists or parallel person stores.
- Task/person links and Follow-up/person links must use canonical persisted relationships. Follow-up links retain stable IDs (the canonical FollowUp.personIds relation); the directory owns the Person records.
- Enabling **«منتظر پیگیری دیگران»** immediately exposes the associated Person selector in that flow. The user can select an existing Person or create a new Person; creation merges into the canonical people directory and the selected stable ID is linked to the Follow-up.
- Editing a Follow-up restores its previously linked people. Removing a person link removes the relation, not the canonical Person record. If a linked Person was deleted, preserve a truthful historical deleted-person representation rather than silently attaching a different Person.
- The Reports Person filter must include Tasks and historical Follow-up records linked to the selected canonical Person.
- A linked/related Person must not automatically be labelled as the Task's مسئول. Show a responsible person only where a real canonical assignee/assignment relationship exists; never infer an assignee from Task.people or FollowUp.personIds.

### 12.6 Follow-up Hero box and historical timeline

- Task Details contains a visually prominent **آخرین پیگیری** Hero card, distinct from ordinary metadata cards.
- The Hero card projects the latest persisted historical Follow-up record and displays its action/title, note/result, actual Follow-up timestamp, applicable «در انتظار پاسخ» state, and elapsed time calculated dynamically from that record's canonical timestamp.
- The elapsed-time value must be derived from FollowUp.dateTime; do not substitute page-open time, edit time, Task.updatedAt, or an unrelated creation timestamp.
- If no historical Follow-up exists, show the explicit empty state: **«هنوز پیگیری ثبت نشده است»**.
- Beneath/alongside the Hero summary, preserve the vertical Follow-up history timeline, newest first by canonical Follow-up timestamp. Each record remains independently viewable/editable/deletable according to the existing canonical history contract; editing one record must not rewrite another record's timestamp or content.
- Adding a Follow-up is an explicit historical-record action and only persists after Save. It must not schedule future work or mutate Task dueDate, recurrence, or independent TaskReminder entries.

### 12.7 Exact implementation and acceptance boundary

- UI, filters, data relationships, reports, and interactions must match this contract exactly; no divergent screen-specific interpretation or parallel model/store is permitted.
- Preserve all existing tests and assertions. No test may be deleted, skipped, weakened, bypassed, or made artificially permissive. Add/adjust coverage only to assert the approved behavior.
- This update is documentation-only. No application source, model, schema, migration, test, workflow, APK, or release setting is changed by recording this contract.
- PR #3052 must remain **OPEN / DRAFT / UNMERGED** and **BLOCKED**. Do not edit main, merge, publish, or release. Release remains **BLOCKED — RELEASE: NO-GO**.

