## Additional source conflict — typography

| ID | Conflict | Evidence | Current classification | Safe action |
|---|---|---|---|---|
| CR-027 | VazirHarf v34.003 vs Vazirmatn | 2026-09-06 VazirHarf directive vs explicit COMMAND 63-R (2026-11-19) naming Vazirmatn v33.003 as Arvin's official font and requiring it throughout the product | Active Arvin font: Vazirmatn v33.003 per COMMAND 63-R; VazirHarf remains a preserved historical instruction, not current Arvin authority | RESOLVED by latest explicit owner command; asset/weight/APK/rendering verification remains open |

Source implementation: `pubspec.yaml`, `lib/theme/app_fonts.dart`, `lib/core/theme/arvin_theme.dart`; `test/vazirharf_settings_convergence_test.dart` currently asserts Vazirmatn despite its VazirHarf-oriented filename. Open font-related PRs include #2975, #2918 and #2932; review their scope against the final owner decision. COMMAND 63-R now resolves the owner decision; current code and font tests are being validated on exact PR heads.

---

## Post-audit conflicts — 2026-11-10

| ID | Conflict | Current evidence | Status |
|---|---|---|---|
| CR-022 | Audit snapshot vs live branch HEAD | Earlier snapshot 9846; live branch/PR now a934, parent 9846 | RESOLVED by refresh; retain 9846 historically |
| CR-023 | SHA-scoped Build failures | 79 on b789; 78 on 9846; current a934 Build 42801502260 also 78 | SHA-scoped; do not transfer results |
| CR-024 | PR changed-file count | 368 pre-a934; current PR API reports 380 | Current count reconciled; old count historical |
| CR-025 | Device Smoke | Run 42801502310 on a934 is PENDING | OPEN; no device acceptance |
| CR-026 | NIRA scheduler | Latest run 42803607805 fails posting to issue #162 (>2,500 comments) | BLOCKED; dispatch root cause not proven |

---

# Arvin Conflict Register — REV8

**Authority:** latest explicit Mobin decision; current REV8 execution order.  
**Snapshot:** 2026-11-10.

| ID | Conflict | Sources / evidence | Active decision | Status / action |
|---|---|---|---|---|
| CR-001 | Governance revision | REV7.2 master vs REV8 execution order | REV8 is current audit authority; preserve REV7.2 history | RESOLVED — docs addendum |
| CR-002 | Blue / Teal / Sky Blue | Historical Blue `#4169A1`, Sky Blue `#3A86EF`, Persian Teal `#0F766E` entries vs explicit COMMAND 63-R palette | Active palette per COMMAND 63-R: `#078B91`, `#066F75`, `#DDF7F5`, `#F0FAF9`, `#D9ECEA`; earlier palettes are superseded for current Arvin UI | RESOLVED by latest explicit owner command; token rollout and visual acceptance remain open |
| CR-003 | Task Details Edit Mode vs Auto-Save | Older Task Details specs and REV7.2 `ARVIN-DEC-2026-11-10-001` | Always-editable Task Details with Auto-Save; no independent edit mode/button | APPROVED; implementation/verification PARTIAL |
| CR-004 | Filter order | Older specs vs REV8 | Time → Center → Project → Category → Tags | REV8 supersedes older order |
| CR-005 | Single-select vs multi-select | Reusable filter supports both modes; product contract distinguishes dimensions | Center, Project, Category single-select; Tags multi-select | APPROVED; UI/test acceptance PARTIAL |
| CR-006 | Four-state Reminder | TaskReminder currently has isEnabled/isAllDay booleans; no four-state enum | Four states are required but names/transitions must not be inferred | OPEN — Mobin decision/specification needed |
| CR-007 | Due Date vs Follow-up Date | Task.dueDate; FollowUp.dateTime; legacy followUpDate and nextFollowUp remain | Due Date belongs to Task; Follow-up date belongs to actual Follow-up history; Reminder is separate | APPROVED; compatibility cleanup not authorized |
| CR-008 | Recurrence vs Occurrence | TaskRecurrenceRepository maps occurrenceHistory | Recurrence definition and generated occurrence/history are distinct | PARTIAL — prove persistence and date semantics |
| CR-009 | Checklist vs History | checklistOccurrences map and raw checklist | New occurrence must reset ticks; history must remain per occurrence | PARTIAL — current checklist tests fail |
| CR-010 | Notebook vs Task deletion | Notebook uses canonical TaskStore and soft trash | Preserve independent note data on Task deletion/unlink | NOT VERIFIED — hard-delete regression needed |
| CR-011 | Template Deep Clone | TaskTemplate/TaskTemplateStore; TaskTemplate has no dueDate | Copy approved template fields only; never copy execution history or checked state | PARTIAL — date-base and assignment behavior needs verification |
| CR-012 | Internal Calendar vs Android Provider | CalendarPage, SystemCalendarBridge, CalendarProviderSyncExecutor | Independent data layers; external event deletion must not delete internal Task | PARTIAL — provider workflow passed; Device Smoke pending |
| CR-013 | Schema/model naming | Dart FollowUp vs SQL follow_up_records; persons/person_directory | One canonical TaskStore; distinguish relation/index tables from domain models | PARTIAL — document naming map |
| CR-014 | Legacy architecture docs vs current code | 2026-08 docs still describe ArvinTask/TaskRepository | Current TaskStore/Task model is live authority | RESOLVED in classification; old docs retained as historical |
| CR-015 | CI failure count | Old SHA b789 run had 79; current SHA 9846 has 78 | Current exact SHA result only | RESOLVED — 78 current distinct failed labels |
| CR-016 | PR diff vs Compare file list | PR Files API 368; Compare API file listing capped at 300 | 368 is full PR changed-file count | RESOLVED — endpoint cap explained |
| CR-017 | Branch vs docs SHA | Branch/PR head 9846; canonical docs did not mention it and referenced b789 | Current SHA 9846 | RESOLVED by REV8 checkpoint update |
| CR-018 | Duplicate branch refs | 35 groups / 109 refs share exact head SHA | Keep history; no branch deletion without approval | OPEN — review candidates |
| CR-019 | Repeated PR heads | 33 groups / 72 PR records share head branch | Keep PR history; no automatic close | OPEN — review candidates |
| CR-020 | NIRA Queue Scheduler | Run 42777810609; comment creation on issue #162 returns 403 after >2,500 comments | Fix feedback path in a separate authorized technical wave | BLOCKED — underlying dispatch error may be masked |
| CR-021 | NIRA state-sync PR churn | 292 of 381 closed PRs share title/branch nira/state-sync; 289 unmerged | Do not close/merge automatically; repair scheduler/PR idempotency | OPEN — NIRA governance |

