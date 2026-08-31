# AI Worker patch recount recovery — 2026-08-31

## Live evidence

AI Worker run `33365912344` on issue #583 proved the #579 timeout/budget hardening works: two Copilot calls were stopped at the 180-second provider timeout instead of hanging. The middle attempt returned a structurally complete unified diff, but Git rejected it as `corrupt patch` because its hunk line counts were inconsistent with the hunk body.

## Bounded recovery

Arvin now uses Git's native `--recount` for both `git apply --check` and the actual apply. `--recount` only derives hunk line counts from the supplied patch body. It does not create missing `diff --git`, `---`, `+++` or `@@` sections and it does not make invalid context applicable.

All existing safety boundaries remain: diff/file-count limits, complete unified-diff validation, applicability check before write, read-only model tools, provider timeout/budget, runtime-owned validation/commit/push, and Production Orchestrator merge authority.

## Executable proof

`test/ai_worker_runtime_behavior_test.dart` proves in a temporary git tree that wrong numeric hunk counts can be safely recovered while mismatched patch context still fails closed.

## Current-main reconciliation

This fix is combined with the single-launch Worker hardening on the post-calendar-provider `main`; earlier validation PRs remain historical only.

Refs: #590 #583 #579.