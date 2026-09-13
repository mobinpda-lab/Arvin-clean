# Arvin UI Conflict Audit — 2026-09-14

## Purpose

This audit prevents historical assumptions from overriding the final Arvin visual reference, product contract, and installed application evidence.

## Authority Rules

1. The approved final visual reference defines appearance and layout.
2. The implementation contract defines behavior and acceptance criteria.
3. Installed application evidence is used to validate real user flows.
4. Historical documents remain traceability evidence unless explicitly promoted.

## Conflict Locks

### Home
- Removed statistical dashboard assumptions must not be restored accidentally.
- Grouping controls must represent real data views.
- Task counts must not be duplicated when an item appears in multiple views.

### Quick Entry
- Fast capture and full form must use one canonical save path.
- Draft protection, keyboard behavior and repeated registration flow require real Android validation.

### Task Detail / Follow-up
- Follow-up history is append-only timeline data unless supported editing rules exist.
- Completing or editing a task must preserve historical evidence.

### Notebook
- Visual improvements must preserve canonical storage.
- No parallel note persistence may be introduced only for UI similarity.

### Projects / Categories / Labels
- Taxonomy is a real relationship in product data.
- Filters and grouping must be connected to existing models.

### Calendar / Next Actions / Settings
- Existing foundations must be reused.
- No placeholder controls or fake integrations are accepted.

## Implementation Gate

Before changing any screen:
1. Read active contract.
2. Inspect current model and service layer.
3. Compare with installed application evidence.
4. Implement.
5. Run analysis/tests and verify on Android.

## Status

This audit records reconciliation rules only. A feature is complete only with implementation evidence, tests and runtime verification.
