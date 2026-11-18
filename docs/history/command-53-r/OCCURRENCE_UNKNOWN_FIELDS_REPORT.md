# Occurrence Unknown Field Preservation Report — COMMAND 53-R

**Status: BLOCKED / NOT IMPLEMENTED**

Historical forensic evidence confirms the V19 destination has no opaque payload for unknown occurrence-state keys. The historical codec cannot reconstruct keys such as `futureField` after normalization.

Required contract:
- Preserve unknown state keys in an independent opaque JSON payload or a retained compatibility envelope.
- Preserve nested objects, arrays, explicit NULL values and original JSON types.
- Known-field updates must merge without replacing or deleting unknown fields.
- TaskStore readback and backup/restore must reproduce the unknown data.
- Unknown-field preservation must not create a parallel occurrence store or alter deterministic occurrence identity.

No persistence implementation or round-trip test was executed for COMMAND 53-R.