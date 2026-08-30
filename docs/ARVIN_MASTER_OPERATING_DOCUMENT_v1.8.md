# Arvin Master Operating Document v1.8

## Enterprise Autonomous Engineering System

Repository: mobinpda-lab/Arvin-clean

## v1.8 Updates

### Project Reporting Standard
- Reports must be understandable for managers and non-programmers.
- Only real verified progress may be reported.
- Completion requires evidence from GitHub, tests, review, or real output.

Report format:
1. Current Status
2. Completed Action
3. Project Status
4. Next Action
5. Short Technical Status when required

### Knowledge Continuity Rule
Important decisions, experiences, errors and solutions:
Experience -> Documentation -> GitHub -> Commit -> Pull Request -> Workflow -> Validation -> Merge

### GitHub Reality Rule
GitHub is the source of truth.
Before major changes review repository, branch, commit, documentation, architecture, PR, CI and tests.

### GitHub Connection Recovery Protocol
If access fails:
1. Recheck GitHub connection and repository access.
2. Refresh session if required.
3. Continue from real repository state, not conversation memory.

### Architecture Governance
Single source of truth:
Item with Notes, Reminders, FollowUps and Calendar references.

Rules:
- No parallel storage.
- No full rewrite without migration.
- Audit existing foundations before replacement.

### Migration Gate
Audit -> Migration Test -> Validation -> CI -> Merge

### Parallel Development Governance
Tracks:
- Architecture / Unified Item
- Iran Calendar
- Home UX
- Widget
- Reminder
- Cloud
- PDF/Print
- Security

Shared foundations must not be changed by conflicting tracks.

### UI Governance
Canonical UI includes:
Dashboard Timeline, Reminder Detail, Create Reminder, Follow-up Timeline, Iran Calendar, Reports, Categories, Settings, Lock Screen Notification and Widget.

### Quality Rule
Real progress means:
Capability + Test + CI + Real Build

### Non Negotiable Rules
Forbidden:
- Full Rewrite
- Parallel Storage
- Duplicate Foundation
- Fake Commit
- Fake CI result
- APK claim without artifact
- Sensitive change without audit

Principle:
Before continuing, prove the real gap; then make the smallest required change.
