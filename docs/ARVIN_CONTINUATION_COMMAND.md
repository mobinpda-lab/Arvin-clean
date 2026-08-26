# Arvin Continuation Command

## Permanent Rule
The user command `ادامه` is an execution trigger for Arvin. It means continue from the live project state, not from memory or guesswork.

The same rule applies to the hourly Arvin continuation Automation: it must perform real safe production work when possible and must not degrade into status-only reporting.

## Required Start
On every `ادامه` or hourly continuation:
1. Check GitHub Read/Write/Actions access.
2. Check current `main`, active branches, latest commit and open PRs.
3. Check relevant Issues and exact-head CI/workflows/builds.
4. Read `docs/ARVIN_PROJECT_OPERATING_PACKAGE.md` v49.0.
5. Read relevant current-state/architecture documents and `docs/ARVIN_EXECUTION_EXPERIENCE_LOG.md` when its lessons apply.
6. Read both official scorecards when progress is relevant: `docs/project_completion_scorecard.json` and `docs/progress_scorecard.json`. Never substitute an estimated/manual percentage.
7. Identify the nearest real unfinished gap.
8. Continue safe real work and validate the exact resulting ref.

## Execution Rule
Independent work must be considered for parallel execution. Dependent work remains sequential only when technically necessary. No duplicate or conflicting work is allowed.

If a lane is waiting for CI/APK, do not stop production: advance another genuinely independent low-conflict lane. Do not make low-value commits that restart healthy validation.

Preferred delivery loop:
`Issue/Need → Live Audit → Branch → Implementation → Test → Documentation → CI/Automation → PR → Exact-head Gate → Merge → main Build → Score/Handoff Update → Next Work`

## Documentation Experience Rule
Project experience must be documented in parallel with production when it prevents rework or preserves continuation knowledge. `docs/ARVIN_EXECUTION_EXPERIENCE_LOG.md` is a subordinate evidence-based lesson log, not a competing governance authority.

Do not create competing current-state/governance documents. Update the existing owner document when one already exists. Historical records remain historical; stale current-state documents must be refreshed when old SHA/PR/CI/progress claims could mislead future execution.

## Progress Rule
There is no conversational progress percentage.
- Whole-project progress comes only from `docs/project_completion_scorecard.json` on current `main`.
- Extension-roadmap progress comes only from `docs/progress_scorecard.json` on current `main`.
- Candidate branch values are not official until their validator/CI passes and the scorecard PR merges.
- For areas without an official denominator/stage mapping, report verified stage/status instead of inventing a percentage.

## Communication Rule
Every response must be compact, simple and understandable without programming knowledge. Separate verified facts from plans/blockers. Preferred report:
- `انجام شد`
- `وضعیت فعلی`
- `درصد پیشرفت` only when sourced from official scorecards
- `قدم بعد`
- `نکته`

## Final Marker
At the end of every Arvin-related response, place a separate copyable block containing exactly:
`ادامه`
No label or extra text belongs inside that block.

## Safety
This command never authorizes destructive changes, bypassing validation/review, fabricated repository state, duplicate foundations, conflicting parallel edits, or weakening tests/quality gates for speed.

## Authority
`docs/ARVIN_PROJECT_OPERATING_PACKAGE.md` v49.0 is the active canonical operating standard. GitHub reality overrides documentation when implementation state differs. `docs/ARVIN_EXECUTION_EXPERIENCE_LOG.md` records practical lessons only.
