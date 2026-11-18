# COMMAND 50-R — Acceptance

**Status: BLOCKED — ROOT CAUSE IDENTIFIED; FULL FORENSIC MATRIX NOT YET ACCEPTED**

**Repository:** `mobinpda-lab/Arvin-clean`
**Branch:** `recovery-02/main-based-integration`
**Reference checkpoint:** `1efd9b1fc41b15ac94dd67d8b128dc702ab7997c`
**Historical V19 source:** `310c0e20e3447c488c1e1c102c38bea5040708ca`

## Confirmed root cause

The COMMAND 49 error occurs on the second installer invocation after the first migration succeeded and removed the old Occurrence keys from `legacy_payload_json`. The next invocation compares an empty legacy history with the still-existing normalized SQL Occurrences and raises a false parity mismatch. The physical database artifact proves the destination row survived and the source JSON keys had already been retired.

Two additional parity hazards are identified directly in the historical codec: explicit NULL optional keys are omitted by readback, and unknown per-occurrence state keys have no destination representation. Their physical negative-fixture runs remain pending.

## Acceptance matrix

| Requirement | Result |
|---|---|
| Historical Installer / Codec / Model / Store source SHA and paths | PASS — recorded |
| Old and destination Occurrence structures | PASS — recorded |
| Simple pending first migration | PASS — physical evidence from COMMAND 49 |
| Exact root cause for COMMAND 49 failure | PASS — confirmed |
| ID / Task ID / timestamp / status for simple pending row | PASS — artifact inspected |
| Completed / cancelled / missed / skipped matrix | PENDING — diagnostic harness authored |
| Multiple Occurrences and multiple Tasks | PENDING — diagnostic harness authored |
| Recurrence-linked and unlinked cases | PENDING — diagnostic harness authored |
| Explicit NULL physical negative case | PENDING |
| Unknown Occurrence-state physical negative case | PENDING |
| Timestamp boundary physical case | PENDING |
| TaskStore readback | PENDING — harness authored |
| Full diagnostic workflow log and artifact | PENDING — no COMMAND 50 run result verified |
| Initial-failure rollback / retry behavior | NOT ACCEPTED |

## Protection

- Historical V19 Installer unchanged.
- Historical Occurrence and Recurrence codecs unchanged.
- Schema and user_version were not edited by COMMAND 50.
- Immutable V7 source fixture unchanged; all added scenario records are generated in isolated copies.
- Main remains anchored at `45e4202b03a434459e4c021a04efa7e8396359db`.
- PR #3495 remains OPEN / DRAFT / UNMERGED.
- No V20 migration, merge, release or deployment was performed.

## Decision

COMMAND 50-R is not COMPLETE. The root cause for the original retry failure is known, but the acceptance criteria require the expanded physical matrix and its actual logs/artifacts. Do not begin V20. Any proposed production correction must be a separate change and must not be applied to historical V19 source under this command.
