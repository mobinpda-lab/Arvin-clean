# TaskStore Readback Report — COMMAND 49-R

**Verdict: BLOCKED — TaskStore readback was not reached.**

The runner contains assertions for:
- Completed Task state and completion timestamp from the historical SQL columns.
- Priority preservation.
- Non-empty recurrence and occurrence history through the actual TaskStore.
- Full serialized TaskStore readback evidence.

The initial V7→V19 install fails earlier at:
`Occurrence migration parity mismatch for Task command49-occurrence-task`.

Consequently no post-migration TaskStore readback was performed and no claim is made that the SQL/JSON compatibility envelope is safe for this run.

Historical observation retained from COMMAND 48-R: one completed Task's generated compatibility JSON envelope showed default completion/priority values while the SQL columns held the authoritative completed state, timestamp, and medium priority. The historical TaskStore decoder was previously observed to overlay SQL columns during read; COMMAND 49-R still requires a fresh physical TaskStore readback after the current migration path succeeds.

Evidence: run `44313646995`, job `134833931852`, artifact `14430913354`.
