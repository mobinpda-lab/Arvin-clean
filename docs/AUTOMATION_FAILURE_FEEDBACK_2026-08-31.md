# ARVIN deterministic production failure feedback — 2026-08-31

## Purpose
Close Issue #562 without introducing a second merge controller or bypassing existing production gates.

## Canonical responsibilities
- `Arvin Production Orchestrator` remains the only guarded promotion/merge authority.
- `ARVIN Production Loop` remains the only workflow that converts terminal gate failures into Auto-Fix Issues.
- `ARVIN AI Code Worker` remains the bounded implementation worker for actionable Auto-Fix Issues.

## Failure behavior
- `success`: no Auto-Fix task.
- `cancelled`: treated as protective/stale execution noise; no Auto-Fix task.
- `failure` / `timed_out`: one idempotent Auto-Fix task keyed by gate name + exact head SHA.
- token-driven Heavy/Fast gates do not rely only on recursive `workflow_run` delivery. The canonical Orchestrator explicitly dispatches Production Loop feedback for real terminal failures it observes.
- an Auto-Fix Issue created by `GITHUB_TOKEN` does not rely on a recursive Issue event to start work. Production Loop explicitly dispatches the bounded AI Code Worker once after creating the deduplicated Issue.

## Safety invariants
- no direct write to `main`;
- no direct merge from Production Loop or AI Worker;
- exact-head/current-main/Fast/Build/Device gates remain mandatory;
- cancellation cannot recursively create failure work;
- duplicate callbacks cannot create duplicate open Auto-Fix Issues;
- scheduled/workflow-run callbacks remain recovery paths while explicit dispatch closes token-recursion gaps.

## Acceptance evidence
The automation contract test must lock cancellation suppression, explicit failure feedback dispatch, idempotent Auto-Fix creation, explicit worker launch, and preservation of the single canonical merge authority.
