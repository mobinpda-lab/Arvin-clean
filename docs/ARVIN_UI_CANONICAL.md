# Arvin Canonical UI Reference
## Status
Accepted product/UI reference. Detailed governance is controlled by `docs/ARVIN_PROJECT_OPERATING_PACKAGE.md` v49.0.
## Core UI
AppShell
- DashboardTimeline
- ReminderCard
- FollowUpCard
- JalaliCalendar
- ReportWidget
- NotificationWidget
## Protected Rules
- Persian RTL-first presentation.
- Calm hierarchy and low visual noise.
- Approved navigation, typography, spacing and component behavior remain stable.
- No UI redesign without explicit owner approval, design review, RTL verification, UX impact review and documentation.
- Current APK screenshots are runtime evidence; they do not automatically replace the accepted canonical design.
## Reminder Contract
- `یادآور` label with smaller time beside it when a time exists.
- All-day reminders must not display a fabricated time.
- Reminder title is shown below.
- Expandable details/actions are supported where approved.
- Quick actions: complete, snooze, edit, convert to Task.
- Lock Screen/widget behavior must remain consistent with the approved concept.
## Migration Direction
UI migration is incremental and must preserve existing working behavior while moving toward the accepted canonical design. Meaningful UI changes require appropriate visual/Golden and RTL validation.