# Arvin Code Audit Checklist — 2026-09-14

## Purpose

This document defines the audit process between the final Arvin product contracts and the actual Flutter implementation.

The goal is production alignment, not visual mockup delivery.

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

### Quick Entry

Verify:
- repeated task creation
- keyboard behavior
- draft preservation
- duplicate prevention

### Task Detail

Verify:
- detail navigation
- follow-up history
- editing without data loss

### Notebook

Verify:
- note mode
- checklist mode
- persistence after restart

### Calendar

Verify:
- Jalali calendar behavior
- task/reminder separation

## Completion states

Each feature must be marked:

- Documented
- Implemented
- Tested
- Android Verified

No feature is considered complete without evidence.
