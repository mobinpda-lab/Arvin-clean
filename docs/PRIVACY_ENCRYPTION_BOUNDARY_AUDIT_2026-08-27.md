# Privacy / Encryption Boundary Audit — 2026-08-27

Issue #244. Refs roadmap feature #17.

## Purpose

Define the smallest safe encryption boundary on Arvin's existing canonical storage and backup path before implementing cryptography. This audit must not create a second Task store, backup representation, settings store, or secret database.

## Current canonical data surfaces

### Local Task data

`lib/services/task_store.dart` stores the complete canonical `Task.toJson()` list as JSON under SharedPreferences key `arvin.tasks`.

Implication: Task content is locally persisted in application preferences without an Arvin-managed encryption envelope. Platform/application sandbox protections still apply, but Arvin itself does not currently encrypt that JSON payload.

### Backup directory preference

`lib/backup_manager.dart` stores the selected SAF directory URI under SharedPreferences key `arvin.backup.directory`. This is configuration metadata, not the backup content itself.

### Portable backup document

`lib/backup_service.dart` currently creates backup format v1 as ordinary UTF-8 JSON with:

- `type = arvin_backup`
- `formatVersion = 1`
- `createdAt`
- canonical `tasks`
- optional portable `settings`

The exact validated bytes written through Android SAF are also passed to the configured cloud provider. Therefore local exported backup and cloud backup share one canonical representation and must remain one path after encryption is added.

### Portable Settings

`AppSettingsService.toPortableJson()` exports only theme mode, Persian-date preference, and optional font family. No credential/token field is part of the canonical portable Settings contract.

### Dropbox credential boundary

`DropboxCloudBackupProvider` receives `accessToken` through constructor injection and uses it only to authorize Dropbox HTTP requests. The provider itself does not write that token to SharedPreferences or to the backup document.

## Security observations

1. Backup v1 payloads are readable JSON. Any party with access to an exported backup file can read its Task/FollowUp content.
2. Cloud upload receives the same readable v1 bytes, so provider-side transport/storage security is currently the only cloud protection beyond Arvin's application boundary.
3. Local canonical Task persistence is also JSON in SharedPreferences, but changing local persistence and portable backup encryption in one migration would multiply data-loss and rollback risk.
4. Dropbox access-token lifecycle is a separate secret-management concern from user-data encryption and must not be inserted into the portable backup payload.
5. Existing v1 restore compatibility is a hard requirement; encryption must be additive/versioned rather than replacing the reader blindly.

## Recommended first implementation boundary

Encrypt at the portable backup byte boundary in `ArvinBackupService`, after canonical payload validation/serialization and before SAF/cloud write. Decrypt at the symmetric read boundary before existing document validation.

Desired architecture:

`canonical Task + portable Settings → validated backup payload → encrypted envelope → SAF / Cloud`

Restore:

`SAF / Cloud → detect envelope/version → decrypt if encrypted → existing canonical backup validation → restore candidate`

This preserves:

- one backup representation;
- one SAF/cloud path;
- the existing canonical Task model;
- current restore validation;
- Dropbox provider independence from cryptographic policy.

## Compatibility contract

A future encrypted backup format must:

- continue reading legacy plaintext format v1;
- write a new explicitly versioned encrypted envelope rather than silently changing v1 semantics;
- authenticate ciphertext so corruption/tampering fails before Task restore;
- never partially mutate local storage before authentication + document validation succeed;
- preserve the current restore-candidate/confirm flow;
- keep Settings portable and validated through `AppSettingsService`;
- avoid hard-coded keys, tokens, or recoverable secrets in source code;
- define recovery behavior before enabling encryption by default.

## Key-management decision required before implementation

A device-bound key alone is insufficient for a backup intended to move to another phone. The implementation design must explicitly choose a recoverable key strategy, for example a user-controlled secret/passphrase deriving or wrapping a data-encryption key, while platform secure storage may protect cached local key material.

The following must be decided and tested before shipping:

- key creation and storage;
- password/passphrase loss behavior;
- key rotation;
- cross-device restore;
- downgrade/legacy v1 restore;
- failed authentication behavior;
- backup metadata visible without decryption, if any.

## Deferred local-at-rest encryption

Local `TaskStore` encryption is a distinct follow-up. It should be designed after portable backup encryption is stable because it affects every app startup/save and has a different recovery/migration risk. It must reuse the canonical Task path rather than create a second encrypted repository.

## Executable contract in this lane

`test/privacy_backup_boundary_contract_test.dart` protects two currently safe invariants:

1. canonical portable Settings contain only the approved non-secret fields;
2. the normal portable backup path does not invent or serialize Dropbox/access-token fields when built from canonical Settings.

The test intentionally does **not** freeze plaintext v1 as desired future behavior.

## Next implementation slice

After this audit is accepted, the next security PR should be a narrow crypto-envelope contract/prototype with legacy-v1 read tests and authenticated-failure tests. Do not combine it with local TaskStore encryption or multi-device sync.
