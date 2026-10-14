# Design System — Universal Arvin Time Picker

**Rule:** One product, one time-selection experience.  
**Canonical specification:** [UX Specification](../UX/UNIVERSAL_ARVIN_TIME_PICKER.md)  
**Decision:** [ADR](../ADR/ADR-2026-10-11-AUTPDS-universal-time-picker.md)  
**Tracker:** [#2589](https://github.com/mobinpda-lab/Arvin-clean/issues/2589)

## Required tokens
- Primary #4A4CAB
- Light primary #E9EAFF
- Background #F8F8FB
- Card #FDFDFE
- Text #232433
- Secondary #80829C

These tokens define the required direction for this component. The first implementation wave is in [PR #2591](https://github.com/mobinpda-lab/Arvin-clean/pull/2591); verify against the existing theme tokens during visual review and reference canonical theme values in code rather than introducing a parallel palette. Screenshot and real-device visual review remain pending.

## Component states
1. Hour selection.
2. Minute selection.
3. Manual input.
4. Manual input validation/error.
5. Saving/disabled action state where required.
6. Cancelled/dismissed.
7. Confirmed/saved.

The selected-time display is always visible and mirrors the draft selection. Selected dial targets use the primary token; unselected targets retain readable contrast. Do not use color alone to communicate selection.

## Interaction invariants
- First open defaults to dial mode.
- Time is 24-hour, with no AM/PM.
- Hour mode distinguishes the 1–12 and 13–24 rings.
- Minute dial uses 5-minute steps; manual entry accepts exact minutes.
- Cancel discards draft state.
- Save confirms the draft and returns the time to the caller.
- Date selection is out of scope for this component.
- Persian RTL and Persian digits are the default user-facing presentation.
- All caller surfaces use the same component; a caller may supply a contextual title and initial value but may not substitute a different picker.

## Integration rule
Existing Roll Box or other form controls may act as the trigger to open UATP. They must not implement a separate clock menu or replace the circular time dialog. Existing theme, localization, date/time data, and scheduling infrastructure remain authoritative.

## Design QA
- [ ] Contrast and selected state are readable.
- [ ] Hour and minute stages are visually distinct.
- [ ] 24-hour inner/outer ring is unambiguous.
- [ ] Keyboard entry is discoverable and validation is understandable.
- [ ] RTL alignment and number ordering are correct.
- [ ] Touch targets and focus semantics are accessible.
- [ ] Layout survives narrow viewport and larger text.
- [ ] No per-feature variant drifts from this standard.
