# ARVIN FINAL PRODUCT CONTRACT

## Authority

This document is the final UI/UX and acceptance contract for Arvin.

Repository: mobinpda-lab/Arvin-clean

Goal: transform the current Flutter application into the final executable product. This contract requires real Flutter implementation, real data connection, real navigation and real persistence. Mockups alone are not acceptable.

## Core Principles

- Preserve existing Task, FollowUp, Project, Category, Tag, Notebook, Calendar, Storage and Service architecture.
- Do not create parallel data models or storage paths.
- Existing user data must remain compatible.

## Final UI Direction

- Persian RTL interface.
- VazirHarf v34.003.
- Primary color #4A4CAB.
- Light background #F8F8FB.
- White rounded cards with subtle shadows.

## Home

Remove statistical cards:
- کل
- فعال
- انجام‌شده
- عقب‌افتاده

Keep time grouping including overdue tasks.

Home views:
- زمان
- پروژه‌ها
- دسته‌ها
- برچسب‌ها

These views must change real grouping, not only appearance.

## Quick Entry

Quick Entry and Full Editor must share one Task Draft and one canonical save path.

Required:
- repeated task entry without closing panel
- preserve shared selections
- prevent duplicate saves
- preserve draft on save failure

## FollowUp

Task detail must show:
- task information
- latest follow up
- follow up history timeline
- add follow up
- edit and complete actions where supported

Adding follow up must append history and never replace existing records.

## Evidence Requirements

Each implementation phase must report:
- branch and commit
- changed files
- tests
- screenshots from real execution
- remaining limitations

No feature is considered complete without evidence.
