# CI Orphan Run Isolation — 2026-08-29

## Purpose
Prevent stale, orphaned, stuck or otherwise non-current GitHub Actions runs from affecting Arvin production decisions.

## Incident recorded
GitHub Actions run `32985995177` (`Arvin Build #685`) remained in `queued` state after PR #201 had already merged and closed. GitHub UI returned `Failed to cancel workflow`, and the run exposed no executable jobs.

This record is historical evidence only. The run must never be treated as active production evidence, a blocker, a merge gate, or a reason to pause healthy lanes.

## Canonical isolation rule
Production decisions may use a workflow run only when all applicable identity checks match the current work item:

1. The PR is currently open and targets `main`.
2. The PR is explicitly eligible for automation (`arvin-auto`) when automatic promotion/merge is involved.
3. Evidence is for the exact current head SHA.
4. Pull-request-triggered Heavy evidence belongs to the same current PR number.
5. `workflow_dispatch` Heavy evidence is acceptable only on the exact current head and after current-main ancestry validation.
6. Current-main ancestry and mergeability are rechecked before merge.

A queued/in-progress run belonging to a closed PR, missing current PR association, pointing at another head, or otherwise orphaned is operationally quarantined. It is visible as GitHub history but has zero authority over current Production.

## Production behavior
- Never pause Production because of an orphan run.
- Never restart a stale/orphan run to make it look current.
- Never reuse its CI result for a different PR/head.
- Do not force-cancel when GitHub rejects cancellation; record it and isolate it instead.
- Healthy current-main lanes continue normally.
- Only exact-head/current-PR evidence can satisfy gates.

## Automation hardening
The Production Orchestrator must filter pull-request Heavy runs by the current PR identity, not by head SHA alone. This prevents an orphaned pull-request run from satisfying or blocking another active PR even if a SHA/ref is reused in an unusual GitHub state.

Contract coverage lives in `test/production_orchestrator_contract_test.dart`.

## Open-PR hygiene
Old PRs are not automatically considered active production work merely because they remain open. Before continuation, classify open PRs as one of:

- **Active:** current-main or intentionally current, with an owner lane and valid evidence path.
- **Rebuild required:** valuable scope but stale base/history; rebuild cleanly on current main before production use.
- **Historical/superseded:** no longer a production lane; preserve traceability, but do not use its CI or branch as current evidence.

Do not bulk-close or mutate historical PRs merely for cosmetic cleanup. Close only when supersession/duplication is proven and recorded.

## Source of truth
GitHub current `main`, active PR identity, exact head SHA and exact workflow evidence remain authoritative. Narrative documents never promote an orphan run back into relevance.
