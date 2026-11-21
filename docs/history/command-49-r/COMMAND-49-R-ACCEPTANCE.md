# COMMAND 49-R — Acceptance

<badge>BLOCKED — V7 TO V19 SAFETY NOT COMPLETE</badge>

**Repository:** `mobinpda-lab/Arvin-clean`  
**Branch:** `recovery-02/main-based-integration`  
**Current evidence commit:** `b28d1321eac6d173294a08d482b9817e9e1c6d7f`  
**Historical V19 source:** `310c0e20e3447c488c1e1c102c38bea5040708ca`  
**Installer blob:** `9f0243dff6d8ffa13649ca7fd2ee33ac4d3a2c21`

## Acceptance matrix

| Requirement | Status |
|---|---|
| Exact V19 source verification | PASS |
| Immutable V7 fixture SHA verification | PASS |
| V7 pre-migration integrity assertions | PASS before installer |
| Safe second install / idempotency | NOT PROVEN |
| Controlled failures at all requested stages | NOT RUN |
| Physical rollback verification | NOT PROVEN |
| Backup restoration and exact snapshot comparison | NOT RUN |
| Non-empty Occurrence transfer | FAIL — parity mismatch |
| Non-empty Recurrence transfer | NOT REACHED |
| TaskStore readback | NOT REACHED |
| All IDs and relations after migration | NOT PROVEN |
| Post-migration SQLite integrity / FK check | NOT REACHED |
| Complete GitHub evidence | PARTIAL — failed run artifacts and logs retained |

## Blocking execution evidence

The latest physical test fails during the first installation:
`Bad state: Occurrence migration parity mismatch for Task command49-occurrence-task`.

- Workflow run: `44313646995`
- Job: `134833931852`
- Artifact: `14430913354`
- Artifact URL: https://github.com/mobinpda-lab/Arvin-clean/actions/runs/44313646995/artifacts/14430913354

Earlier attempts and their artifacts:
- Run `44312630186`, artifact `14431736141`
- Run `44313242199`, artifact `14431437351`

## Protection state

At final audit:
- `main` remains at `45e4202b03a434459e4c021a04efa7e8396359db`.
- PR #3495 remains OPEN / DRAFT / UNMERGED.
- No merge, release, or deployment was performed.
- Historical V19 installer source was not modified.
- No V20 migration was started by this command.

## Decision

Do not accept COMMAND 49-R. Do not start V20. First investigate the historical Occurrence parity mismatch without modifying the historical installer, then rerun the complete retry, failure-injection, backup/restore, recurrence, and TaskStore evidence suite.
