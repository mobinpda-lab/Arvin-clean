# ARVIN — Task Details UI Refinement Audit Register

**Repository:** `mobinpda-lab/Arvin-clean`  
**Tracking:** PR #3052 / Issue #2102  
**Branch:** `fix/recovery-calendar-device-smoke-2026-10-31`  
**Scope:** Task Details presentation and description metadata only

## Approved UI contract

1. Remove the status/follow-up badge from the top Task Details summary container. The task title remains the primary heading.
2. Place a compact pencil control directly in the description section of `TaskDetailPage`.
3. Activating the pencil exposes an inline multiline description editor. Save persists the edited description; Cancel discards the in-progress text.
4. When description is empty, show a neutral placeholder and retain the same inline edit affordance.
5. Description editing is not a separate Note entity or Note-creation workflow. No separate note-creation UI or schema is introduced.
6. The scope is limited to `TaskDetailPage`. Do not add this affordance to `QuickCaptureDialog` or the general `TaskEditorDialog`.

## Data and persistence invariants

- A successful description change updates Task `updatedAt`.
- Description editing must not assign, clear, or recompute Task `completedAt`.
- Existing historical `FollowUp` entries are immutable during this operation; IDs, timestamps, notes, results, and legacy `nextFollowUp` values remain unchanged.
- Existing Task/TaskStore compatibility fields remain preserved: `nextFollowUp`, `followUpEnabled`, `followUpDate`, and any existing `enabled` field in its actual schema owner.
- The persistence callback changes only the canonical Task description and `updatedAt`, then reloads the canonical Task from TaskStore.
- No Task model or TaskStore schema deletion/migration is part of this refinement.

## Implementation files

- `lib/task_detail_page.dart` — removes the summary status badge and implements inline description display/edit/save/cancel.
- `lib/main.dart` — connects inline save to canonical TaskStore persistence.
- `test/task_detail_followup_flow_test.dart` — covers empty description, badge removal, inline save, `updatedAt`, and preservation of `completedAt` and FollowUp history.

## Explicit non-scope

- No changes to `QuickCaptureDialog`.
- No changes to `TaskEditorDialog`.
- No separate Note model, repository, table, or creation flow.
- No change to Task completion lifecycle, FollowUp creation/editing, or calendar behavior.
- No removal of legacy fields or destructive migration.

## Verification status

This register records the approved contract and implementation intent. CI and test results must be read from completed GitHub Actions runs on the final PR head SHA. A successful file write or commit is not a test PASS.

**Release decision remains:** `BLOCKED — RELEASE: NO-GO`.  
**Issue #2102 remains:** `OPEN`.

### Legacy-field inventory clarification

The read-only inventory of `lib/models/task.dart` and `lib/services/task_store.dart` confirms the named legacy fields `FollowUp.nextFollowUp`, `Task.followUpEnabled`, and `Task.followUpDate` remain present and serialized/persisted. No standalone property or SQL field named exactly `enabled` was found in either of those two files; exact-word occurrences are UI/widget flags or comments elsewhere. This refinement does not create, rename, or delete an `enabled` data field. If a distinct legacy `enabled` schema member is intended, its owning model/table/path must be identified before any future schema operation.

## Persistence hardening for strict Follow-up immutability

Description updates use `TaskStore.updateDescription`, a targeted SQL UPDATE of only the Task description, `updated_at`, and the corresponding two envelope keys. It deliberately avoids the general `TaskStore.save` path, whose legacy-compatible rewrite replaces relation rows. The targeted path does not delete, recreate, or update `follow_ups` or `follow_up_people` rows. A TaskStore regression test verifies that `completedAt`, Follow-up IDs/content, `nextFollowUp`, `followUpEnabled`, and `followUpDate` remain unchanged.

When TaskDetailPage is opened in a context that does not supply the app-level callback (for example, a report drill-down), the page falls back to the same targeted `TaskStore.updateDescription` operation. The pencil remains actionable in all TaskDetailPage entry points; no general editor or Quick Capture entry point is added.
