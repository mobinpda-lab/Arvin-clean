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

Maximum Parallel means independent work runs together, not that the same task is generated twice. A single Worker per issue reduces duplicate Copilot/OpenAI provider cost, competing writes to `ai/issue-N`, force-with-lease races, duplicate validation and Production noise.

## Contract proof

`test/ai_worker_provider_contract_test.dart` verifies that:
- the Worker cannot start from `issues:labeled`;
- Orchestrator explicitly dispatches the Worker and records its marker;
- Production Loop explicitly dispatches Auto-Fix work;
- the Worker still cannot merge and delegates Fast/Production promotion.

Refs: #588, #579.
