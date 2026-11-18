# COMMAND 47-R — V7 → V19 Execution Report (Updated by COMMAND 48-R)

**Overall status: PARTIAL — DIRECT V19 EXECUTION CONFIRMED; FULL COMMAND 47 ACCEPTANCE STILL BLOCKED.**

## Actual Installer execution

The exact historical v19 Installer was executed on a physically independent copy of the approved Main v7 fixture:
- Workflow run: `44308608481` — SUCCESS.
- Job: `134816565546` — SUCCESS.
- Source ref: `310c0e20e3447c488c1e1c102c38bea5040708ca`.
- Installer blob: `9f0243dff6d8ffa13649ca7fd2ee33ac4d3a2c21`.
- Runtime: Flutter 3.47.0 / Dart 3.13.0.
- Fixture SHA-256 before migration: `68752dcafcbe84abe399d71ac3411ec9832084fb888e84158d8a3b4a819913f0`.
- Pre/post `PRAGMA user_version`: 7 → 19.
- Post `integrity_check=ok`; foreign-key violations: 0.
- Task IDs, Task core SQL fields, retained source rows and canonical relation parity: PASS for this fixture.

## Evidence

- Artifact ID: `14429935379`.
- Artifact ZIP SHA-256: `09e2bd12e09955e4ea69ad3c2c02193dd5a534912fe4ed4942c7ae83df8b2af9`.
- Pre-snapshot SHA-256: `26a5d1d819b93c3c2095ed7b042771a9a6c2064520ada11f2e834935d7460479`.
- Post-snapshot SHA-256: `cc1ca0a6d19893c1ebaca15c59de1b631a8e32e25dfe3777785e002ccc9dde33`.

## Remaining gates

Retry and failure-recovery tests have not been run. The approved fixture contains no occurrence-history rows, so non-empty occurrence transfer remains unexercised. See the updated data, relation and exception reports.

Main remains unchanged. PR #3495 remains OPEN / DRAFT / UNMERGED. No v20 execution, release or deployment occurred.
