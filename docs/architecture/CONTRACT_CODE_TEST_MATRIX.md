# Contract Code Test Matrix

| Contract | Code Area | Test Area | Status |
|---|---|---|---|
| Home UI Contract | lib/main.dart / Home widgets | Home tests | Migration required |
| Task Contract | models/task.dart | Task tests | Canonical |
| Storage Contract | TaskStore / persistence layer | Migration tests | Verify |
| Backup Contract | Backup services | Backup tests | Verify |

## Rule
Every product capability must have a traceable path:

Contract -> Code -> Test -> Validation

No undocumented UI behavior is accepted as canonical.