No conflict was hidden by deleting historical records. No code or test was changed in this audit.


## COMMAND 63-R conflict resolution addendum — 2026-11-19

| ID | Conflict | Latest owner evidence | Active decision | Status |
|---|---|---|---|---|
| CR-028 | Local P2P suspended vs re-authorized | COMMAND 63-R explicitly includes Local P2P Phase 1 as an active P1 workstream, following the earlier COMMAND 62-R authorization | Local phone↔tablet P2P on shared Wi-Fi/hotspot is authorized; cloud/Dropbox remains deferred Phase 2. Security review precedes implementation. | RESOLVED for scope authority; protocol/security acceptance remains OPEN |
| CR-029 | Six Home time groups vs REV10 five groups | COMMAND 63-R explicitly lists five groups and supersedes the historical separate completed_past group | تاریخ‌گذشته، امروز، فردا، آینده، فاقد زمان; completed prior-date Tasks stay visible inside تاریخ‌گذشته after active overdue Tasks. | RESOLVED for product contract; code/test/device acceptance remains OPEN |

## COMMAND 63-R implementation conflicts — 2026-11-19

| ID | Conflict | Latest evidence | Active decision | Status |
|---|---|---|---|---|
| CR-030 | REV8 Home filter order vs COMMAND 63-R | CR-004 records the older REV8 order Time → Center → Project → Category → Tags; COMMAND 63-R lists Time, Project, Category, Tag, Center | COMMAND 63-R order supersedes the older order: Time → Project → Category → Tag → Center, rendered RTL. Preserve CR-004 as historical evidence. | RESOLVED for product contract; PR #3569 exact-head CI/device acceptance pending |
| CR-031 | Home header drift from REV10 | Current base header had title «آروین» plus a subtitle and a global-filter button; owner-approved identity is Bismillah capsule, exact title and physical header actions | Use Bismillah capsule, title «مدیریت کارها و پیگیری آروین», notification action physical-left, menu physical-right, search below. No legacy status cards. | RESOLVED for product contract; PR #3569 draft, notification inbox not implemented |
| CR-032 | Center schema-9 lineage vs current schema-17 | #3052 current code has Center model/store/page and scalar `projects.center_id`; no accepted `center_projects`, `project_categories` or `task_centers` M2M contract. #3550 remains open. | Do not copy schema-9 installers or rebuild tables blindly. Approve an additive schema-18 migration only after exact current-schema, unknown-field, rollback and backup review. | OPEN — design proposal only; #3550 OPEN |
| CR-033 | Person deletion as physical row delete vs directory exclusion | #3549/#3495 lineage proposed `person_directory_exclusions`; current #3052 has separate `persons` and `person_directory` tables | Removing a Person from the directory must preserve Person identity and all Task/Follow-up history. Use stable-ID exclusion tombstones; only explicit re-add clears the exclusion. | Implemented in Draft PR #3574; exact-head Build and device acceptance pending |
| CR-034 | Person exclusions in backup vs omission in v1 backup | Existing backup v1 payload contains active `peopleDirectory` but no exclusion set | Add optional `personDirectoryExclusions` while preserving old-backup compatibility; include normal/emergency snapshots and exact rollback; prove independent-file restore. | Implemented in Draft PR #3575; exact-head Build and Android export/import pending |
| CR-035 | Legacy `Task.reminderDate` constructor input vs canonical TaskReminder records | Task model treats reminderDate as a deprecated compatibility projection/input; canonical persistence is `taskReminders` with stable IDs and sequence | New fixtures and production writes use canonical TaskReminder records. Preserve legacy JSON migration separately; do not treat constructor-only reminderDate as durable storage. | Test corrections and migration in Draft PR #3570; exact-head CI pending |
| CR-036 | Variable-font assumption vs actual Vazirmatn v33.003 archive | Official v33.003 archive contains nine static TTF weight files; no variable font is registered by the app | Register all nine static weights 100–900 under one Vazirmatn family; include OFL and AUTHORS. Do not claim variable-font support. | Assets and manifest test in Draft PR #3573; APK/device rendering pending |
| CR-037 | Follow-up history vs legacy followUpEnabled boolean | Task.followUpEnabled is a deprecated computed compatibility getter reflecting whether canonical Follow-up history exists | Do not persist or assert a separate boolean state. A non-empty Follow-up history makes the compatibility getter true; preserve no-write-before-save behavior. | Test corrected in Draft PR #3570; exact-head CI pending |

No historical row was deleted or silently rewritten. Older CR-004 and CR-002 records remain preserved; this addendum records the newer COMMAND 63-R authority.
