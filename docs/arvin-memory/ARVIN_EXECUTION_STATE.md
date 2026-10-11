# LIVE CONTINUATION CHECKPOINT — 2026-10-11 18:27 Iran time

This checkpoint supersedes older PR-head snapshots and "Next action" entries below. Refresh all live GitHub state before future operations.

## Latest completed step
- Re-read this execution state first, then refreshed live PR #2591/#2595/#2600/#2601/#2602 and accepted RTLC issue #2605.
- Compared patches for #2591, #2595 and #2602 to identify shared files and data-contract risk. All three are still OPEN; #2591 and #2595/#2602 are Draft, #2595 is stacked on #2591. PR #2600 remains OPEN/DRAFT. Current reported heads: #2591 `eae0394163a958223b79fc3b7aa914f79b664b8a`; #2595 `0786a2e067594d92b35c6a3028c633e8abc9bb3d`; #2600 `0413c5a7b862d4e0718f67a2587ec8dc36b04429`; #2601 `b832aeb6e0f55c78db0b1814adc0d5bd63447c23`; #2602 `15c40a81ec7e45fe690de40ebbd9cf005e57af80`. Refresh before relying on them.
- Verified current main `a6ced27660d34cd87dd8915aff68d3a7555fd57a` and read `lib/models/task.dart`: canonical root Task has `description`, but no root `note`; it already has Notebook item-kind and scoped note concepts.
- Found a new unapproved data-contract change in #2595: adds root `Task.note`, modifies Task serialization/deserialization and TaskStore known keys, and changes backup/restore test expectations. Command v8 lists Task Description but does not authorize a second root field. This is a data/architecture gate, so do not silently approve it or propagate it.
- Posted review comments on #2595 and #2602 to keep both Draft and reconcile the overlapping form lane; comments: https://github.com/mobinpda-lab/Arvin-clean/pull/2595#issuecomment-6110326453 and https://github.com/mobinpda-lab/Arvin-clean/pull/2602#issuecomment-6110326886.
- Recorded the finding in `ARVIN_PROBLEM_REGISTER.md` (commit `4fa06f3f2feb3e368ef55116320e76ad235ee216`) and `ARVIN_DECISION_LOG.md` (commit `53a35664b40b1ab64ba9a8642663013056953fe3`) on the existing documentation branch. GitHub Read/Write access was used; no app code, main, APK, merge, or release was changed.

## Current status
- **Completed:** Cross-PR overlap/data-contract audit; comments posted; data-risk gate recorded in memory.
- **In Progress:** Universal time picker rollout and Task form reconciliation; RTLC integration remains accepted direction but not implemented/accepted; product and release evidence.
- **Blocked:** Approval of root `Task.note` vs existing `description` semantics and legacy data/backup mapping requires explicit product-owner decision. This is the stop condition defined by Command v8 (data risk/architecture change).
- **Current bottleneck:** Several Task Editor PRs overlap and #2595 introduces an unapproved Task data-contract change; #2602 previously failed three test shards and Device Smoke was skipped.
- **Next action:** Ask owner whether a separate root Task Note is intended in addition to Description. Until decided, continue only safe read-only patch/CI evidence work and documentation reconciliation; do not merge #2595/#2602 or propagate `Task.note`. After decision, consolidate to one canonical form/time-picker branch, fix test root causes without weakening tests, then integrate RTLC once and run exact-head CI + Device Smoke + physical-device acceptance.

---

## Documentation audit writeback — 2026-10-11

- Conversation-decision history was added at `docs/arvin-memory/ARVIN_CONVERSATION_DECISION_HISTORY.md`, commit `cef2a03e7d4f0dd73cbefad796e0393c8723267d`; read-back verified time-picker and checklist requirements are present.
- `ARVIN_PROBLEM_REGISTER.md` addendum committed at `abfe3d719eed8ec134c26fd82ba8d432bd83e315`; `ARVIN_EVIDENCE_MAP.md` addendum committed at `7933bf44f36fdfed1da9b4e918acd0218a28bbb6`.
- PR #2600 audit comment posted: https://github.com/mobinpda-lab/Arvin-clean/pull/2600#issuecomment-6109981897.
- Current memory branch has been updated but is still not main; re-fetch current head before any later write. No application code, APK, merge or release change was made.

# DEEP CONVERSATION AUDIT CHECKPOINT — 2026-10-11 (supersedes stale next-action notes below)

## Owner request
The owner explicitly asked for a meticulous review of this conversation so no requirement, prior finding, or dependency is missed. This checkpoint records that audit and corrects earlier stale notes below; use live GitHub before every subsequent action.

