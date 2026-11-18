# Notebook Quick Checklist Templates — 2026-08-27

Refs #270 #264 #268.

## Purpose

Add fast Persian checklist starters to the existing Arvin Notebook without creating a new data type, repository, key, database, migration, or backup format.

## Canonical path

All templates become ordinary notebook `Task` objects immediately after creation:

`Notebook UI -> CanonicalNotebookRepository -> Task.checklist -> TaskStore (arvin.tasks)`

There is no persisted template entity and no template-specific behavior after creation.

## Presets

- `لیست خرید`: title `لیست خرید`; starters `نان`, `شیر`, `میوه`
- `وسایل سفر`: title `وسایل سفر`; starters `مدارک`, `شارژر`, `لباس`
- `کارهای امروز`: title preset, empty checklist, immediate checklist-input focus
- `چک‌لیست جدید`: empty checklist, immediate checklist-input focus

Starter entries use the existing canonical checklist encoding (`[ ] ...` / `[x] ...`).

## Editing contract

Checklist entries, including starter entries, are ordinary items. While editing a note the user can:

- check/uncheck an item;
- rename an item;
- remove an item;
- append new items.

Editing and removal apply to every notebook checklist, not only template-created notes.

## Compatibility

- `Task` schema unchanged.
- `TaskStore` key unchanged.
- Backup/restore representation unchanged.
- Search semantics unchanged because templates are normal titles/checklist text.
- Existing notes remain compatible.
- Cancelling either the mode chooser or template chooser creates nothing.

## Validation

Focused widget coverage proves:

- simple-note creation remains unchanged;
- cancelling either chooser creates no Task;
- shopping/travel starter lists persist through the canonical repository;
- today/blank presets start empty and focus checklist entry;
- starter items can be renamed and removed;
- existing note autosave/check/uncheck behavior remains intact.

Delivery follows Draft Fast CI -> Ready full Build/Release+Debug APK/Device Smoke -> exact-head/current-main lock -> merge -> post-merge main validation.
