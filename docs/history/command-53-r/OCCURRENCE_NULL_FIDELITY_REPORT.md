# Occurrence Explicit NULL Fidelity Report — COMMAND 53-R

**Status: BLOCKED / NOT IMPLEMENTED**

Historical forensic evidence confirms SQL NULL values are written, but readback omits keys whose SQL values are NULL. Thus source `completionDate: null` and `result: null` are not reconstructed as explicit JSON keys and parity fails.

Required contract:
- Preserve three distinct states: absent key, present key with NULL, present key with non-NULL value.
- Persist key-presence metadata independently from nullable SQL values (or a lossless source envelope).
- Reconstruct explicit NULL keys on readback.
- Verify exact JSON key presence after closing and reopening the database.
- Do not normalize absent and explicit NULL to equivalence without a separately approved compatibility decision.

No schema/codec change or round-trip test was executed for COMMAND 53-R.