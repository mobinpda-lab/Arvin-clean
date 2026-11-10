# NIRA Repository Audit — REV8

**Repository:** `mobinpda-lab/NIRA`  
**Main HEAD:** `7a27ee63b65d343e45c5786f782f2567611722dc`  
**Snapshot:** 2026-11-10

## Repository inventory

| Item | Count / state |
|---|---|
| Branches | 112 (100 + 12 pages) |
| Protected branches | 0 |
| Open PRs | 7 |
| Closed PRs | 381 |
| Closed merged | 60 |
| Closed unmerged | 321 |
| Main commit history | 132 (100 + 32) |
| Workflow files | 26 |
| Factory tests | 23 under factory/tests/ |
| Docs files | 20 |
| Tree entries | 130 |
| Total workflow runs | 30,005 |

No NIRA branch was reported protected by the branch API. This is a governance risk, not an authorization to change branch protection.

## Workflow evidence

Latest 100 runs:
- 53 SUCCESS
- 10 FAILURE
- 27 CANCELLED
- 10 SKIPPED

Selected runs:
- Recovery Sweep 42799537170 — SUCCESS.
- Client Monitor 42798707817 — SUCCESS.
- Factory Pulse 42796683408 — SUCCESS.
- Autonomous Self Completion 42796622281 — SUCCESS.
- Main Closure 42777826931 — SUCCESS.
- Queue Scheduler 42777810609 — FAILURE.
- Failure Feedback 42777796050 — SUCCESS.
- Production Orchestrator 42777795705 — SUCCESS.

### Queue Scheduler failure

Run 42777810609's log shows the scheduler's error-reporting path trying to create a comment on issue **#162**. GitHub returns HTTP 403: `Commenting is disabled on issues with more than 2500 comments`.

The workflow's catch handler attempts to post the failure comment and then rethrows. That comment failure may mask the original dispatch error. The log also reports provider-pressure capacity values, but the underlying dispatch error is not conclusively established from the exposed log. The proven terminal blocker is the comment-limit 403.

## Repeated state-sync PRs

Across all 381 closed PRs:
- **292** have title `docs(nira): sync derived project state`.
- All use head branch `nira/state-sync`.
- **289** of these are closed-unmerged; 3 are merged.
- PR #797 is currently OPEN / READY on the same branch, with 2 commits and 2 changed files. Head SHA `98f2c4c200cab4ea450deef884e1986ce5480602`; base Main SHA `7a27ee63b65d343e45c5786f782f2567611722dc`.

This is strong evidence of recurring state-sync PR churn. It is not permission to close #797 or delete the branch. The state-sync generator should be audited for idempotency, diff detection, and one-open-PR-per-client behavior.

## L10 and end-to-end

- README states L10 remains **UNVERIFIED** until a registered client completes a reconstructible end-to-end task.
- `factory/tests/test_registered_client_e2e.py` exists, but file existence is not proof of a successful production E2E run.
- Adapter `factory/adapters/arvin.py`, registry, client workflows and control-plane tests establish an integration surface, not complete operational acceptance.
- Arvin/NIRA remain separate repositories; no merge of their code or workflows is authorized.

## Current classification

| Capability | Implementation | Verification |
|---|---|---|
| Production Orchestrator | PRESENT | PARTIAL |
| Failure Feedback | PRESENT | PARTIAL |
| Queue Scheduler | PRESENT | FAILING on comment-reporting path |
| Recovery Sweep | PRESENT | PARTIAL |
| Registered-client E2E | TEST/CONTRACT PRESENT | NOT VERIFIED |
| L10 | GOVERNANCE GATE PRESENT | UNVERIFIED |

No NIRA branch, PR, issue, workflow, or repository setting was modified.