## GitHub Read/Write and live repository reality
- Read/Write access verified in this run. All writes are limited to the existing documentation branch `docs/arvin-autonomous-memory-20261011`; no write to `main`, no app code edit, no APK build, and no release/merge performed.
- Latest main commit confirmed by commit search: `a6ced27660d34cd87dd8915aff68d3a7555fd57a`. `main` does not yet contain this `docs/arvin-memory/` checkpoint.
- PR #2600 is OPEN/DRAFT, branch `docs/arvin-autonomous-memory-20261011`, head `40963f0fe54ba8d34375c1c6c7fc62c01f27b627`, base SHA `72a2f4cc24df7a38eff9856ce403461615db5280` (stale versus main). Do not merge until rebase/reconciliation and validation.
- Documentation PRs #2598 (`32860ad0a07778d210ba1dac4caf2dc68effccc5`), #2599 (`bd03c61749f4cf093f25251330a54ca773f48c7f`) and #2600 overlap and are all based on old main `72a2f4c...`. Reconcile into one consistent authority hierarchy; do not create competing status/roadmap/memory sources.
- #2590 is OPEN (not merged), head `1810e454a20e29eec837be9ac446e222795d79f8`; #2591 is OPEN/DRAFT, head `eae0394163a958223b79fc3b7aa914f79b664b8a`; #2595 is OPEN/DRAFT, head `0786a2e067594d92b35c6a3028c633e8abc9bb3d`, stacked on #2591; #2602 is OPEN/DRAFT, head `15c40a81ec7e45fe690de40ebbd9cf005e57af80`; #2601 is OPEN, head `b832aeb6e0f55c78db0b1814adc0d5bd63447c23`. Each still has stale base `72a2f4c...` except #2595's base is the earlier #2591 head `0c43dfbe3c0f7188cea6e03614300be81271e158`.
- Latest recorded #2602 CI: Build #38139809938 passed Analyze and Debug/Release APK jobs but failed three test shards; Device Smoke #38139809930 was skipped. Failures include missing repeat control keys, automatic/manual reminder behavior, date-only All-Day persistence, custom Clock Dial test, and taxonomy row width 99.33px vs >270px expectation. Do not merge or weaken tests.
- RTLC decision #2605 is OPEN and explicitly accepted as product direction, not implemented/accepted. Existing `RecurrenceTrackingLevel` JSON field and history/checklist foundations must be reused; keep `followUpEnabled` distinct.
- Release gate #2102 and owner acceptance ledger #1139 remain open. Main-head workflow/status lookup previously returned no PR-associated runs/statuses; that is missing evidence, not a pass. Physical-device acceptance and owner release approval remain unverified.

