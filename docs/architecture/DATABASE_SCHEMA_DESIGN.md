# Database Schema Design — Working Contract
- Status: DESIGN REQUIRED / NOT APPROVED AS IMPLEMENTED
- Recorded: 2026-11-18 | Governing decision: [ADR-001](ADR-001-project-execution-model.md)

## Target principles
One SQLite database, one final schema, one migration registry, one Database Executor, one authoritative Store set, one backup/restore contract. Preserve IDs and history. Enforce FKs, uniqueness, atomic transactions, safe retry and failure recovery. No parallel storage for the same domain data.

## Candidate entities to inventory
Core: `centers`, `projects`, `categories`, `tasks`, `tags`, `people`, `follow_ups`, `reminders`, `checklist_items`.
Relations: `center_projects`, `project_executions`, `project_categories`, `task_tags`, `task_people`, `follow_up_people`.
Existing Task and Project membership structures must also be inventoried.

## Required semantics
- `projects`: shared identity.
- `center_projects`: Center↔Project membership.
- `project_executions`: one independent execution per (Project, Center), unique pair.
- `tasks`: optional execution reference; Tasks without Project/Center/Category remain valid.
- `categories`: independent reusable identity; Task cardinality awaits consumer audit.
- `tags`: one SQLite-backed source.
- Reports aggregate by distinct Task identity and report per execution/Center separately.

## Explicitly unresolved
1. Final table/column definitions and indexes.
2. Whether current schema represents optional Task→ProjectExecution without losing legacy meaning.
3. Category cardinality per Task.
4. Fate and migration semantics of `tasks.project_id` and `project_items`.
5. Existing Center/Project/Task membership tables.
6. Reminder and Checklist ownership and persistence.
7. Complete backup inclusion list and format version.

Do not implement destructive DDL until these questions have documented answers and exact historical SQLite fixtures prove lossless migration.