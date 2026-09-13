# Arvin Canonical UI Authority

Status: Binding authority for UI contract reconciliation.

This document supersedes conflicting historical UI contracts. Detailed surface requirements remain linked through `docs/ARVIN_UI_CANONICAL.md` and `docs/PRODUCT_CONTRACT_MATRIX.md`.

## Authority Rules

1. Canonical UI contracts are the source of truth for product surfaces.
2. Existing working models, services, repositories and storage paths must be preserved.
3. No parallel Task, Note, Reminder or UI state architecture may be introduced to satisfy visual migration.
4. Every UI change must map:

`Contract -> Code -> Test -> Evidence`

5. Deferred interactions remain visible in the Product Contract Matrix until validated.

## Phase 2 Scope

Phase 2 is Home Final Migration.

Goals:

- reconcile Home implementation with canonical Home contract;
- preserve canonical TaskStore and Task identity;
- remove conflicting UI assumptions;
- complete missing interaction wiring;
- add regression coverage.

## Migration Pipeline

Contract update
→ implementation audit
→ minimal code change
→ automated tests
→ device/visual validation
→ matrix update

## Non-goals

- full rewrite of Home;
- replacement of existing services;
- new storage models;
- independent UI-only data flows.
