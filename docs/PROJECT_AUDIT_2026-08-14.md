# Arvin Project Audit — 2026-08-14

## Purpose

This document records the pre-change architecture audit required before each Arvin change. The source of truth remains `Arvin-clean`; `arvin-task-tracker` and `daftar-peygiri` are reference projects only.

## Current architecture findings

- `lib/main.dart` still contains the legacy `ArvinTask`/`TaskRepository` path with `followUpDate`.
- `lib/models/task.dart` already contains the richer `Task` + `FollowUp` model and legacy `followUpDate` migration.
- Calendar behavior is already stabilized for Jalali/Persian/RTL and constrained test viewports; do not rewrite it without a failing regression or an approved UX wave.
- FollowUp work must converge the legacy UI path onto the richer model rather than creating a third persistence format.
- Backup compatibility must remain intact while the migration is completed.

## Reference-project decisions

### arvin-task-tracker

Use as the primary UX/reference source for:

- automatic current date/time when recording a follow-up;
- editable date and time controls;
- Jalali/Persian date handling;
- reminder/timezone behavior;
- follow-up history and next-follow-up concepts.

Do not wholesale-copy its storage or replace stabilized Arvin-clean infrastructure.

### daftar-peygiri

Use selectively as a product/CI reference. Reuse only patterns that fit the current Arvin architecture and test contract.

## Parallel development rule

Independent commits and independent waves must be started in parallel whenever dependencies do not require sequencing. A green result is required before merging dependent work, but must not block unrelated independent validation.

## Next implementation sequence

1. Keep the existing Calendar and Android/CI infrastructure unchanged.
2. Finish FollowUp storage/service validation.
3. Bridge the legacy `main.dart` task path to the richer FollowUp domain model.
4. Connect FollowUp Entry to TaskStore/service.
5. Surface latest follow-up in task UI.
6. Connect next follow-up to Calendar/Reminder only after the domain bridge is stable.
7. Run end-to-end regression and produce a fresh APK.

## No-regression gate

Before every code change: compare current `main`, open PRs, existing tests, persistence keys, backup format, and reference-project behavior. If a reported problem is already fixed, do not touch it again.
