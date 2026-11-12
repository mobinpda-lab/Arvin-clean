## REV8 post-audit live refresh — 2026-11-10 11:10 UTC

This addendum supersedes earlier pre-refresh snapshot values; historical values remain preserved.
- Main HEAD: `45e4202b03a434459e4c021a04efa7e8396359db` (protected=true).
- Authorized branch / PR #3052 HEAD: `a934cabebc814aea13c1800ab151821d12714226`; parent `9846f10850031c63964fdc81ae0ab1cdb3028517`.
- PR #3052 remains OPEN / DRAFT / UNMERGED; 2,131 ahead / 0 behind; 380 changed files; 0 reviews.
- Build `42801502260` on a934: FAILURE, 1,296 passed / 78 failed. Device Smoke `42801502310`: PENDING. Calendar Provider `42801502275` and Follow-up Persistence `42801502256`: SUCCESS.
- a934 is a documentation-only commit affecting 20 files under docs/project-continuity; source/test/schema/migration/workflow trees are unchanged.
- Current tree: 1,412 branches; 1,812 Main commits; 302 test files; 25 working workflows; docs/ 271 files (266 Markdown); project-continuity 45 files.
- Release remains BLOCKED — RELEASE: NO-GO. Main remains READ-ONLY; no destructive actions authorized.

---

# ARVIN MASTER GOVERNANCE — REV8

Authority: Mobin — Product Owner & Product Director
Repository: mobinpda-lab/Arvin-clean
Main SHA: 45e4202b03a434459e4c021a04efa7e8396359db
Authorized branch: fix/recovery-calendar-device-smoke-2026-10-31
Working HEAD before REV8 docs commit: 9846f10850031c63964fdc81ae0ab1cdb3028517
PR #3052: OPEN / DRAFT / UNMERGED
Release: BLOCKED — RELEASE: NO-GO

## REV8 authority and reconciliation addendum

REV8 supersedes REV7.2 wherever their current-state snapshots or cleanup inventories differ. REV7.2 content below is preserved as historical governance evidence. Live GitHub repository, exact branch HEAD, code/schema/migrations/tests/workflows and exact-SHA Actions evidence remain operational truth.

- Main is READ-ONLY. No merge, release, force-push, rebase, history rewrite, branch/PR deletion, test deletion, migration/table deletion, workflow deletion or security-ruleset change is authorized by this audit.
- REV8 authorizes non-destructive documentation reconciliation on the authorized working branch. Technical changes remain subject to a separate valid implementation authorization.
- Branch inventory: 1,412 branches; only main is protected in the observed branch API result. The authorized working branch is unprotected.
- PR inventory: 1,238 records; 100 open, 1,138 closed. PR #3052 remains OPEN / DRAFT / UNMERGED.
- Current Build 42795405617 on SHA 9846f108... failed with 78 distinct test labels. Device Smoke 42795405388 is pending. Calendar Provider and Follow-up Persistence passed on the same SHA.
- All 12 REV8 audit deliverables are stored under docs/project-continuity/audit/ and indexed by README.md.
- Do not call branches without open PRs stale/abandoned without last-commit-date and dependency evidence. Do not classify repeated subjects or identical trees as duplicate commits without patch/parent review.
- Release remains BLOCKED — RELEASE: NO-GO.

---

## Historical REV7.2 governance text (preserved)


**Authority:** Mobin — Product Owner & Product Director  
**Repository:** mobinpda-lab/Arvin-clean  
**Related repository:** mobinpda-lab/NIRA  
**Historical PR:** #3052  
**Authorized working branch:** fix/recovery-calendar-device-smoke-2026-10-31  
**Execution baseline SHA:** b789343c9699ca440d043d71d47db3dcdfafa57c  
**Main SHA:** 45e4202b03a434459e4c021a04efa7e8396359db  
**Canonical path:** docs/project-continuity/  
**Release:** BLOCKED — RELEASE: NO-GO

## 1. Authority and Source of Truth

