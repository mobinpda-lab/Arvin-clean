# Arvin — AI Continuity Protocol
**Authority:** Mobin — Product Owner & Product Director  
**Repository:** `mobinpda-lab/Arvin-clean`  
**Status:** MANDATORY / CANONICAL OPERATIONAL CONTINUITY RULE  
**Language:** English is used for machine-readable governance; Persian product terms and owner decisions remain authoritative.

## 1. Non-negotiable rule

No AI model, agent, automation, developer, conversation, session, or delegated worker may start an independent workstream, repeat a completed action, reinterpret an unresolved issue as approved, or change project direction before reading the latest recorded project state and reconciling it with live GitHub.

Every session MUST:
1. Read the repository-root `AGENTS.md`.
2. Read this file, `AI_CONTINUITY_PROTOCOL.md`.
3. Read `PROJECT_STATE.md`.
4. Fetch the live repository, active branch, PR state, latest commits, and exact-SHA workflow evidence before any action that depends on current status.
5. Read the relevant canonical product/governance documents and source/tests before making a change.
6. Continue from the latest verified checkpoint, not from memory, an old chat, an exported ZIP, an old SHA, or an unverified report.
7. Record the outcome and the next safe action in `PROJECT_STATE.md` before handing work to another agent.

Failure to complete these steps means the agent is NOT READY TO EXECUTE.

## 2. Authority and source precedence

Resolve conflicts in this order:
1. The latest explicit decision or instruction from Mobin, Product Owner.
2. Live GitHub repository state: exact branch refs, PR metadata, commits, source tree, tests, workflows, and exact-SHA evidence.
3. This protocol and the mandatory instructions in `AGENTS.md`.
4. The latest `PROJECT_STATE.md` checkpoint, reconciled against live GitHub.
5. Canonical product/governance records under `docs/project-continuity/`, architecture specifications, QA evidence, and historical ledgers.
6. Prior conversations, summaries, exported archives, or agent memory — context only, never stronger than current evidence.

If two documents disagree, do not silently choose one or erase the history. Record the conflict, identify which source is authoritative, and request Mobin's decision when the owner intent is genuinely ambiguous.

## 3. Mandatory live preflight

Before any implementation, documentation edit, branch operation, commit, PR action, or status claim:
- Fetch repository metadata and default branch.
- Fetch the current working branch ref and its exact HEAD SHA.
- Fetch the related PR and verify head branch, head SHA, base SHA, state, draft, and merge status.
- Fetch the latest commits and inspect their messages/parents.
- Fetch relevant Actions runs for the exact HEAD SHA; inspect failed or pending jobs when needed.
- Fetch the relevant current files at that exact SHA.
- Record the UTC timestamp or the available GitHub event timestamps.
- Distinguish GitHub's committed state from local workspace state. GitHub cannot prove local uncommitted changes; mark local state NOT VERIFIED unless directly inspected.

Never assume a branch name, SHA, PR state, test result, artifact, or approval remains current from a previous session.

## 4. Current Arvin delivery-stream guardrails

The following is the live checkpoint captured when this protocol was established; it is not a substitute for the mandatory fresh preflight:
- Repository: `mobinpda-lab/Arvin-clean`.
- Active delivery branch: `fix/recovery-calendar-device-smoke-2026-10-31`.
- Related PR: `#3052`, base `main`; keep OPEN / DRAFT / UNMERGED unless Mobin explicitly changes that instruction.
- Main was observed at `45e4202b03a434459e4c021a04efa7e8396359db` and is READ-ONLY.
- PR branch HEAD was observed at `c6750a92243a3a2046ab36823f280505b5335dfe` before this continuity commit.
- The observed latest commit message was `docs(governance): register unresolved typography authority conflict`.
- Build run `42805111874` on that SHA: FAILURE; Analyze and APK build stages succeeded, while six test shards failed.
- Device Smoke run `42805112200`: PENDING.
- Calendar Provider run `42805111910`: SUCCESS.
- Follow-up File Persistence run `42805112251`: SUCCESS.
- Draft Review APK run `42805111849`: SUCCESS.
- These results apply only to SHA `c6750a92243a3a2046ab36823f280505b5335dfe`. They do not transfer to this or any later documentation commit.
- Release status: **BLOCKED — RELEASE: NO-GO**.

The continuity documentation commit is documentation-only. Do not infer a new test result or release approval from it.

## 5. Current product architecture authority — SQL ONLY

Mobin's final architecture decision is:
**ONE PRODUCT · ONE CANONICAL DATABASE · ONE SQL SOURCE OF TRUTH.**

- SQL is the sole canonical owner of all persistent product/business data, entities, relationships, history, and operational state.
- Durable duplicate JSON/SharedPreferences ownership is not an approved architecture.
- JSON is permitted at explicit boundaries such as Backup, Import/Export, Data Transfer, and genuinely temporary/rebuildable payloads.
- Historical JSON data must be migrated non-destructively into relational SQL with identity, relationship, ordering, null, duplicate, and history preservation proven before any legacy path or column is retired.
- Occurrence history and per-occurrence checklist state require independent durable identity and relational ownership.
- Reminder, Follow-up, Task due date, recurrence, occurrence, and their histories must not be conflated.
- The four Reminder states must never be invented. If names/transitions are not established by source and owner contract, record UNKNOWN and ask Mobin.
- No destructive migration, legacy deletion, schema retirement, or data cleanup is authorized by this architecture decision alone.

