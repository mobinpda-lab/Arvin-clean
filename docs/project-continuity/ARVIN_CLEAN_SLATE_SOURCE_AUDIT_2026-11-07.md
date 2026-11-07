# ARVIN — Source Audit After PO Clean-Slate Authorization
**Audit date:** 2026-11-07  
**Audited branch:** `fix/recovery-calendar-device-smoke-2026-10-31`  
**Audit checkpoint commit:** `f4c1b0e9ff477b7ffb4fc733495f3e687d0e1f1e`  
**Governing issue:** #823 · **PR:** #3052  
**Release:** **BLOCKED — RELEASE: NO-GO**

## 1. Scope and evidence discipline

This is a read-only source audit performed after recording the product-owner authorization. Findings below are directly supported by the source files and blob revisions listed. The audit did not execute DDL, change runtime models, alter test expectations, or claim CI/device acceptance. Structural schema refactoring is now authorized, but not yet implemented.

## 2. Database and canonical-model findings

### Confirmed structural debt

| Area | Source evidence | Finding |
|---|---|---|
| Drift schema | `lib/services/g1_drift_schema.dart`, schema version 11, blob `ee2b4d806b5b4700729a52bae2eb1c590a08f401` | `tasks` still has `follow_up_enabled`, `follow_up_date`, and singular `reminder_date`; `follow_ups` still has `reminder_date` and `next_follow_up`. |
| FollowUp model | `lib/models/task.dart`, blob `c2cd07069cb3be60d4851037c31726ffb9124363` | `FollowUp` still exposes and serializes `reminderDate` and `nextFollowUp`; the historical timestamp is still represented by `dateTime` with `completedAt` as an alias. |
| Task model | same file/blob | `Task` still exposes `followUpEnabled`, `followUpDate`, legacy singular `reminderDate`, and legacy reminder migration version fields. |
| Task persistence | `lib/services/task_store.dart`, blob `e9cd33d6e5c08cf8815ad8658fe949f0e78dece1` | Insert/decode paths still write/read the legacy task columns and map deprecated Follow-up scheduling fields. |
| Reminder normalization | `lib/models/task.dart` and `task_store.dart` | `TaskReminder` exists, but the Drift schema has no dedicated `task_reminders` relation table in the inspected schema. Independent reminder records are currently carried through the task JSON envelope, alongside a legacy singular-reminder bridge. |
| Person relationship | `task_people`, `people`, `follow_up_people` in G1 schema; `Task.people` in model | Related-person relationships exist, but they are not a canonical Task assignee relationship. |
| Task Details | `lib/task_detail_page.dart`, blob `d71655090547a8983c37812578defa6f060f9ab1` | The responsible-person card explicitly states that no independent assignee is registered. Checklist save code still protects legacy follow-up scheduling fields. |

### Required schema/model alignment

1. Define the canonical `Task` table and its actual relations without `follow_up_enabled`, `follow_up_date`, or singular legacy `reminder_date` columns.
2. Give independent `TaskReminder` records a first-class relational persistence contract, including stable ID, Task FK, date/time, all-day, enabled state, and ordering/sequence.
3. Define `FollowUpRecord` as historical-only with canonical `completed_at`; remove future reminder/scheduling fields from its model, table, codec, queries, and UI.
4. Remove compatibility bridges and migration-version flags only after all read/write call sites and tests are moved to canonical paths.
5. Define the Unified Person Entity and distinguish generic related people from an assignee relation. Do not invent assignee data.
6. Replace schema initialization/rebuild strategy coherently; avoid leaving old columns in a fresh schema or maintaining parallel sources of truth.

## 3. UI/UX source findings

### Home
- `lib/home/home_filter_ui.dart` defines Home-specific filter controls and a `HomeFilterSheet`; its source comments describe reuse among Home dimensions.
- The Home screen state in `lib/main.dart` maintains separate sets for time, center, project, category, and tag selections.
- A globally reusable `ReusableMultiSelectFilterBottomSheet` shared across Home, Calendar, and other applicable screens was not established by the inspected source. The universal component remains an implementation gap.
- The Home single-row 360–412dp requirement and the exact new header/title/subtitle contract require exact-head visual/widget verification; source presence alone is not acceptance.

