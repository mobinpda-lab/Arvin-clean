# Encrypted Backup Envelope v1 — Prototype Contract

Issue #248. Follows merged audit #244 / PR #245.

## Scope

This lane prototypes only the cryptographic byte envelope around the existing canonical Arvin backup document. It does not yet change `ArvinBackupService.writeBackup`, SAF, cloud upload, TaskStore, restore mutation, UI, or Sync.

Canonical direction:

`existing validated backup bytes → encrypted envelope → existing SAF / Cloud path`

Restore direction:

`bytes → legacy-v1 pass-through OR authenticate/decrypt envelope → existing backup validation → existing restore candidate flow`

## Envelope v1

- type: `arvin_encrypted_backup`
- formatVersion: `1`
- KDF: Argon2id
- cipher: AES-256-GCM
- 16-byte random salt
- random cipher nonce
- authenticated ciphertext/MAC
- fixed AAD binds the envelope type/version/KDF/cipher contract

Production-default KDF parameters are intentionally explicit and serialized in the envelope. Restore validates bounded parameters before derivation to prevent attacker-controlled resource-exhaustion values.

## Recovery contract

The prototype accepts a user-controlled passphrase and derives the encryption key from that passphrase plus the envelope salt. It does not store or serialize the passphrase/key. Product UI, secure cached-key storage, loss/rotation UX and cross-device recovery wording remain separate acceptance work before encryption can be enabled by default.

## Compatibility

Legacy plaintext Arvin backup format v1 remains readable and is returned unchanged to the existing validator. The prototype does not reinterpret or silently rewrite legacy v1.

## Failure behavior

Wrong passphrase or modified ciphertext fails authenticated decryption before any plaintext bytes are returned to the restore pipeline. Invalid algorithm/version/KDF metadata is rejected before decryption.

## Guardrails

This PR must not:

- encrypt local `TaskStore`;
- implement multi-device Sync;
- create a second backup repository/database;
- fork SAF and cloud backup representations;
- serialize Dropbox/access tokens or credentials;
- wire encryption on by default before recovery/UI behavior is accepted.

## Tests

`test/encrypted_backup_envelope_test.dart` covers:

- canonical bytes encrypted/decrypted round-trip;
- passphrase is never serialized;
- randomized envelope output for the same backup/passphrase;
- legacy plaintext v1 pass-through;
- wrong passphrase failure;
- tamper rejection;
- malicious oversized KDF parameter rejection.
