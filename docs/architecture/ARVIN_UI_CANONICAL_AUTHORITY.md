# Arvin UI Canonical Authority

Status: Active

This document is the highest authority for UI contracts in Arvin.

## Rules

1. New UI flows MUST follow a registered canonical contract.
2. Conflicting legacy UI contracts are deprecated.
3. UI changes follow:

Contract -> Implementation -> Test -> Evidence

4. Widgets must not own domain persistence decisions.
5. Task flows must use the canonical Task path and existing services.
6. No second Task model or persistence path is allowed.

## Product Principle

Arvin is the product. Supporting systems are implementation mechanisms only.

## Phase 2 Target

Home Final Migration:
- Home contract stabilization
- canonical add/edit flow
- contract-code-test traceability
- UI drift removal
