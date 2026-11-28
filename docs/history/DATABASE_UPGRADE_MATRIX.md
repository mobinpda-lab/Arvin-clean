# DATABASE UPGRADE MATRIX — COMMAND 41-R
**Status:** NO SUPPORTED UPGRADE PATH ACCEPTED

| Path / edge | Git ancestry | Code evidence | File-backed historical execution | Status |
|---|---|---|---|---|
| Main v7→v8 | Main is merge base; v8 is 334 commits ahead | v8 schema/installer found | Not run from Main v7 fixture | BLOCKED |
| v8→v9-A Task Template | v9-A descends from Main; schema 9-A found | Template DDL exists | Not proven | BLOCKED |
| v8→v9-B REV10 hierarchy | separate canonical #3495 source; declared sourceSchemaVersion=8 | additive migration code exists | Current exact-head test fails before migration due QueryExecutor not opened | BLOCKED |
| v9-A→v10→v11 | Git commits found | template context and checklist DDL | Not run | BLOCKED |
| v11→v12 | Git commits found | Reminder/Follow-up/Person transfer DDL | Not run as independent fixture | BLOCKED |
| v12→v13 | Git commits found | legacy tables dropped after copy | Not run | BLOCKED |
| v13→v14→v15 | Git commits found | Task rebuilds and Task-person relation transfer | Not run | BLOCKED |
| v15→v16→v17 | Git commits found | Occurrence/Recurrence tables and JSON conversion | Not run | BLOCKED |
| v17→v18→v19 | Git commits found | Reminder and Task rebuilds, legacy entity transfer | Not run from Main v7 fixture | BLOCKED |
| v19→v20 | v20 commit descends from v19; 340 commits ahead | M2M migration supports only source version 19 | Historical PR tests pass on exact v20 PR SHA, not canonical #3495 | BLOCKED for Main compatibility |
| Main v7→v20 | Git ancestry exists through v9-A/v19/v20 historical branch | No accepted single sequential upgrade runner/fixture proof | No end-to-end Main v7 physical SQLite test | BLOCKED |
| v20 historical line→current #3495 | Diverged; merge base is Main | current canonical branch uses v9-B and does not include v20 source | Not applicable | NOT A VALID DIRECT EDGE |

## Current canonical PR branch versus historical v20 line
- Current #3495 HEAD: `f5c64285687cd2665cc383e10277cb6e0266f4c2`.
- Historical v20 head: `812082964c649be7660c41213209ec34aea7167b`.
- Git compare: diverged; Main is merge base; canonical branch is 212 commits ahead of Main while v20 line is 2,557 commits ahead of Main.
- Therefore v20 test results must not be attributed to the current canonical branch.

## Version 9 rule
v9-A and v9-B are separate schemas. Do not connect v9-B to v10/v19 merely because the version integer matches. A migration edge requires exact source fingerprint, preconditions, DDL and data fixture proof.

**No edge is marked PASS for Main v7 upgrade compatibility.**
