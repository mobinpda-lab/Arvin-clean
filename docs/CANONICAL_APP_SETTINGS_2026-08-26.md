# Canonical App Settings — 2026-08-26

Issue #231. Refs #8 #15 #195.

## Purpose

Add the missing user-facing Arvin settings foundation without creating a second persistence engine or duplicating Backup/Restore.

## Canonical path

`Settings UI -> AppSettingsService -> existing SharedPreferences foundation`

Stored preferences are limited to UI settings:

- theme mode: system / light / dark
- Home Persian-date display preference
- optional font-family slot for an actually available app font

Task, FollowUp, Reminder, Calendar, Notebook and Backup domain data are not stored here.

## Font guard

The current repository contains no custom font asset registered in `pubspec.yaml`. The Settings UI therefore reports the app/system default and does not invent a selectable font or download a new asset. A custom family may only become selectable after the corresponding asset is deliberately added and validated.

## Backup guard

Settings does not implement a second backup flow. Its Backup/Restore entry delegates to the existing Home `ArvinBackupManager` path.

## Persian date

Home keeps its existing Gregorian display by default for migration safety. When the preference is enabled, `PersianDateFormatter` renders the Home follow-up date as Jalali with Persian digits. Calendar's existing Persian behavior remains untouched by this preference.

## Parallel delivery

The settings service, formatter, page and focused tests are prepared independently while Android Device Smoke #230 is validated. The final Home/MaterialApp wiring must be reconstructed on the latest `main` after #230 before merge.