This document is the canonical governance source for Arvin. The operational truth is the live GitHub repository, the exact current working-branch commit, the canonical continuity documents, actual source/schema/migrations/tests/workflows and GitHub Actions evidence tied to the exact SHA. The historical Source ZIP is archive-only. It is not a prerequisite for audit, decision-making, documentation or execution. Never request or wait for it as a gate. Preserve its historical provenance without using its old hash to judge live code.

If evidence conflicts, prefer the live repository and the latest explicit Mobin decision. Historical notes remain historical; do not silently erase or rewrite them.

## 2. Execution Permissions and Guardrails

REV7.2 authorizes reading the repository, branches, PR, workflows and files; creating/updating the eight canonical documentation files; synchronizing continuity documents; recording approved decisions; creating one documentation-only commit; and pushing it to the authorized working branch. No further confirmation is required for those documentation actions.

This order does not authorize changes to executable source, tests, schemas, migrations, workflows, security settings, PR metadata, merge, release or Main. Main is read-only. PR #3052 remains OPEN / DRAFT / UNMERGED. No force push or history rewrite. Only the eight canonical documentation paths may be included in this governance commit. Before moving the branch ref, re-read its head and use an expected-SHA lease. If the branch has moved, stop and reconcile; never overwrite another actor's commit.

GitHub API cannot prove the local uncommitted working tree. Report local state as NOT VERIFIED unless an actual local workspace is available.

## 3. Historical REV7.2 Repository Baseline — 2026-11-10 (superseded by REV8)

- Main HEAD: 45e4202b03a434459e4c021a04efa7e8396359db.
- Authorized branch HEAD: b789343c9699ca440d043d71d47db3dcdfafa57c.
- PR #3052: OPEN, DRAFT, UNMERGED; base main; head branch is the authorized branch; base SHA equals Main; head SHA equals branch HEAD.
- Compare: 2,129 commits ahead, 0 behind.
- Existing PR changed files: 367 total; 61 docs files; 32 under docs/project-continuity. These are existing PR changes, not the REV7.2 docs commit.
- Active Main ruleset: main-protection; deletion and non-fast-forward blocked; PR-based update required. Ruleset reports zero required approving reviews. This does not replace product-owner acceptance.
- The canonical directory currently has seven of the eight required files. MASTER_GOVERNANCE.md is missing. MASTER_CHARTER.md is also absent at the checked path; no charter content was available to migrate. PRODUCT_DECISIONS, CURRENT_STATE, ROADMAP, OPEN_ISSUES, IMPLEMENTATION_LOG, HANDOFF and README exist but their checkpoints are stale relative to 10 November.

## 4. Canonical Document Set

1. MASTER_GOVERNANCE.md — this document; sole governance authority.
2. PRODUCT_DECISIONS.md — date-stamped owner decisions with Decision IDs and three-axis status.
3. CURRENT_STATE.md — exact repository/branch/SHA/CI/product checkpoint.
4. ROADMAP.md — Wave 0 through Wave 5 with dependencies and acceptance criteria.
5. OPEN_ISSUES.md — verified gaps, CI failures and decisions required.
6. IMPLEMENTATION_LOG.md — chronological implementation and evidence record.
7. HANDOFF.md — next agent's first actions and safety constraints.
8. README.md — entry point and document navigation.

Retain prior history in each existing document. Do not create parallel continuity documents or duplicate changelogs. If MASTER_CHARTER.md appears in a future branch, preserve its useful history and redirect it to this master; do not delete it without controlled migration.

## 5. Status Contract

Each feature must have three independent statuses:

- Product Approval: APPROVED or SUPERSEDED.
- Implementation: IMPLEMENTED, PARTIAL, MISSING or BLOCKED.
- Verification: VERIFIED, PARTIAL or NOT VERIFIED.

A file/class is not verification. VERIFIED requires reproducible acceptance evidence on the exact SHA and all relevant acceptance gates. A PASS on an older SHA never transfers. A workflow that fails before executing tests is an infrastructure/execution failure, not proof of a product defect. A test assertion failure is evidence of a failing contract, but not automatically proof of root cause.

