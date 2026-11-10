# Test Validation Report — WAVE 4

**Current implementation checkpoint:** `dbfcdb02879ed3939cb6a69d3a150e2237283a51`  
**Status:** NOT VERIFIED — exact-SHA workflows pending.

## Tests added/updated in source

- Task migration rejects same ID with different content.
- Project migration rejects same ID with different content.
- Project ordering and unknown-field preservation across ProjectStore save.
- Occurrence history and per-occurrence checklist migration, SQL round-trip and TaskStore save/load.
- Recurrence relational SQL round-trip.
- G1 schema assertions for Recurrence and Occurrence tables.
- Legacy source retention assertions replace prior assumptions that unproven sources are dropped.

## Exact-SHA CI

The latest exact-SHA workflow lookup for `dbfcdb02879ed3939cb6a69d3a150e2237283a51` returned:
- Arvin Build run `42864431438`: PENDING.
- Device Smoke run `42864430851`: PENDING.
- Calendar Provider Acceptance run `42864431259`: QUEUED.
- Follow-up File Persistence run `42864430953`: QUEUED.
- Draft Review APK run `42864431042`: QUEUED.
- Other orchestration/parallel jobs: pending or queued at the time of lookup.

The previous P0-B SHA `28abfa4390adbb7523eb003417f2007ea44e5293` had an Arvin Build FAILURE, with test shards failing. That result is historical and does not establish the outcome on the current SHA.

## Not run / not verified

No local Flutter command was run in this session. Integration tests and Android Device Smoke have not yet completed on the current SHA. No test has been deleted, skipped, bypassed or weakened.
