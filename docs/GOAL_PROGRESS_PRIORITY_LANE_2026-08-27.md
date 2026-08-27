# Goal / Project Progress Priority Lane — 2026-08-27

Refs #295 #286 #195 #92.

## Purpose
Continue Goal → Project → Item without creating another task system. Goal and Project progress is derived from the completion state of the existing canonical Tasks referenced by Project item IDs.

## Foundation
- `GoalProgressService` reads `GoalPlan` plus canonical `Task` objects.
- Overall Goal progress counts unique referenced Task IDs so duplicate project ownership cannot inflate the result.
- Per-project progress remains visible.
- Missing Task references stay explicit validation evidence.
- Duplicate canonical Task IDs are rejected rather than choosing a silent winner.

## Safety
- no new Task schema, database, storage key or repository;
- no copied Task payload inside Goal/Project;
- no write or UI side effect;
- #289 Goal/Project domain remains the required parent foundation.

## Delivery strategy
Implementation is committed on a stacked branch while current Full Gate runners are busy. The PR is intentionally delayed to avoid CI contention. After #289 merges, this branch will be reconciled onto the resulting `main`, then opened for Fast CI before any user-facing integration.