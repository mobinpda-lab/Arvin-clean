# Canonical Backup Portability — 2026-08-26

Issue: #221. Refs #195.

## Live gap closed

The existing SAF/Dropbox backup foundation was already portable, but Home used the legacy `ArvinTask` projection as its backup/restore boundary. That projection omits canonical fields added after the legacy Home model and could lose category, checklist, reminder, FollowUp history, recurrence and timestamps across devices.

## Canonical rule

Backup/restore preserves the existing source of truth rather than inventing a second representation:

`TaskStore / arvin.tasks -> Task.toJson() -> existing Arvin backup document -> Task.fromJson() -> confirmed TaskStore write`

The backup format, SAF flow and optional Dropbox bytes remain unchanged.

## Implemented Vertical Slice

`ArvinBackupManager` exposes additive canonical methods:

- `backupCanonicalTasks(...)` serializes the complete `Task.toJson()` shape.
- `restoreCanonicalTasks()` decodes a validated backup into canonical `Task` objects without mutating storage before user confirmation.
- Restore rejects empty or duplicate Task ids before a destructive replace can occur.

Home now:

- backs up `_searchSource`, the lossless canonical Task view rather than `ArvinTask.toJson()`;
- creates the emergency pre-restore backup from that same canonical source;
- parses restore candidates with `Task.fromJson()` through `restoreCanonicalTasks()`;
- writes only after explicit confirmation through the existing `TaskStore/arvin.tasks` path;
- reloads Home after the confirmed canonical write.

Focused tests cover complete Task round-trip preservation and lock the Home wiring to the canonical methods. No temporary automation file or alternate storage path remains in the feature tree.

## Merge evidence still required

The feature remains incomplete until its final exact head passes Arvin Parallel Wave and full Arvin Build/APKs, followed by the post-merge main Build.

## Guardrails

- No second backup format.
- No second Task database/storage key.
- No legacy projection used as the portability source.
- Restore candidate parsing is read-only until explicit user confirmation.
- Existing SAF/Dropbox foundation is reused.
