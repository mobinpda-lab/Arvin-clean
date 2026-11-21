# REV10 EXECUTION LOCK — ARVIN / COMMAND 126-R

**Authority:** Product Owner (Mobin)
**Product baseline:** REV10
**Repository:** `mobinpda-lab/Arvin-clean`
**Sole development route:** PR #3495 — `recovery-02/main-based-integration`
**Main policy:** READ ONLY
**Release authority:** Product Owner only
**Created against live Candidate SHA:** `6d8bb22c519c80fd51d933a08ebf4e8bd3573898`
**Main SHA observed:** `45e4202b03a434459e4c021a04efa7e8396359db`
**Status:** OWNER DECISIONS LOCKED / IMPLEMENTATION ACCEPTANCE INCOMPLETE

> This file operationalizes REV10 and COMMAND 126-R. It does not replace the REV10 master charter, owner decision register, or any source evidence. It does not declare product completion.

## 1. Authority and source hierarchy

The active master charter is the REV10 section embedded in `docs/project-continuity/MASTER_GOVERNANCE.md`, beginning at line 82 in the audited blob. The exact source Git blob SHA is `cdea45d11f4e25795231f2aca10cfdc1b6cde521`. This is a Git blob SHA, not a SHA-256 checksum.

Supporting active source set:
- `docs/project-continuity/PRODUCT_DECISIONS.md`
- `docs/project-continuity/CURRENT_STATE.md`
- `docs/project-continuity/ROADMAP.md`
- `docs/project-continuity/OPEN_ISSUES.md`
- `docs/project-continuity/IMPLEMENTATION_LOG.md`
- `docs/project-continuity/HANDOFF.md`
- `docs/rev10/REV10-MASTER-BASELINE.md`
- `docs/rev10/REV10-OWNER-DECISIONS.md`
- `docs/rev10/REV10-FEATURE-ACCEPTANCE-MATRIX.md`
- `docs/rev10/REV10-CHANGE-CONTROL.md`
- `docs/ADR/ADR-2026-11-14-CENTER-PROJECT-CATEGORY-M2M.md`

Authority order: latest explicit Product Owner decision → approved architecture/product decision → REV10 charter → canonical contracts → actual source/schema for implementation facts → exact-SHA test and CI evidence → historical reports. Historical ZIPs, ADRs, logs, older branches and reports remain evidence only; they cannot silently replace REV10. No standalone REV10 PDF or ZIP was found in the audited Candidate tree. The canonical charter is Markdown; no PDF page count or SHA-256 is claimed.

## 2. Immutable Product Owner decisions

1. REV10 is the binding product baseline.
2. Primary Blue is exactly `#4169A1`; canonical token source is `lib/arvin_colors.dart`. No theme, refactor, or contrast variant may redefine it.
3. Center is a first-class, independently managed product entity.
4. Home has five independent filters: Time, Center, Project, Category, Tags.
5. The five due-date groups remain independently present: Overdue, Today, Tomorrow, Future, No Date.
6. Multi-select semantics: OR within one dimension; AND across dimensions.
7. Center↔Project and Project↔Category are many-to-many. Task→Center, Task→Project and Task→Category are independently optional 0..1. Task↔Tag is many-to-many.
8. Local SQL is the durable source of truth. No parallel permanent JSON/SharedPreferences/secondary database.
9. Preserve IDs, nullable values, unknown fields, relationships, occurrence/recurrence history, checklist state and audit history.
10. Do not infer ambiguous historical relations from names, labels or Task text.
11. Do not weaken, delete, skip or bypass a valid test to obtain green CI.
12. Main is read-only. PR #3495 is the only active development route. No parallel feature PR or active historical branch.
13. Merge, release, deployment and production-user migration require explicit owner approval.
14. NIRA remains independent and is not a runtime dependency or part of this execution.

## 3. Change-control protocol

Before every code change:
- Identify the exact REV10 clause and owner decision.
- Inspect the current Candidate source, SQL schema, consumers, migration and tests.
- Record conflicts; do not resolve ambiguity by inference.
- Work only on `recovery-02/main-based-integration` through PR #3495.
- Run targeted tests and then relevant CI against the resulting exact SHA.
- Record workflow Run ID, Job ID, artifact ID and digest where applicable.
- Update this lock and the feature matrix without inheriting prior-SHA PASS.
- Keep missing evidence as BLOCKED, INCOMPLETE EVIDENCE, NOT TESTED or UNRESOLVED.
- Stop and request owner clarification if an actual product decision is ambiguous.

No Main writes, force-push, history rewrite, PR merge, release, deployment, destructive production-data operation or real-user migration is authorized.

## 4. Requirement-to-implementation traceability

