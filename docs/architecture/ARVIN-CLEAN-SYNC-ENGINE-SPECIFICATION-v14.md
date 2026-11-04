# Arvin-clean Multi-Device Sync Architecture Specification v14.0

## Status
PRODUCT DIRECTION APPROVED — PHASE 1 LOCAL P2P
IMPLEMENTATION STATUS: NOT VERIFIED

## Repository and Governance
- Repository: mobinpda-lab/Arvin-clean
- Active implementation branch: fix/recovery-calendar-device-smoke-2026-10-31
- This document records product scope and architecture constraints; it does not claim that Local P2P has been implemented or tested.
- PR #3052 remains OPEN / DRAFT / UNMERGED. No merge, release, or main-branch change is authorized by this document.

## Product Decision — 2026-11-04
The multi-device sync capability is split into two separate phases.
- Phase 1 — Local P2P Sync: the current and highest-priority product requirement.
- Phase 2 — Cloud / Dropbox Sync: a separate future extension, archived from the earlier v13 proposal until Phase 1 has matured.
Phase 2 must not become a dependency, prerequisite, or hidden service for Phase 1.

## Phase 1 — Local P2P Sync (Current Priority)

### Product Goal
Synchronize Arvin data directly between a phone and a tablet when both devices are connected to the same local network.
Supported network situations include:
- A shared home or office Wi-Fi router.
- A direct hotspot network where both devices can communicate locally.

### Explicit Non-Goals
Phase 1 must work without:
- Internet connectivity.
- A cloud account or user sign-in.
- Dropbox or another cloud provider.
- A cloud relay, remote server, or third-party sync intermediary.

Local SQLite remains the operational source on each device. Network access is a transport between trusted Arvin devices, not a replacement for local persistence.

### Pairing and Device Trust
- First-time pairing is initiated by a user on the devices.
- The approved pairing UX is a dedicated one-time code or QR code.
- Pairing must authenticate the intended peer and establish a trusted-device relationship before any user data is exchanged.
- A pairing code/QR must not act as a reusable long-term secret.
- Device trust lifecycle states are: PENDING, ACTIVE, SUSPENDED, REVOKED.
- A user must be able to revoke a paired device; revoked devices must no longer exchange data.
- Pairing payload format, key agreement, key storage and exact cryptographic protocol remain NOT DECIDED and require a security-reviewed implementation contract before coding.

### Discovery and Automatic Synchronization
- After successful pairing, devices should discover one another when they become reachable on a shared local network.
- Two-way synchronization should start automatically in the background when a trusted paired device is available.
- Temporary network loss must pause transfer safely; it must not discard locally committed changes.
- Reconnection must resume from durable synchronization state and must be idempotent.
- Discovery technology, transport protocol, port allocation, retry/backoff policy and Android background execution mechanism are NOT DECIDED. They must be selected based on Android platform constraints and tested on physical devices; do not assume a specific protocol in advance.

### Data and Persistence Boundaries
- Phase 1 targets Arvin's canonical Task, independent TaskReminder, FollowUp history and approved Arvin calendar data.
- Each device continues to read and write through the existing canonical application/domain and repository/store boundaries.
- SQLite/Drift remains local persistence; do not introduce a parallel database, a database-file-copy sync design, or a second model of Task/Reminder/FollowUp.
- Remote payloads must be validated before they can affect local Domain state.
- Preserve existing data and migration compatibility. No destructive schema migration is permitted as part of sync enablement.
- Task due date, independent TaskReminder, recurrence and historical FollowUp remain distinct concepts and must not be conflated by synchronization.

### Change Tracking and Consistency
The implementation requires durable change tracking and a retryable outbound/inbound process. The following are design requirements, not claims that the tables or algorithms already exist:
- Record locally committed changes before attempting network delivery.
- Identify each operation uniquely and make applying the same operation more than once safe.
- Track per-device synchronization progress without assuming that wall-clock timestamps provide a globally reliable order.
- Separate entity version, operation version and protocol version.
- Apply a received change transactionally and advance synchronization progress only after the local write succeeds.
- Define deletion/tombstone propagation and safe retention before implementation.
- Exact schema, operation envelope, acknowledgement protocol and retention/garbage-collection rules remain NOT DECIDED.

### Conflict Handling
- Conflicts must not silently discard either device's locally committed work.
- User decision takes precedence where automatic resolution is unsafe.
- Deterministic domain-specific rules may resolve only cases whose semantics are explicitly defined and tested.
- Wall-clock last-write-wins alone is not an accepted general conflict strategy.
- Conflict representation, causal/version metadata and per-entity resolution rules remain NOT DECIDED pending a dedicated design and test matrix.

### Security and Privacy
- Only explicitly paired and currently trusted devices may exchange Arvin data.
- Pairing and data transfer must use an authenticated, encrypted channel.
- Secrets and long-lived device credentials must be stored using platform-secure storage and must never be committed to source control.
- The protocol must resist unauthorized peers, replayed operations, tampered payloads and accidental cross-account/device association.
- Exact cipher suite, key derivation, key rotation, recovery and device-revocation mechanics require a separate security review before implementation. No cryptographic algorithm is assumed by this product-scope document.

