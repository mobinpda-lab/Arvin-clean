# Stale Heavy PR Gate Guard — 2026-08-27

Refs #278 #195.

## Problem

A Ready PR can already be spending runner time on Build/APK/Device while an independent lane merges to `main`. Arvin policy correctly invalidates the old-base evidence, so continuing those heavy runs wastes time and the PR must be rebuilt anyway.

## Guard

`.github/workflows/cancel-stale-pr-gates.yml` runs only after a push to `main` or `master`.

It inspects only queued/in-progress pull-request runs named:

- `Arvin Build`
- `Arvin Device Smoke`

For each active run it uses that run's immutable `head_sha` and asks GitHub to compare:

`current main ... run head`

This distinction is deliberate: the PR branch may already have advanced while an older heavy run is still executing. The guard classifies the exact commit under test, not the PR's newer current head.

The run is kept when its own head is identical to/ahead of current main, or when GitHub reports current main as the merge base. It is cancelled only when GitHub proves the run head no longer contains current main.

Uncertain/missing API evidence is logged and skipped; uncertainty never causes cancellation.

## Boundaries

- no global lane serialization;
- no rebase or force-push;
- no auto-merge;
- no cancellation of main/gate/device push validation;
- no cancellation of Parallel Fast Lane;
- no product code/model/storage change;
- only `contents: read`, `pull-requests: read`, `actions: write` permissions.

Every keep/cancel log includes run, workflow, PR, run head, main, compare status and merge-base evidence.

## Validation

- workflow runs a pure classification self-test before any API cancellation work;
- `test/stale_pr_gate_workflow_contract_test.dart` locks trigger, permissions, target workflows, exact run-head comparison/cancel behavior and forbidden automation actions;
- delivery remains independent from product code and requires fresh exact-head CI before merge.
