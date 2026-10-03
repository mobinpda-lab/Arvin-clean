# ARVIN Code Change Plan — Phase 6

## Purpose

This document converts the approved UI reference and audit decisions into an implementation plan. No mockups are considered delivery. Changes must result in a working Flutter application connected to existing data models and services.

## Rules

- Reuse existing Task, FollowUp, Project, Category, Label and Notebook flows.
- Do not create parallel storage only for visual similarity.
- Preserve existing user data, history, archive, trash, reminders and recurring tasks.
- Every feature must move through: documented → implemented → data connected → tested → Android verified.

## Execution order

1. Home and grouping views
2. Quick entry and repeated task creation
3. Task detail and FollowUp history
4. Notebook and checklist editor
5. Calendar, Next Action and Settings
6. Full regression testing

## Change control

Before editing any Dart file:
- identify current widget and service owner
- identify existing data source
- record expected behavior
- test after modification

## Release evidence required

- flutter analyze result
- test results
- real Android execution evidence
- remaining limitations report
