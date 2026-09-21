# Arvin Integration Delta Map — 2026-09-21

## Baseline
- Integration branch: `feature/arvin-final-integration-20260921`
- Baseline: `675e6ceeb300c48202b00ccfe68d64ecc5351831` (PR #1259 exact-head)
- Source delta: PR #1222 exact-head `8e99d4d1785738d78a900b4e2db37ff6cca00009`
- Merge base: `25c2ecf7e935ac7a75cfa0d386e1e5eb1d342d47`

## Result of controlled extraction
The nine files changed by both PRs were compared at the exact heads. The newer #1259 implementation already contains the relevant final-UI direction from #1222 and, in several places, adds newer persistence/safety behavior. Therefore a direct merge or copy of #1222 would risk regressing #1259.

### Classification
- KEEP #1259 as authoritative for:
  - `lib/main.dart`
  - `lib/quick_capture_dialog.dart`
  - `test/home_stat_filters_test.dart`
  - `test/quick_capture_dialog_test.dart`
  - `test/widget_test.dart`
  - `test/widgets/home_page_test.dart`
  - `test/widgets/home_quick_capture_test.dart`
  - `docs/ARVIN_FINAL_UI_AND_BEHAVIOR_CONTRACT.md`
  - `docs/ARVIN_UI_CANONICAL.md`
- TAKE from #1222: none identified at this checkpoint.
- REIMPLEMENT: none identified at this checkpoint.

## Evidence
#1259 already contains:
- four Home grouping modes and removal of legacy summary/dropdown UI;
- Bottom Sheet Quick Capture;
- Android Back/draft protection;
- latest FollowUp text on Task cards;
- swipe completion/trash/undo behavior;
- updated Home and Quick Capture tests.

#1222 contains earlier versions of the same surfaces. Copying those versions over #1259 would replace newer behavior rather than add missing capability.

## Gate decision
G0 extraction gate: **PASS — no code delta to transplant from #1222 at this checkpoint.**

Next exact action: create the first controlled Integration commit only for this evidence ledger, then begin G1 storage/model safety checks on the unchanged #1259 baseline. No functional rewrite is permitted before G1 evidence.
