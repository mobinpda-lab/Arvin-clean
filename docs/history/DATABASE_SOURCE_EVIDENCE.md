# DATABASE SOURCE EVIDENCE — COMMAND 41-R
**Status:** PARTIAL FORENSIC INDEX — NOT P0 ACCEPTANCE  
**Audit reference:** `f5c64285687cd2665cc383e10277cb6e0266f4c2`  
**Main:** `45e4202b03a434459e4c021a04efa7e8396359db`

## Evidence rules
Every item below was fetched from GitHub at the named commit. Blob SHAs identify exact file content. Line numbers are 1-based. Commit ancestry is not equivalent to an executable database-upgrade proof.

## Schema history
| Version / lineage | Commit | Schema blob | File | Relevant lines / finding |
|---|---|---|---|---|
| Main v7 | `5e974519087c14f07387e45a903cee3409cc68bf` | `cd065ff25c680ed064e89068b3d063e737091025` | `lib/services/g1_drift_schema.dart` | 1–157; CREATE statements 10–64; conditional ALTERs 72–97; Person backfill 120–138 |
| v8 | `874dd8b567fdceae7ed62f01a93804dcea1a5473` | `f4d488fa3f972c4ce123df6089b66569b9c8849c` | same | 1–182; Centers and template tables; Project center/template fields and partial unique index at 112–122 |
| v9-A Task Template | `708c112a82c753f1dcdb77f1cf9712a6336a725d` | `617c05e4416bede903e78b65bd32a839d2d7c65a` | same | 1–189; task_templates, project_templates, project_template_tasks, template_task_applications |
| v10 | `00e3d8007798c5e29222faaa9c4738075c9d5a93` | `fe1d21c368dfdbf6e6fbf772d5bee6d6af277d46` | same | 1–204; adds task_templates.center_id_snapshot / project_id_snapshot (102–105) |
| v11 | `96651f7690a1cd40f7fa087e12293bcf288bb667` | `b217251b908114e76ef643045b1e0cd4f9911f75` | same | 1–231; adds task_templates.checklist_enabled (126–132) |
| v12 | `01238b00dd9e58cdc3987bf24b093a9d6c23f6ac` | `ae69d0bbeaf90bc92e3d5e91fd6a2fdd576c8e99` | same | 1–334; canonical task_reminders, follow_up_records, persons, follow_up_record_people |
| v13 | `7bcd218254c7931a766bdd091bb3d39483c1888e` | `c4f061eb8dcc3b7a1f965f23391142e651cf7ba3` | same | 1–394; copies legacy records then DROP follow_up_people/follow_ups/people at 361/364/367 |
| v14 | `102e7d4fc00674524c50f577ce9f5b929d67349d` | `981ef6e9bce7f616b07acf0d08def939a1157382` | same | 1–447; task rebuild into tasks_canonical_v14; DROP/RENAME at 420–421 |
| v15 | `1313c3e59a726126db06d22d5e63e4ff952b1e15` | `9beacd7f152ca86197ca45934577c5d695b606bc` | same | 1–496; Task-person relation conversion; DROP task_people at 266; Task rebuild at 455–467 |
| v16 | `0b5df95fb2c8e7e810b1fb25b4cb0ffc94d434ce` | `f537638ad2218479e74a47012623db63acb5b919` | same | 1–632; adds task_occurrences, occurrence_checklist_items, task_recurrence_rules |
| v17 | `e12d86c77aecebde94f2f386a3b6c5732d539ccd` | `84123487cfa6fcbc0ab2d5f67798ba65ca4352b8` | same | 1–635; adds tasks.recurrence_json and legacy recurrence conversion |
| v18 | `bceadc8f9bba6a9d7f0ba6756b7477f0cdb264b2` | `5dfe5c12bab58cd83f973a8fd76f24d6db2160d9` | same | 1–757; task_reminders table rebuild at 400–439 |
| v19 | `3bede0d3615c74b37985905f8b21d70d9b44bcce` | `9f0243dff6d8ffa13649ca7fd2ee33ac4d3a2c21` | same | 1–951; installer, canonical entity transfers, reminder rebuild and Task rebuild |
| v20 | `812082964c649be7660c41213209ec34aea7167b` | `b03b90efac9f3c5cbef3b1b649385cdf6369ca62` | `lib/services/g1_drift_schema.dart` | PR #3463 target schema v20; M2M migration is separate file below |

