# Arvin Conversation Continuity Checkpoint — 2026-10-11

**Purpose:** Durable handoff so owner requirements from the current conversation and recent Arvin work are not lost between sessions. This is a requirement ledger, not a claim that features are implemented.

## Working rules
- GitHub is the source of truth for code and execution status. Refresh live main, PR heads, branches, workflows and comments before acting.
- Before changes: audit the whole relevant flow and overlapping PRs; make a focused change; add regression coverage; validate exact head; document evidence and blockers.
- Do not claim solved, complete, release-ready, tests green or device-verified without matching evidence. Orchestration-only success is not product validation.
- Product first; keep existing canonical models and interactions. No parallel Task, Note, Calendar, Tracking, Follow-up or report stores. Run independent lanes in parallel only where they do not conflict.
- Preserve Persian RTL, VazirHarf v34.003 (do not replace with Vazirmatn), approved Arvin colors and visual identity. Root Task.description remains the only root Task text field; no root Task.note. Existing FollowUp.note and Notebook notes stay unchanged.

## Current conversation requirements and open acceptance items

### A. Unified visual language (owner request)
- Extend the soft-pastel Home/Calendar style consistently to all existing screens: Notebook, Reports, task forms/details, settings and other sections.
- Use semantic colors for status and domain identity, rounded cards, subtle elevation, compact spacing and readable typography.
- Do not create duplicate screens, duplicate report icon/page, new domain models or parallel components. Verify narrow phone widths, RTL, contrast and clipping.

### B. Report filter and note reporting (owner request; detailed decision file)
- Gregorian-facing date/time controls in Report Center are a known open defect; use Persian/Jalali UI and Persian digits.
- Compact expandable RollBoxes: Time, Project, Category, Tag, Note, Task Status, Tracking, Follow-up. Selection must persist when collapsed.
- Multi-select: multiple Projects, Categories, Tags, statuses and note types; selected chips, counts, icons and expansion indicators.
- Reports consume canonical Task, Project, Category, Tag, Tracking, Follow-up, Calendar and Notes data; they do not own data.
- Note filters: title, body, category, tag, created/modified dates and Task association, limited to data available through existing canonical repositories/relations.
- Full contract: `docs/arvin-memory/ARVIN_REPORT_FILTER_DECISION.md`.

### C. Home / Calendar / Settings / Reports / Notebook requests
- Phone-calendar events imported for display should also appear on Home.
- In Arvin Calendar, selecting a task reveals Edit / Register in phone calendar / Delete in one horizontal row; keep actions hidden/collapsed until selection.
- Reports icon already exists: move that existing destination/icon into bottom navigation; do not create another Reports page/icon/engine.
- Project settings currently cannot add projects reliably and edits do not persist: treat as a P0 persistence defect until fixed and validated.
- Notebook Category / Tag / Project controls should be in one horizontal RTL row.
- Notebook tick, numbered-list and checklist toolbar labels must not clip. Checklist must render as a real compact interactive checkbox (not literal `[ ]`), toggle on tap, and persist after save/reopen. Add layout/toggle/persistence regressions.
- These requests were logged in issues #516, #2151, #2385, #850, #1139; notebook checklist details were commented on #850 and #1139. Verify live issue state before claiming completion.

### D. Calendar sync contract
- Sync only title, date, time, description, recurrence details and reminder.
- Marking a Task Done or moving it to Archive alone must not trigger a phone-calendar operation.
- Update the same linked external event; no duplicates and no title/date matching as identity.
- Unregistered phone-calendar event Edit is already applied and owner-tested on installed app: open that exact external event editor; do not reimplement. Regression coverage can be added later.
- Recurrence projection/edit identity and provider/device acceptance remain open until exact-head tests and physical-device proof exist. Existing related issues include #2248 and #2535.

### E. Repeat / Task form / data decisions
- Draft PR #2606: recurrence should default to seven editable occurrences and prefill current local date/time when repeat is enabled on an unscheduled task; automatic reminder aligns with due time. CI had passed on the recorded head, but Device Smoke was skipped and owner physical-device acceptance is pending. Refresh exact head/status before action.
- Draft PR #2595 and overlapping time-picker/taxonomy PRs must be audited together before changes; avoid stale stacked branches and do not weaken failing tests.
- Owner decision: root Task.description only; no root Task.note. Keep scoped FollowUp.note and Notebook notes unchanged.
- Repeat/tracking history and calendar sync need immutable past occurrences, future-only recurrence changes and canonical IDs; never create copied Tasks per recurrence.

### F. Current visual refinement and Report Filter PRs
- PR #2607, branch `feat/calendar-pastel-compact-cards-20261011`, is open Draft at head `0ef03757ee869a49f7d36cfcad05f2d09751a31c`, based on `main`; not merged. It now includes cross-screen pastel styling, compact expandable report filters, multi-select, canonical Notebook-as-Task report filtering, and a Persian date picker. The discovered Build run `38160581498` failed test shards 2 and 5 on an earlier head; a fresh run tied to the exact current head must be confirmed. Device Smoke was skipped. Do not claim exact-head validation based on a different branch's successful run.
- Important integration gap: PR #2607's `_pickTime` still calls generic Flutter `showTimePicker`, while the shared Persian-digit 24-hour `showUniversalArvinTimePicker` is in PR #2591. Reconcile the overlap; do not duplicate the picker. Keep both PRs Draft until the combined exact head passes.
- Existing Calendar item tap behavior still needs verification against the owner requirement to open/edit the same canonical Task; do not accept the visual change alone as proof of correct navigation.
- PR #2608, branch `docs/report-filter-memory-20261011`, is the documentation/anti-forget PR at head `b2e922a0ebce98c93339a6aeb1d0b14de52607b8`, not merged. It overlaps on `docs/arvin-memory/ARVIN_REPORT_FILTER_DECISION.md` with #2607, so reconcile the duplicate document before merging either PR.

### G. Other known release/acceptance gates
- Backup/restore needs real Android file-picker/provider and round-trip checks, including IDs, relations, settings, Notebook checklists and calendar links; do not equate merged code with device acceptance.
- Reports should extend the existing canonical reporting flow with filters/preview/copy/share/print/PDF; do not introduce a second report engine.
- Release gate remains blocked until exact artifact SHA, Analyze/tests/build, Android/device evidence, release notes/install guide/user guide/known issues/architecture summary and explicit owner acceptance are documented.
- Any storage, migration or architecture-level decision is sensitive and requires independent review (including DeepSeek cross-review per owner workflow) before implementation.

## Mandatory next-session startup
1. Read this file, `docs/arvin-memory/ARVIN_REPORT_FILTER_DECISION.md`, `docs/ARVIN_PROJECT_STATE.md`, `docs/PRODUCT_CONTRACT_MATRIX.md` and `docs/UI_UX_GOVERNANCE.md`.
2. Refresh GitHub main, open PRs/issues, branch heads and exact-head CI.
3. Reconcile duplicate/stacked PRs before editing; report Read/Write access truthfully.
4. Select the highest-impact open product defect, implement only after audit, test and record evidence.
5. Keep every checklist item open until its acceptance evidence exists.
