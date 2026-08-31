# AI Worker single launch authority — 2026-08-31

## Live finding

Arvin already had idempotent issue routing in `ARVIN Orchestrator`, including an explicit `<!-- arvin-worker-dispatch -->` marker and an explicit workflow dispatch for actionable issues. `ARVIN Production Loop` also explicitly dispatches the worker for GITHUB_TOKEN-created Auto-Fix issues because recursive issue events are intentionally not trusted.

The AI Worker itself still listened to `issues:labeled` for `arvin-auto`. That left two possible launch paths for the same issue: direct label execution and the canonical explicit dispatch.

## Bounded fix

- `ARVIN AI Code Worker` is now `workflow_dispatch` only;
- `ARVIN Orchestrator` remains the single launch authority for normal actionable issues;
- `ARVIN Production Loop` retains its explicit dispatch for newly-created Auto-Fix issues;
- worker concurrency is keyed only by the required `issue_number` input;
- provider/runtime behavior, branch/PR ownership and Production merge authority are unchanged;
- no product/model/storage path is touched.

## Why this improves Maximum Parallel

Maximum Parallel means independent work runs together, not that the same task is generated twice. A single Worker per issue reduces duplicate provider cost, competing writes to `ai/issue-N`, force-with-lease races, duplicate validation and Production noise.

## Current-main reconciliation

This combined Worker reliability package is rebuilt after Calendar Settings #592 moved `main`; earlier #589/#593 validation is historical only.

Refs: #588 #579.
