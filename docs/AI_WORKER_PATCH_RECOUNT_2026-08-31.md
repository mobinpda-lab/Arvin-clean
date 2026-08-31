# AI Worker patch recount recovery — 2026-08-31

## Live evidence

AI Worker run `33365912344` on issue #583 proved the #579 timeout/budget hardening works: two Copilot calls were stopped at the 180-second provider timeout instead of hanging. The middle attempt returned a structurally complete unified diff, but Git rejected it as `corrupt patch` because its hunk line counts were inconsistent with the hunk body.

## Bounded recovery

Arvin now uses Git's native `--recount` for both `git apply --check` and the actual apply. `--recount` only derives hunk line counts from the supplied patch body. It does not create missing `diff --git`, `---`, `+++` or `@@` sections and it does not make invalid context applicable.

All existing safety boundaries remain:
- diff/file-count limits;
- complete unified-diff structure validation;
- applicability check before write;
- read-only model tools;
- provider timeout and total budget;
- runtime-owned tests/commit/push;
- Production Orchestrator as the only merge authority.

## Executable proof

`test/ai_worker_runtime_behavior_test.dart` creates a temporary git working tree and proves:
- a complete patch with deliberately wrong numeric hunk counts is accepted through `--recount` and changes only the intended content;
- the same mechanism still rejects a patch whose context does not match.

Refs: #590 #583 #579.
