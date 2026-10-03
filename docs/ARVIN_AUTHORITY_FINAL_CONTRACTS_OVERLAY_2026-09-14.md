# Arvin Final Authority Overlay

## Purpose

This document supplements `DOCUMENT_AUTHORITY_INDEX.md` after the final UI and production implementation contracts were created.

## New active references

### Visual authority
`docs/ARVIN_FINAL_UI_VISUAL_REFERENCE.md`

Controls:
- visual identity
- layout
- colors
- typography
- screen composition
- navigation appearance

### Implementation authority
`docs/ARVIN_FINAL_PRODUCT_IMPLEMENTATION_CONTRACT_2026-09-14.md`

Controls:
- user behavior
- acceptance criteria
- data preservation
- workflow rules
- production delivery requirements

## Conflict rule

When older UI documents conflict with these final contracts, the final contracts win.
Historical documents remain available only for traceability.

## Production rule

A feature is not complete because a class, service, screen or old PR exists. Completion requires:

- implemented behavior
- preserved data
- tests/evidence
- real Android validation when applicable

## Next execution order

1. Reconcile authority documents.
2. Audit existing Flutter implementation against contracts.
3. Remove or mark conflicting assumptions.
4. Implement missing behavior.
5. Validate with real builds and evidence.
