# Arvin Canonical Authority

## Purpose
This document is the highest-level governance reference for Arvin architecture and UI decisions.

## Authority Rules
- New UI flows must follow approved contracts.
- Existing historical documents are references, not active authority.
- No duplicate product models or persistence paths may be introduced.
- Migration must preserve user data and remain backward compatible.

## Current Migration Boundary
Legacy:
- `ArvinTask`
- `TaskRepository`
- `arvin.tasks` persistence envelope

Canonical target:
- `Task` model
- Unified follow-up/reminder/recurrence flow
- Single source of truth

## Migration Principle
Incremental migration with adapters, tests, and validation gates.

Required validation:
- flutter analyze
- flutter test
- flutter build apk --release