Status vocabulary:
- **APPROVED** = owner-approved requirement.
- **IMPLEMENTED** = source/schema exists; not acceptance.
- **VERIFIED** = exact-SHA test/device/owner evidence proves the stated scope.
- **INCOMPLETE EVIDENCE** = partial implementation or tests, missing full chain.
- **BLOCKED** = required implementation, dependency or approval absent.
- **NOT TESTED** = no relevant exact-SHA evidence.
- **UNRESOLVED** = source/owner decision insufficient.

| REV10 requirement | Candidate source / implementation paths to audit | Acceptance evidence required | Initial live disposition at 6d8bb22 |
|---|---|---|---|
| Product identity, Local-First, offline-first, SQL-only | `MASTER_GOVERNANCE.md`, `lib/services/g1_drift_schema.dart`, Task/Project/Center/Tag/Person stores | Source review, canonical SQL persistence, offline operation, no parallel permanent store | INCOMPLETE EVIDENCE |
| Primary Blue #4169A1 | `lib/arvin_colors.dart`, theme consumers, `test/arvin_primary_blue_contract_test.dart` | Token/consumer audit + exact-SHA governance and visual test | INCOMPLETE EVIDENCE; decision locked |
| Center model and identity | `lib/models/center.dart` | Validation, stable ID, serialization and lifecycle tests | IMPLEMENTED; full acceptance incomplete |
| CenterStore CRUD | `lib/services/center_store.dart` | Create/read/update/archive/restore/safe-delete, transactions, file-backed SQLite | IMPLEMENTED; targeted persistence test exists |
| Center↔Project M2M | CenterStore, schema v9 migration, `center_projects`, M2M ADR | Multi-to-multi fixtures, bidirectional lookup, edge isolation, FK and transaction tests | IMPLEMENTED in part; end-to-end incomplete |
| Project↔Category M2M | schema migration, `project_categories`, Project/Category stores | Full canonical Store/UI/query/backup parity; no guessed links | INCOMPLETE EVIDENCE |
| Task direct Center/Project/Category | Task model, TaskStore, schema, Task Editor | All independent nullable combinations and invalid-edge rejection | INCOMPLETE EVIDENCE |
| Tag M2M | TagStore, TaskStore, `task_tags` | CRUD, multi-link, search, filtering, persistence and backup | INCOMPLETE EVIDENCE |
| Person as independent entity | People models/store, Task and Follow-up links | CRUD/search, identity snapshots, relationship/history retention | INCOMPLETE EVIDENCE |
| Unified Entity Management | Center, Project, Category, Tag, Person screens and stores | Independent create/edit/archive/restore/search/dependency review/safe delete | BLOCKED / not fully verified |
| Center management UI | Center page/route/widgets | Full Persian RTL lifecycle UI and persistence | NOT ACCEPTED |
| Project management | ProjectStore and Project UI | CRUD/archive/restore/search, M2M membership and backup | INCOMPLETE EVIDENCE |
| Category management | Category entity/store/UI | CRUD/search/archive and Project M2M integration | INCOMPLETE EVIDENCE |
| Time filter | Home filter UI/state/projection | Select/clear/reopen, five-dimension combined behavior | INCOMPLETE EVIDENCE |
| Center filter | Home filter UI/state and SQL projection | Real Center data, selector, persisted selection and Task projection | BLOCKED; absent from four-card implementation |
| Project filter | Home filter UI and Task projection | OR within Project; AND with other dimensions | INCOMPLETE EVIDENCE |
| Category filter | Home filter UI and Task projection | OR within Category; AND with other dimensions | INCOMPLETE EVIDENCE |
| Tags filter | Home filter UI and Task projection | OR within Tags; AND with other dimensions | INCOMPLETE EVIDENCE |
| Five independent due-date groups | `lib/main.dart`, `lib/home/grouping/`, Home projection | Overdue/Today/Tomorrow/Future/No Date, including combinations with all filters | IMPLEMENTED in source; exact-SHA acceptance incomplete |
| Home sorting | Home list/projection and sort controls | Independent field/direction, ascending/descending, selection survives rebuild | NOT TESTED |
| Home filter management control | Home filter UI | Separate management control, individual clear and Clear All | INCOMPLETE EVIDENCE |
| Task Details single-column UX | `lib/task_editor_dialog.dart`, detail widgets, shared sheets | REV10 field order, selectors, create-new, autosave/error/retry | INCOMPLETE EVIDENCE |
| Quick Capture | Quick Capture dialog and TaskStore | Center/Project/Category/Tags/Person flows, save and reopen | INCOMPLETE EVIDENCE |
| Task autosave safety | Task Editor, TaskStore | concurrent-write/lost-update, save indicator, error/retry, navigation/restart | INCOMPLETE EVIDENCE |
| Reminder Stop Bell | Issue #3646, Android/Flutter reminder actions | Stops audio only; Task and Reminder unchanged | BLOCKED |
| Reminder Follow-up | Issue #3646, Task detail follow-up flow | Same Task identity, persisted follow-up history | BLOCKED |
| Reminder Snooze | Issue #3646, existing scheduler | New time replaces old schedule; duplicate prevention | BLOCKED |
| Reminder Complete | Issue #3646, canonical TaskStore | Real persisted Task completion and active Reminder termination | BLOCKED |
| Reminder Activity / lifecycle | Android Activity, manifest, notification service, scheduler | Foreground/background/closed app, permission handling, process death and reboot | BLOCKED; notification foundation alone is insufficient |
| Scheduler uniqueness | Existing reminder scheduler and delivery services | Reuse canonical scheduler; no parallel scheduler/storage | INCOMPLETE EVIDENCE |
| Templates | ProjectTemplateStore, TaskTemplateStore, ProjectTemplateService | Scope selection, persistence, migration and reusable templates | INCOMPLETE EVIDENCE |
| Deep Clone | Template instantiation services | New IDs, independent entities, unchecked checklist, no old execution/history IDs | INCOMPLETE EVIDENCE |
| Cross-Center activity identity | Template/Task identity model | Same activity reusable while each Center execution remains independent | UNRESOLVED / NOT ACCEPTED |
| Cross-Center reports | Report Center, report projections | Accurate status, denominator, no double count, repeatable after reopen | INCOMPLETE EVIDENCE; definitions may remain unresolved |
| Calendar | Calendar route, reminder services and projections | Full calendar interaction, recurrence, persistence and exact-SHA device test | INCOMPLETE EVIDENCE |
| Follow-up and waiting states | Follow-up model/store/projection | Identity, history, ordering, reminders and restart tests | INCOMPLETE EVIDENCE |
| Checklist | Task checklist model/store/editor | Persistence, recurrence/reset rules and Deep Clone isolation | INCOMPLETE EVIDENCE |
| Search | Search projections/services | Cross-entity and relationship-aware search, Persian behavior | INCOMPLETE EVIDENCE |
| Notebook | Notebook repository and Task/Project stores | Canonical SQL identity, relations and backup parity | INCOMPLETE EVIDENCE |
| Reports | Report Center and PDF/report projections | Cross-Center aggregates, reproducibility and no duplicate counting | INCOMPLETE EVIDENCE |
| Settings | Settings screens/preferences | Only approved preferences; no second official font or Primary token | INCOMPLETE EVIDENCE |
| Vazirmatn typography | `pubspec.yaml`, theme, font assets, typography tests | Weights 300/400/500/600/700, actual screen rendering and APK packaging | INCOMPLETE EVIDENCE |
| Persian RTL and Jalali | UI routes, date services, localization | RTL, Persian digits/text, Jalali behavior, mixed-script regression | INCOMPLETE EVIDENCE |
| Persian PDF | PDF renderer and fonts | Inspect actual PDF for embedded font, shaping, RTL, clipping and tables | NOT TESTED on current SHA |
| Accessibility | UI widgets, semantics and tests | TalkBack/semantics, focus order, contrast, scaling and device checks | NOT TESTED |
| D01 schema/migration | schema/migration files and migration workflows | Sequential supported-version path, constraints, indexes, triggers, FK | INCOMPLETE EVIDENCE |
| D02 missing/NULL/FALSE/TRUE | Migration fixtures and SQL codecs | Preserve all four states distinctly where applicable | INCOMPLETE EVIDENCE |
| D03 Follow-up metadata/Person | Follow-up/Person stores and migration | IDs, ordering, metadata, Person and relationship parity | INCOMPLETE EVIDENCE |
| D04 independent physical backup/restore | Backup manager, SQLite backup, Android SAF | Database A to independent Database B, reopen and full row/edge parity | INCOMPLETE EVIDENCE |
| D05 atomicity/rollback/recovery | migration/backup transaction code | Failure injection, rollback, source preservation, retry and recovery | INCOMPLETE EVIDENCE |
| Unknown fields and historical IDs | codecs, migration, backup | Unknown-field retention, exact identity and history snapshots | INCOMPLETE EVIDENCE |
| Occurrence and recurrence | occurrence/recurrence models and stores | Sequential migration, recurrence behavior, occurrence parity and restart | INCOMPLETE EVIDENCE |
| Backup encryption/tamper/corruption | backup format/crypto/restore | Wrong key, tamper, corruption, retry and no destructive partial restore | NOT TESTED |
| Android SAF | backup import/export | Real SAF file picker, permission, interrupted I/O and restore | NOT TESTED |
| Regression recovery | all relevant tests and source fixes | Root-cause classification; no weakening/deletion/bypass | INCOMPLETE EVIDENCE |
| Repository/workflow consolidation | `.github/workflows/`, scripts, CODEOWNERS | Workflow inventory, duplicate/security review, required checks | INCOMPLETE EVIDENCE |
| Branch protection and CODEOWNERS | ruleset 20952260, `.github/CODEOWNERS` | Owner review, required CI, thread resolution, canonical branch protection | BLOCKED / admin setting required |
| E2E product acceptance | `integration_test/`, device smoke | Full user journeys on one exact Candidate SHA | NOT TESTED |
| Release signing | release workflow and signing configuration | Owner key, non-debug signature, install/upgrade and APK SHA-256 | NOT ACCEPTED |
| Physical Android device | device test evidence | Real phone install, upgrade, permissions, RTL/font, backup/restore | NOT TESTED |
| Handoff and release notes | active continuity docs | accepted feature list, known gaps, artifact and owner approval | NOT READY |

