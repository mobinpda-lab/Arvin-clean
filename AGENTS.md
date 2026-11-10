# AGENTS.md — Mandatory Instructions for Every AI Agent

**Repository:** `mobinpda-lab/Arvin-clean`  
**Authority:** Mobin — Product Owner & Product Director

## STOP — READ BEFORE ANY ACTION

Every AI agent, coding assistant, automation, delegated worker, and future conversation MUST read these files in this order before inspecting implementation details or taking action:

1. `AGENTS.md` (this file).
2. `AI_CONTINUITY_PROTOCOL.md`.
3. `PROJECT_STATE.md`.
4. Live GitHub repository, current working branch, latest commits, related PR, and exact-HEAD workflow evidence.
5. `docs/project-continuity/MASTER_GOVERNANCE.md`.
6. `docs/project-continuity/CURRENT_STATE.md`, `HANDOFF.md`, `OPEN_ISSUES.md`, and `PRODUCT_DECISIONS.md`.
7. The relevant architecture specifications, source files, tests, and evidence.

If any mandatory file is missing or unreadable, stop and report the gap. Do not proceed from chat memory alone.

## Mandatory execution rules

- Continue from the latest verified project checkpoint. Do not start an independent workstream or repeat completed work.
- Live GitHub and the latest explicit Mobin decision override stale documentation and prior conversation summaries.
- Re-fetch the active branch HEAD and PR state before every write. Bind every test/CI statement to an exact SHA.
- Main is READ-ONLY. PR #3052 must remain OPEN / DRAFT / UNMERGED unless Mobin explicitly changes the rule.
- Follow the SQL-ONLY canonical architecture recorded in `AI_CONTINUITY_PROTOCOL.md`; do not introduce durable JSON/SharedPreferences shadow ownership.
- Respect the active task's authorization boundary. Read-only audits must remain read-only. Documentation-only permission is not source-code permission.
- Never remove, skip, weaken, bypass, or artificially time out tests. Never delete legacy data or perform destructive migrations without explicit authorization and proven rollback.
- Do not claim IMPLEMENTED or VERIFIED without direct source and exact-SHA evidence.
- Preserve historical decisions and reports. Append or supersede transparently; never silently rewrite history.
- After every meaningful work unit, update `PROJECT_STATE.md` and leave one deterministic next action.

## Current stream reminder

The latest recorded active task is the WAVE 4 SQL-ONLY read-only data ownership and migration audit. Its previous report is interim. Complete the evidence inventory before claiming the audit is comprehensive. Do not modify Wave 4 deliverable documents unless separately authorized.

**No agent is permitted to ignore these instructions or proceed without reading the current project state.**


## WAVE 4 REV8 — explicit owner authorization addendum (2026-11-10)

Mobin has explicitly authorized **AUDIT + IMPLEMENTATION + TESTING** for WAVE 4 SQL consolidation on this working branch. This latest owner instruction supersedes the older read-only Wave 4 reminder and the prior restriction on editing Wave 4 deliverables. Source, Schema, Migration, Tests, Workflows where necessary, and the requested audit reports may be changed within the authorization.

Non-negotiable limits remain: only `fix/recovery-calendar-device-smoke-2026-10-31`; Main READ-ONLY; PR #3052 OPEN / DRAFT / UNMERGED; no force-push, merge, release, test weakening or unproven legacy deletion. Re-fetch the live head and PR before writes. WAVE 4 is not COMPLETE until exact-SHA tests, backup/restore, full parity and owner gates are proven.
