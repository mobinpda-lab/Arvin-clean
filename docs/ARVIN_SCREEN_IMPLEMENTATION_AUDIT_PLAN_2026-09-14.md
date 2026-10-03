# Arvin Screen Implementation Audit Plan — 2026-09-14

## Purpose

This document defines the next operational audit step after establishing the final UI and product contracts.

The goal is not to create mockups. The goal is to compare the real Flutter implementation with the approved Arvin reference and prepare production changes.

## Audit Order

1. Home
- Header
- Search
- Grouping controls
- Task cards
- Bottom navigation

2. Quick Entry
- Keyboard behavior
- Repeated task creation
- Draft preservation
- Shared save path with full form

3. Task Detail
- Status
- Follow-up history
- Edit behavior
- Completion behavior

4. Notebook
- Notes
- Checklists
- Editor behavior
- Persistence

5. Calendar
- Jalali dates
- Task/event separation
- Data connection

6. Settings and More
- Only functional options exposed
- Persistent preferences

## Evidence Required

Each audited feature must have:

- Document reference
- Existing implementation location
- Gap description
- Required code change
- Test evidence
- Android verification status

## Regression Rules

- Do not duplicate existing models.
- Preserve existing Task, FollowUp, Project, Category, Label and Notebook data.
- Do not restore superseded UI decisions.
- Do not claim completion without executable evidence.
