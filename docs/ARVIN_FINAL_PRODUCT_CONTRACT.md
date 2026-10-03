# ARVIN FINAL PRODUCT CONTRACT

## Authority

This document is the final UI/UX and product behavior authority for Arvin.
It replaces conflicting old UI requirements.

## Core Rule

Arvin is not rebuilt from zero. Existing architecture remains:

- Task
- FollowUp
- Project
- Category
- Tag
- Notebook
- Calendar
- Storage
- Services

No parallel data path is allowed.

## UI System

- Persian
- RTL
- VazirHarf v34.003
- Primary color: #4A4CAB
- Background: #F8F8FB
- White rounded cards
- Soft shadows

Reference images define layout only. Text and data must come from real application data.

## Home

Remove old statistic cards:

- کل
- فعال
- انجام‌شده
- عقب‌افتاده

Keep overdue as a real time grouping.

Four fixed views:

1. زمان
2. پروژه‌ها
3. دسته‌ها
4. برچسب‌ها

Views must change real grouping, not decoration.

## Quick Entry

Quick Entry and Full Editor share one Task Draft and one save path.

Required:

- sequential task creation without closing panel
- preserve shared selections
- prevent duplicate saves
- preserve input on errors

## Task Detail and FollowUp

Task cards open details, not editor.

FollowUp detail requires:

- task information
- latest follow-up card
- follow-up timeline
- add follow-up
- edit task
- complete task

History must never be replaced by a new follow-up.

## Notebook

Keep existing Notebook storage.
Support:

- notes
- checklists
- search
- categories

## Calendar

Real Persian calendar:

- month
- week
- day

Separate:

- Task
- FollowUp
- Reminder
- Event

## Acceptance Evidence

Every phase must report:

- branch
- commit
- changed files
- tests
- screenshots from real execution
- remaining limitations

No completion claim without evidence.
