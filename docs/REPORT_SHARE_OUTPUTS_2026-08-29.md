# Arvin Report Sharing Outputs — 2026-08-29

## Purpose

Add shareable text output alongside PDF without disrupting the current Arvin production flow.

## Canonical architecture

Report data is produced once and rendered through independent output adapters:

`Report Data -> PDF Renderer / Text Renderer / Share`

Text output must not become a second reporting system and must not duplicate domain logic.

## User-facing outputs

Arvin reports should support:

1. Share as text
2. Copy text
3. Share/export PDF

## Text renderer rules

The text renderer should reuse the same report model/data used by PDF output and preserve the same logical ordering of sections and fields.

Text output may include, where applicable:

- report title
- report date/time
- task/follow-up items
- status
- descriptions/notes
- totals/summary

The destination application controls the visual font of shared plain text. Therefore the fixed report typography rules for PDF remain unchanged.

## PDF typography

PDF/print reports remain fixed on the canonical Arvin report font:

`Vazirmatn UI FD`

The UI font preference must not alter PDF typography.

## Isolation and parallel execution

This work must run fully in parallel with the existing Arvin production process.

Mandatory constraints:

- Do not pause, cancel, restart, or block any active production workflow, PR, build, or test.
- Keep Production Orchestrator and the main delivery lane unchanged.
- Implement report sharing in an isolated branch/PR.
- Avoid simultaneous edits to files already being changed by active PRs where practical.
- Rebase/update against the latest `main` before merge and resolve conflicts in this lane only.
- If a conflict with an active production lane appears, the main production lane has priority; this feature waits instead of stopping the project.
- Do not create a second settings store, report domain model, or parallel reporting architecture.

## Acceptance criteria

The feature is complete when:

1. A report can be shared as plain text.
2. Report text can be copied to the clipboard.
3. Existing PDF sharing/export remains functional.
4. Text and PDF outputs are generated from the same canonical report data.
5. Text output preserves meaningful section/field order.
6. Empty optional fields do not create broken or noisy output.
7. Persian/RTL text remains readable when shared to common target apps.
8. PDF continues to use Vazirmatn UI FD independently from the UI font setting.
9. Regression tests cover text rendering and existing PDF output boundaries.
10. No active Arvin production path is stopped or replaced.

## Execution principle

**Maximum Parallel; fast, automatic, documented, non-blocking, no parallel architecture, short non-technical reporting.**
