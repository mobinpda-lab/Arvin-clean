# Arvin official progress metrics

## Purpose
Arvin has one automated percentage system in GitHub with two deliberately separate numbers:

1. **Arvin TOTAL project completion** — the official percentage for the whole current Arvin delivery plan.
2. **19-feature Product Extension progress** — the existing percentage for the extension roadmap only.

These values must never be mixed. The whole-project number answers «کل آروین چند درصد پیش رفته؟». The extension number answers «از ۱۹ قابلیت Extension چند درصد جلو رفته‌ایم؟».

No percentage is derived from commit count, PR count, lines of code, elapsed time, intuition, or chat estimates.

---

## 1. Official TOTAL Arvin percentage

### Fixed denominator
The whole-project denominator is the eight canonical delivery gates defined in `docs/PROJECT_ROADMAP_2026-08-14.md`:

- Gate A — Unified Item + adapter/migration + regression
- Gate B — Notebook UI + persistence
- Gate C — Home + Search on canonical Item path
- Gate D — Calendar + Prayer Times + Iranian Holidays
- Gate E — Widget + Lock Screen validation
- Gate F — PDF + Print + IranSans
- Gate G — Reminder/Google Calendar + Backup/Dropbox
- Gate H — E2E + device release + APK evidence

The denominator is therefore **8 gates × 100 points = 800 points**.

Each gate has equal fixed weight. There are no hidden effort weights and no manual weighting adjustments. Changing the denominator or gate list requires an explicit governance PR; it may not happen silently as part of ordinary feature work.

### Stage ladder for every gate
Each gate has exactly one cumulative stage:

| Score | Required state |
|---:|---|
| 0 | No dedicated implementation evidence. |
| 10 | Dedicated audit and acceptance scope exist. |
| 25 | Architecture or delivery contract is accepted. |
| 40 | Core implementation exists with focused automated evidence. |
| 55 | The gate's canonical internal path is integrated end-to-end. |
| 70 | The gate's real user-facing or operational path is wired. |
| 85 | Regression/E2E, exact-head CI and applicable APK/device evidence are complete. |
| 100 | The gate Definition of Done is complete, status/handoff is current, and no acceptance gap remains. |

Stages are cumulative. A gate cannot claim a higher stage while a prerequisite stage is missing.

### Formula
`sum(gate.stage) / (8 × 100) × 100`

The committed source of truth is `docs/project_completion_scorecard.json`.

### Baseline — 2026-08-26
Evidence-backed conservative baseline on main SHA `af817256e5b019f3b096199c29db88e5b87044e5`:

- Gate A: 55
- Gate B: 25
- Gate C: 70
- Gate D: 40
- Gate E: 10
- Gate F: 0
- Gate G: 40
- Gate H: 40

Total: `280 / 800 = 35.0%`.

This is a completion index against the committed eight-gate delivery plan. It is **not** a prediction of remaining calendar time or engineering effort.

---

## 2. Official 19-feature extension percentage

The existing extension metric remains unchanged in meaning and is intentionally separate from the total project metric.

Its denominator is the 19 capabilities in `docs/PRODUCT_EXTENSION_ROADMAP_2026-08-15.md`. Each capability uses the same allowed stage values `{0,10,25,40,55,70,85,100}` with feature-specific delivery evidence.

### Extension formula
`sum(feature.stage) / (19 × 100) × 100`

Wave X1 uses feature IDs `1, 2, 3, 6, 7, 10, 11, 17`:

`sum(X1 feature stages) / (8 × 100) × 100`

The committed source of truth is `docs/progress_scorecard.json`.

The extension metric must not be added to or averaged with the eight-gate total metric because many extension features reuse or sit inside the core gates; combining them would double-count the same engineering delivery.

---

## Evidence rules
A score increase requires committed GitHub evidence appropriate to the stage. Evidence may include code paths, tests, feature/architecture documents, PRs, exact-head CI, APK artifacts, post-merge main validation, device/E2E evidence, or closed delivery issues.

Rules:
1. Progress credit requires evidence listed in the relevant scorecard entry.
2. GitHub reality outranks narrative status documents if they disagree.
3. CI evidence is valid only for the exact SHA/ref it tested.
4. A service/parser/core implementation does not receive user-facing credit without real UI/operational wiring when the gate or feature requires it.
5. Existing foundations are not automatically credited to a new feature merely because that feature may reuse them.
6. A score may decrease if a later audit proves an earlier claim premature.
7. A scorecard change must go through normal PR review and automation; do not edit a displayed percentage independently of its stage evidence.

## Anti-dispute rule
There is no separate conversational percentage. When asked for «درصد کل آروین», report `reported_metrics.total_percent` from `docs/project_completion_scorecard.json` on current `main` after validating it. When asked for the 19-feature roadmap, report `reported_metrics.overall_percent` from `docs/progress_scorecard.json`.

If the scorecards and current repository evidence disagree, the scorecard is corrected through an evidence-backed PR before a new official percentage is claimed.

## Automation
`tool/progress_score.py --check` validates both official scorecards:

### Whole-project checks
- exactly eight unique gate IDs A..H;
- only allowed stage values;
- progress credit must include evidence;
- every gate must explain its current stage;
- baseline SHA format;
- fixed canonical roadmap path;
- recomputed total percentage and gate counts must exactly match committed reported metrics.

### Extension checks
- exactly 19 unique roadmap IDs;
- only allowed stage values;
- progress credit must include evidence;
- Wave X1 membership is fixed;
- recomputed overall/Wave X1 percentages and count metrics must exactly match committed reported metrics.

`.github/workflows/progress-score.yml` (`Arvin Progress Score`) runs the validator automatically whenever either scorecard, this metric contract, the validator, or its workflow changes.

## Reporting format
For normal management reporting, use:

`کل آروین: X% | Extension 19-feature: Y% | مدرک: scorecards + Arvin Progress Score`

Do not present an unvalidated branch value as the official main percentage.
