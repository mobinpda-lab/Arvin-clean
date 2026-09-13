# Contract Code Test Matrix

| Contract | Code Area | Test Area | Status |
|---|---|---|---|
| Home UI | main.dart / Home flow | Home tests | Migration pending |
| Task Model | models/task.dart | Model tests | Canonical |
| Legacy Storage | TaskRepository / arvin.tasks | Migration tests | Compatibility boundary |
| Backup Restore | Backup services | Integration tests | Verify during migration |

## Rule
Every product capability must map from contract to code to validation test.
