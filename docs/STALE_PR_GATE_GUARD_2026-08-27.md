# Stale Heavy PR Gate Guard — 2026-08-27

Refs #278 #195.

## Problem

A Ready PR can already be spending runner time on Build/APK/Device while an independent lane merges to `main`. Arvin policy correctly invalidates the old-base evidence, so continuing those heavy runs wastes time and the PR must be rebuilt anyway.

## Guard

`.github/workflows/cancel-stale-pr-gates.yml` runs only after a push to `main` or `master`.

It inspects only queued/in-progress pull-request runs named:

- `Arvin Build`
- `Arvin Device Smoke`

For each run it fetches the PR head and asks GitHub to compare:

`current main ... PR head`

The run is kept when the PR head is identical to/ahead of current main, or when GitHub reports current main as the merge base. It is cancelled only when GitHub proves the head no longer contains current main.

Uncertain/missing API evidence is logged and skipped; uncertainty never causes cancellation.

## Boundaries

- no global lane serialization;
- no rebase or force-push;
- no auto-merge;
- no cancellation of main/gate/device push validation;
- no cancellation of Parallel Fast Lane;
- no product code/model/storage change;
- only `contents: read`, `pull-requests: read`, `actions: write` permissions.

Every keep/cancel log includes run, workflow, PR, head, main, compare status and merge-base evidence.

## Validation

- workflow runs a pure classification self-test before any API cancellation work;
- `test/stale_pr_gate_workflow_contract_test.dart` locks trigger, permissions, target workflows, compare/cancel behavior and forbidden automation actions;
- delivery remains Draft until current product integration is stable and Fast CI is green.