### Recovery and Reliability
- A device must retain locally committed changes while offline or disconnected.
- Interrupted transfers must be resumable and safe to retry.
- A failed or invalid remote operation must not corrupt the local database or advance the durable cursor.
- Recovery must validate local persistence and replay only verified, idempotent operations.
- Snapshot format, journal replay protocol, backup integration and recovery UX remain NOT DECIDED.

### Phase 1 Development Waves
- P2P-0: Product and protocol contracts; threat model; data ownership.
- P2P-1: Local network discovery and secure first-time pairing.
- P2P-2: Durable local change journal and operation identity.
- P2P-3: Authenticated two-way transfer and acknowledgement/resume.
- P2P-4: Conflict detection, visibility and domain-specific resolution.
- P2P-5: Revocation, recovery, deletion propagation and retention.
- P2P-6: Multi-device simulation, network interruption and physical-device tests.
- P2P-7: Controlled production rollout after all acceptance gates pass.

## Phase 2 — Cloud / Dropbox Sync (Future, Archived)
- The earlier v13 Dropbox proposal is retained separately as an archived Phase 2 design.
- Phase 2 is deferred until Local P2P has matured and passed its product, security, reliability and physical-device acceptance gates.
- Dropbox or any cloud provider must remain an optional future adapter; Phase 1 must not depend on it.
- OAuth/account linking, remote storage layout, provider cursors, cloud conflict coordination, encryption/key recovery and provider replacement require a separate future specification and owner authorization.
- The v13 document is historical Phase 2 material, not the current Phase 1 implementation contract.

## Quality and Acceptance Gates
Before Phase 1 can be considered production-ready:
- Pair two real Android devices using the approved code/QR flow.
- Complete initial two-way synchronization over a shared local network with internet unavailable.
- Verify automatic synchronization after trusted devices reconnect to the shared network.
- Verify offline changes survive app restarts, process death and network interruption.
- Verify duplicate delivery is idempotent and conflicting edits are visible/resolved without silent loss.
- Verify device revocation prevents further exchange.
- Verify Task, TaskReminder, FollowUp and calendar data retain their distinct canonical semantics.
- Verify no destructive migration or parallel storage path is introduced.
- Run flutter analyze, flutter test, relevant Android build checks, security review, multi-device simulation and physical-device acceptance on one exact candidate SHA.

## Definition of Done
Phase 1 is complete only when the above Local P2P behaviors are implemented and evidenced on exact-SHA CI and physical Android devices. A successful build alone is not proof of multi-device synchronization.
Phase 2 remains deferred and is not part of Phase 1 acceptance.

Version: 14.0
Status: PHASE 1 LOCAL P2P — PRODUCT DIRECTION APPROVED; IMPLEMENTATION NOT VERIFIED


## OWNER DECISION — P2P-0 LOCAL PAIRING AND CONFLICT POLICY (2026-11-04)

The product owner has approved the following Phase 1 decisions. These decisions refine the Local P2P product contract; they do not claim that discovery, pairing, transport or synchronization is implemented.

### Direct local pairing
- Pairing is performed directly between Arvin devices on the same local Wi-Fi network or a phone hotspot.
- The user may establish the pairing by scanning a QR Code or entering a six-digit PIN.
- Pairing and subsequent Phase 1 synchronization must not require an external server, Internet access, cloud account or Dropbox.
- The QR/PIN is a local pairing bootstrap, not by itself proof of a complete authenticated or encrypted transport.

### Conflict and deletion policy
- The approved conflict-resolution policy is Last-Write-Wins (LWW), comparing the last-edit timestamp of competing versions.
- Deletions must be represented and propagated as durable tombstone records; a deletion must not be silently resurrected by an older copy received from another peer.
- Tombstones are synchronization data, not permission for immediate physical deletion. Safe purge/retention conditions must be specified before implementation.

### Decisions still required before implementation
- Timestamp trust, clock skew handling and deterministic tie-breaking when timestamps are equal are not yet specified.
- QR payload contents, PIN expiry, retry/rate limits and pairing-session lifecycle remain to be specified.
- Cryptographic identity, key agreement, authenticated encryption, key storage/rotation and device revocation protocol remain **NOT DECIDED**; do not select or imply a cryptographic suite without a separate security review and owner approval.
- Operation IDs, idempotency, acknowledgements, retry/resume, offline queue durability and tombstone retention/purge conditions remain subject to the P2P-0 contract.
- Task, TaskReminder, recurrence, FollowUp and calendar ownership semantics remain independent and must be preserved.

**Status:** OWNER-APPROVED PRODUCT DECISIONS RECORDED / TECHNICAL SECURITY AND RELIABILITY CONTRACT INCOMPLETE / IMPLEMENTATION NOT VERIFIED.
