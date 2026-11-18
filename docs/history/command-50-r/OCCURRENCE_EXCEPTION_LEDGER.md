# COMMAND 50-R — Occurrence Exception Ledger

| ID | Condition | First failing boundary | Observed / inferred effect | Evidence |
|---|---|---|---|---|
| C50-E01 | Re-run after successful source retirement | `readTask` result vs empty source history in parity comparison | Existing SQL rows are reported as mismatch although first transfer succeeded | Physically confirmed by run `44314123737`, job `134835632144`, artifact `14431997314` |
| C50-E02 | Explicit `completionDate: null` or `result: null` in source state | Source-map vs readback-map canonical JSON comparison | SQL NULL is represented correctly, but readback omits explicit-null keys and map parity fails | Direct comparison of historical codec; physical negative fixture pending |
| C50-E03 | Unknown per-occurrence state key | Source-map vs readback-map canonical JSON comparison | No destination SQL field exists; readback omits the key and parity fails closed | Direct comparison of historical codec; physical negative fixture pending |
| C50-E04 | Duplicate scheduled timestamp for one Task | `writeTask` duplicate timestamp guard | FormatException; no silent duplicate row acceptance | Historical source inspected |
| C50-E05 | Empty or key/date-mismatched timestamp | `_scheduledAt` validation | FormatException; malformed identity rejected | Historical source inspected |
| C50-E06 | Unsupported status value | Enum validation in `writeTask` | FormatException; unknown status rejected | Historical source inspected |
| C50-E07 | Invalid recurrence enum / interval / count / date | `RecurrenceSqlCodec._decodeStrict` | FormatException; invalid recurrence definition rejected | Historical source inspected |

## Rollback and recovery caution

The COMMAND 49 artifact proves the second-install failure state and retained destination row. It does not by itself establish physical rollback behavior for an initial-install failure. The expanded COMMAND 50 negative fixtures must capture post-error database state and integrity checks before any rollback claim is made.

## No data masking

No source Occurrence was deleted, normalized or rewritten to force parity. The test-only negative cases deliberately retain explicit NULL and unknown state values so the historical codec's actual comparison behavior remains visible.
