# Arvin Gate A Audit — 2026-08-15

## Scope
Read-only architecture/state audit before any production refactor. Branch: `audit/unified-item-gate-a-2026-08-15`.

## Verified state
- `lib/models/task.dart` contains the current `Task` model and `FollowUp` model.
- `Task.fromJson` performs the legacy `followUpDate -> FollowUp` migration when no loaded FollowUps exist and a parseable legacy date is present.
- `follow_up.dart` is documented by the project state as a re-export and is not treated as a second FollowUp model.
- `lib/main.dart` still contains a separate `ArvinTask` model and `TaskRepository`, using the `arvin.tasks` SharedPreferences key.
- `HomePage` in `main.dart` still uses `TaskRepository` / `ArvinTask` for its active UI data path.

## Architectural finding
The repository currently has a real production-path duality between the newer `Task`/FollowUp model and the legacy `ArvinTask`/`TaskRepository` path. This is a confirmed migration target, not yet permission to refactor.

## Gate A decision
**BLOCKED — PROVE BEFORE REFACTOR**

Do not remove or rename `ArvinTask`, `TaskRepository`, or `Task` yet.

## Required next evidence
1. Map all references to `ArvinTask` and `TaskRepository`.
2. Locate and audit all existing migration tests.
3. Complete migration contract tests for identity, fields, FollowUps, legacy precedence, null/missing/empty input, malformed input behavior, round-trip stability, duplicate protection, and reconciliation.
4. Determine whether stateful migration/idempotency exists; do not invent a stateful migration test if migration is only deserialization.
5. Run the full test suite and actual GitHub Actions workflow.
6. Re-audit before any production refactor.

## Change policy
This audit intentionally changes documentation only. No production Dart code is changed by this audit.

## Canonical architecture rule
`Unified Item -> Reminder -> FollowUps[] -> History`

No parallel model, repository, storage layer, or feature-specific data path should be introduced without an explicit architecture decision.
