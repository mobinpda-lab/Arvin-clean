# REV10 CHANGE CONTROL
## Authority and route
- Product authority: owner-approved REV10 and explicit owner decisions.
- Sole active development route: PR #3495, branch `recovery-02/main-based-integration`.
- Main is READ ONLY.
- No merge, release, deployment or production-user migration without explicit owner approval.
## Protected decisions
- Primary Blue = `#4169A1`.
- Center remains a first-class product entity.
- Home retains five independent filter dimensions and five independent due-date groups.
- Center↔Project and Project↔Category remain M2M.
- Reminder retains four actions and existing scheduler/storage foundations.
## Required change protocol
1. Identify the exact REV10 clause and current owner decision.
2. Inspect current code, tests, migrations and dependent flows before editing.
3. Record conflicts as blockers; do not resolve product ambiguity by inference.
4. Create a focused commit only on the canonical branch.
5. Run targeted tests, then relevant CI on the exact resulting SHA.
6. Record Run ID, Job ID, artifact IDs and exact result. No inherited PASS from older SHA.
7. Update the feature matrix and master tracker.
8. Keep incomplete evidence as INCOMPLETE EVIDENCE / NOT TESTED / BLOCKED.
9. Request owner approval for decisions reserved to the owner.
## GitHub ruleset checkpoint
Active repository ruleset 20952260 (`main-protection`) applies only to `refs/heads/main`. It includes deletion and non-fast-forward protections and requires a pull request, but:
- required approving review count = 0
- CODEOWNERS review = false
- required review-thread resolution = false
- required CI checks = none
- canonical integration branch is not protected
The connector cannot read the branch-protection endpoint (403) and this mission did not modify repository settings. Do not claim owner approval enforcement is active. Admin-authorized settings change remains required.
## Conflict response
Stop the affected change, preserve source evidence, record the exact files/lines/SHAs, consult REV10 and current owner decision register, and obtain owner clarification where the source is genuinely ambiguous. Do not delete or weaken a feature/test to make CI green.


## Historical recovery matrix
The canonical source-to-acceptance recovery ledger is maintained in [REV10-HISTORICAL-RECOVERY-MATRIX.md](REV10-HISTORICAL-RECOVERY-MATRIX.md). This matrix is evidence-oriented and does not supersede REV10 or owner decisions.


## MASTER EXECUTION 131-R live recovery checkpoint — 2026-11-21
- Audited Candidate: `e380ffd86c4157796cecd6a0d9c4a21716344d55`; Main: `45e4202b03a434459e4c021a04efa7e8396359db`; PR #3495 OPEN / DRAFT / UNMERGED; 434 ahead / 0 behind.
- COMMAND 20-E run `44880424929`: PASS on the exact Candidate SHA. Attempt 2 Device Smoke run `44880424928` reports People SUCCESS; stale artifact `14698614096` is superseded by latest artifact `14699814794`.
- Zero Dollar run `44876935899` is an older-SHA environment failure: KVM was unavailable but software fallback was selected; AVD was not found and product smoke was not reached. Issue #3654 tracks the workflow correction.
- Historical source-to-acceptance ledger: [REV10-HISTORICAL-RECOVERY-MATRIX.md](REV10-HISTORICAL-RECOVERY-MATRIX.md).
- Current exact-SHA CI: Build `44880424925` PASS; Governance `44880424937` PASS; Device Smoke Attempt 2 `44880424928` PASS; COMMAND 20-E `44880424929` PASS; Follow-up Persistence `44880424931` PASS.
- No Main write, merge, release, deployment or production-data operation occurred.
