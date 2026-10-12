# ARVIN FOLLOW-UP MODEL CORRECTION

**Decision version:** 1.0  
**Owner-approved source:** Follow-Up & Reminder Execution Correction supplied on 2026-10-12  
**Status:** IN PROGRESS — decision recorded; implementation and validation are not complete.  
**Scope:** canonical Task editor, Quick Add, Follow-up registration, Task/Follow-up persistence, Calendar projection, reminder sync, tests and memory.

## Authority and precedence

This decision replaces earlier conflicting Follow-up UX interpretations. The owner's latest clarification supersedes the earlier sentence that removed the Full Task Editor's toggle:
- The Full Task Editor **keeps** its existing `کار پیگیری‌دار` toggle and its existing `دارای چک‌لیست` capability/toggle. Neither is to be removed.
- Remove only the independent, automatically populated `زمان پیگیری` field from the Full Task Editor.
- Quick Add must also gain `دارای پیگیری` and `دارای چک‌لیست` toggles. They operate on the same canonical Task and existing storage/write path.
- Quick Add's Follow-up toggle opens a compact roll box for adding a follow-up, viewing existing follow-ups, and managing status; the checklist toggle activates its compact checklist roll box.
- Do not add new sections or a parallel editor/model/store.
- A Follow-up is created from the existing **افزودن پیگیری** action, using the existing canonical Task/Follow-up path.
- The Follow-up registration page has one user-facing temporal concept only: **یادآور پیگیری بعدی**.

## Problem

The existing product has overlapping temporal concepts and controls: Task-level `followUpDate`, Follow-up `nextFollowUp`, Follow-up `reminderDate`, plus automatically initialized/editable date/time controls on the registration screen. Several services still consume `nextFollowUp`, while Calendar projects `reminderDate`. This creates confusing UI and makes naive field removal or remapping a data/behavior risk.

## Canonical model

```text
Task (canonical owner)
  └── Follow-up (history/result, same Task identity)
        └── Follow-up Reminder (optional schedule, linked to parent Task)
```

- Follow-up title is optional.
- Follow-up description/result is the recorded outcome.
- Follow-up Reminder date and time are optional and may be cleared independently.
- There is exactly one user-facing Follow-up reminder schedule. Do not create a second reminder section or parallel reminder engine.
- The reminder retains a stable relationship to the canonical parent Task ID. Calendar rows expose a **کار مادر** action that opens that Task.
- Calendar title uses the Follow-up title when supplied; otherwise it is **پیگیری + عنوان Task مادر**. The reminder timestamp comes only from the configured Follow-up Reminder. Result text is the reminder description.
- No Task-level automatic Follow-up Time field remains in the Full Task Editor.
- Legacy data compatibility is not permission to silently discard dates. Before removing `nextFollowUp`/legacy `followUpDate` consumers, inspect serialization, SQL storage/migration, backups, restore, history, automatic scheduling, agenda, next-action and Calendar links. Where legacy timestamps exist, preserve them through a reviewed, tested compatibility/migration path; do not keep two active user-facing schedules.

## UI contract

### Full Task Editor

- Keep the existing `کار پیگیری‌دار` toggle.
- Keep the existing checklist capability/toggle; checklist remains available for any Task and is not dependent on Follow-up.
- Remove only the automatically populated/editable `زمان پیگیری` field from this form.
- Preserve existing Follow-up records/history and the dedicated `افزودن پیگیری` flow.
- Do not make this form a second Follow-up creation/storage system.

### Quick Add

- Compact the existing Project, Category, Tag, Reminder, Repeat and Due Date controls without harming readability, RTL or touch usability.
- Add `دارای پیگیری` and `دارای چک‌لیست` toggles in addition to their retained Full Editor counterparts.
- Follow-up toggle opens a compact roll box with: add a Follow-up, view existing Follow-ups, and manage status. It must not create a duplicate Task or parallel store.
- Checklist toggle opens/enables the checklist roll box. Full checklist editing remains available in the Full Task Editor.
- Both entry experiences must preserve the same Task draft/identity and canonical write path.

### Follow-up registration

- Replace the separate `پیگیری بعدی` and `یادآور این پیگیری` controls with one `یادآور پیگیری بعدی` control.
- Do not default the reminder date/time to the current system timestamp.
- Date and time can each be cleared; reminder may be absent while the result is still saved.
- Title remains optional; result/description can be saved without a reminder.
- Preserve Follow-up identity, result/history, waiting-for-response status, parent Task identity and backup/restore compatibility.

## Protected contracts

- Task is the source of truth; no standalone Follow-up entity/store or parallel reminder engine.
- A reminder is a projection of the existing Follow-up relationship and remains linked to the canonical parent Task.
- No duplicate Task or Calendar event; stable IDs and existing event links remain intact.
- Do not silently migrate, clear or repurpose a persisted timestamp until all consumers and backup/restore paths are covered by tests.
- Persian RTL, Jalali date entry, accessible controls, compact-screen layout and clear empty/cleared states are required.
- No merge to main or release without exact-head validation and explicit owner approval.

## Validation required

1. Full Task Editor retains `کار پیگیری‌دار` and checklist; only automatic `زمان پیگیری` is removed; existing Follow-up history remains reachable.
2. Follow-up creation is through `افزودن پیگیری`; Quick Add has both toggles and roll boxes; toggles do not create a second Task.
3. Quick Add has compact metadata controls and both toggles; draft, Task identity and single-write behavior are preserved.
4. Follow-up page has one reminder control; no auto-current date/time; date/time can be independently cleared; result-only save works.
5. Calendar title fallback, reminder timestamp, result description and parent-task link are verified.
6. Audit all consumers of `nextFollowUp`, `followUpDate` and `reminderDate`; verify JSON, SQL migration, backup/restore, automatic scheduler, agenda, next action and Calendar sync.
7. Run focused widget/unit/integration tests, Analyze, all test shards, Debug/Release builds and relevant Device Smoke lanes on the exact head.
8. Review Persian RTL/compact-screen screenshots. Emulator checks do not substitute for physical-device acceptance.

## Current execution record

- **Changed:** canonical decision clarified to retain both existing Full Editor toggles and add equivalent Quick Add toggles; only the auto-populated Full Editor `زمان پیگیری` field is removed by this decision.
- **Evidence:** owner's explicit correction in conversation on 2026-10-12; canonical tracker Issue #2593 and experimental integration PR #2640.
- **Remaining:** implement the UI/model/consumer changes, migration safety and tests; then capture exact-head CI and visual/device evidence.
- **Next:** implement within existing Task/Follow-up architecture and existing task-form/calendar issues and PRs; do not create a duplicate feature branch or system.
