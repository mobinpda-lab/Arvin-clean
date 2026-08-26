# Arvin Continuation Command
## Permanent Rule
The user command `ادامه` is an execution trigger for Arvin. It means continue from the live project state, not from memory or guesswork.

The same rule applies to the hourly Arvin continuation Automation: it must perform real safe production work when possible and must not degrade into status-only reporting.

## Required Start
On every `ادامه` or hourly continuation:
1. Check GitHub Read/Write/Actions access.
2. Check current `main`, active branches, latest commit and open PRs.
3. Check relevant Issues and exact-head CI/workflows/builds.
4. Read `docs/ARVIN_PROJECT_OPERATING_PACKAGE.md`.
5. Read the relevant current-state/architecture documents and `docs/ARVIN_EXECUTION_EXPERIENCE_LOG.md` when its lessons apply.
6. Read `docs/progress_scorecard.json` for official progress; never substitute an estimated percentage.
7. Identify the nearest real unfinished gap.
8. Continue safe real work and validate the exact resulting ref.

## Execution Rule
Independent work must be considered for parallel execution. Dependent work remains sequential only when technically necessary. No duplicate or conflicting work is allowed.

If a lane is waiting for CI/APK, do not stop production: advance another genuinely independent low-conflict lane. Do not make low-value commits that restart healthy validation.

The preferred delivery loop is:
`Issue/Need → Live Audit → Branch → Implementation → Test → Documentation → CI/Automation → PR → Exact-head Gate → Merge → main Build → Score/Handoff Update → Next Work`

## Documentation Experience Rule
Project experience must be documented in parallel with production when it prevents rework or preserves continuation knowledge. Use `docs/ARVIN_EXECUTION_EXPERIENCE_LOG.md` as the living evidence-based lesson log; it is subordinate to the canonical operating package and must never become a documentation bottleneck.

Do not create competing governance documents. Update the existing owner document when one already exists. Stale current-state documents must be refreshed when their old SHA, PR, CI or progress claim could mislead future execution.

## Progress Rule
Progress is reported only from the official Scorecard and its GitHub validation. Report overall Roadmap and active Wave percentages when present. For a section without an official denominator/stage mapping, report its verified stage/status instead of inventing a percentage.

## Communication Rule
Every response must be compact, simple and understandable without programming knowledge. Separate verified facts from plans/blockers. Standard report:
- `انجام شد`
- `وضعیت فعلی`
- `درصد پیشرفت`
- `قدم بعد`
- `نکته`

## Final Marker
At the end of every Arvin-related response, place a separate copyable block containing exactly:
`ادامه`
No label or extra text belongs inside that block.

## Safety
This command never authorizes destructive changes, bypassing validation/review, fabricated repository state, duplicate foundations, or conflicting parallel edits.

## Authority
`docs/ARVIN_PROJECT_OPERATING_PACKAGE.md` is the active canonical operating standard. GitHub reality overrides documentation when implementation state differs. `docs/ARVIN_EXECUTION_EXPERIENCE_LOG.md` records practical lessons, not competing governance.
