# G1-DRIFT SQL Schema Contract

Status: design/verification contract. This document does not switch the canonical TaskStore.

Baseline: d16923a295784dc1364637e9e159a758285af567
Execution issue: #1324

## Canonical ownership

The existing Dart product models remain the only domain model:
- Task
- FollowUp
- Project
- Tag
- Notebook/Checklist
- PersonReference

SQL is a persistence implementation behind the existing migration boundary. No second domain model is introduced.

## Relational schema

### tasks

Primary key: `id` (TEXT)

Columns:
- id TEXT NOT NULL PRIMARY KEY
- title TEXT NOT NULL
- description TEXT NOT NULL
- created_at TEXT NULL
- updated_at TEXT NULL
- due_date TEXT NULL
- follow_up_enabled INTEGER NOT NULL
- follow_up_date TEXT NULL
- category TEXT NULL
- notebook_kind TEXT NULL
- reminder_date TEXT NULL
- priority TEXT NOT NULL
- archived INTEGER NOT NULL
- trashed INTEGER NOT NULL
- completed INTEGER NOT NULL
- recurrence_json TEXT NULL

The SQL row must preserve the canonical Task JSON semantics. Null and absent optional values must not be silently converted into product defaults that change meaning.

### follow_ups

Primary key: `id` (TEXT)

Columns:
- id TEXT NOT NULL PRIMARY KEY
- task_id TEXT NOT NULL REFERENCES tasks(id)
- date_time TEXT NOT NULL
- note TEXT NOT NULL
- result TEXT NULL
- reminder_date TEXT NULL
- next_follow_up TEXT NULL
- completed INTEGER NOT NULL
- ordinal INTEGER NOT NULL

Constraint: (task_id, ordinal) UNIQUE.

`ordinal` preserves the original FollowUp list order. `date_time` is not a replacement for ordering.

### projects

Primary key: `id` (TEXT)

Columns:
- id TEXT NOT NULL PRIMARY KEY
- name TEXT NOT NULL

### project_items

Primary key: (project_id, task_id)

Columns:
- project_id TEXT NOT NULL REFERENCES projects(id)
- task_id TEXT NOT NULL REFERENCES tasks(id)
- ordinal INTEGER NOT NULL

### tags

Primary key: `id` (TEXT)

Columns:
- id TEXT NOT NULL PRIMARY KEY
- name TEXT NOT NULL

### task_tags

Primary key: (task_id, tag_id)

Columns:
- task_id TEXT NOT NULL REFERENCES tasks(id)
- tag_id TEXT NOT NULL REFERENCES tags(id)
- ordinal INTEGER NOT NULL

### checklist_items

Primary key: (task_id, ordinal)

Columns:
- task_id TEXT NOT NULL REFERENCES tasks(id)
- ordinal INTEGER NOT NULL
- value TEXT NOT NULL

The ordinal is authoritative because the current product model stores checklist order as a list.

### task_people

Primary key: (task_id, person_id)

Columns:
- task_id TEXT NOT NULL REFERENCES tasks(id)
- person_id TEXT NOT NULL
- person_json TEXT NOT NULL
- ordinal INTEGER NOT NULL

This preserves the current PersonReference payload without creating a second People domain store.

## Legacy conversion rules

1. Legacy JSON is read exactly once through the existing migration boundary.
2. Reader -> Adapter -> Writer remains the only migration path.
3. IDs are preserved verbatim.
4. FollowUp order is preserved by ordinal.
5. Checklist order is preserved by ordinal.
6. Optional values retain null/absent semantics where the domain model distinguishes them.
7. Duplicate primary/relationship IDs fail closed.
8. A failed migration must leave legacy storage unchanged.
9. Re-running a successful migration must be idempotent.
10. Legacy Home UI state is never migrated as product data.

## Verification requirements

Before canonical TaskStore cutover:
- legacy fixture -> SQL -> domain round-trip equality
- Task/FollowUp/Checklist/Project/Tag/PersonReference ID equality
- ordering equality
- duplicate rejection
- idempotent second migration
- failure/rollback leaves legacy unchanged
- backup/restore compatibility
- Analyze + full test suite
- Debug + Release APK
- Android Device Smoke on the exact final commit

This contract is intentionally separate from the TaskStore cutover so the currently validated SharedPreferences path remains recoverable until SQL verification is complete.