## 6. Product and Design Authority

### 6.1 Product hierarchy and task semantics

The product hierarchy is Center → Project → Category → Task. Center, Project and Category are single-select; Tags are multi-select. Quick Capture must allow saving without selecting Center, Project or Category. The Inbox behavior for unclassified work must be explicit and must not create a parallel Task store. Task due date, independent TaskReminder, recurrence and historical Follow-up are separate concepts. Follow-up history must never replace Task due date.

### 6.2 Reminder

The owner requires a four-state Reminder model. The reviewed TaskReminder class currently exposes isEnabled and isAllDay booleans; this does not define four domain states or their transitions. Do not invent names or semantics. Record the gap and request the missing state-transition contract before implementation. Keep reminder time/date independent from Task due date and historical Follow-up.

### 6.3 Home, filters and capture

The universal filter order is Time → Center → Project → Category → Tag. Values within a dimension use OR; different dimensions use AND. Inline creation must auto-select the newly created value. Show selected counts. All interactive targets must be at least 48dp. Acceptance widths are 360, 390 and 412dp. Home must distinguish overdue, today, tomorrow, future and no-date work; completed work must not become overdue. Sorting must expose approved alphabetical, date, priority, oldest/newest and reverse directions. Quick Capture is minimal, classification-optional and writes through canonical TaskStore.

### 6.4 Notebook and templates

Notebook notes and checklists must remain independent from Task deletion and project unlinking. Conversion to Task must preserve the original text. Generate a title from the first content line only on first save when no user title exists; never overwrite a later user title. Task Template deep copy includes title, unchecked checklist definition, priority, tags, category, project, center and default people; it excludes Follow-up history, change logs and prior checked state. New occurrence dates must be based on the chosen new start date. Any unimplemented field must be recorded as a gap, not claimed as complete.

### 6.5 Calendar and reports

Internal Arvin calendar and Android Calendar Provider remain separate data layers. Deleting an external event must never delete the internal Task. Gregorian, Jalali and Hijri displays, prayer overlays and religious assets must remain isolated. Reports and PDF output must be reconciled against canonical data; visual presence alone is insufficient.

## 7. Design System

- Active Blue & White brand primary: #4169A1, as present in lib/core/theme/arvin_theme.dart at the baseline SHA.
- #008080 Persian Teal is retained as a historical brand direction and current secondary selectable Accent; it is not the active Brand Primary.
- #3A86EF is retained as a historical sample/reference value, not silently promoted to primary. Current code's glow token is #404169A1; record the discrepancy rather than changing it without owner decision.
- Five semantic dimension colors in ArvinColors: Time #008080; Reminder #D97706; Project #7C3AED; Category #2563EB; Tag #16A34A. Confirm exact navigation mapping against the owner visual contract before claiming complete navigation acceptance.
- Notebook orange: #C76B16.
- Eisenhower: P1 #DC2626; P2 #D97706; P3 #2563EB; P4 #80829C.
- Nine secondary Accent palette values: #008080, #1B4965, #2A9D8F, #4361EE, #7209B7, #F77F00, #D90429, #606C38, #2B2D42. Accent selection must not override brand primary.
- Light and Dark tokens exist in ArvinTheme/ArvinColors. Core Light tokens include white cards, #F4F6F9 neutral background, #E5E7F0 border and 16px card radius; Dark tokens include #25283A surface and #41465B border.
- Official font: Vazirmatn. Registered weights: Light 300, Regular 400, Medium 500, SemiBold 600, Bold 700. No substitute family without owner approval.
- Minimum interactive touch target: 48dp. The current shared filter component has 48dp controls; Quick Capture tests still include 40dp controls, so app-wide compliance is not verified.
- Animation, Haptic Feedback, exact RTL behavior across every viewport, and visual fatigue reduction require explicit visual/device acceptance; do not infer them from theme tokens.

## 8. Approved Auto-Save Decision

