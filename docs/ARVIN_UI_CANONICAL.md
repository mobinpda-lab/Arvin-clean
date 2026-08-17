# Arvin Canonical UI Reference v1

Status: Accepted

## Design Direction

- This image represents target UI direction.
- Current APK screenshots are runtime evidence only.
- Future UI changes must follow this reference.

## Component Architecture

AppShell
 ├── DashboardTimeline
 ├── ReminderCard
 ├── FollowUpCard
 ├── JalaliCalendar
 ├── ReportWidget
 └── NotificationWidget

## UI Governance Rules

No UI change without:

1. Canonical UI alignment
2. Component Design review
3. RTL verification
4. UX impact review
5. Documentation update

## Migration Principle

Current APK UI is preserved as runtime evidence. UI migration must move incrementally toward the Canonical UI design system without breaking existing functionality.
