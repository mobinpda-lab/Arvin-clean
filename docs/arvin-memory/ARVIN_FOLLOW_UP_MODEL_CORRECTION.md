# ARVIN FOLLOW-UP MODEL CORRECTION

**Decision version:** 1.0  
**Owner-approved source:** Follow-Up & Reminder Execution Correction supplied on 2026-10-12  
**Status:** IN PROGRESS — decision recorded; implementation and validation are not complete.  
**Scope:** canonical Task editor, Quick Add, Follow-up registration, Task/Follow-up persistence, Calendar projection, reminder sync, tests and memory.

## Authority and precedence

This decision replaces earlier conflicting Follow-up UX interpretations. In particular:
- The Full Task Editor must **not** contain the `کار پیگیری‌دار` toggle or an independent automatic `زمان پیگیری` field.
- The Quick Add flow owns the fast `دارای پیگیری` toggle and its compact expandable box.
- The Full Task Editor remains the place to edit Task details and checklist items; it must not become a second Follow-up creation/storage system.
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
- No Task-level Follow-up Time is a separate scheduling source.
- Legacy data compatibility is not permission to silently discard dates. Before removing `nextFollowUp`/legacy `followUpDate` consumers, inspect serialization, SQL storage/migration, backups, restore, history, automatic scheduling, agenda, next-action and Calendar links. Where legacy timestamps exist, preserve them through a reviewed, tested compatibility/migration path; do not keep two active user-facing schedules.

## UI contract

### Full Task Editor
- Remove the current `کار پیگیری‌دار` toggle from this form.
- Remove the independent automatic `زمان پیگیری` field.
- Preserve existing Follow-up records/history and the dedicated `افزودن پیگیری` flow.
- Keep checklist editing in the Full Task Editor; disabling the checklist mode must not delete saved checklist data.

### Quick Add
- Compact the existing Project, Category, Tag, Reminder, Repeat and Due Date controls without harming readability, RTL or touch usability.
- Add `دارای پیگیری` and `دارای چک‌لیست` toggles.
- Follow-up toggle opens a compact roll box with: add a Follow-up, view existing Follow-ups, and manage status. It must not create a duplicate Task or parallel store.
- Checklist toggle opens/enables the checklist roll box. Full checklist editing remains available in the Full Task Editor.

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

1. Full Task Editor has neither `کار پیگیری‌دار` toggle nor `زمان پیگیری` field; existing Follow-up history remains reachable.
2. Follow-up creation is through `افزودن پیگیری`; Quick Add roll box supports add/view/status.
3. Quick Add has compact metadata controls and both toggles; toggles do not create a second Task.
4. Follow-up page has one reminder control; no auto-current date/time; date/time can be independently cleared; result-only save works.
5. Calendar title fallback, reminder timestamp, result description and parent-task link are verified.
6. Audit all consumers of `nextFollowUp`, `followUpDate` and `reminderDate`; verify JSON, SQL migration, backup/restore, automatic scheduler, agenda, next action and Calendar sync.
7. Run focused widget/unit/integration tests, Analyze, all test shards, Debug/Release builds and relevant Device Smoke lanes on the exact head.
8. Review Persian RTL/compact-screen screenshots. Emulator checks do not substitute for physical-device acceptance.

## Current execution record

- **Changed:** this canonical decision record is being added to the existing task-form work branch; no implementation is claimed by this document alone.
- **Evidence:** owner-provided version 1.0 contract and source inspection on 2026-10-12.
- **Remaining:** implement the UI/model/consumer changes, migration safety and tests; then capture exact-head CI and visual/device evidence.
- **Next:** implement within existing Task/Follow-up architecture and the existing task-form issue/PR; do not create a duplicate feature branch or system.
