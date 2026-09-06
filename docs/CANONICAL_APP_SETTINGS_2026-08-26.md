# Canonical App Settings — 2026-08-26

Issue #231. Refs #8 #15 #195.

## Font guard

VazirHarf v34.003 is the canonical public/default Arvin font. `fontFamily == null` means use the Arvin default (VazirHarf), not another settings controller. Licensed/private fonts such as IRANSansX may be used only when legitimately available and must extend the same `AppSettingsService` contract.

## Backup guard

Settings does not implement a second backup flow. Backup/Restore delegates to the existing `ArvinBackupManager` path.

## Persian date

When enabled, `PersianDateFormatter` renders Home follow-up dates as Jalali with Persian digits.

## Typography convergence

- VazirHarf v34.003 is the canonical public/default font.
- `fontFamily == null` means use the Arvin default.
- Any additional font picker must extend `AppSettingsService` and must not create parallel settings storage.
