# Arvin-clean Multi Device Sync Architecture Specification v13.0

## Status
FINAL DESIGN FREEZE + IMPLEMENTATION CONTRACT

## Repository
mobinpda-lab/Arvin-clean

## Purpose
Design specification for secure multi-device synchronization of Arvin-clean.

Goals:
- Install Arvin on multiple devices.
- Synchronize Task, Reminder, FollowUp and Calendar data.
- Support offline-first operation.
- Prevent data loss.
- Support future cloud providers.

## Architecture Principles
- GitHub is the source of truth for code and changes.
- Cloud is storage only, not the sync engine.
- Local SQLite is the operational source.
- Remote data must be validated before entering Domain.
- Sync logic must remain independent from Dropbox.

## Core Components

Sync Coordinator

- Local Sync Engine
- Change Log
- Sync Queue
- Conflict Engine
- Cloud Provider Adapter
- Encryption Service

## Version Model

Three independent versions are maintained:

1. Entity Version
2. Operation Version
3. Protocol Version

They must never be merged into one value.

## Database Sync Tables

Required tables:

- change_log
- sync_queue
- devices
- conflicts
- cursors
- audit_log
- transactions

## Sync Flow

Remote Data

-> Validation

-> Sync Model

-> Conflict Resolution

-> Domain Entity

-> SQLite

## Multi Device Model

Each device has:

- deviceId
- platform
- lastSeen
- trustState

Trust states:

PENDING
ACTIVE
SUSPENDED
REVOKED

## Conflict Resolution

Priority:

1. User Decision
2. Explicit Rule
3. Valid Latest Version
4. Device Priority

## Cloud Strategy

Initial provider:

Dropbox

Future providers:

- Google Drive
- Other Cloud Providers

Dropbox responsibilities:

- Store
- Retrieve
- Version History

Arvin owns synchronization logic.

## Security

Required:

- OAuth 2.0 PKCE
- Secure token storage
- No secrets in source code
- AES-256-GCM encryption support

## Recovery

Recovery model:

Snapshot + Journal Replay

Failure handling:

Freeze Sync
-> Validate Database
-> Restore Snapshot
-> Replay Journal
-> Resume

## Development Waves

Sync-0 Contracts
Sync-1 SQLite Infrastructure
Sync-2 Change Queue
Sync-3 Sync Engine
Sync-4 Conflict Engine
Sync-5 Dropbox Adapter
Sync-6 Encryption
Sync-7 Multi Device Simulation
Sync-8 Production Rollout

## Quality Gate

Before merge:

- flutter analyze
- flutter test
- flutter build apk --release
- Security review
- Sync simulation
- Documentation update

## Definition of Done

Production ready when:

- Multiple devices synchronize correctly.
- Offline changes are preserved.
- Conflicts are visible and resolved.
- Recovery is tested.
- Migration is tested.
- Cloud provider can be replaced.

Version: 13.0
Status: FINAL DESIGN FREEZE
