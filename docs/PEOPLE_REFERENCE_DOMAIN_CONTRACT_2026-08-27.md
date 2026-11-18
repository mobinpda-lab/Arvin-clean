# People / Contacts — persistence-neutral Person reference contract — 2026-08-27

Refs #324 #320 #322 #195.

## Purpose
Advance the merged People/Contacts boundary by one architecture-only step: define the smallest Person identity and Task relationship contract without creating a CRM, a contact database or a second source of truth.

## Contract
- `PersonReference.id` is a stable Arvin-owned identity.
- `PersonReference.displayName` is sufficient for offline display.
- Phone numbers, email addresses and device/provider contact ids are deliberately not identity fields in this slice.
- `TaskPersonContext.taskId` references an existing canonical Task id; it never copies Task payload.
- A Task may have zero or more Person references.
- Person ids must be unique inside one Task relationship.
- The relationship list is immutable after construction.

## Validation
The domain contract rejects blank Person ids, blank display names, blank Task ids and duplicate Person ids. Focused tests also cover ids containing `:` and immutable relation behavior.

## Explicit non-goals
- no JSON codec or migration;
- no Task model/persistence field yet;
- no People/Contacts repository, database or SharedPreferences key;
- no device contacts permission/import;
- no phone/email/provider enrichment;
- no cloud/contact sync;
- no People UI.

## Next safe slice
Only after this contract is merged and validated: audit the additive canonical Task persistence shape and backup compatibility for an optional person-reference field. Keep provider access and UI separate.
