# V7 → V19 Precondition Matrix

**Main v7 DDL blob:** `cd065ff25c680ed064e89068b3d063e737091025`  
**v19 Installer blob:** `9f0243dff6d8ffa13649ca7fd2ee33ac4d3a2c21`  
**Fixture SHA-256:** `68752dcafcbe84abe399d71ac3411ec9832084fb888e84158d8a3b4a819913f0`

| Topic | Main v7 actual source | v19 target / behavior | Result |
|---|---|---|---|
| Schema version | Schema 7; fixture `user_version=7` | Historical Installer 19; Drift ensureOpen updates user_version | PASS — observed 7→19 |
| Tasks | Legacy scheduling columns plus core Task fields and JSON envelope | Adds canonical fields, copies legacy scheduling values, guarded Task rebuild | PASS on fixture; core SQL values and IDs compared |
| Projects | `projects(id,name,color_value,is_archived,legacy_payload_json)` | Adds storage ordinal and Center/template fields | PASS; original fields and ID preserved |
| Follow-ups | `follow_ups` with date_time/title/note/result/reminder_date/next_follow_up/completed/waiting/ordinal | Copies to `follow_up_records`, stores next-follow-up metadata in Task envelope, converts reminder | PASS; ID and relation preserved |
| People | `people` directory | Copies to `persons`, seeds `person_directory` | PASS; Person ID preserved |
| Task-person | `task_people` with JSON payload | Strictly validates JSON and creates `task_persons` | PASS; relation and original raw JSON preserved |
| Follow-up-person | `follow_up_people` | Copies to `follow_up_record_people` | PASS; relation preserved |
| Reminders | No normalized reminder table in v7 | Creates `task_reminders` from legacy Task/Follow-up data | PASS; expected reminder row materialized |
| Recurrence | `tasks.recurrence_json` | Strict codec creates `task_recurrence_rules` | PASS; rule materialized and unknown raw key retained |
| Occurrence | JSON envelope fields if present | Codec creates occurrence/checklist occurrence rows with parity checks | Installer path executed; fixture had no occurrence rows to transfer |
| Checklist | `checklist_items` | Existing table retained | PASS; both rows unchanged |
| Tags | `tags`, `task_tags` | Existing tables retained | PASS; IDs and relations unchanged |
| Project membership | `projects`, `project_items` | Existing relation retained | PASS; both rows unchanged |
| Unknown Task/Project/Person/Recurrence data | Legacy JSON/raw source payloads | Compatibility envelope and source table preservation | PASS for fixture's seeded unknown values; see ledger |

## Runtime evidence

The corrected runner asserts Task core-column equality, all source-table row equality for retained legacy relations, canonical Person/Task-person/Follow-up-person mapping, reminder and recurrence creation, and selected unknown-field retention. Both pre/post SQLite integrity checks pass; post-install foreign-key violations are zero.

The fixture is deliberately small (2 Tasks, 1 Project, 1 Follow-up, 1 Person, 1 Tag, 2 Checklist rows). Results establish compatibility for this exact historical fixture, not every possible production database variation or custom SQLite object.
