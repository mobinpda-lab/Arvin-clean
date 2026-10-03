# Arvin Authority Index Addendum — 2026-09-14

## Purpose

This addendum extends the existing Document Authority Index after the introduction of the final visual and implementation contracts.

## New active references

### Visual authority

`docs/ARVIN_FINAL_UI_VISUAL_REFERENCE.md`

Defines:
- final visual language
- layout direction
- colors
- navigation appearance
- screen composition
- real installed Arvin experience reference

### Product implementation authority

`docs/ARVIN_FINAL_PRODUCT_IMPLEMENTATION_CONTRACT_2026-09-14.md`

Defines:
- behavior contracts
- data preservation rules
- acceptance criteria
- production completion requirements
- testing expectations

## Conflict rule update

When older UI documents conflict with these final contracts:

1. preserve historical documents for traceability;
2. do not use them as implementation authority;
3. follow the newest approved visual or implementation contract for the affected area;
4. require evidence before marking a feature complete.

## Production completion rule

A feature is not complete because a widget, model, service or document exists.

Completion requires:

- real implementation
- connected data flow
- tested behavior
- Android verification where applicable
- evidence of acceptance

## Next execution phase

After authority reconciliation:

1. audit existing Flutter implementation;
2. map every screen against final contracts;
3. fix gaps without creating parallel architecture;
4. verify with real builds and tests.
