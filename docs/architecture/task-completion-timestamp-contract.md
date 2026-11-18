# Task completion timestamp contract (Wave 7-61 Track B)

Status: implementation contract for the reconciled Wave 7-61 Track B scope.

## Canonical field and storage

- `Task.completedAt` is nullable and represented as an ISO-8601 timestamp in Task JSON.
- Canonical SQLite storage is `tasks.completed_at TEXT NULL`.
- The canonical SQL schema is already version 7 and includes this column. The idempotent schema installer also inspects existing task columns and adds `completed_at` when upgrading an older table. No destructive table rebuild or schema-version bump is required.
- TaskStore reads/writes the timestamp in the SQL column and canonical JSON envelope. Backup/restore carries the Task JSON field without inventing a timestamp for historical completed rows that have no known completion time.

## State transitions

| Operation | completed | completedAt |
|---|---:|---|
| First completion | true | current timestamp |
| Repeated completion | true | preserve original |
| Explicit reopen | false | null |
| Completion after reopen | true | fresh current timestamp |
| Metadata / Task Note edit | unchanged | strictly unchanged |

Completion is an explicit lifecycle operation. An editor payload must not implicitly complete or reopen a Task. Metadata edits update `updatedAt` and preserve Task identity, `completedAt`, and existing `followUps`.

Single, bulk and swipe completion update the existing Task in place and preserve all follow-up history. TaskStore persists Task and follow-up relations transactionally.

## Compatibility and non-goals

- Existing `follow_up_enabled` and `follow_up_date` columns are intentionally retained and untouched by this track.
- No follow-up records are synthesized, dropped or rewritten.
- A legacy completed Task without a trustworthy completion timestamp remains `completedAt == null`; due dates, reminder dates and follow-up dates are not substitutes.

## Typography contract (Track A)

The bundled Vazirmatn Regular/Medium/Bold assets are the only supported application family. Light and dark themes use Vazirmatn. Settings retain text-size control but do not expose a font picker or read/write a font-family preference. Portable backup settings omit `fontFamily`; restore ignores the legacy key. Shared PDF report rendering embeds bundled Vazirmatn Regular/Bold assets.

## Validation

Focused tests cover Task JSON lifecycle, SQL persistence and safe schema installation, metadata immutability, bulk completion and follow-up preservation, settings/backup compatibility, and default PDF rendering. CI must validate the resulting commit SHA; earlier baseline runs are not evidence for this commit.
