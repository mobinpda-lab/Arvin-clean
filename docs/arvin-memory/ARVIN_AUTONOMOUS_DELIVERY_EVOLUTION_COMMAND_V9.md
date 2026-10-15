# ARVIN AUTONOMOUS DELIVERY & EVOLUTION COMMAND
## VERSION 9.0 — Owner-issued authoritative execution command
Date recorded: 2026-10-14
Project: Arvin (آروین)
Repository: mobinpda-lab/Arvin-clean
Status: Authoritative command captured from owner conversation. This document supersedes V8 for execution; preserve V8 as historical record.

## Mission
Drive Arvin autonomously from its actual current state to final product delivery while preserving architecture, preventing duplicate work, recording knowledge, correcting deviations, completing capabilities, solving problems, and learning from real use.

This is an execution command, not an explanatory plan. Operate in AUTONOMOUS EXECUTION MODE:
CHECK → UNDERSTAND → DECIDE → EXECUTE → VALIDATE → RECORD → CONTINUE.

## 1. Continuation rule
Never restart analysis, rewrite architecture, repeat prior decisions, or redo completed work when this command is reintroduced. Continue from the latest recorded state. First read `docs/arvin-memory/ARVIN_EXECUTION_STATE.md`; identify Last Completed Step and Current Bottleneck. Every execution must report DONE, BLOCKED, or NEXT ACTION.

## 2. GitHub is the project brain
GitHub is the official memory for source, decisions, progress, problems, solutions, evidence, UX experience and release history. No important knowledge may remain only in chat.

## 3. Mandatory pre-change inspection
Before any change, inspect repository, branch, latest commit, Issues, PRs, documentation, architecture, current code, existing tests, CI/CD, build/release status and project memory. No change without this check.

## 4. Required project memory
Maintain `docs/arvin-memory/`:
- `ARVIN_EXECUTION_STATE.md`: Completed, In Progress, Blocked, Next Action, Current Bottleneck.
- `ARVIN_DECISION_LOG.md`: Problem, Decision, Reason, Impact, Status.
- `ARVIN_PROJECT_KNOWLEDGE.md`: project knowledge, lessons, architecture corrections and important decisions.
- `ARVIN_USER_EXPERIENCE_LOG.md`: installation, real use, feedback, UX defects and corrections.
- `ARVIN_PROBLEM_REGISTER.md`: problem, root cause, solution and status.
- `ARVIN_EVIDENCE_MAP.md`: feature, test, result, validation and evidence.

## 5. No-forget rule
Record every important decision, problem, suggestion, architecture correction and real-use feedback from conversations or project inspection in GitHub documentation.

## 6. Anti-duplication
Before creating anything, inspect code, commits, Issues, PRs, tests and docs. Classify as Existing→Improve, Incomplete→Complete, Broken→Repair, Missing→Create. Do not create duplicates.

## 7. Core architecture
Task is the canonical source of truth. Task owns/links Checklist, Repeat, Tracking, Follow-ups, Reminders, History and Calendar projection. Follow-up contains title, result, `nextFollowUp`, Waiting Response and Person references. Every new capability must define how it relates to canonical Task data.

## 8. Final Follow-up contract
Remove the user-facing “کار پیگیری‌دار” concept. Every Task can have zero, one or multiple Follow-up records. Follow-up existence is inferred from data, never controlled by a flag. `followUpEnabled` must not be a product/domain source of truth.

## 9. `nextFollowUp` contract
Keep `nextFollowUp`; it means planned next action/review time. It is not a Reminder and must not automatically create notifications or external sync. Creating a Reminder from it requires explicit user choice.

## 10. Multiple Reminder contract
A Task can have zero, one or multiple independent Reminders. Each has stable ID, title, date/time and Task relationship. Editing/deleting one must not delete or mutate the Task, any Follow-up, or another Reminder. Preserve legacy data until compatibility and migration are proven safe.

## 11. Waiting Response and Person model
Waiting Response is more than a boolean: Follow-up → Waiting Response → Person(s). Support selecting multiple People, adding/removing/editing People. Person is not a CRM; it is used for Tasks, Follow-ups and Reports.

## 12. Person management
Add People to Settings beside Project, Category and Tag. Support add, edit, delete and search.

## 13. Quick Entry and Full Form
Quick Entry: remove “پیگیری‌دار”; retain “چک‌لیست‌دار”, because Checklist is chosen when creating a Task while Follow-ups can be added throughout its lifetime.
Full Task Form: remove “کار پیگیری‌دار”; replace it with a “پیگیری‌ها” section and “+ افزودن پیگیری”, with independent record management.

## 14. Calendar contract
Calendar is a projection, not Task owner. Synchronization follows CREATE then UPDATE EXISTING, using Task ID and external event ID/stable identity. Duplicate events are forbidden.

## 15. Calendar UX
Short tap opens the canonical Task page. Long press opens management actions such as edit, register in Calendar, manage Reminder, change time and delete. Normal tap must not show management actions.

## 16. Reports
Reports do not own data; derive from Task and linked records. Filters include Project, Category, Tag, Person, Follow-up, Reminder and Date. Example: all Tasks waiting for a response from a named Person.

## 17. Backup and Restore
Backup includes Task, Checklist, Repeat, Tracking, Follow-up, Reminder, Person, History and Calendar links. Restore must preserve complete integrity. Release is forbidden without Backup/Restore validation.

## 18. Development loop
For every change: Analyze → Inspect → Implement → Test → Validate → Commit → Document.

## 19. Quality and evidence
Nothing is DONE without Code + Test + Build + Validation + Evidence. Evidence may include commit, test result, screenshot, device result and report. Documentation-only changes must never be represented as application fixes.

## 20. Failure resolution
For each failure record Problem → Root Cause → Impact → Solution → Execution → Validation. Classify as Infrastructure, Product, Test, Data/Migration or Unknown. Never remove tests merely to get green CI; never guess or claim success without evidence.

## 21. Product acceptance scenario
Create Task → add Follow-up → select Person → create Reminder → show in Calendar → tap to open Task → long press for actions → report by Person → Backup → Restore → verify integrity.

## 22. Release delivery mode
Before release validate Core Flow, Backup, Restore, Migration, Calendar, Repeat, Checklist, Tracking, Follow-up, Reminder, Person, installation, device behavior and evidence.

## 23. Final handover
Prepare Release Notes, Installation Guide, User Guide, Known Issues, Architecture Summary and Evidence Report.

## 24. Stop conditions
Stop only when an owner decision is needed, data loss risk exists, a fundamental architecture change is required, or access is missing. Otherwise continue execution.

## 25. Final execution command
The executor is responsible for continuing Arvin. Every run must inspect, learn, avoid duplication, correct, record and continue. The goal is a complete, stable, reliable, maintainable product ready for real use.

## Active data-safety gate — 2026-10-14
The historical repository records conflict on whether legacy `Task.reminderDate` is automatically converted into a new `TaskReminder` or preserved with its existing Calendar identity. Do not choose by guess, do not run migration, and do not clear/overwrite/copy data until the decision history is reconciled and an idempotent, rollback-safe mapping is explicitly approved and tested. See Issue #2654 comment 6176411140 and Issue #1901 comment 6176412001.

## Current status at capture
- Owner command V9 is recorded as the authoritative execution command.
- Follow-up/Reminder requirements and the unresolved migration conflict are recorded in Issues #2654 and #1901 and the memory docs.
- No app code or user data was changed by this documentation capture.
- Release remains NO-GO pending implementation and complete evidence-based validation.
