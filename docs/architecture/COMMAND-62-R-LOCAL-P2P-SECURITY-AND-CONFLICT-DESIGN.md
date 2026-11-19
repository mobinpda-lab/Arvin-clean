# COMMAND 62-R — Local P2P Security and Conflict Design
**Status:** DESIGN PROPOSAL — SECURITY REVIEW REQUIRED — NOT IMPLEMENTED  
**Authority:** Product-owner COMMAND 62-R (2026-11-19)  
**Phase:** Local P2P only; Dropbox/cloud is excluded as Phase 2.  
**Operational PR:** #3052 / `fix/recovery-calendar-device-smoke-2026-10-31`

## 1. Scope and invariants
Local P2P connects an owner's Arvin phone and tablet over a shared local Wi-Fi or hotspot network. The system must work without Internet access, cloud accounts, remote relays or Dropbox.

Each device remains independently usable offline. Its existing local SQLite/Drift database remains the sole durable source of truth. Synchronization is a transport and operation-reconciliation layer; it must not copy database files, create a second Task model, or bypass canonical repositories/stores.

The protocol must preserve stable IDs, Task/Reminder/recurrence/Follow-up separation, Person history, Project/Center/Category relations, Checklist/Occurrence state and unknown forward-compatible fields. A lost connection must never roll back locally committed work.

## 2. Threat model
Protect against:
- An unrelated device on the same LAN attempting to pair or read/write data.
- Spoofed discovery announcements and address changes.
- Passive LAN packet capture and active man-in-the-middle interception.
- Replayed pairing payloads, operation messages or acknowledgements.
- A previously trusted but revoked device reconnecting.
- Duplicate, reordered, truncated or corrupted transfer batches.
- A device going offline during an apply/acknowledgement boundary.
- Clock skew, concurrent edits and deletion/update races.
- Malformed or oversized payloads attempting to corrupt local state.

Out of scope for this phase: protection from a fully compromised/unlocked endpoint, malicious OS/root access, cloud account recovery, Internet relay and cross-owner sharing. These limitations must be visible in the product security documentation.

## 3. Proposed connection and trust flow
This section is a proposal, not an approved cryptographic implementation.

1. Discovery is limited to the local network using Android Network Service Discovery (mDNS/DNS-SD) or an equivalent platform-supported local discovery mechanism. Discovery advertises only a temporary service identifier and protocol version; it never exposes user data.
2. The user explicitly starts pairing on both devices. Pairing is never silently accepted from discovery.
3. Each device has a stable random device ID and a long-term signing identity. Private key material must be non-exportable where Android Keystore support permits; otherwise use a platform-reviewed secure-storage design.
4. The first device displays a short-lived QR payload containing protocol version, device ID, public identity key, ephemeral key material, random nonce and expiry. It contains no private key, user data or reusable bearer credential.
5. The peer validates the signed payload and expiry, performs authenticated ephemeral key agreement, and both devices display the same short authentication string. The user must confirm that the strings match on both screens before either side becomes trusted.
6. The handshake derives fresh session keys. A QR payload is single-use, expires quickly, and is rejected on replay.
7. Subsequent sessions authenticate both device identities and pin the paired public keys. A device in REVOKED state cannot reconnect or submit operations.
8. Data transfer uses an encrypted, integrity-protected channel. TLS 1.3 mutual authentication with pinned device identity is the preferred candidate; the exact Android/Dart key-provider integration and certificate lifecycle must be proven before implementation. If the chosen platform stack cannot keep private keys protected, stop and revise the design rather than falling back to plaintext or an unauthenticated socket.

No custom cryptographic primitive or home-grown key exchange is permitted. A maintained implementation and its security properties must be reviewed before code is written.

## 4. Pairing lifecycle
Device trust states:
- PENDING: pairing handshake started but not mutually confirmed.
- ACTIVE: both sides confirmed the same authentication string and stored peer identity.
- SUSPENDED: temporarily disabled locally.
- REVOKED: permanently untrusted; future sessions and queued inbound data from that identity are rejected.

Pairing records contain device ID, public identity key/fingerprint, protocol version, creation/last-seen timestamps, state and revocation metadata. They do not contain reusable QR tokens or plaintext private keys.

Re-pairing an existing device must require an explicit owner action and must not silently overwrite a trusted identity. Identity-key changes require a clear re-verification flow.

## 5. Durable operation envelope
A sync operation is an immutable, versioned record stored in the existing SQLite database:
- `operation_id`: globally unique random identifier.
- `origin_device_id`: authenticated source device.
- `origin_sequence`: monotonically increasing sequence per source device.
- `entity_type` and stable `entity_id`.
- `operation_kind`: create, field update, relation add/remove, completion, or tombstone.
- `payload_schema_version` and canonical payload.
- `causal_context`: version-vector or equivalent causal frontier.
- `dependency_ids`: operations required before this operation can apply.
- `created_at`: diagnostic/display time only; never the sole conflict-ordering authority.
- Integrity metadata and bounded payload size.

