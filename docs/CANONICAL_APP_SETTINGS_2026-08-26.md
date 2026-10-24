# Canonical App Settings — 2026-08-26

> **DEPRECATED AS A TYPOGRAPHY AUTHORITY.** Historical settings design record only. Current font contract: `docs/TYPOGRAPHY_CANONICAL.md`; where any wording conflicts, the canonical typography contract prevails.

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

**Vazirmatn is the only canonical and mandatory default UI font family for Arvin**, per `docs/TYPOGRAPHY_CANONICAL.md` and Issue #2974. A missing or null `fontFamily` means Vazirmatn, never VazirHarf or the device/system font. Legacy persisted or backed-up `VazirHarf` values must migrate explicitly to `vazirmatn`; restoring such a backup must not fail. Settings must not create a parallel font-preference store.

## Backup guard

Settings does not implement a second backup flow. Its Backup/Restore entry delegates to the existing Home `ArvinBackupManager` path.

## Persian date

Home keeps its existing Gregorian display by default for migration safety. When the preference is enabled, `PersianDateFormatter` renders the Home follow-up date as Jalali with Persian digits. Calendar's existing Persian behavior remains untouched by this preference.

## Reconstruction evidence

The Settings vertical slice was reconstructed on `main` `c93cd03ea48a91b792fb995537cac3c847920a89`, preserving the merged Android runtime fix, mutable canonical Task list, device-smoke workflow, and bundled VazirHarf assets. Temporary reconstruction/convergence workflows self-remove; they are not part of the product diff.

## Joplin reference guard

Joplin is useful as an architecture reference for future offline-first sync, revision history, conflict handling and storage evolution. Its main code is AGPL-3.0-or-later and uses a different TypeScript/React Native stack, so this completion lane copies no Joplin source code and introduces no second SQLite/database/storage foundation. Any future storage evolution must migrate the existing canonical `Task` / `arvin.tasks` path deliberately rather than run a parallel database.

## Typography convergence

- The current authority is `docs/TYPOGRAPHY_CANONICAL.md`; this document is historical for its original date and is subordinate where it conflicts with that contract.
- Vazirmatn is the only canonical default UI family. VazirHarf is not a default, fallback, or active alternative.
- `fontFamily == null`, an absent key, an unknown legacy value, and a legacy `VazirHarf` value all resolve explicitly to `vazirmatn` without breaking restore.
- Font selection continues through the existing `AppSettingsService`; no parallel settings store/controller is permitted.
