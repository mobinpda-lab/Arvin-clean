# Arvin data model

## Task

`ArvinTask` is the canonical persisted task model. The legacy `followUpDate` field remains readable and writable for backward compatibility while `followUps` stores the follow-up history.

## FollowUp

A `FollowUp` contains:

- `id`
- `dateTime`
- `note`
- `result`
- `nextFollowUp`

Follow-up is **not** a Task status. It is task-related history and scheduling data.

## Migration rule

When old JSON contains `followUpDate` but no `followUps`, the loader creates one deterministic legacy FollowUp. Existing `arvin.tasks` storage is preserved.
