# COMMAND 32 — PR Transfer Matrix
Live checkpoint: 2026-11-18
Code SHA audited: `687341469152035053f6325b671c4bad9dab8c96`
Canonical PR #3495 — OPEN / DRAFT / UNMERGED
Main: `45e4202b03a434459e4c021a04efa7e8396359db`

Status: PARTIAL. GitHub search reports 113 open PRs, 521 closed-unmerged PRs, and 629 merged PRs (1,150 closed total). The repository's previous canonical checkpoint records 1,439 branch refs. The complete 1,263-PR unique-commit audit and fresh 16-page branch SHA audit are not complete. No claim of full historical reconciliation is made.

## Verified focused transfer decisions
| PR | Scope | Decision / evidence |
|---|---|---|
| #3495 | REV10 canonical route | KEEP — sole destination. Current head `687341469152035053f6325b671c4bad9dab8c96`, 149 commits ahead / 0 behind Main, 134 changed files. |
| #3470 | Vazirmatn weight contract; 24 commits / 21 files | REVIEW — no bulk transfer. Requires visual/RTL review of all affected UI files. |
| #3463 | M2M v19/v20; 139 commits / 42 files | DEFER — no direct merge. Depends on #3384 and a v19 schema/store dependency closure; canonical v7→v8 changes must be proven before sequential v7→v20 acceptance. |
| #3384 | Legacy field presence / unknown metadata / SQL / Person refactor; 218 commits / 120 files | SELECTIVELY ADAPTED. Follow-up opaque metadata contract implemented in canonical via extensionData + extension_json; broad schema-v19 refactor not cherry-picked. |
| #3382 | Raw SQL diagnostics; 3 commits / 2 files | KEEP AS EVIDENCE until SQL root-cause closure. |
| #3380 | Diagnostic executor lifecycle; 8 commits / 2 files | KEEP AS EVIDENCE. |
| #3376 | Persist-task envelope capture; 7 commits / 2 files | KEEP AS EVIDENCE. |
| #3366 | Task editor metadata preservation; 8 commits / 6 files | REVIEW — some patch fields are absent from canonical Task; no incompatible bulk port. |
| #3365 | Device Smoke / Calendar navigation; 4 commits / 3 files | CLOSED as represented. Device Smoke file was byte-identical; navigation file byte-identical; Calendar test in canonical is a stronger/superseding variant. Branch retained. |
| #3364 | SQL Follow-up envelope; 10 commits / 6 files | PARTIAL — A02 addresses opaque Follow-up metadata; task-level null/false semantics and migration-writer conflict detection still need audit. |
| #3356 | SQL envelope diagnostic; 1 commit / 1 file | KEEP AS EVIDENCE pending exact migration-writer test. |
| #3348 | File-backed Project / multi-reminder tests; 8 commits / 5 files | CLOSED as represented. Workflow, navigation and reminder test were byte-identical; canonical ProjectStore and Calendar tests are stronger/superseding. Branch retained because #3365 used it as base. |
| #3346 | Task editor canonical-field preservation; 3 commits / 3 files | NOT PORTED — patch references fields absent from canonical model. |
| #3341 | File-backed SQLite tests; 3 commits / 2 files | CLOSED as represented. Canonical file-backed reminder lifecycle test covers legacy migration, reopen, CRUD and tombstone; canonical ProjectStore test is stronger. Branch retained. |
| #3052 | Main-based Calendar/device-smoke recovery stack; 2,192 commits / 395 files | DO NOT DIRECT-MERGE; unique history needs granular review. |
| #3340 | REV9 governance | Superseded by REV10; preserve history. |
| #3388 | Wave 0 continuity docs | Archive/reference; REV10 remains authority. |
| #3448 | REV10 master charter proposal | Authority represented in canonical governance; archive source after doc-link audit. |

## COMMAND 32 commits
- `8dee3947939b941a48be4a5882b10fcf3ec20ab4`: A01 All-Day + W01 expression/KVM/merge-base corrections.
- `ed93d6ad30bfe4e75199f297efda0a2b8099ce49`: A02 Follow-up extension metadata + A03 historical Person ID restore.
- `ebaf71bd2330914b4e3ece6cbadaa94b7a71fc2e`: seven initial COMMAND 32 reports.
- `76cbf11146ccf0f7eb3d7e4ae394f6c7e3deef1a`: Calendar card visibility test stabilization.
- `687341469152035053f6325b671c4bad9dab8c96`: H01 SharedPreferences disk-flush evidence before force-stop.

## Outstanding transfer
- Audit all remaining 113 open PRs and 521 closed-unmerged PRs by unique commit and file/blob equivalence.
- Audit 629 merged PRs only for documentation/authority conflicts; their merged code is already on Main.
- Review typography, Task editor, SQL envelope, M2M, and older reminder/Calendar chains.
- No additional PR should close until its complete changed-file set is represented.
