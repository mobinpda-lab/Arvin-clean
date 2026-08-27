# Notebook creation modes — 2026-08-27

## Decision
Arvin notebook creation offers two lightweight entry modes:

- `یادداشت ساده`
- `چک‌لیست`

Both modes create the same canonical `Task`-backed notebook item. There is no new entity, storage key, database, or backup format.

## Why
Shopping lists, travel packing lists, daily to-dos, and similar list-shaped notes are all the same product concept: a notebook item using the existing `Task.checklist` field.

Creating a separate ShoppingList/List model would duplicate persistence, search, backup, and migration behavior, so it is explicitly rejected.

## UX contract
- Tapping `یادداشت جدید` opens the mode chooser.
- Cancel creates nothing.
- `یادداشت ساده` preserves the existing editor behavior.
- `چک‌لیست` creates the same canonical notebook item with the initial title `چک‌لیست جدید` and focuses the checklist input after the editor opens.
- Existing notes remain unchanged and can still mix description text and checklist items.

## Persistence
`CanonicalNotebookRepository` remains the only notebook boundary and still writes only through the canonical TaskStore. `Task.checklist` remains the only checklist persistence path.

## Validation
Widget coverage must prove:
1. cancelling the chooser creates nothing;
2. simple-note mode preserves the current note path;
3. checklist mode focuses the checklist input and persists an item;
4. existing read/edit/toggle/autosave behavior remains intact.

## Fast follow-up
Quick templates such as `لیست خرید`, `وسایل سفر`, and `کارهای امروز` may be added later as presets over this same checklist path. They must not introduce new persistence models.
