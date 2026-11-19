# REV10 HOME FILTER ACCEPTANCE — COMMAND 60-R.1
**Observed:** 2026-11-19 / ۲۸ آبان ۱۴۰۵
**Canonical SHA inspected:** `6d806125e91056fedb74b0644d77a273ee4b675f`
**Status:** BLOCKED / NOT ACCEPTED

## Five due-date groups
The canonical Home projection in `lib/main.dart` currently builds five groups:
1. `overdue` — «تاریخ‌گذشته»
2. `today` — «امروز»
3. `tomorrow` — «فردا»
4. `future` — «آینده»
5. `no_date` — «فاقد زمان»

The five grouping buckets exist. Their Persian labels are semantically aligned with the requested «گذشته، امروز، فردا، آینده، بدون زمان» but are not text-identical.

## Filter dimensions
`lib/home/home_filter_ui.dart` currently declares only:
`time, project, category, tags`.
The Home cards and `_homeFilterActive` logic include these four dimensions; Center is absent. This is not a complete REV10 Home filter implementation.

## Required remaining work
- Add a real Center filter to the Home UI and selection state.
- Wire selection through Center model/store/repository to SQL-backed relationships.
- Apply Center selection to the actual Home task projection; do not merely display a chip/card.
- Preserve REV10 OR-within-dimension and AND-across-dimensions semantics.
- Persist and restore the selected filter state where the current product contract requires it.
- Add tests for selecting, combining, clearing, reopening and filtering by Center.
- Validate all five due-date groups together with Center, Project, Category and Tag filters.

## Decision
Five time groups: IMPLEMENTED IN SOURCE, not separately accepted end-to-end.
Center filter: NOT IMPLEMENTED in canonical Home.
Overall REV10 Home filter acceptance: NOT ACCEPTED.
