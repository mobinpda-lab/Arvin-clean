# DATABASE UPGRADE MATRIX — COMMAND 40-R
**Status:** BLOCKED / NO SUPPORTED PATH ACCEPTED  
**Canonical PR:** #3495 — OPEN / DRAFT / UNMERGED

| Source state | Target state | Source evidence | Edge proof | Disposition |
|---|---|---|---|---|
| Main v7 | v8 | Main schema v7; historical v8 SHA recorded in prior ledger | not run | BLOCKED |
| v8 | legacy Template v9 | historical v9-A schema source | not established | BLOCKED; lineage A |
| v8 | REV10 hierarchy v9 | `G1Rev10HierarchyV9Migration` source blob `f9569182a1d79a116e1e1f4c400e69f7c47863b4` | no independent file-backed fixture in this execution | BLOCKED; lineage B |
| legacy Template v9 | v10–v18 | historical version SHAs listed in prior ledger | adjacency and data mapping not established | BLOCKED |
| REV10 v9 | v19 | PR #3384 v19 schema is from a separate stacked PR lineage | no Main-based sequential edge proven | BLOCKED |
| v19 | v20 | PR #3463 v20 schema/migration source | no exact current-SHA acceptance evidence re-run here | BLOCKED |
| Main v7 | v20 | combination of the above | no end-to-end Main v7 fixture or supported path proven | BLOCKED |

For every edge, still required: exact source/destination commit and blob; schema fingerprint; DDL; row-transfer mapping; ID preservation; FK/unique/index changes; retired fields; rollback boundary; retry behavior; supported/unsupported cases; fixture path and exact test result.

## Version 9 conflict
Version 9-A (legacy Task Template lineage) and version 9-B (REV10 hierarchy migration) remain separate until schema fingerprints and preconditions prove a valid connection. A numeric `user_version = 9` alone is insufficient.

**No upgrade edge is marked PASS.**
