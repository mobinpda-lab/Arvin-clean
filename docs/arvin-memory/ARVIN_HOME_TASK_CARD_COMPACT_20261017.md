# Home Task Card Compactness — 2026-10-17

## Scope
- Reduce vertical whitespace in home-screen task cards without changing task actions, task data, or RTL structure.
- Keep title and due-date text sizes unchanged.
- Keep selection mode and checkbox behavior intact.

## Change
- `lib/main.dart`: task-card vertical padding changes from 4 px top/bottom to 2 px top/bottom (4 px less per card).
- Task completion control uses compact density, zero internal padding, and 34 px minimum constraints instead of the default IconButton tap-target sizing.
- Selection checkbox uses compact density and shrink-wrapped tap-target sizing.
- `test/widgets/home_page_test.dart`: verifies the completion control stays at or below 36 px, title remains 14 px, due-date label remains 11 px, and the widget tree reports no exception.

## Size comparison
| Measurement | Before | After | Change |
|---|---:|---:|---:|
| Vertical card padding (top + bottom) | 8 px | 4 px | -4 px/card |
| Completion control minimum height | default 48 px | 34 px | -14 px |
| Estimated minimum single-line card height (control + vertical padding) | 56 px | 38 px | -18 px (about 32%) |

The estimated total applies to a simple single-line card. Actual rendered height varies with optional follow-up, checklist, taxonomy, priority, due-date and restore rows. No claim of screenshot-measured before/after height is made.

## Verification gates
- Targeted home widget test and existing home-page tests must pass on the exact PR head.
- Analyze/build/device-smoke results must be reviewed before promotion.
- Visual screenshot comparison is still required where CI produces screenshots; test success alone is not proof of physical-device acceptance.

## Release
`RELEASE: NO-GO` until required CI, visual and physical-device acceptance evidence is complete.
