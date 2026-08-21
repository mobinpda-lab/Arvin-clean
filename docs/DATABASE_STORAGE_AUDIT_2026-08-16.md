# Arvin v1 — Database / Storage Audit — 2026-08-16

## Scope

This document records the current evidence from the Arvin-clean repository before any Database/Migration or Repository refactor.

## Confirmed

- Persistence currently uses `shared_preferences`; no separate database engine is being introduced at this stage.
- `FollowUpRepository` is a concrete persistence boundary over `SharedPreferences` for FollowUp data.
- `Task.toJson()` includes `followUpDate`; therefore the previously reported `followUpDate` round-trip loss is **not confirmed** and must not be treated as a bug.
- `Task.fromJson()` contains compatibility behavior that can reconstruct a FollowUp from a legacy `followUpDate` when the FollowUp list is empty. This is compatibility logic, not a formal versioned database migration system.
- Repository and persistence tests already exist; the earlier estimate of only ~5 tests is not reliable.

## Current boundary (evidence-based)

```text
Task / FollowUp models
        ↓
FollowUpRepository
        ↓
SharedPreferences
        ↓
JSON envelope
```

This is an initial map, not the target Clean Architecture boundary.

## Open questions

1. Exact behavior for malformed JSON and malformed FollowUp entries.
2. Legacy precedence when both legacy and current FollowUp data exist.
3. Idempotency of legacy reconstruction and subsequent save/load cycles.
4. Whether all persistence paths use the same boundary or whether additional direct SharedPreferences call-sites exist.
5. Formal migration/versioning contract for a future schema change.

## Decision

Do **not** introduce a database migration, new Repository layer, or Riverpod refactor yet.

The next safe step is targeted regression testing of existing persistence behavior. Only confirmed defects should receive minimal code fixes.

## DeepSeek review note

DeepSeek review remains useful for the Migration Contract and malformed-data policy after the targeted tests establish the actual behavior. No architectural decision should be based solely on the earlier unverified bug list.

## Validation protocol

Audit → targeted tests → minimal fix (if proven) → Build/Quality/Parallel validation → documentation → commit → re-audit.
