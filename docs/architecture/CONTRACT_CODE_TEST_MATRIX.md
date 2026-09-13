# Contract Code Test Matrix

| Contract | Code Area | Test | Status |
|---|---|---|---|
| Home | lib/main.dart / Home flow | Home migration tests | Migration pending |
| Task Model | models/task.dart | Model tests | Canonical |
| Legacy Storage | TaskRepository | Migration regression tests | Protected boundary |
| Backup Restore | Backup services | Backup tests | Verify during migration |

## Rule
Every product capability must map:

Contract -> Code -> Test -> Validation

No feature is complete without this chain.
