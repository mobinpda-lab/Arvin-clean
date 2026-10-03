# Arvin UI Conflict Audit Matrix — 2026-09-14

## Purpose

This document tracks conflicts between historical UI assumptions, current canonical decisions, the installed real Arvin output, and the final implementation contract.

## Authority Rule

New implementation must follow:

1. Real installed Arvin reference approved by owner.
2. ARVIN_FINAL_UI_VISUAL_REFERENCE.
3. ARVIN_FINAL_PRODUCT_IMPLEMENTATION_CONTRACT.
4. Existing contracts only when they do not conflict.

## Conflict Tracking

| Area | Historical Risk | Final Decision | Action |
|---|---|---|---|
| Home statistics | Old dashboard cards may return | Follow final Home contract | Remove conflicting assumptions |
| Home grouping | Static examples may replace data logic | Groups must come from real data | Verify implementation |
| Quick Entry | Mock flow is insufficient | Continuous registration workflow required | Audit code |
| Task detail | Direct editing from cards is not accepted | Card opens details first | Verify navigation |
| FollowUp | Timeline must not be replaced | Preserve history append behavior | Verify persistence |
| Notebook | Separate storage risks duplication | Preserve canonical Notebook storage | Verify implementation |
| Calendar | Visual calendar alone is insufficient | Must connect to real task data | Audit integration |
| Settings | Placeholder options forbidden | Only functional settings visible | Audit screens |

## Implementation Gate

No feature is considered complete only because a widget, class, or document exists. Completion requires:

- real user flow
- persistence verification
- tests where applicable
- Android validation evidence

## Next Audit Targets

- Home implementation
- Quick Entry implementation
- Task Detail implementation
- Notebook implementation
- Calendar implementation
- Settings implementation
