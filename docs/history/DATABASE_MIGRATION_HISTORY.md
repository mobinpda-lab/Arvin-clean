# DATABASE MIGRATION HISTORY — COMMAND 40-R
**Status:** PRELIMINARY SOURCE MAP — NOT A PROVEN UPGRADE PATH  
**Repository:** mobinpda-lab/Arvin-clean  
**Canonical PR:** #3495  
**Canonical branch HEAD at start:** `6005fb58f6c40db404353cf695445726e933d5cd`  
**Main:** `45e4202b03a434459e4c021a04efa7e8396359db`

## Verified source map
| Schema/source | Exact source | Observed status |
|---|---|---|
| Main v7 | Main `lib/services/g1_drift_schema.dart`, blob `cd065ff25c680ed064e89068b3d063e737091025` | Confirmed `version = 7`; installer uses `arvin_storage_meta`, not `PRAGMA user_version` |
| Legacy v9 Task Template lineage | commit `708c112a82c753f1dcdb77f1cf9712a6336a725d`, schema blob `617c05e4416bede903e78b65bd32a839d2d7c65a` | A distinct v9 source |
| Canonical REV10 v9 | branch schema blob `3bd140f9a07b54c1e4a1dff26d64f965b437ec52`; migration blob `f9569182a1d79a116e1e1f4c400e69f7c47863b4` | v9 with separate additive v8→v9 hierarchy migration |
| PR #3384 v19 | head `310c0e20e3447c488c1e1c102c38bea5040708ca`; schema blob `9f0243dff6d8ffa13649ca7fd2ee33ac4d3a2c21` | v19 source; not a Main-based sequential migration ledger |
| PR #3463 v20 | head `812082964c649be7660c41213209ec34aea7167b`; schema blob `b03b90efac9f3c5cbef3b1b649385cdf6369ca62` | v20 candidate; M2M migration separate from v19 installer |

## Preliminary version inventory
The previously recorded SHA index for versions 7–20 is retained as preliminary evidence. It is not independently verified as a sequence of executable adjacent migrations. Versions 10–18 have not yet been fully reconstructed here from every source commit, file diff and merge boundary.

| Version | Existing historical note | COMMAND 40-R disposition |
|---:|---|---|
| 7 | Main baseline | source confirmed; complete baseline fixture not run |
| 8 | follow_ups.extension_json | source SHA noted; DDL/edge proof pending |
| 9-A | Task Template lineage | distinct v9 lineage; source schema fetched |
| 9-B | REV10 hierarchy v8→v9 | distinct migration file fetched; edge and fixture proof pending |
| 10–11 | template context/checklist settings | preliminary only |
| 12 | relational Follow-up/Reminder/Person structures | preliminary only |
| 13 | Follow-up/People retirement after transfer | destructive proof pending |
| 14–15 | Tasks table rebuilds | exact before/after proof pending |
| 16 | reminder source consolidation | exact transfer proof pending |
| 17 | recurrence_json | preliminary only |
| 18 | task_reminders rebuild | destructive proof pending |
| 19 | Task rebuild / legacy column retirement | source available in PR #3384; complete edge proof pending |
| 20 | Center/Project/Category hierarchy M2M | source available in PR #3463; integration and file-backed proof pending |

## Required next evidence
1. Fetch every exact schema and migration source at each historical commit.
2. Record parent commits, merge boundaries and blob SHAs; distinguish authored code from later copied state.
3. Extract every CREATE, ALTER, index, trigger, table rebuild, INSERT…SELECT, UPDATE, DELETE and DROP statement.
4. Establish each adjacent upgrade edge and supported source fingerprint.
5. Never infer a migration edge from version integers alone.

**Result: BLOCKED.** This file is a source map, not a completed historical ledger.
