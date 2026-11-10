# ARVIN — PERMANENT AI GOVERNANCE POLICY

**Status:** MANDATORY / CANONICAL AI OPERATING POLICY  
**Authority:** Mobin — Product Owner & Product Director  
**Canonical product charter:** [MASTER_GOVERNANCE.md](MASTER_GOVERNANCE.md) (REV9)  
**Repository:** mobinpda-lab/Arvin-clean  
**Related factory repository:** mobinpda-lab/NIRA (separate repository; not the Arvin product)

## 1. Authority and precedence
1. Latest explicit product-owner decision from Mobin.
2. REV9 MASTER_GOVERNANCE.md for product scope, semantics, design and governance.
3. PRODUCT_DECISIONS.md and explicit decision records, respecting status and supersession.
4. Approved canonical architecture/data contracts and relevant specifications.
5. Live repository source, SQL schema, active tests and exact-SHA CI evidence for implementation/verification facts.
6. CURRENT_STATE.md, ROADMAP.md, OPEN_ISSUES.md, IMPLEMENTATION_LOG.md and HANDOFF.md as continuity records.
7. Historical reports, old PR descriptions, chat summaries and model memory (context only; never proof of current state).

A newer explicit owner decision supersedes an older conflicting decision, but the older decision must remain in history with a SUPERSEDED record. Do not resolve a conflict by guessing.

## 2. Mandatory reading sequence — every task, every agent
1. `AGENTS.md`.
2. `AI_CONTINUITY_PROTOCOL.md`.
3. `PROJECT_STATE.md`.
4. Live GitHub: repository/default branch, current branch HEAD, target PR state, open related PRs/issues and exact-SHA checks.
5. `docs/project-continuity/MASTER_GOVERNANCE.md`.
6. `PRODUCT_DECISIONS.md`, `CURRENT_STATE.md`, `ROADMAP.md`, `OPEN_ISSUES.md`, `IMPLEMENTATION_LOG.md`, `HANDOFF.md`, and `README.md` in docs/project-continuity.
7. Relevant module, UX, architecture, database, migration, backup/restore, test and audit records; read NIRA documents only when the task crosses the Arvin/NIRA boundary.

If a required file is missing, unreadable, contradictory, or stale, stop and report the exact gap. Do not proceed from conversation memory alone.

## 3. Repository-first continuity
- GitHub is the durable project record; re-fetch live state at the start of every mission and before every write.
- Record Main SHA, working branch, PR number/state/head SHA, related PRs, and exact-SHA workflow evidence.
- Distinguish APPROVED / PRODUCT SCOPE / PROPOSAL / NEEDS OWNER DECISION / IMPLEMENTED / VERIFIED / HISTORICAL / BLOCKED.
- IMPLEMENTED requires source evidence; VERIFIED requires valid test or owner acceptance evidence tied to the exact SHA.
- Historical status snapshots must remain labelled HISTORICAL when superseded by live evidence.
- After each meaningful work unit, update continuity documents and leave one deterministic next action.

## 4. Authorization and protected operations
- Read-only authorization permits no writes.
- Documentation-only authorization permits only explicitly scoped Markdown/agent-instruction files on an authorized non-main branch.
- Implementation authorization is limited to the exact files, branch and task stated by Mobin.
- No direct commit/push to Main, force-push, history rewrite, merge, release, publication, destructive migration, data deletion, schema/test/workflow change, or bypass unless separately and explicitly authorized.
- A broader past authorization does not override the latest narrower mission scope.
- If a safe selective transfer or docs-only diff cannot be proven, stop.

## 5. Permanent product and data invariants
- ONE PRODUCT: one integrated personal/professional commitments and follow-up system.
- SQL is the sole durable product-data source of truth. JSON is permitted only for backup, import/export, transfer and temporary payloads. No parallel durable JSON/SharedPreferences shadow store.
- Preserve IDs, relationships, null/empty distinctions, history, occurrences and user data. Migrations must be non-destructive, repeatable and parity-verified before legacy retirement.
- Task, Due Date, Reminder, Follow-up, Waiting For, Next Action, Recurrence, Occurrence and Checklist are semantically distinct according to REV9 and approved later owner decisions.
- Do not create a new model/table or parallel persistence path without explicit architecture and owner approval.
- UI redesign must preserve existing product capabilities and follow the permanent Persian/RTL, Jalali, accessibility and enterprise UX charter.

## 6. Evidence and reporting
For each claim, identify source path/symbol, exact SHA, test/check name and result, device/OS/build when relevant, and owner acceptance if applicable. A green build alone does not prove UX, migration parity, physical-device behavior or release readiness. Missing evidence is UNVERIFIED, not PASS.

## 7. Conflicts and open decisions
Record each conflict in PRODUCT_DECISIONS.md and audit/CONFLICT_REGISTER.md with source, date, authority, status, impact, safe action and owner question. Preserve old wording as historical/superseded; never silently erase it. REV9 explicitly leaves the Vazirmatn/VazirHarf conflict as NEEDS OWNER DECISION despite older records; no agent may choose the font until Mobin resolves that conflict.

## 8. NIRA boundary
NIRA is a separate factory/control-plane repository. Arvin remains the product. Do not transfer product authority, product state or release status between repositories. Verify NIRA live only when relevant; do not infer Arvin implementation from factory artifacts.

## 9. Handoff contract
Every handoff must include live Main SHA, branch/PR/head SHA, changed-file scope, exact checks, unresolved conflicts, release gate and one next action. Release remains BLOCKED — RELEASE: NO-GO until all REV9 gates and explicit owner approval are met.


## 10. Agent adapter compatibility
See [AI_ADAPTER_COMPATIBILITY.md](AI_ADAPTER_COMPATIBILITY.md) for the verified repository paths and the Windsurf Cascade compatibility assessment. Agent-specific files are thin pointers only; this policy remains the sole canonical AI instruction source.


## 10. Current owner direction — LOCAL-FIRST / SYNC SUSPENDED (2026-11-10)

- Arvin is a standalone LOCAL-FIRST product. Essential business capabilities must operate on the local device without Internet, cloud account, remote server or another Arvin installation.
- Local SQL remains the sole durable source of truth for product data.
- All multi-device synchronization is SUSPENDED: Local P2P, LAN/device-to-device, Cloud, Dropbox, remote transport, pairing, conflict resolution and sync automation.
- Do not implement, migrate, test as a product feature, schedule or expand synchronization while suspended. Existing specifications and decisions remain historical records.
- The previous Local P2P Phase 1 / Cloud Phase 2 plan is SUPERSEDED as active direction. Reopening requires a separate explicit Mobin authorization.

## 11. Repository Cleanup Program — official wave sequence

The only active Repository Cleanup Program sequence is:
- WAVE 0 — Live Repository Baseline
- WAVE 1 — Git History Forensic Audit
- WAVE 2 — Test Governance & CI Audit
- WAVE 3 — Architecture & Documentation Audit
- WAVE 4 — Safe Cleanup & Consolidation

Do not create parallel cleanup-wave numbering. Each wave requires Baseline, Change Register, Before/After, Validation Evidence, Remaining Risks and Handoff. A successful commit alone does not complete a wave.

**Current authorization:** documentation-only changes on PR #3340's existing documentation branch. Main, PR #3052, source, SQL/schema, migrations, tests, workflows, product features, branch/PR deletion, merge and release remain outside scope.
