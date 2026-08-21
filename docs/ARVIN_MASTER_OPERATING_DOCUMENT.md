# Arvin Master Operating Document v1.6

## Identity
- Project: Arvin v1 / Arvin-clean
- Repository: mobinpda-lab/Arvin-clean
- Technology: Flutter / Dart
- Target: Android

## Purpose
Arvin is a professional Persian RTL productivity application for Task, Reminder, Follow-up, Calendar, Notification, Backup and future cloud features.

## Source of Truth
GitHub is the authoritative source for code, branches, commits, PRs, workflows, tests and build status.
No implementation status should be claimed without GitHub evidence.

## Product Vision
Arvin is not only a task manager. It is a complete personal time and productivity system.

Core modules:
- Task Engine
- Reminder Engine
- Follow-up Engine
- Jalali Calendar
- Iran Official Calendar
- Prayer Reminder
- Backup and Restore
- Reports
- Widget
- PDF and Print
- Security

## Calendar System
Arvin Calendar includes:
- Persian Jalali calendar
- Iran official holidays
- National and religious occasions
- Personal events
- Connection between calendar, tasks and reminders

## Reminder System
Reminder includes:
- Task reminders
- Time based notifications
- Repeat schedules
- Background execution

### Prayer Reminder Module
Supported capability:
- Daily prayer times
- Fajr
- Sunrise
- Dhuhr
- Maghrib
- User configurable notifications before prayer times

## Current Product Foundation
- Task management
- Follow-up foundation
- Dates and tags
- Bulk operations
- Archive and trash
- Settings
- Backup/Restore foundation

## Architecture
Target architecture:
- Clean Architecture
- Feature Based Architecture
- Repository Pattern
- Riverpod state management
- SQLite with controlled migration

Target features:
lib/features/
- tasks
- reminder
- followup
- calendar
- backup
- report

## Wave Model

### Wave 0
Audit:
- Repository
- Branches
- Commits
- PRs
- Workflows
- Documentation

### Wave 1
Production Foundation:
- Architecture stabilization
- Core improvements
- Quality foundation

### Wave 2
Feature Expansion:
- Reminder Engine
- Follow-up Engine
- Jalali Calendar
- Iran Official Calendar
- Holiday support
- Prayer Reminder

### Wave 3
Product Completion:
- Cloud
- Widget
- PDF
- Security
- Release

## AI Continuation Rule
When receiving "ادامه آروین":
1. Check real GitHub status.
2. Review latest project state.
3. Continue active wave.
4. Avoid duplicate work.
5. Report with evidence.

## Reporting Standard
Every report must include:
- Current status
- GitHub evidence
- Completed work
- Result
- Problems
- Next action

## Change Rules
- No direct large changes on main.
- Use branches.
- Use small reversible commits.
- Test before declaring success.
- Update documentation with important decisions.

## Final Goal
Build Arvin as a fast, parallel, controlled software production system and deliver a complete Persian productivity application.

## Change Log
Version: v1.6
Changes:
- Added Iran official calendar requirements.
- Added official holidays and occasions support.
- Added Prayer Reminder module.
- Updated product vision and Wave planning.
