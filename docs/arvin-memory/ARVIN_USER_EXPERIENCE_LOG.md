# Arvin User Experience Log

## 2026-10-09 — Calendar task actions reported missing
- Date: 2026-10-09 (conversation date; exact report time not established here)
- Context: User installed/used an Arvin build and inspected the Calendar task view.
- User Feedback: «در تقویم کارهای آروین دکمه ثبت در تقویم گوشی و دکمه ویرایش حذف شده است»
- Problem: The user reported that “add/register in phone calendar” and “edit” actions were missing from the Arvin Calendar task UI.
- Solution: No verified fix is recorded in this entry. Recheck live issues/PRs and test the actual UI before claiming resolution.
- Status: UNVERIFIED / acceptance evidence required.

## 2026-10-11 — Backup/restore acceptance boundary
- Date: 2026-10-11
- Context: Release-readiness and autonomous execution planning.
- User Feedback: The owner requires real installation/device experience to be retained and treated as product evidence.
- Problem: Emulator smoke cannot prove actual Android file-picker/provider behavior or physical-device data integrity.
- Solution: Require a documented physical-device export/restore round-trip and record device/OS, steps, backup artifact or screenshots/logs, and before/after data checks.
- Status: BLOCKED pending physical-device evidence.

## 2026-10-11 — Repeat Tracking Level owner contract
- Context: Owner supplied RTLC to strengthen important recurring commitments without introducing separate loan/debt/habit/payment/contract/customer-follow-up systems.
- Product expectation: Task form places «نوع پیگیری» after Repeat; «عادی» is the default and «مهم و قابل پیگیری» reveals advanced information progressively. Home uses only a restrained «تعهد مهم» / action-needed cue. Report Center offers «همه»، «عادی»، «مهم و قابل پیگیری» filters and accurate tracking metrics.
- Data expectation: existing Task identity, Repeat, occurrence history, per-occurrence checklist state, and backup/restore remain safe; past history immutable and future settings adjustable.
- Implementation status: decision recorded in [#2605](https://github.com/mobinpda-lab/Arvin-clean/issues/2605); first-pass source audit found model/persistence foundations already exist. Main-form/Home/report integration and end-to-end evidence remain pending. No UI screenshot or physical-device result was produced by this audit.




## 2026-10-11 — Owner installed-product feedback
- Environment: installed Android app (version/device not supplied in this report).
- Feedback: recurring Tasks fail to generate the promised 7 occurrences; recurrence activation should automatically fill today's date and current time but allow edits; automatic Calendar sync still has problems after changing a Task.
- Action: opened Draft PR #2606 for safe recurrence-editor defaults and regression coverage; recorded Calendar recurrence identity/projection defect in existing architecture issue #2248.
- Device reproduction/result: not yet captured in this session. Do not mark the user-facing defect resolved until exact-head CI and appropriate Android Calendar Provider validation are complete.

## 2026-10-11 — Calendar sync scope and state-change boundary
- Environment: product-owner clarification; device/build not specified.
- Decision: sync only Task title, date, time, description, recurrence details and reminder to the phone calendar. Marking Done or moving to Archive alone does not require calendar synchronization.
- Existing owner record: [#2248 comment](https://github.com/mobinpda-lab/Arvin-clean/pull/2248#issuecomment-6111402411).
- Acceptance: update the same linked external event; no duplicates; do not trigger calendar work solely for Done/Archive. Device/provider validation remains pending.

## 2026-10-11 — Report Center bottom navigation correction
- Environment: owner inspected the installed Arvin UI.
- Feedback: the Reports icon already exists; the missing change is placement in the bottom navigation row.
- Acceptance: move/reuse the existing icon and route to the existing Report Center. Do not create another reports screen, renderer, model or store.
- Record: [#2385](https://github.com/mobinpda-lab/Arvin-clean/issues/2385#issuecomment-6111105369). Code/device acceptance remains pending.

## 2026-10-11 — Notebook toolbar and checklist interaction defect
- Environment: owner inspected Notebook UI; exact device/build not provided.
- Feedback: labels associated with numbered-list, tick and checklist icons are clipped/incomplete; checklist appears as literal `[ ]` and tapping does not toggle it.
- Acceptance: full labels visible in supported RTL phone widths; render a real compact interactive checkbox; toggle and persist state after save/reopen through canonical Task.checklist/Notebook path.
- Records: [#850](https://github.com/mobinpda-lab/Arvin-clean/issues/850#issuecomment-6111078741), [#1139](https://github.com/mobinpda-lab/Arvin-clean/issues/1139#issuecomment-6111079224).
- Status: reported defect, not fixed or accepted yet.

## 2026-10-11 — Pastel visual language expansion
- Environment: owner requested extending the soft, color-coded Home/Calendar experience to every existing Arvin section, explicitly including Notes/Notebook and Reports.
- Work staged in [PR #2607](https://github.com/mobinpda-lab/Arvin-clean/pull/2607): consistent rounded card style and form-field shape; soft status colors in Calendar, Reports and Next Action; lavender note cards and green checklist cards in Notebook.
- Expected outcome: one coherent personal-assistant visual language, semantic color meaning, compact cards, readable RTL labels, and no clipping at small phone widths.
- Acceptance: compare Home, Calendar, Notebook list/editor, Report Center, Next Action, Task details/forms, settings and other card-based surfaces on an installed Android build. Ensure text remains readable and existing interactions/data remain unchanged.
- Status: code staged; CI was pending and Device Smoke skipped at last check. No owner/device acceptance claimed. Separate Notebook checklist toggle defect remains open.

## 2026-10-11 — Report filter usability and Persian date correction
Owner requirements:
- Report filter dates must use the Jalali/Persian calendar, not Gregorian calendar UI.
- Replace the long crowded filter sheet with collapsible roll-box sections for Time, Project, Category, Tag, Note, Task Status, Tracking and Follow-up.
- Show each section's icon, title, selected count, expand/collapse indicator, selected chips and multi-select options.
- Use Arvin's soft semantic pastel palette to distinguish project, category, tag, note and status filters.
- Multi-select must support several projects, categories, tags, task statuses and note kinds at once.
- Notes are reportable through the existing canonical Task/Notebook representation, including title/text and created/updated dates; no separate note/report data store.
Current implementation pointer: PR #2607. Automated validation, small-screen RTL visual check, and owner acceptance are still pending. Note-to-another-Task linkage and external-calendar-only report ingestion remain explicit model/integration gaps, not claimed as implemented.


## 2026-10-11 — Exact-main Device Smoke screenshot review
- Environment: GitHub Actions Device Smoke artifacts for exact `main` SHA `d8afc717eaf02d6d0bedf92e800c7f93209c97bd`; screenshots are automation/emulator captures, not a user-reported physical-device session.
- Home screenshot: primary task card, pastel quick filters and bottom navigation appear legible in the captured RTL viewport.
- People screenshot: empty-state message and add-person action are visible; no user data is shown.
- Quick Capture screenshot: selection controls use a compact three-column layout; several Persian labels are visibly clipped/truncated (e.g. project/category/tag and date/time-related chips). This is a P2 readability/UX issue to fix or explicitly validate at small phone widths.
- Status: screenshot review completed for these three artifacts only. Backup/Restore and People jobs were not yet complete at the checkpoint; full exact-main Device Smoke and physical-device acceptance remain pending.


## Live checkpoint 2026-10-12
No new owner installation, physical-device result, screenshot, or acceptance was supplied in this execution. Do not fabricate an installation/version/device record. Exact-main emulator runs are stale/incomplete; Calendar, Backup/Restore, RTL/compact-screen and golden-flow acceptance remain open.
## 2026-10-13 — Owner clarification: Arvin database is currently empty
- **Environment:** owner clarification in the Arvin execution conversation; exact installed version/device not specified.
- **Owner statement:** no information has been entered into Arvin; the database is raw/empty.
- **Product implication:** current owner-entered records should not be described as being at risk of migration loss. This statement does not independently verify all installed databases, local fixtures, old backups, or legacy JSON payloads.
- **Engineering response:** retain fresh-install/empty-database coverage and continue compatibility testing for legacy Task.reminderDate, old JSON/backup decoding, idempotent migration and duplicate-safe Calendar identity. Empty current data does not waive release validation or authorize deleting compatibility paths.
- **Status:** recorded; implementation/CI/device validation remain separate and pending. No user data was changed.
