# DATABASE HISTORICAL DDL — COMMAND 41-R
**Status:** PARTIAL EXTRACTION — NOT COMPLETE  
**Source index:** [DATABASE_SOURCE_EVIDENCE.md](DATABASE_SOURCE_EVIDENCE.md)

## Schema table inventory by historical source
The table names below are extracted from actual `CREATE TABLE` statements in the exact Schema blobs. This is an inventory, not a substitute for full DDL transcription.

| Version | Tables declared in source |
|---:|---|
| 7 | tasks, follow_ups, projects, project_items, taxonomy_categories, tags, task_tags, checklist_items, task_people, people, follow_up_people, arvin_storage_meta |
| 8 | v7 plus centers, project_templates, project_template_tasks, template_task_applications |
| 9-A | v8 plus task_templates |
| 10 | same declared table set as 9-A; adds template context columns |
| 11 | same declared table set as 10; adds checklist_enabled |
| 12 | adds task_reminders, follow_up_records, persons, follow_up_record_people |
| 13 | removes follow_ups, follow_up_people and people from canonical DDL after data transfer |
| 14 | adds tasks_canonical_v14 as a temporary rebuild table |
| 15 | adds task_persons; temporary tasks_canonical_v15 |
| 16 | adds task_occurrences, occurrence_checklist_items, task_recurrence_rules, person_directory |
| 17 | same relational table set as v16; adds recurrence_json to Tasks |
| 18 | same canonical table set plus temporary reminder rebuild table |
| 19 | tasks, task_reminders, follow_up_records, persons, person_directory, follow_up_record_people, task_persons, centers, project_templates, task_templates, project_template_tasks, projects, project_items, template_task_applications, taxonomy_categories, tags, task_tags, checklist_items, task_occurrences, occurrence_checklist_items, task_recurrence_rules, arvin_storage_meta |
| 20 | v19 plus center_projects, categories and project_categories in the M2M migration |

## DDL and index evidence
- v7 CREATE statements: Schema lines 10–64; conditional ALTER statements lines 72–97.
- v8 adds Center and template DDL; Project Center/template columns and partial unique index at lines 112–122.
- v9-A adds Task Template DDL and project template context.
- v9-B creates Center, Center↔Project, Category, Project↔Category and migration-exception tables; adds three optional Task foreign keys and five indexes.
- v19 DDL is declared at lines 15–98. It includes PKs and UNIQUE constraints on Task, Reminder, Follow-up, Person, junction, occurrence and recurrence structures. Installer conditionally adds fields and validates foreign keys.
- v20 creates two junction tables with composite primary keys and RESTRICT foreign-key actions, plus reverse indexes and Task hierarchy indexes. It adds two compatibility triggers.

## ALTER, rebuild and destructive DDL
| Source | Operation | Exact source lines | Finding |
|---|---|---:|---|
| v13 | DROP legacy Follow-up/People tables | 361, 364, 367 | Destructive after data-copy phase |
| v14 | DROP tasks / RENAME canonical replacement | 420–421 | Task table rebuild |
| v15 | DROP task_people | 266 | Relationship source retired after transfer |
| v15 | DROP tasks / RENAME replacement | 466–467 | Second Task rebuild |
| v18 | RENAME task_reminders, CREATE replacement, INSERT…SELECT, DROP retired table | 400–439 | Selected canonical columns copied and compared |
| v19 | Reminder rebuild | 351–449 | Checks unknown columns, custom indexes and triggers; compares selected row values |
| v19 | Task rebuild | 474–617 | Defers on unknown columns, custom indexes, triggers or outgoing FKs; compares canonical projection |
| v19 | legacy schedule retirement | 726–850 | Preserves SQL values in legacy JSON envelope before retirement |
| v20 | M2M junctions and Task FKs | migration lines 61–108 | Additive; source v19 tables retained |

## Limitations
This file does not yet reproduce every complete CREATE TABLE statement, all individual column types/defaults/nullability, all FK actions, all index definitions, all triggers, or every transfer SQL statement for versions 7–20. The exact source SHA and line ranges are preserved in DATABASE_SOURCE_EVIDENCE.md. No DDL parity claim is made.

**Result: BLOCKED.** Full DDL extraction and independent SQLite schema parity remain required.
