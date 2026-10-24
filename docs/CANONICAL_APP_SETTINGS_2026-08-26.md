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

**Vazirmatn (وزیرمتن)** is the canonical/default Arvin UI font. The mandatory weights are body Regular 400, secondary Light 300, menus/buttons Medium 500, headings Bold 700, and important emphasis SemiBold 600. `fontFamily == null` must resolve to Vazirmatn after the runtime migration is implemented. Preserve the existing `AppSettingsService` and storage key; do not create a parallel settings system. See [`docs/TYPOGRAPHY_CANONICAL.md`](TYPOGRAPHY_CANONICAL.md).

## Backup guard

Settings does not implement a second backup flow. Its Backup/Restore entry delegates to the existing Home `ArvinBackupManager` path.

## Persian date

Home keeps its existing Gregorian display by default for migration safety. When the preference is enabled, `PersianDateFormatter` renders the Home follow-up date as Jalali with Persian digits. Calendar's existing Persian behavior remains untouched by this preference.

## Reconstruction evidence

The Settings vertical slice was reconstructed on `main` `c93cd03ea48a91b792fb995537cac3c847920a89`, preserving the merged Android runtime fix, mutable canonical Task list, device-smoke workflow, and bundled VazirHarf assets. Temporary reconstruction/convergence workflows self-remove; they are not part of the product diff.

## Joplin reference guard

Joplin is useful as an architecture reference for future offline-first sync, revision history, conflict handling and storage evolution. Its main code is AGPL-3.0-or-later and uses a different TypeScript/React Native stack, so this completion lane copies no Joplin source code and introduces no second SQLite/database/storage foundation. Any future storage evolution must migrate the existing canonical `Task` / `arvin.tasks` path deliberately rather than run a parallel database.

## Typography convergence

- **Vazirmatn (وزیرمتن)** is the canonical public/default Arvin UI font.
- `fontFamily == null` means use the Arvin default VazirHarf.
- Any licensed/private or additional public font picker must extend `AppSettingsService`; it must not create a parallel settings store/controller.
- Legacy `VazirHarf` setting values must be migrated compatibly to the canonical `Vazirmatn` default; do not break old Settings or backups.
