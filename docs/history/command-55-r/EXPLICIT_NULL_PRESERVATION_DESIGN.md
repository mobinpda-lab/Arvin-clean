# Explicit NULL Preservation Design

## Problem
V19 Occurrence SQL projection stores `completed_at` and `result` as nullable columns, but `readTask` emits those JSON keys only when the SQL value is non-NULL. Thus an absent key and an explicitly present JSON null collapse to the same SQL/readback representation.

## Required three-state model
For every nullable JSON field:
- ABSENT: key not present.
- EXPLICIT_NULL: key present with null.
- VALUE: key present with a valid value.

No state may be inferred from a Dart nullable value alone.

## Proposed SQL representation
For each nullable field `f`, store:
- `f_value` with the native nullable SQL value;
- `f_present INTEGER NOT NULL CHECK (f_present IN (0,1))`.

Interpretation:
| present | value | Meaning |
|---:|---|---|
| 0 | NULL | key absent |
| 1 | NULL | explicit JSON null |
| 1 | non-NULL | key with value |
| 0 | non-NULL | invalid; fail integrity check |

For V19 `completionDate`: `completion_date_present`, `completed_at`.  
For V19 `result`: `result_present`, `result`.

Any additional nullable fields discovered in the pinned Task/Occurrence source must use the same pattern. The initial pinned Occurrence codec identifies these two nullable state fields; unknown fields are handled by the opaque payload contract.

## Decode and encode rules
- Decode uses `map.containsKey(field)` before reading the value.
- If absent, set present=0/value=NULL.
- If present with null, set present=1/value=NULL.
- If present with the expected type, set present=1/value=value.
- Wrong type is a validation error, never coerced to null.
- Readback emits no key for absent; emits key:null for explicit null; emits key:value for value.
- Do not call `?? default` for these fields.

## Legacy data without presence metadata
A V19 SQL row has no reliable presence bit. If the original legacy envelope still exists, derive presence from its raw parsed map using `containsKey`. If the source has already been retired and there is no receipt or source snapshot, the distinction is unrecoverable: mark as LEGACY_PRESENCE_UNKNOWN and block automatic acceptance. Do not guess absent or explicit null.

## Migration and runtime
The forward migration adds presence columns and backfills only from verified legacy source or an independently proven V19 source snapshot. Existing rows with no source proof are not assigned inferred semantics. Normal runtime write/read must retain the bits. Tests must cover all three states through SQL close/reopen and JSON export/import.
