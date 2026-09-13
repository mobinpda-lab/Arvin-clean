# Arvin Canonical UI Implementation Map

Date: 2026-09-14
Status: Active audit reference

## Purpose

This document converts the final UI reference decision into an implementation map. It prevents old UI contracts from silently returning during development.

## Authority order

1. Final UI decision specification.
2. Latest screen references for the same feature.
3. Existing working data models and services.
4. Old visual documents only when they do not conflict.

## Current architectural constraints

- Existing Task, FollowUp, Project, Category, Tag and Notebook models remain the source of truth.
- No parallel storage layer may be created for visual similarity.
- Legacy Home statistics cards must not return.
- UI projections must consume real application data.

## Screen reconciliation

| Area | Target | Implementation rule |
|---|---|---|
| Home | Four grouping modes | Time, Projects, Categories, Tags are real data views |
| Quick Entry | Persistent rapid creation panel | Must use the same save path as full form |
| Task Card | Real task projection | Follow-up preview shown only from real data |
| Task Detail | Follow-up history aware | History must never be replaced by latest entry |
| Notebook | Separate note/checklist experience | Keep existing notebook persistence |
| Calendar | Real date integration | No fake counters or mixed event types |
| Settings | Functional options only | No placeholder controls |

## Known legacy risks

- Flat Flutter structure and older pages require reconciliation before large UI changes.
- Legacy Home logic must not become a second source of truth.
- Existing migration decisions around unified Task storage must be preserved.

## Delivery sequence

1. Finalize contracts and remove ambiguity.
2. Reconcile Home and grouping architecture.
3. Implement quick entry behavior.
4. Implement task detail and follow-up flow.
5. Complete notebook, calendar and settings.
6. Validate on real Android execution.

## Evidence required for completion

Every completed phase must include:

- commit identifier
- changed files
- analyzer/test results
- real device screenshots
- implemented/tested status

