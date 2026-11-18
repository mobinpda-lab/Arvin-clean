# User Database Compatibility Matrix

**Status:** design-level; no real-user database inspected.

| Database state | Upgrade possible? | Required preservation / preconditions | Safe behavior |
|---|---|---|---|
| Main V7 | Potentially, after exact fingerprint and backup | Preserve SharedPreferences `arvin.tasks`, SQL IDs, Projects, Follow-ups, reminders, checklists, Tags, People and links; run approved sequential path | Do not jump to V20/V21 based on user_version |
| Intermediate schema | Unknown until each predecessor is inventoried | Exact DDL fingerprint, source migration history, valid predecessor chain, backup/restore proof | Unknown version / shape → stop |
| V19 clean, no Occurrence history | Potentially, only with proof source keys were present and empty or trusted receipt | Confirm both outer Legacy keys' presence states and SQL zero-row state | Missing keys alone are not proof of empty history |
| V19 with non-empty Occurrences | Current V19 retry/round-trip acceptance is blocked | Compare source and destination per record; preserve IDs, Task IDs, timestamps, status, NULL presence, unknown payload | Any mismatch → rollback / stop |
| V19 after Occurrence source keys were removed | Only with trusted receipt or original backup/snapshot | Receipt must prove source fingerprint, counts and destination fingerprint; otherwise source is unavailable | No receipt/snapshot → ambiguous; do not auto-repair |
| Legacy and SQL both contain data | Potentially after full parity | Compare exact identity, field presence, payload, order, FK relations and recurrence | Conflict → stop; no silent skip/overwrite |
| Incomplete / malformed / unknown schema | Not automatically | Forensic copy and manual recovery plan | Read-only quarantine; no write |

## Non-negotiable source states
For each Task, independently inspect `occurrenceHistory` and `checklistOccurrences` with `containsKey`:
- ABSENT;
- EXPLICIT_NULL;
- PRESENT_EMPTY;
- PRESENT_DATA;
- INVALID_TYPE.

ABSENT is not PRESENT_EMPTY. SQL rows without a receipt do not prove source completeness. A V19 database whose keys were removed without an occurrence-specific receipt is not safely classifiable from destination rows alone.

## Identity and relation preservation
Every future upgrade must compare Task IDs, Occurrence IDs, `task_id` FKs, recurrence ownership, checklist order, Project membership, People relations, Follow-up relations and Tag links before and after. Preserve unknown JSON fields and explicit NULL. Do not delete, reassign, normalize or synthesize a relationship to make a constraint pass.

## Recovery
- Before writes: verified backup + restore into a separate file + snapshot.
- During migration: single transaction for owned data and receipt; injected failures must leave either pre-state or verified post-state.
- Ambiguous state: no write; provide exportable diagnostics and require trusted backup/source.
