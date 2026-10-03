# Arvin UI Implementation Audit Matrix

## Purpose

Operational contract connecting the canonical UI reference to the Flutter implementation.
Prevents deprecated UI decisions from returning.

## Product baseline

Repository: mobinpda-lab/Arvin-clean
Platform: Flutter Android

Existing capabilities to preserve:
- Task management
- Follow-up management
- Tags
- Bulk operations
- Archive and trash
- Swipe configuration
- Backup/Restore

## Canonical decisions

### Home
- RTL Persian UI
- No legacy four statistic cards
- Four fixed grouping controls:
  - Time
  - Projects
  - Categories
  - Tags
- Grouping must use real data.

Status: Documented

### Quick Entry
- Compact bottom panel
- Sequential task creation
- Keep selected metadata after save
- Protect unsaved drafts.

Status: Documented

### Task Card
- Completion control
- Title
- Related project/category
- Real status and dates
- Follow-up preview when available.

Status: Documented

### Follow-up Detail
- Preserve history
- Add follow-up appends history
- Update task views after success.

Status: Documented

### Notebook
- Notes and checklists remain separate
- Full editor behavior
- Existing storage preserved.

Status: Documented

### Calendar
- Real Persian calendar
- Separate tasks, reminders, follow-ups and events.

Status: Documented

## Deprecated decisions

- Legacy home statistic cards are not authoritative.
- Images define layout intent, not fake content.
- UI must connect to existing domain models.

## Execution sequence

1. Code audit
2. Shared design system
3. Home grouping
4. Quick entry
5. Task detail and follow-up
6. Notebook
7. Calendar and settings
8. Android verification
