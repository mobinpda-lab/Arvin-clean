# DEC-2026-10-09-01 — Retire the legacy main-build dispatcher

**Status:** Accepted for implementation; validation required before release-gate closure  
**Scope:** GitHub Actions orchestration only. No product data, app behavior, or release approval rules change.

## Context

The canonical `.github/workflows/build.yml` already runs on pushes to `main`/`master`, pull requests targeting those branches, and explicit manual dispatches. The current-main build uses the concurrency group `arvin-build-main` with cancellation enabled so newer exact-head runs replace older runs.

The legacy `.github/workflows/arvin-orchestrator.yml` also runs for pull-request open/synchronize events and on a schedule. The separate `.github/workflows/arvin-release-dispatcher.yml` listened for every successful run of that legacy orchestrator and dispatched `build.yml` on `main`, regardless of whether the event was a product release or a PR-branch update. Those redundant main dispatches canceled in-flight exact-main Build runs during the current execution, preventing stable release-gate evidence.

Observed cancelled main Build runs include [37942586927](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/37942586927), [37943170615](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/37943170615), [37943519469](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/37943519469) and [37943566874](https://github.com/mobinpda-lab/Arvin-clean/actions/runs/37943566874). The latest was a `workflow_dispatch` on main from `github-actions[bot]`.

## Decision

Delete the legacy dispatcher. Keep the canonical Build workflow's push/PR/manual triggers and the newer Production Orchestrator's exact-head Build + Device Smoke dispatch for eligible PR branches. Do not alter or bypass the release-closure gate.

## Consequences

- Pull-request updates no longer trigger a duplicate Build on `main` through the legacy router.
- Main Build and Device Smoke can complete without being repeatedly superseded by unrelated branch activity.
- The legacy issue/PR routing workflow remains available; only its redundant Build-dispatch side effect is retired.

## Validation required

1. The CI contract test proves the legacy dispatcher is absent and canonical Build triggers remain present.
2. This PR passes Analyze, all test shards, Debug/Release APK and Device Smoke.
3. After merge, a fresh exact-main Build and all six Device Smoke lanes must complete on the same main SHA.
4. Release remains blocked until #2102, #1901 and product/device acceptance are legitimately resolved.
