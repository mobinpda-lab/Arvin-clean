# People / Contacts boundary audit — 2026-08-27

Refs #320 #195 and Product Extension Roadmap capability #6.

## Decision
People/Contacts starts as an optional relationship/context for the existing canonical Item/Task. It does **not** start as a CRM, contact database, or second source of truth.

## Current repository finding
A repository/code search on the current main baseline found no existing Person/Contact domain type or dedicated People/Contacts storage/repository to extend. The roadmap therefore remains the authority for the first boundary: define the relation before changing persistence.

## Minimum future relation contract
A future implementation may attach zero or more lightweight person references to a canonical Task/Item. A reference must have a stable Arvin-owned identity and a display label sufficient for offline rendering. External-provider identifiers, phone numbers, email addresses and device-contact metadata are optional enrichments and must not become the identity of the canonical Item itself.

The relation belongs to the existing Item/Task data path. If persistence is later approved, it must be additive/backward-compatible in the existing canonical envelope and must not create a second Task/Note/FollowUp store.

## Explicitly out of scope for this audit
- standalone CRM records or pipeline;
- `arvin.people` / `arvin.contacts` storage keys;
- People/Contact repository or database;
- Android/iOS contacts permission or provider import;
- cloud/contact sync;
- phone/email lookup or network enrichment;
- UI screens;
- migration or production model changes.

## Migration/backward compatibility expectations
Existing Task JSON must continue to decode unchanged when no person relationship exists. Any future relationship field must be optional and lossless for older data. Backup/restore and sync semantics must be audited before the relationship is persisted.

## Executable guard
The companion boundary test scans production `lib/` source and fails if this audit slice introduces forbidden standalone People/Contacts persistence keys or repository classes. The guard is intentionally narrow and may only be changed by a later explicitly approved architecture slice.

## Next accepted step
After this audit is merged and the project foundation allows it, define a small persistence-neutral Person reference value object plus pure relation tests. Do not add permissions, provider access, CRM storage or UI in the same slice.
