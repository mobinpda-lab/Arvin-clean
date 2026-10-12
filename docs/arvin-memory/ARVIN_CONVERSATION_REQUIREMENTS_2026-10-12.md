# Conversation Anti-Forget Ledger — Arvin
Updated: 2026-10-12
Repository: https://github.com/mobinpda-lab/Arvin-clean

This is the durable checklist of material owner requirements raised across the current Arvin conversation and its continuation context. It supplements, but does not replace, source code, Issues, PRs, tests or the six canonical memory files.

## Operating rule
- On every continuation, read `ARVIN_EXECUTION_STATE.md` first, then this ledger and the latest relevant decision/issue/PR.
- A discussion, issue, open PR or running workflow is not completion. Mark DONE only with implementation, tests, exact-head Build, applicable provider/device validation and evidence.
- Before any write, refresh main SHA, PR head/base, issues, code/tests, exact-head CI and project memory. No blind merge, duplicate implementation or meaningless commit to manufacture CI.
- Keep historical context; append dated corrections instead of silently erasing earlier decisions.

## A. Calendar ownership, sync and duplicate prevention — P0
- [ ] Task is source of truth; Calendar is projection, never an independent owner/store.
- [ ] With global auto-sync enabled, all eligible Arvin-owned projections automatically reach the selected writable phone calendar: Task due/reminder, recurrence and explicitly configured independent FollowUp reminder.
- [ ] First sync creates; later edits update the same provider event; repeated sync is idempotent. Identity uses stable Task/link ID and provider `calendarId + eventId`; never use title/date as authoritative identity.
- [ ] Events imported from the phone retain stable provider identity/import-origin metadata and never echo back to that phone calendar, including via manual «ثبت در تقویم گوشی». Exclusion must survive restart and backup/restore.
- [ ] Manual import of an event already linked to an Arvin Task or an Arvin-created provider event shows a clear Persian duplicate warning and offers the existing Task/event; no duplicate Task/link/event.
- [ ] Manual «ثبت در تقویم گوشی» and «ویرایش در تقویم گوشی» actions remain available. Re-registering an already-linked item warns and offers the existing provider event rather than silently claiming a new registration.
- [ ] Legacy per-source settings must not silently defeat the owner rule when global auto-sync is enabled; preserve settings/backup deserialization compatibility.
- [ ] Test create-once, repeated-sync no-op, same-event update, deleted/cleared reminder stale-event cleanup, imported-origin exclusion and backup/restore.
- Trace: Issue #2635; PR #2636. Independent-reminder projection/stale-link cleanup dependency: PR #2631. Exact-head validation and provider/device evidence remain open unless freshly verified.

## B. FollowUp independent reminder — P1
- [ ] In FollowUp editor, consolidate «پیگیری بعدی» and «یادآور پیگیری مستقل» into exactly one control: **«یادآور پیگیری مستقل»**.
- [ ] Helper text exactly: **«این پیگیری در تقویم گوشی ثبت شود»**.
- [ ] FollowUp appears in Arvin/phone Calendar only if its own independent reminder is explicitly configured. FollowUp history date or parent Task date alone must not create an event.
- [ ] Use the reminder's own date/time. Editing updates same linked event; clearing/removing it removes or safely reconciles the linked event without stale events/duplicates.
- [ ] Preserve legacy `reminderDate` and `nextFollowUp`: proposed mapping gives `reminderDate` priority if both exist; otherwise maps legacy `nextFollowUp` to the unified reminder; new writes use `reminderDate` and clear `nextFollowUp`. Require JSON, TaskStore, backup/restore and provider tests.
- Trace: Issue #2635; PR #2636 and projection dependency PR #2631. Backup/restore and physical provider validation remain gates.

## C. Lawful Calendar icon/color identity — P1
- [ ] Arvin Task/due/repeat: purple `#4A4CAB` + task/checklist icon.
- [ ] Independent FollowUp reminder: amber `#B45309` + notification/follow-up icon.
- [ ] Phone-calendar import: teal `#0F766E` + phone/external-calendar icon.
- [ ] Apply consistently to agenda/day/week/month and related rows/results. Origin dots are helpful, but keep icon/label too; color must not be the only signal. Check contrast, light/dark themes, RTL and accessibility.
- Trace: Issue #2635 / PR #2636; visual acceptance is not complete.

## D. Global date/time layout — P1/P2
- [ ] Wherever date and time appear together, keep them on one horizontal row whenever it fits: Home, Calendar, task rows/forms, Quick Add/full editor, Reports/filters, FollowUp, Notebook, search/results and lists.
- [ ] Use shared widget/style, Persian/Jalali and RTL support, narrow Android screens and accessibility text scaling. Do not blindly shrink text; use explicit tested stacked fallback only when the row cannot fit.
- [ ] Presentation-only; no Task, recurrence, sync identity, persistence or backup format changes.
- Trace: PR #2633 `ArvinDateTimeLabel` is a partial rollout (Timeline, FollowUp Office, Task Detail). Remaining surfaces, exact-head Build and screenshots are still required.

## E. Compact task cards and progressive disclosure — P1/P2
- [ ] Compact task cards/rows especially Home/Calendar, and also Reports, Next Action, Notebook, search/results and all relevant lists.
- [ ] Keep title and essential status/date visible; clamp long text. Collapse description, checklist preview, tags, taxonomy, priority and secondary metadata by default; reveal via expand/tap/detail.
- [ ] Preserve data, touch usability, legibility, accessibility and RTL; presentation-only.
- Trace: PR #2627 covers Home disclosure and Calendar density; other surfaces and RTL/compact-screen visual acceptance remain open.

