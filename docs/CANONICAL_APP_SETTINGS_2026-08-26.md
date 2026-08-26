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

Vazirmatn is bundled and registered on current `main` and is the canonical public/default Arvin font. `fontFamily == null` therefore means “use the Arvin default (Vazirmatn)”, not “create another font/settings controller”. Licensed/private fonts such as IRANSansX may be used only when their assets are legitimately available; additional public fonts must extend this same `AppSettingsService` contract rather than create a parallel settings system.

## Backup guard

Settings does not implement a second backup flow. Its Backup/Restore entry delegates to the existing Home `ArvinBackupManager` path.

## Persian date

Home keeps its existing Gregorian display by default for migration safety. When the preference is enabled, `PersianDateFormatter` renders the Home follow-up date as Jalali with Persian digits. Calendar's existing Persian behavior remains untouched by this preference.

## Reconstruction evidence

The Settings vertical slice was reconstructed on `main` `c93cd03ea48a91b792fb995537cac3c847920a89`, preserving the merged Android runtime fix, mutable canonical Task list, device-smoke workflow, and bundled Vazirmatn assets. Temporary reconstruction/convergence workflows self-remove; they are not part of the product diff.

## Joplin reference guard

Joplin is useful as an architecture reference for future offline-first sync, revision history, conflict handling and storage evolution. Its main code is AGPL-3.0-or-later and uses a different TypeScript/React Native stack, so this completion lane copies no Joplin source code and introduces no second SQLite/database/storage foundation. Any future storage evolution must migrate the existing canonical `Task` / `arvin.tasks` path deliberately rather than run a parallel database.

## Typography convergence

- Vazirmatn bundled on `main` is the canonical public/default font.
- `fontFamily == null` means use the Arvin default, not a second settings system.
- Any licensed/private or additional public font picker must extend `AppSettingsService`; it must not create a parallel settings store/controller.
