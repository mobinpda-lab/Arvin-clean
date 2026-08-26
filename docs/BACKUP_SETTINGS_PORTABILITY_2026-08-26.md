# Backup Settings Portability — 2026-08-27

Issue #235. Refs #231 #195.

## Goal

Allow the existing Arvin portable backup document to carry canonical app settings during device transfer without creating a second backup format, manager, storage key, or database.

## Format decision

The existing `arvin_backup` format remains `formatVersion: 1`.

Existing task-only documents remain valid. New documents may include an optional object:

```json
"settings": {
  "themeMode": "dark",
  "usePersianDate": true,
  "fontFamily": "Vazirmatn"
}
```

The low-level backup service validates that `settings`, when present, is an object. `AppSettingsService` owns the typed interpretation and persistence of those keys. `ArvinBackupManager` returns Tasks and Settings from one file selection as one restore candidate so the UI can validate and confirm the complete restore once.

## Compatibility contract

- Old v1 Task-only backups remain valid and restore with `settings == null`.
- Missing individual Settings keys use safe current defaults.
- Invalid value types or unsupported theme values fail validation before local settings are changed.
- Tasks continue to use the full canonical `Task.toJson()` / `Task.fromJson()` shape.
- The same SAF / Dropbox byte path is reused.

## Reference-project lessons applied

### Joplin

Joplin is used as an architecture/testing reference, not as copied source. This slice adopts the useful production habits of keeping transport-format validation separate from typed application state, preserving backward compatibility, and testing migration/restore candidates before mutating local state. Joplin's repository is AGPL-3.0-or-later by default, so no AGPL implementation code is copied into Arvin.

### TimeJot

TimeJot's public product/help documentation reinforces a local-first device-transfer experience where backup remains understandable and user-controlled. Its application source is not treated as available; only public behavior/documentation is used as a product reference.

## Guardrails

- Existing SAF and cloud backup bytes are reused.
- Existing task-only v1 backups remain readable.
- No format-version bump is needed for an optional backward-compatible field.
- No second Backup service/manager is created.
- No second settings store is created.
- No Joplin or TimeJot application source is copied.

## Validation

Focused tests cover:

- old Task-only v1 compatibility;
- optional Settings encode/validate round-trip;
- malformed Settings rejection;
- canonical Task + Settings candidate restore without storage mutation;
- typed `AppSettings` portable encode/decode/persistence;
- duplicate Task ID rejection remains active.

Final Home wiring must back up the current Settings together with Tasks, validate imported Settings before confirmation, restore through the existing `TaskStore` + `AppSettingsService`, and notify the app shell so Theme/date/font changes apply immediately.
