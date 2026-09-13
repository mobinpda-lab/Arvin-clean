# Arvin Canonical Authority

## Purpose
This document is the highest-level governance reference for Arvin architecture and UI evolution.

## Authority Rules

1. New UI work MUST follow canonical contracts.
2. Historical documents describe decisions but are not active authority.
3. Code changes must map to a contract and a validation path.
4. No parallel product models or persistence paths may be introduced.

## Current Migration Boundary

Legacy compatibility remains protected:

- ArvinTask
- TaskRepository
- arvin.tasks persistence envelope

Canonical direction:

- Task model
- TaskStore boundary
- Unified follow-up/reminder/recurrence model

## Home Migration Rule

Home migration must be incremental:

Legacy data -> Adapter boundary -> Canonical Task model -> UI

Large rewrites are prohibited until migration validation is complete.

## Validation Gate

Every migration step requires:

- flutter analyze
- flutter test
- flutter build apk --release

## Status

Authority established. Phase 2 Home Final Migration is gated by contract verification.
