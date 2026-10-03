# Arvin Flutter Screen Audit Matrix — Phase 1

Date: 2026-09-14

## Purpose

This document starts the implementation audit between the final Arvin product contracts and the current Flutter application.

The goal is not to redesign from scratch. Existing models, services and stored data remain the source of truth.

## Audit Rules

- UI similarity alone is not acceptance.
- A feature is complete only when UI, data connection, interaction, persistence and verification exist.
- Existing Task, FollowUp, Project, Category, Label and Notebook paths must be reused where possible.
- Conflicting legacy UI requirements are not allowed to override the final product contract.

## Screen Audit Order

### 1. Home

Required checks:
- Header and RTL layout
- Search behavior
- Four grouping modes
- Real task data rendering
- Empty/loading/error states
- Navigation integration

Status: Audit pending

### 2. Quick Entry

Required checks:
- Bottom input panel
- Keyboard behavior
- Sequential task creation
- Draft preservation
- Duplicate prevention
- Shared save path with full form

Status: Audit pending

### 3. Task Detail / Follow Up

Required checks:
- Task metadata
- Follow-up history
- Add follow-up persistence
- Update without history loss

Status: Audit pending

### 4. Notebook

Required checks:
- Notes
- Checklist
- Search
- Categories
- Persistence

Status: Audit pending

### 5. Calendar / Next Action / Settings

Required checks:
- Real data connection
- No fake capabilities
- Stable settings

Status: Audit pending

## Next Evidence Required

For each screen:
- Flutter source files
- Current behavior
- Gap with contract
- Required change
- Test evidence

No production completion claim is allowed without evidence.