## 5. Current live Candidate checkpoint

At the time of this lock:
- Main HEAD: `45e4202b03a434459e4c021a04efa7e8396359db`.
- PR #3495 is OPEN / DRAFT / UNMERGED, base `main`, head `recovery-02/main-based-integration`.
- Candidate HEAD: `6d8bb22c519c80fd51d933a08ebf4e8bd3573898`.
- PR #3495 was updated at `2026-11-21T06:44:38Z`.
- Candidate tree contains `docs/rev10/`, Center model/store, Home grouping/filter code, migration and test assets.
- Candidate tree has no `REV10-EXECUTION-LOCK.md` before this commit.
- `docs/rev10/REV10-FEATURE-ACCEPTANCE-MATRIX.md` still names older audited SHA `c033513de5bd0067a093c59303c4071acf42f564`; it must be refreshed against the live Candidate after this lock commit.
- Issue #3646 remains OPEN; its acceptance contract explicitly says no dedicated four-action Task reminder Activity/controller/UI has been found and all four actions/process-death/reboot/device evidence are required.
- Current exact-SHA check runs show passing Analyze/test shards, Debug/Release build and selected emulator Device Smoke scenarios, but one Android environment diagnostic remained in progress and the aggregate commit status was pending at audit time.
- A successful CI Release build is not owner-signed delivery, a physical-device test, or permission to release.

