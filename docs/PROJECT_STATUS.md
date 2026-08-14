# Arvin project status

## Milestone

Arvin v1.1.0

## Current parallel tracks

1. TaskStore / FollowUp model stabilization
2. Follow-up history and last follow-up display
3. Archive and Trash navigation/restore
4. Main menu, Settings and font selection
5. Calendar stabilization and Jalali reminder time

## Current blocking rule

Do not merge feature UI tracks until `flutter analyze` and `flutter test` are green on the relevant branch.

## Data safety

Keep the existing `arvin.tasks` SharedPreferences key and preserve legacy `followUpDate` during migration.
