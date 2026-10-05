# Arvin — AI Evaluation & Continuity Guide

> Purpose: make Arvin independently understandable and reviewable when the repository is exported as a ZIP and provided to an AI assistant in a new conversation or account.

## 1. Project identity

- Repository: `mobinpda-lab/Arvin-clean`
- Product: Persian RTL Android personal organizer for Tasks, Follow-ups, Projects, Categories, Tags, Checklist, Date/Time, Reminders, Calendar, Notes/Notebook, Backup/Restore and related daily workflows.
- Stack: Flutter/Dart; Riverpod direction; canonical Task foundation; existing Reminder/Scheduler and Calendar integration; Drift is present in dependencies.
- Product principle: PRODUCT FIRST. Factory, CI, architecture and automation are means, not the product.
- Main branch is the source of truth. Never trust an old report when live GitHub disagrees.
- Never introduce parallel storage/model/repository/engine for an existing capability.
- User data, IDs, history and Backup/Restore compatibility are protected requirements.

## 2. How an AI reviewer should start

When a ZIP is supplied, read in this order:

1. This file: `ARVIN_AI_CONTEXT.md`.
2. `docs/ai/arvin-project-evaluation.md`.
3. `docs/ai/arvin-remaining-work.md`.
4. `README.md`, `pubspec.yaml`.
5. `docs/architecture/` and relevant ADR/decision documents.
6. Canonical domain/model/store/repository code.
7. Tests and integration/device-smoke workflows.
8. Only then inspect individual UI files.

Do not infer completion from the existence of code. A capability is DONE only when the repository implementation, integration behavior, relevant tests and available evidence agree.

## 3. Mandatory evaluation questions

For every major capability determine:

- Product behavior: what should the user be able to do?
- Current implementation: where is it implemented?
- Canonical source of truth: which model/store/repository/service owns it?
- Persistence: is state actually saved and restored?
- Integration: does it work through Home, forms, Detail, Calendar, Reminder, Search, Backup/Restore as applicable?
- Regression risk: what existing flows can it break?
- Tests: what exact tests prove it?
- CI evidence: which exact HEAD/SHA was tested?
- Device evidence: is real Android acceptance required, and is it available?
- Status: DONE / IN PROGRESS / PARTIAL / BLOCKED / NEEDS VERIFICATION / NEEDS FINAL DEVICE VERIFICATION / DUPLICATE / SUPERSEDED / UNKNOWN / BACKLOG.

## 4. Golden product flows

At minimum evaluate:

1. Create Task → Project/Category/Tag → Date/Time → Reminder → Save → reopen.
2. Date-only Task → true All-Day → Calendar/Reminder/Widget/Lock Screen preserve no-time semantics.
3. Date+Time Task → exactly one canonical same-time automatic Reminder.
4. Edit Date/Time repeatedly → no duplicate Reminder/Event.
5. Task → Checklist → toggle/progress → persistence.
6. Repeat → independent occurrence state → Checklist/history/progress.
7. Task ↔ Follow-up → status/last action/next action/result/timeline.
8. Task → Phone Calendar sync when opt-in → edit/delete/target-calendar change → no orphan/duplicate.
9. Project/Category/Tag create → immediate selection/list visibility → filters without reopen.
10. Notebook → edit/autosave/reopen → canonical taxonomy/filtering.
11. Backup → Restore → IDs/history/checklist/timeline/taxonomy remain correct.
12. Home → Time/Projects/Categories/Tags/status/priority filters → daily decision center.

## 5. Architecture guardrails

- Checklist is a general Task capability, not a separate product/module.
- Repeat models a commitment lifecycle: start/end/count/current/completed/remaining/progress/next/history.
- Follow-up is a core Task identity with its own status/action/result/timeline semantics.
- Date-only is a true All-Day state; midnight is never the user-facing semantic.
- Date+Time is Timed and creates/reconciles exactly one canonical automatic due-time Reminder.
- Manual Reminder must not be silently overwritten by auto-reminder behavior.
- Calendar/Reminder/Recurrence changes must use existing canonical infrastructure unless an accepted architecture decision says otherwise.
- Fundamental model/storage/migration changes require explicit architecture review and backward-compatible migration.

## 6. Evidence policy

Never label a feature complete because:
- a file exists;
- an Issue is closed;
- a PR is merged;
- one test passes;
- an old APK works;
- an old SHA had green CI.

Prefer exact current-main or exact-PR-head evidence. For UX/device behavior, automated evidence is not a substitute for required real-device acceptance.

## 7. ZIP review contract

A ZIP is an inspection snapshot, not a replacement for live GitHub.

When only a ZIP is available:
- evaluate architecture, code, tests, docs, workflows and product completeness from the snapshot;
- mark live CI, open PR state, current GitHub issues and real-device acceptance as UNKNOWN unless included as evidence files;
- use the Git history/SHAs inside the ZIP only if present;
- do not claim current GitHub state from a ZIP timestamp alone.

For a high-level evaluation, produce:
1. Product maturity assessment.
2. Architecture assessment.
3. Completed capabilities with evidence.
4. Remaining P0/P1/P2 work.
5. Duplicated/legacy/superseded paths.
6. Data/migration risks.
7. Test/CI/release gaps.
8. Recommended next execution lane.
9. Exact files/issues that should change next.

## 8. Permanent references

- #1923 — continuity/live remaining-work ledger.
- #2224 — permanent execution cycle for `ادامه آروین`.
- #2301 — canonical Date/Time/Reminder P0.
- #2230 — general Task Checklist.
- #2248 — Calendar architecture/sync gate.
- #2254 — Repeat architecture.
- #1901 — real-device regression closure.
- #2251 — product completion / Release-Ready program.
- #2102 — release gate/evidence.
- #1911 — Notebook/Home filter contract.
- #1860 — Typography.
- #847 — Taxonomy.
- #1891 — Quick Add / scheduling / taxonomy / swipe.

## 9. Continuation rule

A new AI conversation should begin by reading these files and then reconciling them with live GitHub. If live GitHub differs, live GitHub wins and the documentation must be updated. The next action must be the highest-value unfinished product lane, not another status-only report.
