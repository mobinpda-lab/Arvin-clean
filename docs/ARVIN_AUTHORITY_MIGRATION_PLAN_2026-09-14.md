# Arvin Authority Migration Plan — 2026-09-14

## Purpose

This document records the transition after introducing the final product implementation contract.

## Active authority chain update

The active authority chain must contain:

1. Live GitHub reality (`main`, current code, tests, CI evidence).
2. Newest owner-approved product decisions.
3. Governance package.
4. Scorecards and evidence registries.
5. Canonical UI and product contracts.
6. Final implementation contracts.

## Newly added canonical implementation contract

`docs/ARVIN_FINAL_PRODUCT_IMPLEMENTATION_CONTRACT_2026-09-14.md`

Role:
- Defines production behavior expectations.
- Prevents old UI assumptions from returning.
- Defines acceptance criteria before claiming completion.

## Reconciliation tasks

- Update DOCUMENT_AUTHORITY_INDEX active references.
- Mark historical conflicting documents as lineage only.
- Keep old documents for traceability.
- Validate implementation against current contracts.
- Require evidence before closing recovery work.

## Completion rule

A requirement is complete only when:

- the intended user behavior exists,
- implementation matches the active contract,
- tests/evidence confirm the behavior,
- no newer authority document overrides it.
