# Arvin Continuation Command
## Permanent Rule
The user command `ادامه` is an execution trigger for Arvin. It means continue from the live project state, not from memory or guesswork.
## Required Start
On every `ادامه`:
1. Check GitHub Read/Write/Actions access.
2. Check `main`, active branch, latest commit and open PRs.
3. Check relevant CI/workflows for the exact ref.
4. Read `docs/ARVIN_PROJECT_OPERATING_PACKAGE.md`.
5. Read the relevant current-state/architecture documents.
6. Identify the nearest real unfinished gap.
7. Continue safe work and validate the exact resulting ref.
## Execution Rule
Independent work must be considered for parallel execution. Dependent work remains sequential only when technically necessary. No duplicate or conflicting work is allowed.
## Communication Rule
Every response must be compact, simple and understandable without programming knowledge. Use copyable text for reusable reports. Remove unnecessary blank lines. State verified facts separately from plans or blockers.
## Final Marker
At the end of every Arvin-related response, place a separate copyable block containing exactly:
`ادامه`
No label or extra text belongs inside that block.
## Safety
This command never authorizes destructive changes, bypassing validation, bypassing review or inventing repository state.
## Authority
`docs/ARVIN_PROJECT_OPERATING_PACKAGE.md` is the active canonical operating standard. GitHub reality overrides documentation when implementation state differs.