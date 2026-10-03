# Arvin UI Convergence Audit — 2026-09-14

## Purpose

This audit connects the approved real installed-app reference, final UI reference, and implementation contract to the existing Flutter product.

The goal is not a mockup. The goal is to identify the exact gap between the required product behavior and the current implementation.

## Audit order

1. Authority documents
2. Existing Flutter screens
3. Existing domain models and services
4. Existing persistence behavior
5. Real installed-app observations
6. Acceptance tests

## Required surfaces

- Home dashboard
- Four home grouping modes:
  - Time
  - Projects
  - Categories
  - Labels
- Task card
- Quick entry
- Full task editor
- Task detail
- Follow-up history
- Notebook
- Calendar
- Next Action
- More and Settings

## Non-negotiable rules

- Preserve existing data models and storage.
- Do not create parallel repositories only for visual similarity.
- Old conflicting UI assumptions must be marked superseded.
- A feature is not complete until behavior and evidence exist.

## Gap report format

| Surface | Current code | Required behavior | Gap | Action |
|---|---|---|---|---|

## Evidence required for completion

- flutter analyze result
- test result
- Android runtime verification
- real screenshots
- commit reference
