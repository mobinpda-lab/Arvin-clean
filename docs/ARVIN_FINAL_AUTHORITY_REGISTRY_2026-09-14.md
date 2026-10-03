# ARVIN FINAL AUTHORITY REGISTRY

Version: 2026-09-14

## Purpose

This document registers the final authority chain for Arvin production completion.

The goal is to prevent UI drift, document conflicts, and implementation based on obsolete snapshots.

## Authority Chain

1. Real installed Arvin application behavior and approved reference screenshots.
2. `docs/ARVIN_FINAL_UI_VISUAL_REFERENCE.md` for visual identity, layout, colors and interaction appearance.
3. `docs/ARVIN_FINAL_PRODUCT_IMPLEMENTATION_CONTRACT_2026-09-14.md` for behavior, data rules, acceptance criteria and production delivery.
4. Existing canonical contracts only when they do not conflict with the above.

## Production Rules

- Do not create mockups as completion evidence.
- Do not mark a feature complete because a class, service or old document exists.
- Implementation must be verified by real execution evidence.
- Existing Task, FollowUp, Project, Category, Label and Notebook data must be preserved.
- Historical documents remain traceability records unless explicitly promoted.

## Required Completion Evidence

Every production phase must provide:

- branch and commit identifier
- changed files
- tests and analysis results
- real Android execution evidence
- remaining limitations

## Conflict Resolution

When documents disagree:

1. Check current repository reality.
2. Check this authority chain.
3. Preserve old information as history.
4. Update contracts instead of silently changing behavior.

## Next Execution Phase

The next phase after authority registration is implementation audit:

- compare contracts against Flutter code
- identify missing behaviors
- identify obsolete UI paths
- execute production waves
