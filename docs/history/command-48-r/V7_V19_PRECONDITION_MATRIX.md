# V7 → V19 Precondition Matrix

**Evidence:** Main v7 DDL blob `cd065ff25c680ed064e89068b3d063e737091025`; v19 installer blob `9f0243dff6d8ffa13649ca7fd2ee33ac4d3a2c21`; immutable fixture snapshot SHA `604b7e93ea6535d7ef176bb1503562b6f1aeed28`.

| Topic | Main v7 actual source | v19 target / behavior | Assessment |
|---|---|---|---|
| Schema version | `G1DriftSchema.version=7`; fixture `user_version=7` | Installer class version 19; no explicit v7-only gate; does not write user_version | Compatible by source inspection; runtime pending |
| Tasks | Legacy scheduling columns `follow_up_enabled`, `follow_up_date`, `reminder_date`; core fields and `legacy_payload_json` | Adds missing canonical fields, copies legacy values into envelope, then guarded rebuild retires three legacy columns | Compatible if exact fixture has no unrecognized task columns/indexes/triggers/FKs; verify in runner |
| Projects | `id,name,color_value,is_archived,legacy_payload_json` | Adds storage ordinal, center/template fields; preserves existing fields | Compatible by DDL |
| Follow-ups | `follow_ups` with id/task/date_time/title/note/result/reminder_date/next_follow_up/completed/waiting_for_response/ordinal | Copies to `follow_up_records`, preserves next-follow-up metadata in Task envelope, converts reminder dates | Compatible by field mapping; exact fixture rows need runtime proof |
| People | `people` directory table | Copies to `persons`, seeds `person_directory` once | Compatible by DDL |
| Task-person | `task_people(task_id,person_id,person_json,ordinal)` | Validates JSON identity/name, creates canonical Person and `task_persons` relation | Compatible only if every fixture payload meets strict validation |
| Follow-up-person | `follow_up_people(follow_up_id,person_id,ordinal)` | Copies to `follow_up_record_people` and creates missing canonical persons | Compatible by field mapping |
| Reminders | No normalized `task_reminders` table in v7; legacy Task/Follow-up reminder fields and JSON envelope | Creates `task_reminders`; derives Task and Follow-up reminders via historical Task model | Compatible by source path; invalid date values fail closed |
| Recurrence | `tasks.recurrence_json` and legacy JSON envelope | `RecurrenceSqlCodec` strictly validates known recurrence fields and writes `task_recurrence_rules` | Compatible if actual recurrence payloads pass strict decoder |
| Occurrence | `occurrenceHistory` and `checklistOccurrences` may reside in Task JSON | Codec moves them to `task_occurrences` and `occurrence_checklist_items`, with parity checks | Compatible if envelope shapes validate |
| Checklist | `checklist_items(task_id,ordinal,value)` | Same table retained; recurring occurrence checklist gets normalized separately | Compatible by DDL |
| Tags | `tags`, `task_tags` | Same table contracts retained | Compatible by DDL |
| Project membership | `projects`, `project_items` | Retained; adds new center/template structures | Compatible by DDL |
| Unknown Task payload keys | Stored in `legacy_payload_json` | Envelope is merged with Task serialization; top-level unknown keys survive; occurrence keys are deliberately moved | Mostly preserved; nested fields normalized by model require snapshot review |
| Indexes / triggers / custom constraints | Fixture report records standard schema checks but not a complete custom-object inventory | Task/reminder rebuilds fail closed or defer on unrecognized objects | Exact object inventory required from fixture runner |

## Schema facts

The accepted fixture inventory reports 12 tables and 15 rows, including 2 Tasks, 1 Project, 1 Follow-up, 1 Person, 1 Tag and 2 Checklist rows. The fixture has `integrity_check=ok`, zero foreign-key violations and the approved SHA-256.

The source-level table/column mapping is coherent. However, this is not a claim that the actual fixture has passed the Installer: runtime execution is separately recorded in the runner artifacts.
