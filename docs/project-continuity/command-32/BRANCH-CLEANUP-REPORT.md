# COMMAND 32 — Branch Cleanup Report
Code checkpoint: `687341469152035053f6325b671c4bad9dab8c96`
Main: `45e4202b03a434459e4c021a04efa7e8396359db`

Status: PARTIAL — THREE PRs CLOSED; NO BRANCH DELETIONS.

## Repository scale
- Search API: 113 open PRs.
- Closed PRs: 1,150 total; 629 merged and 521 closed-unmerged.
- Prior repository checkpoint: 1,439 branch refs. A fresh complete page-by-page branch SHA audit is still outstanding.
- Current canonical PR #3495 remains OPEN / DRAFT / UNMERGED.

## PR cleanup completed
- #3365 closed after confirming its Device Smoke file and navigation file are byte-identical to canonical; its Calendar integration test is superseded by the canonical variant with additional historical Follow-up and reminder assertions.
- #3348 closed after confirming byte-identical Device Smoke, navigation and reminder test files; canonical ProjectStore and Calendar tests are stronger/superseding.
- #3341 closed after confirming its file-backed reminder lifecycle and ProjectStore cases are represented by canonical tests with broader reopen, CRUD, metadata and integrity assertions.
- #3348 branch was a base of #3365; #3365 was closed first. No remaining open PR was found using either branch as base. No open PR was found using #3341 branch as base.

## Branches
- The three PRs' branches were not deleted. The connected GitHub actions available in this session do not expose a delete-ref operation.
- No other branch deleted.
- No force push or history rewrite.
- Diagnostic branches #3376/#3380/#3382 and migration branches #3384/#3463 remain protected.
- #3052 and its dependent recovery chain remain protected.

## Required before further branch deletion
Resolve exact SHA for every ref; map all open/closed PRs; enumerate commits not reachable from canonical; compare changed files and workflows; verify no dependent PR, workflow, tag, release, issue, or evidence link; preserve archive refs where unique history is not in #3495.

No branch deletion was attempted without this proof and an available delete-ref action.
