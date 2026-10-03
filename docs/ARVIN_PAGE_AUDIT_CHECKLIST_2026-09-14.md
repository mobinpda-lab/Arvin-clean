# Arvin Page Audit Checklist — 2026-09-14

## Purpose

This document defines the audit sequence before changing production code. The goal is convergence between the real installed Arvin experience, canonical design references, existing architecture, and final implementation.

## Audit Rules

- Do not create parallel storage models for visual similarity.
- Reuse existing Task, FollowUp, Project, Category, Label and Notebook foundations.
- A feature is not complete until UI, data connection, persistence and test evidence exist.
- Legacy documents that conflict with the final authority must be marked as superseded.

## Page Review Order

### 1. Home

Check:
- RTL header and title
- Search placement
- Four grouping controls
- Real task grouping data
- Task card behavior
- Empty/loading/error states

### 2. Quick Entry

Check:
- Keyboard behavior
- Repeated task creation flow
- Draft preservation
- Duplicate submission prevention
- Shared save path with full form

### 3. Task Detail / Follow Up

Check:
- Task metadata
- Latest follow-up preview
- Timeline history
- Add follow-up persistence
- No history deletion on edit/complete

### 4. Notebook

Check:
- Simple note mode
- Checklist mode
- Editor behavior
- Persistence after reload

### 5. Calendar

Check:
- Jalali dates
- Task and reminder separation
- Connection to source data

### 6. Categories / Projects / Labels

Check:
- Real grouping
- Create/edit flows
- Icons and colors
- Ungrouped items

### 7. Settings and More

Check:
- Only functional options are shown
- Persistent settings
- Backup/recovery paths

## Evidence Required

Each audited area must report:

- Current implementation files
- Gap from canonical contract
- Change required
- Tests required
- Android verification status
