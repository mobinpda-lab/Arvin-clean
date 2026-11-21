# MAIN V7 TO V20 MIGRATION REPORT — COMMAND 42-R
**Status:** BLOCKED — P0 NOT COMPLETE
**Main:** `45e4202b03a434459e4c021a04efa7e8396359db`
**Canonical branch at execution:** `6a5712b9b25a6868988a16287e9a38986cb1571d`
## Historical source facts
- Main v7 schema source blob: `cd065ff25c680ed064e89068b3d063e737091025`.
- v8 schema source: commit `874dd8b567fdceae7ed62f01a93804dcea1a5473`, blob `f4d488fa3f972c4ce123df6089b66569b9c8849c`.
- v9-A Task Template schema source: commit `708c112a82c753f1dcdb77f1cf9712a6336a725d`, blob `617c05e4416bede903e78b65bd32a839d2d7c65a`.
- v19 installer source: commit `3bede0d3615c74b37985905f8b21d70d9b44bcce`, blob `9f0243dff6d8ffa13649ca7fd2ee33ac4d3a2c21`.
- v20 M2M migration source: commit `812082964c649be7660c41213209ec34aea7167b`, blob `a2c768da3c90d2610ea2285ddd248e8fbbc27489`.
## Important path clarification
The historical v19 implementation is a large idempotent installer, not a complete set of independently callable version-by-version migration functions for every edge v7→v19. Its source creates canonical tables, conditionally adds columns, migrates Task-person and Follow-up/Person/Reminder/Recurrence data, and rebuilds/retire legacy structures. Static source inspection suggests it may be a candidate direct bootstrap from a Main v7-shaped database, but this has NOT been executed against the physical fixture and must not be treated as a supported path yet.
The v20 migration explicitly accepts only source schema version 19 and targets 20. It cannot be invoked directly on v7.
## Runtime execution blocker
This execution environment has Python SQLite 3.46.1 but no Flutter SDK, Dart SDK, or sqlite3 CLI. The historical migration is Dart/Drift code with exact model and codec dependencies. Reimplementing it in Python or replacing it with hand-written SQL would not test the historical migration and is prohibited by this command.
No historical Dart migration was run. No post-migration database exists. No upgrade PASS is claimed.
## Required next proof
Run the exact v19 installer and its exact historical Task/Recurrence/Occurrence model-codec dependency closure against a copy of the committed physical fixture in a Flutter/Dart environment. Capture SQL/log output, schema marker, counts, IDs, row values, unknown JSON keys, NULLs, and FK checks. Then execute the exact v20 migration against the v19 output file. Preserve the original fixture unchanged for every retry/failure scenario.
