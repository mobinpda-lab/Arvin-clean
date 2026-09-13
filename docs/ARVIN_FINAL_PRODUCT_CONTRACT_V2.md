# ARVIN FINAL PRODUCT CONTRACT V2

## Authority

This document is the final UI/UX and acceptance contract for Arvin.
It replaces conflicting UI requirements while preserving existing architecture and data.

## Principles

- Real Flutter implementation only; no mock-only UI.
- Reuse existing Task, FollowUp, Project, Category, Tag, Notebook, Calendar and Storage layers.
- No parallel models or storage paths.

## Home

Remove statistic cards:
- کل
- فعال
- انجام‌شده
- عقب‌افتاده

Keep overdue as a real time grouping, not a statistic card.

Home views:
- زمان
- پروژه‌ها
- دسته‌ها
- برچسب‌ها

Views must change real grouping and keep stable RTL ordering.

## Quick Entry

Quick Entry and Full Editor share one Task Draft and one save path.

Requirements:
- Persian RTL bottom sheet
- autofocus title
- title-only save
- repeated entry without closing sheet
- preserve shared selections
- prevent duplicate saves
- protect unsaved drafts on back

## Task Card

Display:
- completion control
- title
- project/category
- due date
- status
- latest FollowUp text when available

Tap opens Task Detail, not direct edit.

## FollowUp Detail

Provide:
- task information
- latest follow up card
- timeline history newest first
- add follow up
- edit when supported
- complete task

Adding follow up appends history and never replaces previous entries.

## Notebook / Calendar / Settings

Preserve existing storage and expose only working features.

## Acceptance

Required evidence:
- branch and commit
- changed files
- flutter analyze
- tests
- real Android screenshots
- three-task quick entry video
- restart persistence check

No completion claim without evidence.
