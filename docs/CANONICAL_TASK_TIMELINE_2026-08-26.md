# Canonical Task Timeline — 2026-08-26

## Scope
This slice advances the Timeline lane in Issue #92 using only timestamps already stored on the canonical `Task` model.

## What changed
- Added `TaskTimelineService` as a read-only chronological projection.
- Timeline entries cover task creation, reminder time, FollowUp history, and task update time when those timestamps exist.
- FollowUp entries preserve their stable ids, note, and result.
- Transitional `followUpDate` is used only when `FollowUps[]` is empty, avoiding duplicate legacy/canonical entries.
- Equal timestamps have deterministic ordering.

## Product effect
The service gives future Timeline UI a single reusable projection without inventing a second history store. It can be consumed by Home/task detail later while `Task + FollowUps[]` remains the source of truth.

## Current boundary
Arvin does not persist every historical status transition yet. This slice therefore exposes only history that is already represented by persisted canonical timestamps; it does not fabricate archive/trash/completion history.

## Validation
Focused tests cover chronological ordering, out-of-order FollowUps, stable ids and text, legacy compatibility, duplicate prevention, and equal-timestamp determinism.

## Guardrails
- No new database or storage key.
- No parallel Task/History repository.
- No UI rewrite.
- No invented historical events.
- Merge only after exact-head `Arvin Build` and `Arvin Parallel Wave` validation.
