# Arvin official progress metric

## Purpose
This document is the official denominator and scoring rule for percentage reports about the 19-feature Product Extension Roadmap.

A percentage is never derived from commit count, PR count, lines of code, number of branches, or elapsed time. It is derived only from the stage recorded for each of the 19 roadmap capabilities in `docs/progress_scorecard.json`.

## Stage ladder
Each roadmap capability has exactly one stage score. A feature may advance only when the evidence for that stage exists in GitHub.

| Score | Required state |
|---:|---|
| 0 | No dedicated implementation evidence. Being named in the roadmap alone is not progress credit. |
| 10 | Dedicated audit, issue, or acceptance scope exists beyond the omnibus roadmap. |
| 25 | Architecture/domain contract for the target capability is accepted and documented. |
| 40 | Core implementation exists with focused automated tests. A parser/service/projection with no real UI stops here. |
| 55 | The canonical persistence/data path is wired end-to-end, or the feature explicitly requires no persistence and that boundary is verified. |
| 70 | A real user-facing UI/UX is wired to the canonical implementation path. |
| 85 | Regression/E2E coverage, exact-head CI, APK validation, and post-merge `main` validation are complete. |
| 100 | The roadmap Definition of Done is complete, including status/handoff documentation, and the feature's delivery issue is closed as complete. |

Stages are cumulative: a feature cannot claim 70 while missing a prerequisite stage. `N/A` does not create free points; it must be explicitly justified by the feature contract and verified by tests/CI where relevant.

## Official formulas

### Overall extension progress
`sum(feature.stage) / (19 × 100) × 100`

All 19 roadmap capabilities have equal denominator weight. Priority changes execution order, not percentage weight.

### Wave X1 progress
Wave X1 uses feature IDs `1, 2, 3, 6, 7, 10, 11, 17`.

`sum(X1 feature stages) / (8 × 100) × 100`

## Baseline on 2026-08-26
The scorecard baseline is intentionally conservative:

- Next Action: 40 — core ranking + tests, no real UI.
- Timeline: 40 — projection + tests, no full Timeline UI/history coverage.
- Semantic Search: 25 — canonical SearchService path improved, but semantic behavior is not implemented.
- Waiting for Response: 40 — canonical contract/core + tests, no Home filter/UI.
- Quick Capture: 40 — parser/core + tests, no real capture UI entry point.
- All remaining target capabilities: 0 unless dedicated evidence exists for that specific target capability.

This yields:
- overall roadmap progress: **9.7%**
- Wave X1 progress: **23.1%**
- fully Done roadmap capabilities: **0 / 19**

## Anti-inflation rules
1. A foundation used by a future capability is not automatically credited as that capability.
2. A core service or parser is not a completed product feature without user-facing wiring when the roadmap calls for a user-facing capability.
3. CI success proves the submitted slice works; it does not by itself promote a feature to 100.
4. Existing Backup, Calendar, FollowUp, Search, or Task foundations are credited only when the target roadmap capability has dedicated evidence.
5. A score increase requires evidence references in `docs/progress_scorecard.json`.
6. A score decrease is allowed if later audit shows a claimed stage was premature.

## Automation
`tool/progress_score.py --check` validates:
- exactly 19 unique roadmap IDs;
- only allowed stage values;
- the official formulas;
- reported overall/Wave X1 percentages;
- count metrics.

`.github/workflows/progress-score.yml` runs this validator whenever the metric, scorecard, validator, or workflow changes.

## Reporting rule
When a user asks for a project percentage, report the score from the current `main` scorecard and state that it refers to the **19-feature Product Extension Roadmap**. Do not present it as a percentage of unknowable future work outside that denominator.
