# LIVE CONTINUATION CHECKPOINT — 2026-10-11

This section supersedes conflicting older snapshots below. The detailed earlier notes are historical context and must not be treated as current status without rechecking.

## Startup result
- Repository: `mobinpda-lab/Arvin-clean`; branch checked: `main`.
- Current main SHA: `a6ced27660d34cd87dd8915aff68d3a7555fd57a` — https://github.com/mobinpda-lab/Arvin-clean/commit/a6ced27660d34cd87dd8915aff68d3a7555fd57a
- GitHub access: Read/Write verified; this checkpoint update is being committed only to the existing documentation branch for PR #2600, not directly to main.
- PR #2585 backup/restore safety is MERGED at `a6ced276...`.
- PR #2587 Calendar collapsed-card actions/recurrence is MERGED at `c57606c223a1d6141bd3d11e1a75cc5cda428470`.
- The main-head Actions wrapper returned no PR-associated workflow runs and combined status returned no statuses for `a6ced276...`; this is **no current-head CI evidence from those lookups**, not proof that no workflow exists or ever ran.
- PR #2600 (this memory branch) remains OPEN/DRAFT and is based on old main `72a2f4cc...`; it must be rebased/reconciled against current main before merge.
- PR #2598 (AMPOP/governance), #2599 (repository audit), and #2600 (memory) are three overlapping OPEN/DRAFT documentation PRs based on the old main. Keep them unmerged until they form one consistent hierarchy and avoid competing status/roadmap/memory copies.
- PR #2601 integrated APK candidate remains OPEN and is based on old main; it is not a release artifact accepted for delivery.
- PR #2602 task-editor changes remain OPEN/DRAFT. The latest recorded Build passed Analyze and APK builds but failed three test shards; Device Smoke was skipped. Do not merge. Fix repeat/reminder reachability, date/time behavior and RTL taxonomy layout; reconcile overlap with PR #2595.
- PR #2595 overlaps task form changes and is stacked on PR #2591 shared time picker. Keep one canonical implementation and validate the final combined head. PR #2591 still lacks verified physical-device acceptance.
- Owner acceptance/release blockers remain in #1139 and #2102; Calendar installed-device recurrence/actions in #2535; advanced Report Center in #2385; taxonomy conformance audit in #2580; repeat/checklist lifecycle acceptance in #2254.
- Physical Android-device acceptance, exact-current-main Build/Device Smoke evidence, complete Golden Flow, full restore round-trip/rollback proof, and final owner acceptance remain NOT VERIFIED.

## Last completed step
Re-read the requested Autonomous Delivery & Evolution Command against live GitHub, read the memory state/evidence map on the existing PR #2600 branch, checked the main commit history, and refreshed PR/issue state. Confirmed that the six-file memory set is incomplete on this branch: `ARVIN_PROBLEM_REGISTER.md` is missing.

## Next action
1. Complete the existing memory branch with a problem register and this live checkpoint.
2. Read back both changes and verify exact commit/file paths.
3. Comment on PR #2600 with the stale-base and documentation-hierarchy blockers.
4. Continue with the highest-priority product gate: recover exact-current-main CI/Device Smoke evidence and reconcile the task-editor PR overlap; do not claim release readiness.

## Current bottleneck
Release evidence and owner acceptance, not lack of another architecture or another workflow. Do not create a new factory or parallel implementation.



Updated: 2026-10-11 (live GitHub recheck; exact-head Build passed, Device Smoke partially complete)
Repository: https://github.com/mobinpda-lab/Arvin-clean
GitHub access: Read/Write verified by live operations.
Authority: live GitHub refs, source, tests and workflow evidence.

## Live recheck — 2026-10-11 13:40 Iran time