Decision ID ARVIN-DEC-2026-11-10-001. Status APPROVED by Mobin under REV7.2. Task Details must be continuously editable; independent Edit Mode and standalone Edit button are removed; each permitted field change is saved automatically through the existing TaskStore/Repository; writes are serialized and durable; confirmed edits survive navigation away; no parallel model/store; Follow-up creation and Task completion remain independent. No test may be removed, skipped, bypassed or weakened.

Current implementation status: PARTIAL. Current source contains immediate title persistence, queued mutations and field-specific TaskStore saves. Complete per-field and route-exit acceptance is not yet proven. Current Build has six failed shards; the test suite includes a missing task-detail-inline-edit-toggle finder expectation. Resolve the test/runtime contract without weakening the test. See PRODUCT_DECISIONS.md and OPEN_ISSUES.md.

## 9. Architecture Audit Matrix — exact SHA b789343c9699ca440d043d71d47db3dcdfafa57c

| Capability | Product Approval | Implementation | Verification | Evidence and remaining gap |
|---|---|---|---|---|
| Task / Due Date / Reminder / Follow-up separation | APPROVED | IMPLEMENTED | PARTIAL | lib/models/task.dart; lib/services/task_store.dart; lib/services/g1_drift_schema.dart. Separate task_reminders and follow_up_records tables. Current test/task_contract_test.dart fails in Shard 2; exact persistence suite also needs complete current-head coverage. |
| Four-state Reminder | APPROVED | BLOCKED | NOT VERIFIED | lib/models/task.dart TaskReminder has isEnabled/isAllDay only. Four states and transitions are not defined; do not guess. |
| Recurrence and occurrence history | APPROVED | IMPLEMENTED | PARTIAL | lib/services/task_recurrence_repository.dart; occurrenceHistory and checklistOccurrences. New occurrence starts from unchecked template. Current shards include failures in recurrence/editor paths. |
| Center/Project/Category/Tags hierarchy | APPROVED | PARTIAL | PARTIAL | lib/models/arvin_center.dart; lib/models/goal_project.dart; lib/services/center_store.dart; lib/services/project_store.dart; lib/services/task_project_assignment_service.dart; lib/models/task.dart. Unclassified Task can be represented; explicit Inbox lifecycle not proven. |
| Universal filters | APPROVED | PARTIAL | PARTIAL | lib/widgets/reusable_multi_select_filter_bottom_sheet.dart supports single/multi select, inline creation, auto-select, count and 48dp rows. Caller order and all 360/390/412dp combinations are not fully verified. |
| Home grouping and sorting | APPROVED | PARTIAL | PARTIAL | lib/home/grouping/home_grouping_service.dart; lib/services/task_list_sort_service.dart; lib/services/home_follow_up_presentation_service.dart; lib/services/home_today_projection.dart. Time grouping uses Task.dueDate; service offers title/date/creation/last-follow-up sorting helpers but complete user-facing sort contract is not proven. |
| Quick Capture | APPROVED | PARTIAL | PARTIAL | lib/quick_capture_dialog.dart; lib/services/task_store.dart. Optional selectors and canonical persistence exist; many Quick Capture tests fail across shards; 40dp control evidence conflicts with 48dp global requirement. |
| Notebook | APPROVED | PARTIAL | PARTIAL | lib/notebook_page.dart; lib/services/canonical_notebook_repository.dart. Same canonical Task identity, soft trash/restore, convertNoteToTask. Hard-delete preservation/unlink guarantees and first-save auto-title are not proven. |
| Templates | APPROVED | PARTIAL | PARTIAL | lib/models/task_template.dart; lib/services/task_template_store.dart; lib/task_template_management_page.dart. Template includes title/description/category/priority/tags/checklist/people/reminder definitions/recurrence and center/project snapshots. Task dueDate is not stored; instantiation path does not assign center/project membership in the reviewed code. |
| Calendar | APPROVED | PARTIAL | PARTIAL | lib/calendar_page.dart; lib/services/system_calendar_bridge.dart; lib/services/calendar_provider_sync_executor.dart. Four views and date projections; external events read-only mirrors; only explicit Task/TaskReminder exports mutate Arvin-owned Provider events. Calendar Provider Acceptance PASS on exact SHA; full physical device and all calendar layers remain unverified. |
| Reports / PDF | APPROVED | PARTIAL | PARTIAL | lib/report_center_page.dart; lib/services/task_report_pdf_renderer.dart; lib/services/work_agenda_report_adapter.dart. Current report tests fail; reconciliation and PDF acceptance incomplete. |
| Backup / Restore / Drift / Migration | APPROVED | PARTIAL | PARTIAL | lib/services/g1_drift_schema.dart (schema v16); lib/services/task_store.dart; lib/backup_manager.dart; backup tests. Migration copies legacy Follow-up data then drops legacy tables inside schema installation; actual user DB/backup/rollback has not been inspected. No destructive migration is authorized. |
| Local P2P / cloud sync | APPROVED | PARTIAL | NOT VERIFIED | Sync services/specifications exist; end-to-end Local P2P pairing, secure transport and conflict acceptance not proven. Cloud/Dropbox is separate future phase. |
| NIRA operational factory | APPROVED | PARTIAL | NOT VERIFIED | NIRA README explicitly says L10 UNVERIFIED until a registered client task yields reconstructible E2E evidence. Main Closure run 42777826931 SUCCESS; Queue Scheduler run 42777810609 FAILURE on NIRA main SHA 7a27ee63b65d343e45c5786f782f2567611722dc. |

