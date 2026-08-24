# Arvin Task Tracker Reference

## Purpose

`mobinpda-lab/arvin-task-tracker` is a reference implementation for Arvin product behavior. It is not a source to copy wholesale into `Arvin-clean`.

## Findings

The reference project has a useful FollowUp model with:

- creation timestamp (`at`)
- optional reminder timestamp (`reminderAt`)
- JSON serialization/deserialization
- Jalali date formatting
- Tehran timezone for scheduled notifications
- FollowUp history attached to each task

It also demonstrates backward-compatible reading of legacy keys such as `description`, `category`, `trashed`, and multiple historical FollowUp keys.

## Calendar decision

The reference project confirms the value of Jalali conversion, Persian digits, RTL weekday ordering, and deterministic compact calendar cells. However, its current date/time selection flow still uses Flutter's standard Gregorian `showDatePicker`/`showTimePicker` for editing dates. Therefore it is **not** a drop-in replacement for Arvin-clean's CalendarPage.

Arvin-clean already has a dedicated Jalali calendar implementation and regression coverage for the constrained 800x544 viewport. The reference project should therefore be used for behavioral comparison and regression ideas, not copied into CalendarPage without a targeted validation wave.

## FollowUp integration direction

The safe architecture for Arvin-clean remains:

`Task model -> TaskStore -> FollowUp service -> FollowUp UI -> HomePage/Task Editor -> Calendar reminder`

Persistence compatibility must be preserved while migrating from legacy `followUpDate` data.

## Rule

Before importing any implementation from the reference project, compare the current Arvin-clean model, storage contract, tests, and documentation. Reuse only isolated behavior that improves the existing architecture without duplicating already-solved work.
