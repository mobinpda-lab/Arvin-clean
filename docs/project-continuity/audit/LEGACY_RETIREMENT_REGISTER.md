# Legacy Retirement Register — WAVE 4

**Policy:** NO PHYSICAL RETIREMENT UNTIL ALL OWNER-DEFINED GATES PASS  
**Checkpoint SHA:** `dbfcdb02879ed3939cb6a69d3a150e2237283a51`

| Legacy source | Current disposition | Retirement gate |
|---|---|---|
| `follow_ups`, `follow_up_people`, `people`, `task_people` | Retained; active migration no longer drops them | Full row/field/relation parity, backup/restore, round-trip, owner acceptance |
| Legacy Task schedule columns | Retained; Task table rebuild path disabled | Full Task field parity and historical schema fixture matrix |
| Legacy Reminder flag / table layout | Retained; Reminder table rebuild path disabled | Reminder row/sequence/content parity and owner acceptance |
| `tasks.legacy_payload_json` | Retained; new Recurrence/Occurrence maps removed from new envelopes | All Task fields relationally mapped; unknown fields safely preserved; backup/restore |
| `projects.legacy_payload_json` | Retained to preserve unknown fields across updates | All Project fields/unknown fields mapped and round-trip proven |
| `tasks.recurrence_json` | Retained as legacy evidence; canonical reads/writes use `task_recurrence_rules` | Relational parity, backup/restore and owner acceptance |
| Template JSON columns | Still active; NOT RETIRED | Normalize tags/checklists/people/reminders/recurrence into child tables |
| SharedPreferences settings/Calendar/other state | Still active; NOT RETIRED | Map each key to a relational owner and migrate transactionally |
| Prayer Completion / Notification State / Sync metadata | Coverage not yet established | Source inventory, contract, SQL owner and backup/restore proof |

No physical legacy table or column was deleted in this execution. No source was retired based on ID equality alone. Release remains NO-GO.