## 10. Exact-SHA CI and Device Evidence

Build run 42763952581 on b789343c9699ca440d043d71d47db3dcdfafa57c: Analyze PASS; Visual structural smoke PASS; Debug APK PASS; Release APK build PASS; Staging APK build/signature/manifest/font audit PASS; shards 0–5 all FAIL. Per-shard counts: 0 231/14; 1 195/5; 2 299/25; 3 148/12; 4 240/11; 5 182/12. Follow-up Persistence run 42763952346 SUCCESS. Calendar Provider run 42763952813 SUCCESS. Device Smoke run 42763952498 incomplete: preparation succeeded, Boot in progress, six other lanes queued. No physical Samsung A52s acceptance is proven.

CI failures are listed by shard in OPEN_ISSUES.md. Observed failure symptoms include missing widget keys/text, unexpected finder cardinality, null/different dates, wrong result counts, color mismatch and a RangeError. These are observed symptoms, not proven common root causes. No test deletion, skip, bypass, timeout weakening or assertion reduction is allowed.

## 11. NIRA Boundary

NIRA is a separate factory repository, not Arvin product code. Its README says L10 remains UNVERIFIED until a registered client task produces reconstructible E2E evidence including bounded failure/fencing/recovery and promotion/release proof. Recent workflow names and green orchestrator runs alone do not prove that end-to-end capability. On the inspected NIRA main SHA, Main Closure and Failure Feedback/Orchestrator runs were green, but Queue Scheduler failed. Do not claim L10 or fully operational factory.

## 12. Wave Plan

- Wave 0 — Governance & Source of Truth: establish these eight files, exact-SHA checkpoint, decision IDs, internal links and one docs-only commit. Ready for this documentation deployment.
- Wave 1 — Data Integrity & Architecture: Reminder state contract, Drift v16, backup/restore, real DB and migration safety. Blocked by missing state semantics and real-data/backup inspection.
- Wave 2 — Core Task Lifecycle: auto-save, Task/Reminder/Follow-up/recurrence/checklist. Partial; blocked by six failing shards and incomplete auto-save proof.
- Wave 3 — Home, Quick Capture & Filters: five filters, OR/AND, sort, Inbox and responsive 48dp. Partial; blocked by current Home/Quick Capture failures and viewport/touch-target gaps.
- Wave 4 — Notebook, Calendar & Templates: safe note lifecycle, template deep clone, Calendar layers and physical acceptance. Partial; Calendar Provider exact-SHA pass does not close all criteria.
- Wave 5 — Reports, Sync & Enterprise Acceptance: reports/PDF, Local P2P, NIRA E2E and final release gates. Blocked by upstream waves and missing E2E evidence.

