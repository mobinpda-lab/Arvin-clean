# ARVIN FINAL PRODUCT CONTRACT 2026

## Authority

This document is the final product contract for Arvin UI/UX implementation.

Repository: mobinpda-lab/Arvin-clean

## Principles

- Real Flutter implementation only; no mock-only UI.
- Preserve existing Task, FollowUp, Project, Category, Tag, Notebook and Storage architecture.
- Do not create parallel data paths.

## Home

Remove statistic cards:
- کل
- فعال
- انجام‌شده
- عقب‌افتاده

Keep time grouping including overdue tasks.

Canonical Home modes:
- زمان
- پروژه‌ها
- دسته‌ها
- برچسب‌ها

The four modes must change real grouping and keep stable RTL ordering.

## Quick Entry

Quick Entry and Full Editor share one Task Draft and one save path.

Required:
- sequential task entry without closing the panel
- preserve shared selections
- prevent duplicate saves
- protect unsaved drafts on back navigation

## Task Detail / FollowUp

Task card opens details, not editor.

FollowUp detail includes:
- task information
- latest follow-up
- real follow-up timeline
- add follow-up flow

Adding a follow-up appends history and never replaces previous records.

## Validation

Final acceptance requires:
- flutter analyze
- tests
- Android verification where available
- real screenshots and evidence before claiming completion
