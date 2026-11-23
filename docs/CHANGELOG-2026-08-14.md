# Arvin — Change Log 2026-08-14

## Product decisions

- FollowUp creation uses the current system date/time by default; both values remain user-editable.
- FollowUp `dateTime` and `nextFollowUp` remain separate concepts.
- Simple Notebook uses the same automatic editable date/time pattern.
- Simple Notebook saves automatically while editing and becomes read-only after leaving the screen; explicit edit action re-enters edit mode.
- Notebook availability is controlled by Settings.
- Notebook dates/times remain internal note metadata. They must not create Google Calendar events, Android/system calendar events, or Arvin Calendar entries unless a future product decision explicitly enables that behavior.

## Reference projects

- `arvin-task-tracker` remains the reference for proven FollowUp/date-time/reminder UX patterns.
- `daftar-peygiri` remains a secondary reference for tracking/CI experience where useful.
- Reference code is never copied wholesale; each candidate pattern is compared with the current Arvin architecture first.

## Stable areas

- Jalali/Persian Calendar behavior and its constrained-viewport regression fixes are not rewritten without a new failing regression or explicit product requirement.
- Android release/CI and independent parallel validation remain protected from unrelated feature changes.

## Current implementation sequence

1. FollowUp domain/store/service/entry stabilization.
2. Simple Notebook foundation and application service.
3. Notebook UI + read-only/edit session policy.
4. Settings feature toggle.
5. Dropbox Backup/Restore compatibility for Notes and FollowUps.
6. Google Calendar/Reminder integration for eligible scheduled items only; Notes remain isolated.
7. End-to-end regression validation.
8. Integrated APK test build.

## Development rule

Before every product change: audit current `main`, open PRs, recent fixes, reference projects, and existing tests. Avoid duplicate fixes. Keep independent commits/Waves and their workflows parallel whenever possible. Update project documentation with every material product or architecture decision.
