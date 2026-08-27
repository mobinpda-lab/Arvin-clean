# Arvin Continuation Command
## Permanent Rule
The user command `ادامه` is an execution trigger for Arvin. It means continue from the live project state, not from memory or guesswork.
## Required Start
On every `ادامه`:
1. Check GitHub Read/Write/Actions access.
2. Check `main`, active branch, latest commit and open PRs.
3. Check relevant CI/workflows for the exact ref.
4. Read `docs/ARVIN_PROJECT_OPERATING_PACKAGE.md`.
5. Read `docs/AI_CONTINUATION_STATE.md` and the relevant current-state/architecture documents.
6. Identify the nearest real unfinished gaps and their dependency/overlap boundaries.
7. Continue safe independent work in parallel and validate every exact resulting ref.
## Maximum Parallel / No-Stop Production Rule
Independent product, test, documentation, audit and validation lanes must be considered for parallel execution whenever they do not overlap the same canonical foundation.

Documentation, reporting, architecture reconciliation, backlog audit or CI observation MUST NOT stop non-conflicting product production.

If one lane is blocked or waiting for a parent merge, CI, physical-device evidence, permission/provider boundary or stale-main reconciliation, unrelated lanes continue automatically.

Dependent work remains sequential only where the dependency is real and technically necessary. No duplicate or conflicting work is allowed.
## Isolation Rule
- one narrow Issue/Branch/PR per independent acceptance slice;
- branch from current `main` unless an intentionally stacked PR records its parent explicitly;
- no direct product work on `main` from documentation/audit lanes;
- no force-push or destructive history rewrite in normal continuation;
- after a parent merge, stacked lanes must reconcile/rebuild from fresh `main` and revalidate before promotion;
- CI evidence belongs only to the exact SHA that produced it.
## Communication Rule
Every response must be compact, simple and understandable without programming knowledge. Use copyable text for reusable reports. Remove unnecessary blank lines. State verified facts separately from plans or blockers.
## Final Marker
At the end of every Arvin-related response, place a separate copyable block containing exactly:
`ادامه`
No label or extra text belongs inside that block.
## Safety
This command never authorizes destructive changes, bypassing validation, bypassing review, inventing repository state, silently replacing canonical foundations, or treating planned/queued work as completed.
## Authority
`docs/ARVIN_PROJECT_OPERATING_PACKAGE.md` is the active canonical operating standard. `docs/AI_CONTINUATION_STATE.md` and dated Maximum Parallel continuation documents provide the current operational map. GitHub reality overrides documentation whenever implementation state differs.