The operation log, per-device acknowledgement cursor, inbox/outbox and unresolved conflict records live in the same canonical SQLite database and use transactional repository/store boundaries. They are not a parallel database.

## 6. Exchange and retry protocol
1. Authenticate the peer before exchanging sync metadata.
2. Exchange protocol compatibility and per-device causal frontiers.
3. Request only missing operation ranges.
4. Transfer bounded, ordered batches with operation IDs and integrity checks.
5. Validate the full batch and all referenced IDs before applying it.
6. Apply each batch transactionally through canonical domain/store pathways.
7. Enforce a unique constraint on `operation_id`; duplicate delivery becomes a safe no-op only after verifying the stored operation identity/content.
8. Persist the applied cursor and acknowledgement in the same successful transaction boundary.
9. If the connection drops before commit, retry the batch. If it drops after commit but before acknowledgement, the repeated batch must be idempotent.
10. Resume from durable cursors after reconnect. Never infer completion merely from a socket close or a local wall-clock timestamp.

## 7. Conflict policy proposal
Last-Write-Wins based only on device clocks is prohibited. Silent overwrite of a committed value is prohibited.

| Domain | Proposed policy |
|---|---|
| Task fields | Merge causally independent field changes. Concurrent writes to the same non-commutative field create a visible conflict for owner resolution. |
| Task deletion vs update | Preserve both facts as a conflict/tombstone state; never silently resurrect or erase the Task. |
| Checklist | Stable item IDs; independent additions merge. Concurrent edits/removal of the same item become an explicit conflict. |
| TaskReminder | Stable reminder IDs; independent reminders merge. Update/delete races are explicit conflicts. |
| Recurrence / Occurrence | Preserve occurrence identity and completion history. Never infer completion from the parent Task's current state. Concurrent edits to the same occurrence require explicit resolution. |
| Follow-up history | Append-only records with stable IDs. Do not rewrite or deduplicate distinct historical records by matching text or timestamps. |
| Person relations | Preserve Person identity and historical Task/Follow-up references. Directory membership changes must not delete historical relation rows. |
| Project/Center/Category/Tag relations | Treat each link/unlink as an identified operation with causal context. Concurrent add/remove of the same link must be resolved deterministically without deleting endpoints. |
| Unknown fields | Preserve unrecognized payload fields byte-for-byte or as lossless structured values through receive/apply/export cycles. |

A version-vector/causal-context design is the preferred candidate. The exact conflict-resolution UI, mergeability rules for every field and tombstone retention/garbage-collection policy remain open and require domain tests before implementation.

## 8. Transaction and data-safety requirements
- Validate protocol version, authenticated origin, payload bounds, schema, entity identity and dependencies before applying.
- Never accept an operation from an unpaired or revoked device.
- Apply related entity and relation changes in one database transaction.
- Do not acknowledge an operation until the local transaction commits.
- Preserve unknown fields and explicit NULL distinctly from absent keys.
- Keep migration receipts and sync cursors durable across app restart.
- Back up sync metadata consistently with the data snapshot; restore must not accidentally reactivate revoked devices.
- No destructive migration is part of the sync feature. Schema additions require a separate reviewed migration and file-backed tests.
- Conflict resolution itself is a new auditable operation, not an unlogged mutation.

## 9. Required validation matrix
Before Local P2P can be accepted:
- Pair phone to tablet and tablet to phone.
- Pair with no Internet, shared Wi-Fi and hotspot.
- Reject invalid, expired and replayed QR payloads.
- Reject a mismatched authentication string and a spoofed peer.
- Verify mutual authentication and encrypted transport.
- Verify revocation blocks an already paired device.
- Sync each direction and repeat the same batch.
- Disconnect before transfer, mid-transfer, after local commit and before acknowledgement.
- Restart both apps and resume from durable cursors.
- Concurrently edit the same Task field and different Task fields.
- Concurrently add/remove Checklist and relation links.
- Race Task deletion with an update.
- Preserve Reminder, recurrence, Occurrence, Follow-up, Person, Project, Center, Category and Tag identities/relations.
- Validate malformed, oversized, reordered and duplicated operations.
- Run SQLite integrity and foreign-key checks after each injected failure.
- Capture evidence from two independent physical Android devices. Emulators alone are not final device acceptance.

## 10. Decisions still required before implementation
- Confirm supported Android API/device matrix and local-network permission behavior.
- Select and review the concrete TLS 1.3/mTLS implementation and Android Keystore bridge.
- Confirm discovery implementation and lifecycle constraints.
- Finalize version-vector structure and conflict UI behavior.
- Define retention and safe garbage collection for operation/tombstone history.
- Define backup/restore behavior when paired devices are restored from different snapshots.
- Define maximum batch/payload sizes, retry/backoff and battery constraints.

**Current disposition:** Local P2P Phase 1 is re-authorized by COMMAND 62-R. This document establishes a threat model and candidate design only. No pairing, networking, cryptographic or sync code has been implemented or accepted. Dropbox/cloud remains Phase 2 and is excluded.
