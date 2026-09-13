# Arvin Code Audit Checklist — 2026-09-14

## Purpose

This document defines the audit process between the final Arvin product contracts and the actual Flutter implementation.

The goal is production alignment, not visual mockup delivery.

## Audit rules

- Existing architecture, models, repositories and storage are the foundation.
- No parallel implementation may be created only to match screenshots.
- Existing user data and capabilities must be preserved.
- A feature is complete only when implementation, persistence, interaction and verification exist.

## Audit order

1. Existing architecture review
2. Existing models and repositories review
3. Screen and widget mapping
4. Behavior verification
5. Data preservation verification
6. Android runtime verification

## Existing capabilities to preserve

- Task model and storage
- FollowUp timeline/history
- Project management
- Category management
- Labels
- Notebook storage
- Calendar data
- Archive and trash behavior
- Reminder and recurrence data

## Screen audit targets

### Home

Verify:
- final RTL layout
- four grouping modes
- real data grouping
- no legacy statistics cards
- task card behavior
- real empty/loading/error states

### Quick Entry

Verify:
- repeated task creation without closing panel
- keyboard behavior
- draft preservation
- duplicate prevention
- error recovery

### Task Detail

Verify:
- detail navigation
- follow-up history
- editing without data loss
- completion without deleting history

### Notebook

Verify:
- note mode
- checklist mode
- persistence after restart
- search and categorization

### Calendar

Verify:
- Jalali calendar behavior
- task/reminder separation
- connection to real task data

## Evidence required

For each completed phase record:

- branch name
- commit id
- changed files
- test results
- flutter analyze result
- real Android screenshot
- remaining limitations

## Completion states

Each feature must be marked:

- Documented
- Implemented
- Tested
- Android Verified

No feature is considered complete without evidence.
