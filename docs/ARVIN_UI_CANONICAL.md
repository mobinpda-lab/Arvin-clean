# Arvin Canonical UI Reference v1

Status: Accepted

## Design Direction

- This image represents target UI direction.
- Current APK screenshots are runtime evidence only.
- Future UI changes must follow this reference.

## Component Architecture

```text
AppShell
 ├── DashboardTimeline
 ├── ReminderCard
 ├── FollowUpCard
 ├── JalaliCalendar
 ├── ReportWidget
 └── NotificationWidget
```

## UI Governance Rules

No UI change without:

1. Canonical UI alignment
2. Component Design review
3. RTL verification
4. UX impact review
5. Documentation update

## Migration Plan

The migration from current APK UI to Canonical UI follows these stages:

1. UI Documentation and Design Tokens
2. AppShell foundation
3. DashboardTimeline migration
4. ReminderCard and FollowUpCard implementation
5. Create Reminder redesign
6. JalaliCalendar migration
7. ReportWidget implementation
8. NotificationWidget and Widget integration

## Migration Principle

Current APK UI is preserved as runtime evidence. UI migration must move incrementally toward the Canonical UI design system without breaking existing functionality.
