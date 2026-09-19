# Arvin UI Implementation Gap Matrix — 2026-09-14

## Purpose

This document is the audit bridge between the approved Arvin visual/product references and the actual Flutter implementation.

It prevents a visual-only completion claim. Every item must move through:

- Documented
- Implemented
- Tested
- Verified on Android

## Audit order

1. Home and navigation
2. Quick Entry
3. Task card and detail
4. Follow-up timeline
5. Notebook
6. Calendar
7. Categories/projects/tags
8. Settings
9. Release validation

## Rules

- Existing Task, FollowUp, Project, Category, Tag and Notebook foundations must be reused.
- No parallel storage model may be introduced only to imitate screenshots.
- Old UI assumptions are historical unless explicitly active in the authority index.

## Initial audit checklist

| Area | Required verification | Status |
|---|---|---|
| Home | Final grouping UI and data behavior | Pending |
| Quick Entry | Continuous entry workflow | Pending |
| Task Detail | Detail before edit behavior | Pending |
| FollowUp | History preservation | Pending |
| Notebook | Note/checklist persistence | Pending |
| Calendar | Real data connection | Pending |
| Taxonomy | Project/category/tag grouping | Pending |
| Settings | Only working options exposed | Pending |
| Release | Analyze, tests, Android verification | Pending |

## Evidence requirement

A feature is not complete from documentation alone. Completion requires code evidence and runtime verification.