## Separate v9-B hierarchy lineage
- Schema at canonical #3495 ref: `lib/services/g1_drift_schema.dart`, blob `3bd140f9a07b54c1e4a1dff26d64f965b437ec52`, version 9.
- Migration: `lib/services/g1_rev10_hierarchy_v9_migration.dart`, blob `f9569182a1d79a116e1e1f4c400e69f7c47863b4`, 329 lines.
- Declared source/target: 8→9 at lines 14–16; transaction starts at 53 and commits/rolls back at 274–278; CREATE junction/catalog/exception tables at 55–93; task FK columns at 105–119; index DDL at 122–137; relationship transfer at 140–255; FK checks at 257–264; marker write at 270–272.
- This is not v9-A. v9-A adds template structures; v9-B adds hierarchy structures and migration exception capture.

## v19 destructive/transfer evidence
File `lib/services/g1_drift_schema.dart` at v19 commit, blob `9f0243dff6d8ffa13649ca7fd2ee33ac4d3a2c21`:
- Schema tables are declared at lines 15–98.
- Installer disables FK enforcement during the transaction at 136–139; performs conditional additions and entity transfers at 142–267; checks FK violations and commits at 263–270.
- Reminder rebuild snapshots rows, renames the source table, recreates canonical table, copies selected columns, compares rows, then drops retired table: lines 351–449.
- Task rebuild uses canonical projection and defers when unknown columns, custom indexes, triggers or outgoing FKs are present: lines 474–617; table replacement/copy/drop/rename at 561–606.
- Legacy Task scheduling values are copied into JSON payload before retiring SQL columns: lines 726–850.
- Legacy Follow-up, People and task-person transfer logic: lines 635–710 and 850–945.

## v20 M2M migration evidence
File `lib/services/g1_many_to_many_hierarchy_migration.dart` at PR #3463 head, blob `a2c768da3c90d2610ea2285ddd248e8fbbc27489`, 369 lines:
- Only accepts source version 19 and targets 20: lines 26–28 and 30–33.
- Creates `center_projects` and `project_categories`; adds optional Task FKs and indexes: lines 61–108.
- Copies valid existing Project→Center evidence; creates stable Category IDs from legacy names; classifies unresolved Task relationships: lines 110–245.
- Validates new FK relations, writes marker and commits: lines 255–278.
- Installs Task hierarchy compatibility triggers: lines 281–315.
- It does not delete the v19 source membership tables in this migration.

## Commit ancestry evidence
GitHub compare results:
- Main SHA `45e4202b03a434459e4c021a04efa7e8396359db` → v8 commit: 334 commits ahead, merge base Main.
- Main → v9-A commit: 812 commits ahead, merge base Main.
- v9-A → v19 commit: 1,405 commits ahead, merge base v9-A.
- Main → v19 commit: 2,217 commits ahead, merge base Main.
- v19 → v20 commit: 340 commits ahead, merge base v19.
- v20 commit → current canonical #3495 HEAD `f5c64285687cd2665cc383e10277cb6e0266f4c2`: DIVERGED; merge base is Main; canonical HEAD is 212 commits ahead and v20 is 2,557 commits ahead.

The ancestry shows a historical Git lineage Main/v7→v8→v9-A→v10…v19→v20. It does not prove the actual Main v7 database can execute the complete upgrade safely. The current canonical PR #3495 is a separate diverged branch carrying v9-B, not the v20 code line.

## Missing evidence
- Full literal DDL transcription (including all column declarations, defaults, PK/FK actions, indexes and triggers) for every historical version.
- Every exact model and Store diff at all migration boundaries.
- All parent/merge boundary audit records for the complete historical series.
- Exact source fixture and independent end-to-end Main v7→v20 test.
- Full row-level preservation proof, retry, rollback and interruption evidence on the supported Main-based path.

**Disposition: BLOCKED — this is a forensic index, not a completed migration certification.**
