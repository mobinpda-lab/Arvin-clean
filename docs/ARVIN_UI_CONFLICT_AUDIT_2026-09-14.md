# Arvin UI Conflict Audit — 2026-09-14

## Purpose

This audit identifies old assumptions that must not override the final Arvin UI reference and implementation contract.

## Authority Rule

The final installed Arvin reference and approved product contracts define the target output. Historical documents remain evidence only.

## Conflict Locks

### Home
- Old dashboard concepts that reintroduce removed statistical cards must not return.
- Grouping views must use real Task data.

### Quick Entry
- Quick registration and full form must share one persistence path.
- Repeated entry workflow must preserve user context where defined.

### Task Detail / Follow-up
- Follow-up history is persistent timeline data.
- Editing or completing a task must not erase history.

### Notebook
- Existing Notebook storage and Task-backed foundations must be preserved.
- A visual redesign must not create parallel persistence.

### Categories / Projects / Labels
- Taxonomy is a real data relationship, not only a visual filter.

## Implementation Rule

Before changing a screen:
1. Check active contract.
2. Check current model/service foundations.
3. Check installed app behavior evidence.
4. Implement with regression tests.

## Status

This document is an audit layer and does not mark implementation complete. Completion requires code, tests and Android verification evidence.
