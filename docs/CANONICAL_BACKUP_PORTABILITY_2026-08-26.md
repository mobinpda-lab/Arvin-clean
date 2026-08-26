# Canonical Backup Portability — 2026-08-26

Issue: #221. Refs #195.

## Live gap

The portable SAF/Dropbox backup foundation already exists, but Home currently passes the legacy `ArvinTask` projection to it. That projection does not contain the complete canonical `Task` state and can omit fields introduced after the legacy Home boundary.

## Canonical rule

Backup/restore must preserve the existing source of truth rather than invent a second representation:

`TaskStore / arvin.tasks -> Task.toJson() -> existing Arvin backup document -> Task.fromJson() -> confirmed TaskStore write`

The backup format, SAF flow and optional Dropbox bytes remain unchanged.

## Implemented foundation

`ArvinBackupManager` now exposes additive canonical methods:

- `backupCanonicalTasks(...)` serializes the complete `Task.toJson()` shape.
- `restoreCanonicalTasks()` decodes a validated backup into canonical `Task` objects without mutating storage before user confirmation.
- Restore rejects empty or duplicate Task ids before a destructive replace can occur.

Focused tests prove preservation of category, checklist, reminder, FollowUp history/result/nextFollowUp, recurrence, timestamps and normal Task state.

## Remaining Vertical Slice work

Home wiring deliberately waits until Widget #204 leaves `main.dart`, avoiding concurrent edits to the shared Home foundation. On latest main the Home backup action must pass the canonical Task list and confirmed restore must save the decoded canonical list through `TaskStore/arvin.tasks`, followed by exact-head CI/APK validation.

## Guardrails

- No second backup format.
- No second Task database/storage key.
- No legacy projection used as the portability source.
- Restore candidate parsing is read-only until explicit user confirmation.
- Existing SAF/Dropbox foundation is reused.