### Calendar
- `lib/calendar_page.dart` has the five source/content filters (All, Arvin Calendar, Device Calendar, Reminders, Incomplete) and the sacred phrase SVG.
- The current semantics label is `وَأُفَوِّضُ أَمْرِي إِلَى اللَّهِ`, which differs from the newly mandated exact wording `أُفَوِّضُ أَمْرِي إِلَى اللَّهِ` by the leading waw.
- Calendar layout, triple-date alignment, lunar offset preference, search/date positions, and four view modes require a full acceptance pass against the new contract.

### Task Details
- The source has an inline-editing implementation path and a dedicated checklist interaction path, but the responsible-person card is currently an explicit no-assignee placeholder.
- The five summary cards, complete structured section order, and no-navigation inline transition require exact-source and widget verification against the newly unified contract.
- The current checklist path contains legacy-field protection logic that should disappear after the canonical model refactor.

### Local P2P
- `docs/project-continuity/LOCAL_P2P_SYNC_SPECIFICATION.md` describes Phase 1 architecture and safety constraints.
- The new owner directive narrows current delivery to P2P-0 documentation/architecture audit only. This work is explicitly not a blocker for local UI/UX smoke and does not authorize cloud sync implementation.

## 4. CI and Device Smoke evidence

### New documentation checkpoint
- Commit: `f4c1b0e9ff477b7ffb4fc733495f3e687d0e1f1e`.
- Exact-commit PR workflow query returned zero workflow runs.
- Exact-commit combined status query returned zero status checks.
- Therefore Build/Analyze/test/APK/Device Smoke on this documentation commit are **NOT VERIFIED**.

### Latest previously documented evidence (not transferable)
- Build run `42370095017` on source SHA `abecec1ec895e6c7df83913247c1cc9ecc083d02`: SUCCESS; Analyze and Visual SUCCESS; six test shards 1,271 / 1,271 passed.
- Device Smoke run `42370095088` targeted the same SHA and was PENDING with zero jobs at the time of the recorded checkpoint.
- The prior checkpoint explicitly states that the emulator workflow runs on GitHub-hosted Ubuntu with an Android API 35 emulator. It does not prove a physical Samsung SM-A528B/DS run.
- The previous review APK was ephemeral/review-only and `publishable=false`; it is not a release APK.
- These results predate commit `f4c1b0e` and cannot be attributed to it.

## 5. Changed files and current execution boundary

The owner-decision document was added at:
- `docs/project-continuity/ARVIN_PO_CLEAN_SLATE_AND_UI_UX_CONTRACT_2026-11-07.md`

This audit record is added at:
- `docs/project-continuity/ARVIN_CLEAN_SLATE_SOURCE_AUDIT_2026-11-07.md`

No runtime source files or tests were changed in this audit checkpoint. No tests were deleted, skipped, or weakened. No database DDL was executed.

## 6. Ordered implementation sequence

1. Map every remaining legacy-field read/write/serialization/query/test reference.
2. Refactor canonical domain models and codecs first; make historical Follow-up strictly historical.
3. Refactor Drift schema and TaskStore transactionally around first-class TaskReminder and FollowUpRecord relations.
4. Remove dead legacy columns and compatibility code from the fresh authorized staging schema.
5. Implement/reuse the Unified Person Entity without fabricating an assignee relation.
6. Implement the shared universal multi-select filter and align Home/Calendar/Task Details UI contracts.
7. Add/retain positive regression coverage for schema shape, CRUD, close/reopen persistence, reminder isolation, Follow-up timestamp immutability, and external-calendar deletion isolation.
8. Run Analyze, all test shards, APK matrix, Calendar Provider, persistence, and all Device Smoke lanes on one exact candidate SHA.
9. Install the exact candidate APK on Samsung SM-A528B/DS and record real-device evidence separately from emulator CI.
10. Keep PR #3052 OPEN / DRAFT / UNMERGED; no main mutation, merge, publication, or release.

**Disposition:** The authorization and consolidated contracts are recorded. The source audit confirms material legacy-schema and UI-contract gaps. Runtime schema alignment and code changes remain pending; all current-head CI and physical-device acceptance are NOT VERIFIED. **BLOCKED — RELEASE: NO-GO.**