Detailed goals, dependencies, files, acceptance, tests and evidence are in ROADMAP.md.

## 13. Release and Final Authority

Release remains BLOCKED — RELEASE: NO-GO until all mandatory acceptance gates pass on one exact candidate SHA, seven Device Smoke lanes finish, all six test shards pass, Calendar Provider and Follow-up Persistence pass, physical-device acceptance is recorded, data integrity/security gates close and Mobin explicitly accepts the candidate. This document does not authorize Main changes, merge or release. Mobin remains the final authority for product decisions.


## 14. WAVE 4 REV8 — latest owner authorization and current execution

On 2026-11-10 Mobin explicitly authorized WAVE 4 as **AUDIT + IMPLEMENTATION + TESTING**. This supersedes older read-only Wave 4 checkpoint language and authorizes in-scope source, schema, migration, test, workflow and audit-report edits on the approved working branch.

Current implementation checkpoint: `dbfcdb02879ed3939cb6a69d3a150e2237283a51`. The implementation is PARTIAL: Task and Project migration parity was strengthened; Recurrence and Occurrence have relational SQL ownership; unproven legacy retirement paths were disabled. Global SQL-only consolidation, full G1 parity, Backup/Restore, exact-SHA tests and Android acceptance remain open.

Main stays READ-ONLY; PR #3052 stays OPEN / DRAFT / UNMERGED; no force push, merge, release, test weakening or unproven legacy deletion. Four Reminder states remain an explicit Mobin decision. Release remains BLOCKED — NO-GO.


## COMMAND 07-A.2.21 — فونت و SQLite / وضعیت اجرایی 2026-11-12

این الحاقیه تصمیم و محدودیت‌های این مأموریت را ثبت می‌کند؛ جایگزین تاریخچه قبلی نیست.

- فونت رسمی برنامه: **VazirHarf v34.003**، شاخه UI-Farsi-Digits، پنج وزن 300/400/500/600/700، با مجوز SIL OFL 1.1.
- منبع فونت به Commit ثابت upstream با SHA 3cbc943b9fb9107baa77008b3e96b3c3e40e9ed8 pin شده و فایل مجوز در assets/fonts/ui/vazirharf/OFL.txt نگهداری می‌شود.
- فایل‌های Vazirmatn حذف نشده‌اند؛ فقط از فهرست فونت‌های runtime در pubspec خارج شده‌اند و برای ممیزی تاریخی باقی می‌مانند.
- هیچ ادعای پذیرش Android/RTL یا انتشار APK بدون تست موفق روی SHA نهایی مجاز نیست.
- Merge، Release و Deployment همچنان فقط با تأیید صریح مالک محصول مجاز است.
- شواهد SQLite هرگز بین SHAها منتقل نمی‌شوند. Snapshot پنج‌چرخه ثبت‌شده روی b9d88bf0381030b5d2fd21aa82436678a65b518a فقط به همان SHA تعلق دارد.


## COMMAND 07-A.2.24 owner typography override — 2026-11-12

The latest explicit Product Owner decision supersedes earlier conflicting font decisions: **Vazirmatn is the only official/default Arvin font.** VazirHarf is not an official or fallback brand font. The canonical technical contract and owner CODEOWNERS proposal are being tracked in PR #3388 at `docs/architecture/ARVIN_TYPOGRAPHY_CONTRACT.md` and `.github/CODEOWNERS`. These are separate unmerged changes and do not yet affect this branch's runtime.

Current branch `cbf7d241e588c6b4b6051dea5bb3d309a8c3cb05` explicitly registers VazirHarf in pubspec, AppFonts, ArvinTheme, PDF renderer and typography tests. This is a confirmed contradiction requiring remediation; do not call the current implementation compliant.
