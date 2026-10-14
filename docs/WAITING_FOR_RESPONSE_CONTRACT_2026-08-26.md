# Waiting for Response contract — 2026-08-26

## Scope
This Wave X1 slice defines the domain contract for «منتظر پاسخ دیگران» without adding a second Task state or persistence path.

## Decision
- The latest canonical `FollowUp.result` is the source of the waiting state.
- Canonical persisted result token: `waiting_for_response`.
- Persian/English legacy aliases are accepted at the read boundary and normalize to the canonical token.
- Completed, archived, or trashed Tasks are not treated as active waiting items even if their latest FollowUp contains a waiting result.

## Implementation
`WaitingForResponseService` provides:
- detection from the latest canonical FollowUp;
- result normalization;
- a helper that returns a replacement FollowUp marked with the canonical waiting token while preserving its identity, note, timestamp, and next-follow-up date.

## UI wiring (2026-10-13)
- Home → More now exposes a direct «منتظر پاسخ دیگران» entry that opens FollowUpOfficePage in waiting-only mode.
- The waiting list evaluates only each Task's latest FollowUp by dateTime and excludes completed, archived, and trashed Tasks.
- Each waiting row exposes «بازکردن کار» to open its canonical Task detail and continue recording Follow-ups.
- No new Task state, persistence field, database, or repository is introduced.

## Guardrails
- No new Task status field.
- No new database/storage/repository.
- No parallel CRM model.
- Existing `FollowUps[]` remains the source of truth.
- Merge only after exact-head `Arvin Build` and `Arvin Parallel Wave` are green.
