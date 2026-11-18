# People / Contacts — Task-facing local UI

Date: 2026-08-27
Issue: #330
Depends on: #327 / PR #329

## Delivered slice

Arvin exposes the canonical `Task.people` relation from the existing Task Timeline through a small Persian RTL page.

The user can:
- see the people linked to the current canonical Task;
- add a local person using only an Arvin-owned id and display name;
- remove one explicit Task ↔ Person relation after confirmation;
- cancel add/remove without writing data.

## Canonical write path

`TaskPeopleService` loads and saves only through the existing `TaskStore` / `arvin.tasks` path. A People edit creates a replacement canonical Task from its JSON envelope with a new immutable `people` relation, preserving unrelated Task fields.

There is no second People persistence key or repository.

## Explicit non-goals

This slice does not add:
- Android Contacts permission;
- device Contacts/provider import;
- phone numbers or email addresses;
- provider ids;
- a CRM/database/address book;
- network or cloud contact sync.

## Verification

Focused tests cover:
- canonical add persistence;
- duplicate id rejection without overwrite;
- immutable relation replacement and remove persistence;
- preservation of unrelated Task state;
- Persian empty/add/remove UI;
- add cancellation with zero write;
- Timeline entry to the Task-facing People page.

User-facing score credit remains gated on exact-head Fast/Build/APK/Device and post-merge main validation.
