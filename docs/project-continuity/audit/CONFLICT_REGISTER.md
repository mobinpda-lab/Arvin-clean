## Additional source conflict — typography

| ID | Conflict | Evidence | Current classification | Safe action |
|---|---|---|---|---|
| CR-027 | VazirHarf v34.003 vs Vazirmatn | Direct owner instruction 2026-09-06: VazirHarf v34.003, replace all Vazirmatn references; current PRODUCT_DECISIONS.md claims later Vazirmatn approvals on 2026-11-05/08 without Decision ID or linked primary source. Code uses Vazirmatn. | NEEDS OWNER-SOURCE RECONCILIATION | Preserve both histories; do not alter font assets/code until the latest direct decision is traceable. |

Source implementation: `pubspec.yaml`, `lib/theme/app_fonts.dart`, `lib/core/theme/arvin_theme.dart`; `test/vazirharf_settings_convergence_test.dart` currently asserts Vazirmatn despite its VazirHarf-oriented filename. Open font-related PRs include #2975, #2918 and #2932; review their scope against the final owner decision. No font code or tests were changed.

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
| CR-002 | Blue / Teal / Sky Blue | REV7.1 owner direction `#4169A1`; 2026-11-08 contract `#3A86EF`; 2026-11-09 Persian Teal `#0F766E` ledger entry | Active primary remains Blue `#4169A1` per latest explicit owner direction | RESOLVED for active token; historical entries retained |
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


---

## REV9 source conflict reconciliation — 2026-11-10

| ID | Conflict | Evidence | Current classification | Safe disposition |
|---|---|---|---|---|
| CR-028 | Primary brand color | REV9 §33 specifies Primary Blue #4169A1 and explicitly rejects old teal as primary; PRODUCT_DECISIONS.md contains a 2026-11-09 Persian Teal record but also records Blue #4169A1 as active under the latest owner direction. | APPROVED: #4169A1; teal primary record HISTORICAL/SUPERSEDED where conflicting. | Preserve teal history; use #4169A1 as current charter token. |
| CR-029 | Vazirmatn vs VazirHarf | Issue #2974 and PR #2918/#2975/#2932 record earlier Vazirmatn approval; REV9 §32 explicitly says conflict remains NEEDS OWNER DECISION. | NEEDS OWNER DECISION under latest owner charter. | Do not choose or alter font. Await explicit Mobin resolution. |
| CR-030 | Multiple open documentation authorities | PR #3022, #2598, #2600, #2866 remain open/unmerged; their documents propose distinct governance/product references. | HISTORICAL / PROPOSAL until owner reconciliation. | Preserve links and do not silently merge their authority. |
| CR-031 | 48dp hit-target standard vs historical 40dp controls | REV9 §31 sets 48dp × 48dp; historical continuity records include smaller controls. | APPROVED requirement; implementation gap to verify. | No code/test change in docs-only mission; record future UX audit. |
| CR-032 | REV9 product waves 0–4 vs REV8 engineering waves 0–5 | REV9 §42 defines product taxonomy; REV8 roadmap tracks engineering execution. | Both retained with distinct meanings. | Do not overwrite engineering history or conflate it with product taxonomy. |
| CR-033 | Reminder four-state state machine | REV9 §12 states exact four-state names/transitions are not established by accessible canonical source. | NEEDS OWNER DECISION. | No guessed states or transitions. |

No historical decision has been deleted. Status changes are explicit and traceable.


## REV10 reconciliation — 2026-11-13

| ID | Conflict | Older source / status | REV10 resolution | Required action |
|---|---|---|---|---|
| CR-034 | Active master REV9 vs latest owner charter | REV9 active in PR #3340; not merged to Main. | REV9 becomes SUPERSEDED as active master; preserved verbatim in MASTER_GOVERNANCE_REV9_ARCHIVE.md. REV10 is active. | Keep #3340 unmerged until its history is incorporated; use the REV10 branch as the successor. |
| CR-035 | v49.1 operating package vs REV9/REV10 governance line | PR #3388 is a separate open documentation branch from Main. | v49.1 operational rules are subordinate to REV10; contradictory limits are superseded. | Reconcile paths and adapters before any documentation promotion; do not merge both competing lines blindly. |
| CR-036 | Four Home filter dimensions vs five global filters | Older Home contracts specify Time/Project/Category/Tag. | SUPERSEDED: Time/Center/Project/Category/Tag is the approved five-filter order everywhere. | Update Home, Calendar, Reports, Follow-up Office, tests and help together. |
| CR-037 | Branch as fifth filter vs Center as fifth filter | Older terminology in historical reports/specifications. | SUPERSEDED: fifth filter is Center; Branch is not the official filter dimension. | Remove only after consumer inventory and safe contract migration. |
| CR-038 | Vazirmatn/VazirHarf unresolved font choice | REV9-004 NEEDS OWNER DECISION. | SUPERSEDED: Vazirmatn sole official/default font; System Default optional; VazirHarf not official. | Preserve assets/provenance as history; verify active references, PDF and APK on exact SHA. |
| CR-039 | Documentation-only autonomy vs continuous development | Older AI policy §4/mission boundary. | SUPERSEDED by REV10 §14 continuous development authorization. | Continue ordinary development on non-main branches; restricted operations remain blocked. |
| CR-040 | Task mandatory organization vs optional links | Any older assumption that Task must have Project/Category. | SUPERSEDED: Center/Project/Category each optional 0..1; Tags 0..N. | Enforce hierarchy ownership at SQL level and test valid/invalid combinations directly. |
| CR-041 | Task Detail horizontal filters or independent Edit Mode | Older visual/interaction assumptions. | SUPERSEDED: single-column detail; organizational order Center/Project/Category/Tag; direct Auto-Save. | Keep Home filter layout separate from Task Details. |

No historical wording was deleted to hide a conflict. Every superseded rule remains traceable to its source.
