# Arvin UI Canonical Authority

Status: Active Authority

## Purpose
This document is the primary UI contract authority for Arvin.
Existing UI contracts that conflict with this document are deprecated.

## Rules

1. UI behavior must be defined by a canonical contract before implementation.
2. No screen, widget, or flow may create an independent data contract.
3. UI reads and writes must follow canonical domain boundaries.
4. Code changes require matching tests and documentation updates.

## Canonical Product Boundary

`Task / Unified Item → Reminder → FollowUps[] → History`

Home, Search, Today, FollowUp, Timeline, Calendar, Backup, Settings, Widget and Reports consume this foundation.

## Migration Rule

Phase migrations must remain reversible and must not introduce:

- parallel persistence paths
- duplicate Task sources of truth
- hidden UI-only business logic
- undocumented contracts

## Evidence Requirement

Every UI contract maps to:

Contract → Code → Test → Evidence
