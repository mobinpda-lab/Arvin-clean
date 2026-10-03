# ARVIN Implementation Backlog Execution Plan

## Purpose
This document converts the product roadmap into executable work items. Each item must move through:

Documented -> Implemented -> Connected to real data -> Tested -> Android Verified

## Priority Order

### P0 - Core User Flow

#### Home
- Remove legacy conflicting home statistics UI.
- Implement four real grouping modes:
  - Time
  - Projects
  - Categories
  - Labels
- Preserve Task as the single source of truth.
- Validate empty/loading/error states.

#### Task Card
- Real completion control.
- Real status and due date display.
- Latest follow-up preview when available.
- Open details instead of direct editing.

### P1 - Task Creation

#### Quick Entry
- Bottom sheet above keyboard.
- Auto focus title.
- Continuous task creation flow.
- Preserve selected metadata.
- Prevent duplicate submission.
- Protect drafts on back and close.

#### Full Task Form
- Shared save path with quick entry.
- Project/category/label/follow-up support.
- Safe unsaved-change handling.

### P2 - Follow Up System

- Task detail redesign.
- Follow-up history preservation.
- Add follow-up without replacing history.
- Real timestamps and states.

### P3 - Notebook

- Notes and checklist separation.
- Full content editor.
- Preserve existing storage.
- Real checklist progress.

### P4 - Calendar and Settings

- Persian calendar validation.
- Separate task, reminder, follow-up and event concepts.
- Functional settings only.

### P5 - Production Infrastructure

#### Sync
- Define sync boundary.
- Conflict strategy.
- Offline-first behavior.

#### Backup
- Export/import.
- Restore validation.

#### Notifications
- Reminder scheduler.
- Android permission handling.

#### Release
- Analyze.
- Tests.
- Release build.
- Real device verification.

## Delivery Rule
No feature is complete without code evidence, test evidence and Android evidence.

## Current Status
Planning and traceability phase completed. Implementation audit follows.