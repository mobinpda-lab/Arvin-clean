# ARVIN Implementation Execution Checklist Phase 4

## Purpose

This document converts the approved Arvin visual and product contracts into an execution checklist.

## Rules

- Do not create parallel data models for UI purposes.
- Preserve existing Task, FollowUp, Project, Category, Label and Notebook storage paths.
- A feature is complete only when UI, data connection, interaction and verification exist.

## Execution Order

### 1. Home
- Verify RTL layout.
- Verify canonical colors and spacing.
- Verify four grouping modes.
- Verify real data counts.
- Remove any obsolete home statistics behavior.

### 2. Quick Entry
- Verify single save path.
- Verify repeated entry workflow.
- Verify keyboard behavior.
- Verify draft preservation on errors.

### 3. Task and FollowUp
- Verify detail navigation.
- Verify follow-up history preservation.
- Verify add-follow-up behavior.

### 4. Notebook
- Verify note and checklist separation.
- Verify canonical persistence.
- Verify editor behavior.

### 5. Calendar and Settings
- Verify real data integration.
- Remove non-functional options.

## Release Evidence Required

- flutter analyze result
- test result
- Android installation verification
- real screenshots
- remaining limitations report

Status: Audit and implementation preparation in progress.
