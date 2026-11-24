# Mission 202-R — Metadata and JSONL Contract

## Metadata identity
The metadata document contains exactly the required identity fields:
- `mission_id`: `202-R`
- `repository`: `mobinpda-lab/Arvin-clean`
- `branch`: exact authorized execution branch
- `commit_sha`: 40-character lowercase Git commit SHA
- `workflow_run_id`: numeric GitHub Actions run identifier encoded as a string
- `run_attempt`: positive integer, not a boolean
- `trace_file`: basename of the actual JSONL trace
- `trace_sha256`: SHA-256 of the actual trace bytes

The writer calculates the digest from the file. Validation recalculates it independently.

## Trace record schema
Each non-empty JSONL line must be a JSON object containing:
`timestamp`, `event`, `operation_id`, `parent_operation_id`,
`correlation_id`, `operation_name`, `elapsed_ms`, `status`, and `error_type`.

Events are `START`, `END`, or `ERROR`. When `event_type` is present, it must equal `event`. START uses RUNNING; END uses SUCCESS; ERROR uses ERROR. `elapsed_ms` is a non-negative integer. Parent IDs may be null only for root operations.

## Lifecycle and nesting
- Every operation ID has exactly one START.
- Every START has exactly one terminal END or ERROR.
- A terminal event must refer to an open operation and preserve its name, parent, and correlation identity.
- A child START must reference an already-open parent.
- A child and parent must share a correlation ID.
- Duplicate operation IDs, duplicate STARTs, orphan terminal events, missing terminal events, invalid parents, and correlation mismatches are rejected.

## Acceptance coverage
P01: valid START → END lifecycle.
P02: valid nested parent/child lifecycle.
N01–N16: missing file; malformed metadata JSON; absent required field; wrong Mission; wrong Repository; wrong Branch; wrong Commit SHA; wrong Workflow Run ID; wrong Run Attempt; wrong Trace filename; actual digest mismatch; invalid JSONL record; invalid event type/fields; duplicate operation/START; invalid lifecycle; invalid Parent/Correlation.

## Historical compatibility
This validator emits and validates the 202-R metadata document. Existing historical 189-R metadata and artifacts are evidence records and must not be rewritten or relabeled as 202-R. The separate workflow-generated historical `metadata.txt` remains outside this JSON metadata contract.

## Status
Implementation and test definitions are present. Exact-SHA execution is required before VERIFIED; owner sign-off is required before ACCEPTED.
