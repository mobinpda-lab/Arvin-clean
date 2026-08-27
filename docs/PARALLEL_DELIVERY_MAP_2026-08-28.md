# Parallel UI delivery map — 2026-08-28

The owner requested Maximum Parallel delivery with short non-technical reporting.

Independent lanes:
- #357 / `feat/357-follow-up-task-detail`: follow-up-enabled task UX.
- #360 / `feat/360-home-visual-final`: final Home visual direction.
- #361 / `feat/361-reminder-widget-visual`: Reminder/Widget visual contract.
- #362 / `feat/362-notebook-category-ux`: Simple Note/To-do/category UX.
- #358/#359: documentation/product-contract reconciliation.

Rules:
1. no lane waits for another unless there is an actual shared-file conflict or canonical-data contract dependency;
2. code, focused tests and brief lane documentation travel together;
3. exact-head CI is evaluated per lane;
4. merge small validated slices rather than batching unrelated UI work;
5. score/status updates follow evidence, not optimistic claims;
6. shared navigation/help reconciliation happens at integration points and must not stop independent feature coding.