## F. Owner-approved Report Filter — P1/P2
- [ ] Issue #2623 contains the owner-approved Report Filter bottom-sheet visual reference; preserve it as canonical target.
- [ ] Persian RTL and Jalali date/time, clear visual hierarchy, compact usable layout, required multi-select controls, correct combinations across canonical data sources, clear/reset and date ranges.
- [ ] Reports query canonical data and own no independent storage. Validate behavior and screenshot against the reference. Issue registration alone is not implementation proof.

## G. Quick Add and Full Task Form — P1
- [ ] Issue #2624 contains owner-approved Quick Add/smart-entry/full-form visual reference.
- [ ] Quick Add and Full Task Form create/edit the same canonical Task identity and share validation/storage; no parallel Task/draft store.
- [ ] Date/time are prominent and consistent with shared picker and global inline date/time rules; progressive disclosure keeps initial entry simple.
- [ ] Active architecture guard: root `Task.description` is canonical; do not add root `Task.note` or change schema/migration/backup semantics until conflicting decision history is explicitly reconciled with the owner.
- Trace: Issue #2593 / PR #2594 architecture decision; Issue #2624 visual reference; overlapping PRs #2591/#2595/#2602/#2607 must be reconciled into one tested integration head, not merged independently.

## H. Repeat and Tracking Level — P1
- [ ] Repeat is a Task capability: Task → Repeat Definition → Occurrence projection → Execution State → History; no copied root Task per repeat.
- [ ] Preserve original Task identity, immutable past history, editable future schedule/settings, independent per-occurrence checklist state and backup/restore round-trip.
- [ ] Accepted product direction in Issue #2605: NORMAL and TRACKING are levels of existing Repeat, not a new CRM or parallel Loan/Debt/Habit/Payment/Contract/Customer system. Default «عادی»; advanced «مهم و قابل پیگیری» reveals details progressively.
- [ ] Validate Task form after Repeat, Task Detail, restrained Home cue, Report Center filters/metrics, history/checklist and backup/restore. Issue #2254 tracks repeat lifecycle. Direction accepted; complete end-to-end proof remains open.

## I. Cleanup, architecture and data integrity — P0/P1
- [ ] Remove only genuinely unused/stale content; merge duplicate implementations carefully; review every deletion and preserve canonical code/contracts.
- [ ] Canonical taxonomy: Project, Category, Tag. Persian Category is «دسته»; Group is not a fourth entity.
- [ ] Home, Reports, Calendar and widgets cannot own parallel storage. Tracking is not CRM replacement. Checklist belongs to Task.
- [ ] Preserve canonical SAF/file-provider backup/restore implementation; do not confuse it with a legacy duplicate backup implementation. Preserve Task/Project/Category/Tag/settings/repeat history/Calendar links; rollback must cover every mutated store.
- Trace: PR #2619 cleanup requires path-by-path review and current-base reconciliation; never blind-merge. Restore rollback fix/decision around commit 05c080e needs exact-head validation.

## J. Release gates and user evidence — P0
- [ ] Release NO-GO until exact-head Analyze/tests/build, relevant six-lane emulator smoke, Calendar Provider Acceptance, real Android provider create/update/no-duplicate, real file-picker Backup/Restore + rollback + Calendar-link integrity, installed-device golden flow, Persian RTL/compact-screen review and explicit owner approval.
- [ ] Emulator CI does not prove physical-device/provider/file-picker behavior, user-data safety or owner acceptance.
- [ ] Never fabricate install/version/device/feedback. After owner testing, log version, device/OS, steps, issue, expected/actual, evidence and resolution in User Experience Log.
- [ ] Final handover: Release Notes, Installation Guide, User Guide, Known Issues, Architecture Summary and Evidence Report.

## K. GitHub memory and anti-forget operation
- [ ] Maintain all six canonical files: `ARVIN_EXECUTION_STATE.md`, `ARVIN_DECISION_LOG.md`, `ARVIN_PROJECT_KNOWLEDGE.md`, `ARVIN_USER_EXPERIENCE_LOG.md`, `ARVIN_PROBLEM_REGISTER.md`, `ARVIN_EVIDENCE_MAP.md`.
- [ ] Link this ledger from execution state; record every material owner requirement, decision, failure, validation and next action in GitHub.
- [ ] Re-fetch all open PRs, issue links, branch heads and workflow conclusions on each continuation. Historical SHA/run entries are not current evidence.
- [ ] Do not claim DONE without code + tests + exact-head Build + applicable validation + evidence.


## Live validation correction — 2026-10-12
- PR #2636 exact head `0b010e105c9d2fbb3279b58795bd42f4340f6b1d`: Build [38239373451](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38239373451), Calendar Provider Acceptance [38239373403](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38239373403), Device Smoke [38239373435](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38239373435) were queued/pending at last poll. No pass claimed.
- Previous Build [38238251976](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/38238251976) FAILED. Logs showed 4px origin dots caused repeated 1px overflow in fixed-height week/month cells; classifying `followup:<task>:<id>` as Task-owned hid «انجام شد». Fixed: dots 3px; `followup:` removed from Task-owned classification; old icon test updated to checklist/phone icons.
- Re-poll exact-head runs; do not mark Calendar UX or release gate DONE until tests/build/smoke/provider checks pass and physical-device acceptance exists.