## 6. Work authorization and safety

An agent may perform only the scope explicitly authorized for the current task.
- Read-only means no file writes, tests that mutate project state, schema/database changes, commits, pushes, branch changes, PR metadata changes, merges, or releases.
- Documentation-only authorization does not authorize executable source, tests, schemas, migrations, workflows, security configuration, or product behavior changes.
- A request to create a commit does not automatically authorize merge, release, PR closure, or Main changes.
- Main remains READ-ONLY unless Mobin explicitly authorizes otherwise.
- Never force-push, rewrite history, or move a branch ref without checking the current head and using an expected-SHA lease.
- Never delete, skip, bypass, weaken, quarantine, or artificially time out tests to obtain a green result.
- Never delete legacy data, tables, columns, branches, PRs, commits, tags, releases, artifacts, or historical documents without explicit scope-specific authorization.
- Never claim that code, migration, test, CI, backup, restore, APK, device behavior, or release is implemented/verified without direct evidence on the relevant exact SHA.

## 7. Evidence and status vocabulary

Keep these dimensions separate:
- Product decision: PROPOSED / APPROVED / REJECTED / SUPERSEDED.
- Implementation: MISSING / PARTIAL / IMPLEMENTED / BLOCKED.
- Verification: NOT VERIFIED / PARTIAL / VERIFIED.
- Delivery/release: OPEN / DRAFT / UNMERGED / BLOCKED / RELEASE NO-GO, as applicable.

Rules:
- File existence is not implementation acceptance.
- Implementation is not verification.
- A test file existing is not a passing test.
- A green orchestrator is not a green product build.
- A workflow result is valid only for its exact SHA and actual completed jobs.
- A prior SHA's PASS never transfers to a later SHA.
- A cancelled, pending, skipped, or not-started test is not PASS.
- If evidence is missing, write UNKNOWN or NOT VERIFIED; never guess.
- Record exact run IDs, job outcomes, commit SHA, and evidence links where available.

## 8. Required continuity update after each meaningful action

At the end of every meaningful work unit, update `PROJECT_STATE.md` with:
- Timestamp and exact inspected HEAD.
- Branch and PR state.
- What was inspected or changed.
- Files/paths changed and commit SHA if committed.
- Tests/workflows run and exact-SHA results, or explicitly NOT RUN.
- Decisions confirmed, conflicts discovered, and unresolved questions.
- Data/security/release risks.
- Whether the working scope is complete, partial, blocked, or not verified.
- One next action with its prerequisites and authorization boundary.

Preserve previous checkpoints as dated entries or a concise history section. Do not silently overwrite a prior checkpoint or erase historical evidence.

## 9. Handoff contract

The outgoing agent must leave:
1. The exact last verified SHA and live branch/PR status.
2. The last completed action and its evidence.
3. The current active task and precise scope.
4. Unresolved blockers and decisions required from Mobin.
5. Tests/workflows not yet run or not yet completed.
6. Explicit prohibited actions.
7. One deterministic next command/action.

The incoming agent must independently re-fetch live GitHub before acting. A handoff is a starting map, not permission to trust stale data.

## 10. Current continuation pointer

At protocol creation, the active task is the user-authorized **WAVE 4 — SQL-ONLY CANONICAL DATABASE AUDIT**, read-only source/data-ownership and migration discovery. The previous report is explicitly interim, not a complete 868-file content audit; no migration safety is proven. Continue the audit from the latest live PR HEAD, complete source/caller/JSON/SQL/backup/sync/test coverage, and preserve the read-only boundary. Wave 4's separate deliverables under `docs/project-continuity` must not be edited unless documentation changes for that audit are separately authorized.

The next agent must not start a new feature or unrelated cleanup before reconciling this Wave 4 checkpoint and obtaining any missing authorization.

---
This protocol remains mandatory until Mobin changes it through an explicit, recorded instruction.


## WAVE 4 REV8 execution authorization supersession — 2026-11-10

Mobin's latest explicit command authorizes **AUDIT + IMPLEMENTATION + TESTING** for WAVE 4, including source code, schema, migrations, tests, requested audit reports and necessary workflow corrections. This supersedes the earlier checkpoint's read-only WAVE 4 status and its restriction on editing WAVE 4 deliverables.

Scope remains limited to `fix/recovery-calendar-device-smoke-2026-10-31`. Main remains READ-ONLY; PR #3052 remains OPEN / DRAFT / UNMERGED. No force push, history rewrite, test deletion/skip/bypass/weakening, merge, release, or legacy data retirement without the exact proof gates. The latest owner command is the controlling authorization; do not ask for repetitive approval for in-scope technical fixes.


---

## REV9 permanent continuity policy — 2026-11-10

REV9 is the active product and governance baseline. Every future agent must read `AGENTS.md`, `PROJECT_STATE.md`, and `docs/project-continuity/AI_GOVERNANCE_POLICY.md` before acting, then follow its full mandatory sequence. Live GitHub is required at mission start and before every write. The latest explicit owner authorization controls scope; the current mission is documentation-only. Historical WAVE 4 implementation authorization is not permission for this documentation branch. No claim of implementation, verification, merge or release may be made without exact-SHA evidence and explicit owner approval where required.