- Re-read this state and evidence map on the existing memory branch; confirmed PR #2600 is the intended documentation-only continuation path. The file is not yet on `main`.
- Main remains `72a2f4cc24df7a38eff9856ce403461615db5280`.
- PR #2585 exact head checked: `5f59d7c7edb12217a2aa3f7a139a042676dc0e76`. Build run [38130522723](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38130522723) is complete and successful: Analyze, all six test shards, Debug APK and Release APK.
- Device Smoke run [38130522703](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38130522703) is still in progress. Home, Quick Capture and SQL Persistence passed; SQL Migration and Backup/Restore are in progress; People is queued. Do not call the full smoke suite passed.
- No physical-device or actual Android system file-picker/provider acceptance was found. Release remains blocked; PR #2585 and #2587 remain unmerged.
- The live Build/Smoke runs above supersede the older pending status recorded below where they conflict.

## Current release state
**IN PROGRESS — RELEASE BLOCKED.** No physical-device acceptance has been provided.

## Last completed step
- Read this state and `ARVIN_EVIDENCE_MAP.md` first, then rechecked PR #2585, Issue #2580, the relevant backup/settings/task/notebook sources, and current-head Actions.
- Owner approval for standalone Category/Tag portability was already recorded in PR #2585 and Issue #2580. The later owner-approved expansion requires notes/notebook checklists and portable app settings, stable-ID reconciliation, preservation of local-only records, omitted-key safety for legacy settings, and rollback across stores.
- Implemented in the existing branch `fix-backup-taxonomy-catalogs-20261010`, without a parallel restore engine:
  - `ArvinBackupManager.reconcileTasksById`: matching Task IDs update, backup-only Tasks add, local-only Tasks remain.
  - Project reconciliation uses stable Project IDs and preserves memberships for local-only Tasks.
  - Settings merge only applies supplied keys, including nested Calendar, backup schedule and Daily Content preferences. Explicit nullable defaults are serialized; older backups that omit a key do not reset it.
  - Daily Content preferences are included in foreground and scheduled backup payloads and validated before restore writes.
  - Scheduled backups now include Calendar-link metadata and canonical Category/Tag catalogs in addition to Tasks, Projects and portable settings.
  - Added tests for Task/Project reconciliation, local-only Notebook/checklist retention, partial legacy settings, explicit nullable settings and scheduled-backup payload contents.
