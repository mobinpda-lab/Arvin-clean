# Arvin Code/UI Audit Checklist — 2026-09-14

## Purpose

This document starts the real implementation audit after establishing the final UI and product contracts.

The goal is not to create mockups. The goal is to verify that the Flutter implementation, existing data models, services, and installed application behavior converge to the approved Arvin reference.

## Audit order

1. Existing architecture and data preservation
2. Current screens and navigation
3. Home and grouping views
4. Quick entry flow
5. Task detail and FollowUp
6. Notebook
7. Calendar and Next Action
8. Settings and production readiness

## Rules

- Existing models and repositories must be reused where possible.
- No duplicate storage layer for visual similarity.
- No feature is considered complete without working data flow.
- Old documents are historical unless explicitly promoted to authority.

## Evidence required per feature

- Source files inspected
- Implementation status
- Tests available
- Android verification status
- Remaining gaps

## Initial audit targets

### Core models

- Task
- FollowUp
- Project
- Category
- Label
- Notebook

### Main screens

- Home
- Quick Add
- Task Detail
- Notebook
- Calendar
- More/Settings

## Completion states

- Documented
- Implemented
- Tested
- Android Verified
