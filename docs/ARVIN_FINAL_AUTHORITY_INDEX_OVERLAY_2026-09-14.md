# Arvin Final Authority Overlay 2026-09-14

## Purpose

This overlay extends the existing Document Authority Index with the new final product references created from the approved real installed Arvin experience.

## New active references

### Visual authority
`docs/ARVIN_FINAL_UI_VISUAL_REFERENCE.md`

Controls:
- approved visual language
- layout hierarchy
- colors
- spacing
- navigation appearance
- screen composition

### Implementation authority
`docs/ARVIN_FINAL_PRODUCT_IMPLEMENTATION_CONTRACT_2026-09-14.md`

Controls:
- product behavior
- workflows
- data rules
- acceptance criteria
- production completion requirements

## Conflict rule

If older UI or implementation documents conflict with these references, they must not redirect implementation.

Historical documents remain available for traceability only.

## Production rule

A feature is not complete because a class, screen, branch or old PR exists. Completion requires:

- working implementation
- preserved data behavior
- tested user flow
- evidence from real execution

## Required next reconciliation

The project must reconcile:

1. current contracts
2. existing Flutter implementation
3. real installed application behavior
4. final acceptance tests
