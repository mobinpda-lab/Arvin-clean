# Arvin Conversation Continuity

> **Superseded checkpoint:** This 2026-10-11 handoff contains an older VazirHarf instruction. Wave 6.71 owner decision overrides it; use Vazirmatn v33.003 as the canonical/default font. Checkpoint — 2026-10-11

**Purpose:** Durable handoff so owner requirements from the current conversation and recent Arvin work are not lost between sessions. This is a requirement ledger, not a claim that features are implemented.

## Working rules
- GitHub is the source of truth for code and execution status. Refresh live main, PR heads, branches, workflows and comments before acting.
- Before changes: audit the whole relevant flow and overlapping PRs; make a focused change; add regression coverage; validate exact head; document evidence and blockers.
- Do not claim solved, complete, release-ready, tests green or device-verified without matching evidence. Orchestration-only success is not product validation.
- Product first; keep existing canonical models and interactions. No parallel Task, Note, Calendar, Tracking, Follow-up or report stores. Run independent lanes in parallel only where they do not conflict.
- Historical checkpoint only: the then-current note preserved VazirHarf v34.003. This is superseded; preserve Persian RTL and approved Arvin colors with Vazirmatn v33.003. Root Task.description remains the only root Task text field; no root Task.note. Existing FollowUp.note and Notebook notes stay unchanged.

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
- PR #2607, branch `feat/calendar-pastel-compact-cards-20261011`, is open Draft and targets `main`; latest verified head at this checkpoint: `5278c5a81165f79a32dc8dd260aef16fed00c9e5`. It contains cross-screen pastel styling, compact expandable report filters, multi-select, canonical Notebook-as-Task report filtering, Persian/Jalali date controls, and the shared `showUniversalArvinTimePicker`.
- Exact-head Build run `38161588760` was queued at the last check; Device Smoke was skipped. Older run `38160581498` failed test shards 2 and 5 on an earlier head and is not evidence for the current head. Confirm fresh exact-head Analyze, all test shards, Debug/Release APK and relevant route tests before acceptance.
- The universal picker file in #2607 is byte-identical to the shared picker in #2591, but is a duplicate changed-file path across two Draft PRs. Reconcile the overlap before merging so there is one canonical shared implementation.
- Calendar item tap behavior still needs explicit verification that it opens/edits the same canonical Task; the visual diff alone is not proof.
- PR #2608, branch `docs/report-filter-memory-20261011`, is open Draft and targets `main`; it contains the anti-forget continuity checkpoint and report filter decision, and updates Project State, User Requirements Memory, Product Contract Matrix and UI/UX Governance. The decision file is also in #2607; keep the copies identical and reconcile the overlapping path before merging.
- Do not merge either PR or claim release/owner acceptance until the overlapping file paths are reconciled and the exact combined head passes validation.

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


## Live correction — 2026-10-12
- Current main is `cea76673d871ce52b84dacf69f355c4282802baa` after cleanup PR #2613; older SHAs and workflow snapshots in this file are historical only.
- Required memory files are not yet on main. PR #2600 and #2608 remain open drafts/stale branches; this checkpoint is being consolidated via a new branch from current main.
- Current-main Build #38178428086 is stale/incomplete; Device Smoke #38178428043 is stale/queued. Do not claim green.
- Product release remains blocked pending physical-device Calendar same-event update, real-file Backup/Restore, Repeat/Checklist golden flow, Persian RTL/compact-screen review and explicit owner approval.
- Current report-filter decision remains: Persian/Jalali user-facing date/time, Persian digits, compact expandable sections preserving selection, multi-select, canonical source data, no parallel Report/Note stores. The shared Universal Arvin Time Picker and Report Center integration must be reconciled on one validated branch.