- Current code PR #2585 head: `5f59d7c7edb12217a2aa3f7a139a042676dc0e76`. Exact-head Analyze and all six test shards are SUCCESS; Debug APK is SUCCESS; Release APK is still IN_PROGRESS. Device Smoke: Home and Quick Capture are SUCCESS; SQL Migration and SQL Persistence are IN_PROGRESS; Backup/Restore and People are QUEUED. These are emulator/CI results, not physical-device acceptance. Previous exact heads exposed stale settings/replace-only test expectations; these were updated to the approved ID-reconciliation contract before the current head.
- PR #2585 remains OPEN / NOT MERGED. CI and emulator results do not prove real Android system file-picker/provider acceptance.
- Main base observed for PR #2585: `72a2f4cc24df7a38eff9856ce403461615db5280` (documentation-only PCTADP decision registration).
- Calendar linked-event edit [PR #2570](https://github.com/mobinpda-lab/Arvin-clean/pull/2570) is merged at [`34a6cee`](https://github.com/mobinpda-lab/Arvin-clean/commit/34a6cee9ae05ad1cf632960b96e98f2a5448e128); physical-device proof remains absent.
- Calendar action visibility/recurrence [PR #2587](https://github.com/mobinpda-lab/Arvin-clean/pull/2587) remains OPEN / NOT MERGED at `4442ce450e4295e500a9db6d5dc5b4d9657b3770`; historical exact-head Build #38089112669 and Device Smoke #38089112675 succeeded across emulator lanes. Physical-device acceptance remains absent.
- Memory documentation [PR #2600](https://github.com/mobinpda-lab/Arvin-clean/pull/2600) remains OPEN / DRAFT; this state refresh is on its existing documentation branch.

## Current GitHub reality
- [Issue #2580](https://github.com/mobinpda-lab/Arvin-clean/issues/2580) remains open for the repository-wide Project/Category/Tag ontology audit. Owner approval for unused Category/Tag portability is recorded.
- [PR #2585](https://github.com/mobinpda-lab/Arvin-clean/pull/2585) is the sole implementation path for backup/restore changes. Current head `5f59d7c7edb12217a2aa3f7a139a042676dc0e76`; exact-head Analyze and all six test shards succeeded, Debug APK succeeded, Release APK and four Device Smoke lanes remain pending/in progress at the latest live check.
- Existing canonical storage remains authoritative: Tasks/Notebook items use TaskStore; Projects use ProjectStore; Category/Tag catalogs use TaskStore; Calendar-link identity uses ExternalCalendarLinkStore. No duplicate storage or restore engine was added.
- Notes and Notebook checklists are canonical Task records; backup paths load the full TaskStore rather than a filtered Home projection.
- Portable settings currently include AppSettingsService values, backup schedule and Daily Content preferences. Device-bound folder/provider URIs, secrets and transient encryption passphrases are not portable settings.
- Catalog merge remains additive and backward-compatible; formatVersion remains 1 and older backups may omit optional catalog/settings fields.

## Taxonomy audit findings (partial)
- `lib/models/task.dart`: `Task.category` and `Task.tags` are separate.
- `lib/models/goal_project.dart`: Project membership stores canonical Task IDs in `itemIds`; this model does not declare a Category relation.
- `lib/home/grouping/home_grouping_service.dart`: `HomeGroup<Task>` is a presentation grouping abstraction, not proof of a fourth domain entity.
- `lib/services/task_store.dart`: canonical Category catalog uses SQL `taxonomy_categories`; canonical Tag catalog uses SQL `tags`.
- `lib/services/tag_store.dart` defines legacy SharedPreferences key `arvin.tags`, but current search found no caller; migration derives SQL Tag rows from `Task.tags`, not `arvin.tags`. Keep this as a low-confidence legacy candidate and do not delete/migrate it without evidence it was populated by a shipped path.
- Source review confirmed the original backup gap for unused standalone Category/Tag catalog entries. The existing PR now serializes these catalog values and merges them additively with regression coverage. Exact-head tests are still pending.
- Do not infer a physical Category-to-Project foreign key from the semantic hierarchy. Do not mass-replace “group”; classify domain, user-facing, presentation, generic technical and historical uses first.

## In progress
1. Complete exact-head Build for PR #2585: Analyze, all six test shards, Debug APK and Release APK.
2. Complete exact-head Android Device Smoke; inspect any failing shard/job and repair safely before claiming success.
3. Verify backup/restore round-trip with legacy v1 backups, unused + assigned catalogs, settings, notes/checklists, stable-ID reconciliation and late-stage rollback.
4. Complete physical Android system file-picker/provider and before/after data-integrity acceptance; emulator smoke is not a substitute.
5. Continue the repository-wide Project/Category/Tag audit and keep PR #2585 and #2587 open until physical acceptance is evidenced.

## Blocked / unproven
- Exact-head Release APK and Device Smoke for `5f59d7c7edb12217a2aa3f7a139a042676dc0e76` are still running/queued at the latest live check.
- Physical Android file-picker/provider backup and restore, failed-restore recovery and real data-integrity acceptance.
- Physical-device Calendar same-ID edit/no-duplicate behavior, action visibility, recurrence/checklist acceptance.
- Full Golden Flow: Task → time → Project → Checklist → Repeat → Tracking → Calendar → Backup → Restore.
- Full taxonomy conformance inventory and final release handover/owner acceptance.

## Next actions
- Poll exact-head Actions for `5f59d7c7edb12217a2aa3f7a139a042676dc0e76`; use only evidence attached to that exact head. If Release APK and Device Smoke settle, refresh this checkpoint and the evidence map.
- If any job fails, inspect its log, fix the root cause in the same PR, and rerun validation on the new head.
- Update the evidence map after Build/Smoke settles, then continue physical-device acceptance and remaining taxonomy audit.
- Keep PRs open/unmerged; never claim release readiness from CI alone.

## Risk rules
Task remains the source of truth for Tasks and Notebook items; Calendar is a projection; Repeat must not create copied Tasks; preserve stable Task ID and external event ID. No merge/release based on CI alone. Never claim user/device acceptance without direct evidence.

## LIVE CONTINUATION CHECKPOINT — 2026-10-11 (Command v8 + RTLC)

This section supersedes earlier next-action text where it conflicts. Do not restart analysis; continue from this checkpoint after a live recheck.

### Latest verified repository state
- Repository: `mobinpda-lab/Arvin-clean`; default branch: `main`.
- Latest main commit returned by GitHub commit search: `a6ced27660d34cd87dd8915aff68d3a7555fd57a` (`fix(backup): preserve portable user data with safe restore`). The preceding mainline commit found was `c57606c223a1d6141bd3d11e1a75cc5cda428470` for Calendar collapsed-card actions/recurrence.
- GitHub Read/Write access is active. This update is restricted to the existing documentation branch for PR #2600; no direct main write is intended.
- Memory files are not present at the corresponding paths on main yet; the current memory branch is `docs/arvin-autonomous-memory-20261011`, PR #2600 OPEN/DRAFT, head `b285719410d380aa1f5d0df7c625493c243a3b12`, base SHA `72a2f4cc24df7a38eff9856ce403461615db5280`. This stale base must be reconciled before merge.
- Overlapping documentation PRs #2598/#2599/#2600 must be consolidated/reconciled before merge; do not merge stale documentation blindly.

### Latest completed step
- Read the owner-provided Autonomous Delivery & Evolution Command v8.
- Located the existing persistent-memory branch/PR rather than creating a parallel memory system.
- Registered the accepted Repeat Tracking Level Contract as [Decision Issue #2605](https://github.com/mobinpda-lab/Arvin-clean/issues/2605), and recorded the decision against existing repeat work #2254 and Task editor work #2593.
- Read-only source audit confirmed that `RecurrenceTrackingLevel { normal, tracking }` already exists in `lib/models/recurrence.dart`, persists within the existing `Task.recurrence` JSON, and defaults to normal for older JSON. `Task` already carries `occurrenceHistory` and `checklistOccurrences`; recurrence repository/page and tests cover some tracking/progress behavior. Do not rebuild these.
- Source search did not find direct tracking-level integration in `lib/task_editor_dialog.dart`, `lib/report_center_page.dart` or Home. This is an integration audit target, not proof that no indirect path exists.
- Explicitly preserve the distinction between Follow-up and Repeat tracking: `followUpEnabled` must not be used as a substitute for `recurrence.trackingLevel`.
- Audit comments were recorded on #2605 and #2254. No application code, schema, database, engine or APK changed in this step; no tests/build/device validation were run for RTLC.

### Current completed / in progress / blocked
- COMPLETED: RTLC product decision registration; first-pass source audit; existing model and persistence support identified.
- IN PROGRESS: update this memory PR with the latest continuation checkpoint and RTLC decision/knowledge/problem/evidence records.
- BLOCKED / NOT VERIFIED: tracking-level integration in full Task Create/Edit, Home cue, Report Center filter and validated missed/remaining/upcoming metrics; full occurrence-history/checklist immutability tests; RTLC backup/restore round-trip; screenshots and physical-device acceptance.
- RELEASE BLOCKED: exact-current-main CI/device evidence and physical-device/owner acceptance remain required. Main-head status lookup is not sufficient to claim a pass.

### Next action — ordered
1. Read back and verify the memory-branch documentation commits and comment on PR #2600 about stale base/documentation hierarchy.
2. Inspect current PR #2591/#2595/#2602 heads and overlap; do not launch conflicting edits or merge failing/stale branches.
3. Continue RTLC with focused integration of the existing `recurrence.trackingLevel` into Task Create/Edit after Repeat, defaulting to «عادی». Keep Follow-up separate. Add/adjust tests for selection and JSON round-trip before widening to Home and Report Center.
4. Derive missed/remaining/upcoming metrics from canonical repeat/history projections; if definitions or model semantics are insufficient, document the exact gap before any protected model/engine/storage change.
5. Validate exact-head tests/build, backup/restore compatibility, screenshots and device behavior. Do not claim done until evidence and owner acceptance exist.

### Current bottleneck
Product acceptance and proof on the current exact head—not another parallel architecture or factory. Keep Task as source of truth, Repeat as Task behavior, occurrence checklist state independent, past history immutable and future settings adjustable.