## 6. GitHub security checkpoint

Ruleset `20952260` named `main-protection` is active and applies to `refs/heads/main`. It prevents branch deletion and non-fast-forward updates and requires a pull request. It currently has:
- required approving reviews: 0
- CODEOWNERS review: disabled
- required review-thread resolution: disabled
- required CI checks: none
- bypass actors: none; connected user bypass: never

The canonical integration branch was reported unprotected. Branch-protection endpoint reads returned 403 from the connected integration. Do not claim full Branch Protection or owner-review enforcement. Required security hardening remains BLOCKED pending an authorized GitHub administration path. No settings were changed by this lock operation.

## 7. Exact-SHA acceptance rule

A capability is accepted only when the same exact Candidate SHA has:
- source review,
- unit and widget tests,
- integration and end-to-end tests,
- SQLite persistence and migration tests,
- restart/process-death tests where relevant,
- device tests where relevant,
- regression tests,
- evidence IDs and recorded results.

No result from an older SHA transfers. Debug/Release build success alone does not accept a feature. Emulator smoke does not equal a real owner-device test. A table, model, screen or workflow alone does not constitute end-to-end acceptance.

## 8. Execution order

1. Lock REV10 and resolve source/decision conflicts.
2. Harden GitHub Main and canonical-branch security through authorized administration.
3. Complete Center and both M2M relations, then all consumers and backup/restore.
4. Complete Home five-filter projection, sorting, state restoration and five-group regressions.
5. Complete Reminder four-action Activity and lifecycle under Issue #3646.
6. Complete D01–D05 and backup safety in parallel with feature work; use test databases only.
7. Complete remaining REV10 entity management, Task Editor, Quick Capture, Templates/Deep Clone, Cross-Center reports, Calendar, Follow-up, Checklist, Search, Notebook, Settings, RTL, accessibility and Persian PDF.
8. Run comprehensive exact-SHA acceptance and update matrix.
9. Build and owner-sign final APK, compute APK-file SHA-256, install/upgrade and test on a real Android phone.
10. Deliver only after explicit owner approval.

Independent work may run in parallel only where dependencies and shared files are understood. No duplicate scheduler, storage engine, database, product route or CI workflow is to be introduced.

## 9. Change history

| Date | Candidate SHA | Change | Authority |
|---|---|---|---|
| 2026-11-21 | `6d8bb22c519c80fd51d933a08ebf4e8bd3573898` | Initial live audit and REV10 execution lock prepared under MASTER EXECUTION 126-R | Product Owner command |

**No product capability is declared complete by this document.**
