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