## Audit findings: important items that must not be lost
1. **Universal time picker (P0 product consistency):** #2589 is accepted UX direction, implementation PR #2591 and docs PR #2590 remain open. Audit all direct/custom time pickers and passive time formatting, including Home filters, Backup Schedule, Follow-up, Reports, Task Editor and Quick Capture. Preserve canonical Task times, reminder/follow-up/repeat/calendar/backup behavior; Persian digits, RTL, 24-hour dial, exact-minute entry, contextual title, cancel/save safety, and real-device proof are required. Existing audit says six direct `showTimePicker` call sites remained on main; recheck current source before action.
2. **Task form overlap and acceptance:** #2595 and #2602 touch the same form; #2595 depends on #2591. Choose one canonical branch only after comparing live diffs/heads. Keep quick entry minimal and Full Form editing the same Task; do not duplicate Tasks. Progressive disclosure must not hide or break date/time, All-Day, reminder, repeat, priority or checklist.
3. **Repeat Tracking Level (RTLC):** after Repeat, selector «نوع پیگیری» → «عادی» default / «مهم و قابل پیگیری»; use existing `recurrence.trackingLevel`. Then separately audit Home's restrained cue and Report Center filters/metrics. Preserve Task ID, occurrence history immutability, per-occurrence checklist isolation, and backup compatibility. Do not conflate with Follow-up.
4. **Calendar installed-app regression:** owner reported missing «ویرایش» and «ثبت در تقویم گوشی», and recurrence showing only current day rather than planned days (up to seven). #2587 and #2570 are merged in current mainline, but this is code status only; #2535 and #1139 remain acceptance gates. Test action visibility, all scheduled dates, stable linked-event update/no duplicates on physical device.
5. **Backup/restore P0:** #2585 is merged at current main SHA, and #2587 is merged at `c57606c...`. Still unverified: physical Android system file-picker/provider, export/restore round-trip, late-stage rollback, preservation of IDs/relations/settings/notebook checklists/catalogs/calendar links, and before/after integrity.
6. **Reports:** #2385 remains open. Extend existing canonical report/filter/print/share/PDF paths; do not create a second report model/engine. RTLC report filtering/metrics are an additional acceptance gate.
7. **Taxonomy:** Project, Category, Tag are canonical; Category = Group synonym, no fourth Group entity/store. Verify actual schema; do not infer a Project foreign key. RTL selector order and width must be genuinely usable at target phone viewport.
8. **Visual/product contract:** preserve Persian RTL and VazirHarf v34.003 (do not replace with Vazirmatn), approved palette (#4A4CAB, #E9EAFF, #F8F8FB, #FDFDFE, #232433, #80829C), Home's four axes Time/Project/Category/Tag, no obsolete stats cards/title/dropdown, clock + calendar icons side-by-side in every create/edit form, and approved reminder widget/lock-screen actions. Color-only changes do not satisfy redesign acceptance.
9. **Checklist requirement:** checklist remains part of Task. The owner requested a high-priority checklist directly under the full/edit Task form, generic for all Tasks (example: daily school checklist active at 06:00 with کیف/خوراکی/لباس). Recurrence occurrence state must remain independent; do not create a separate checklist subsystem.
10. **Release handover:** before final handover, require release notes, installation guide, user guide, known issues, architecture summary and evidence report, tied to an exact candidate artifact and explicit owner acceptance.

## Completed audit step
Compared the current Command v8 against the existing memory documents, decision records, live issues and overlapping PR state. Found that earlier snapshots contain contradictory/stale claims and that the conversation decision-history file is not present on this memory branch. The new decision-history document is being added on this existing branch to close that memory gap; it is an index of decisions, not implementation evidence.

## Next action
1. Read back the new conversation decision-history file and this updated state from this exact branch.
2. Comment on #2600 with the audited gaps and stale-base/documentation hierarchy.
3. Select one canonical task-form implementation lane after diff/test comparison; repair #2602 root causes without weakening tests, then integrate RTLC once.
4. Recover/run exact-current-main Build + Device Smoke evidence; continue physical-device and owner acceptance gates.
5. Reconcile/rebase docs PRs before any merge. Do not claim final/release-ready until product evidence and owner acceptance exist.

---

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

## Fresh CI checkpoint — PR #2602 exact head (2026-10-11)
- Checked workflow run [#38139809938](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38139809938) for PR #2602 head `15c40a81ec7e45fe690de40ebbd9cf005e57af80`: Debug and Release APK jobs passed, but overall Build failed because three quality test shards failed. Device Smoke [#38139809930](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38139809930) was skipped.
- Confirmed failures: repeat lifecycle control key missing; recurrence RollBox key missing; automatic/manual reminder tests failed; date-only All-Day persistence failed; custom due-time Clock Dial test failed; RTL taxonomy row width expected >270 px but actual 99.33 px.
- Recorded exact evidence in PR #2602 comment [#6109904220](https://github.com/mobinpda-lab/Arvin-clean/pull/2602#issuecomment-6109904220). Do not merge or weaken tests; fix reachability/date-time/layout root causes and rerun all shards + Device Smoke.



## OWNER DECISION UPDATE — 2026-10-11

### Completed: Task Description vs Note decision
- Owner selected **Option 1**: retain only the existing root Task `description`; do not add a separate root `Task.note`.
- This supersedes the earlier “Blocked: ask owner” next-action text in historical checkpoints. The product decision is resolved; implementation cleanup and validation remain outstanding.
- Required follow-through: comment on #2595 and #2602; remove/revert root `Task.note` plus serialization/TaskStore/backup changes that exist only to support it; preserve existing Notebook/FollowUp note behavior; run exact-head tests/build and inspect backup/restore compatibility. Do not weaken tests or merge/release without evidence.
- GitHub Read/Write access used for recording this decision. App code has not yet been changed by this decision-recording step.

## OWNER DECISION — 2026-10-11 (supersedes earlier decision gate)
- Owner selected Option 1: keep the existing root `Task.description` as the only root Task text field; do not add a root `Task.note`.
- This resolves the prior owner-decision gate. Scoped `FollowUp.note` and Notebook note/checklist concepts remain unchanged; this decision does not authorize deleting or migrating those scoped fields.
- Required implementation on the canonical Task-form lane: remove only the newly introduced root `Task.note` from the Task model, JSON serialization/deserialization, TaskStore known-key handling, editor UI/state, and backup/restore test changes. Preserve legacy payload safety and existing Description values; add/retain regression tests proving legacy JSON and backup/restore round-trip still work without a second root field.
- PR #2595 must remain Draft until this correction and exact-head Analyze, all test shards, Debug/Release APK and relevant device smoke are verified. PR #2602 must not reintroduce the root field and its previously failing test shards must be fixed at root cause; never weaken assertions.
- Current execution result: decision resolved and documented; implementation patch not yet applied or validated in this step. No merge, main write, APK build, or release occurred.
