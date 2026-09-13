# Arvin Canonical Authority

## Purpose
This document is the highest-level governance reference for Arvin architecture and UI evolution.

## Authority Rules
- New UI work must follow approved contracts.
- Existing legacy paths may remain only as migration boundaries.
- No duplicate product models or parallel persistence paths may be introduced.
- Changes must be validated through contract, implementation, and tests.

## Current Migration State
Legacy:
- main.dart
- ArvinTask
- TaskRepository

Canonical target:
- models/task.dart
- Task
- Unified follow-up/reminder/recurrence model

## Migration Principle
Incremental migration with compatibility boundaries. No large rewrite.

## Decision Authority
This document overrides older UI decision documents when conflicts exist.
