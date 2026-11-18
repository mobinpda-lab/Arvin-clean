# COMMAND 50-R — Acceptance

**Status: COMPLETE — ROOT CAUSE CONFIRMED; V19 MIGRATION REMAINS BLOCKED**

**Repository:** `mobinpda-lab/Arvin-clean`
**Branch:** `recovery-02/main-based-integration`
**Reference checkpoint:** `1efd9b1fc41b15ac94dd67d8b128dc702ab7997c`
**Historical V19 source:** `310c0e20e3447c488c1e1c102c38bea5040708ca`

## Confirmed root cause

The COMMAND 49 error occurs on the second installer invocation after the first migration succeeded and removed the old Occurrence keys from `legacy_payload_json`. The next invocation compares an empty legacy history with the still-existing normalized SQL Occurrences and raises a false parity mismatch. The physical database artifact proves the destination row survived and the source JSON keys had already been retired.

Two additional parity hazards were physically reproduced: explicit NULL optional keys are omitted by readback, and unknown per-occurrence state keys have no destination representation. Both failed closed, preserved the original JSON, left no partial SQL Occurrence rows, and passed integrity/FK checks.

## Acceptance matrix

| Requirement | Result |
|---|---|
| Historical Installer / Codec / Model / Store source SHA and paths | PASS — recorded |
| Old and destination Occurrence structures | PASS — recorded |
| Simple pending first migration | PASS — physical evidence from COMMAND 49 |
| Exact root cause for COMMAND 49 failure | PASS — confirmed |
| ID / Task ID / timestamp / status for simple pending row | PASS — artifact inspected |
| Completed / cancelled / missed / skipped matrix | PASS — physical run `44367002583` |
| Multiple Occurrences and multiple Tasks | PASS — physical run `44367002583` |
| Recurrence-linked and unlinked cases | PASS — physical run `44367002583`; Task-level relation confirmed |
| Explicit NULL physical negative case | FAIL_CONFIRMED — expected parity rejection; original JSON retained and transaction rolled back |
| Unknown Occurrence-state physical negative case | FAIL_CONFIRMED — expected parity rejection; original JSON retained and transaction rolled back |
| Timestamp boundary and offset physical case | PASS — boundaries preserved; Occurrence offset retained as text; Recurrence offset normalized to UTC |
| TaskStore readback | PASS — physical readback on migrated database |
| Full diagnostic workflow log and artifact | PASS — run `44367002583`, job `135024297667`, artifact `14456982207` |
| Initial-failure rollback / retry behavior | PASS as forensic observation — initial negative cases roll back; second install still fails with existing rows preserved |

## Protection

- Historical V19 Installer unchanged.
- Historical Occurrence and Recurrence codecs unchanged.
- Schema and user_version were not edited by COMMAND 50.
- Immutable V7 source fixture unchanged; all added scenario records are generated in isolated copies.
- Main remains anchored at `45e4202b03a434459e4c021a04efa7e8396359db`.
- PR #3495 remains OPEN / DRAFT / UNMERGED.
- No V20 migration, merge, release or deployment was performed.

## Decision

COMMAND 50-R forensic analysis is COMPLETE: the source-to-SQL matrix and the negative cases ran on isolated copies, the original retry mismatch has an exact root cause, and the two additional parity hazards are physically reproduced. This completion does **not** authorize V20. Historical V19 remains unsafe to accept until an independently approved repair handles retry, explicit NULL and unknown Occurrence fields. Any repair remains a separate proposal; historical V19 source stays immutable.

## Final execution evidence

- Run: `44367002583` — SUCCESS.
- Job: `135024297667` — SUCCESS.
- Artifact: `14456982207` — https://github.com/mobinpda-lab/Arvin-clean/actions/runs/44367002583/artifacts/14456982207
- Artifact SHA-256: `080d32fde09c0d2160ec121f1c3e5854606659ef8aa14e1ebd4f60c61f4f8260`.
- Test harness commit: `5d5e63d9dbe95077a1e501e69576d299897cab11`.
