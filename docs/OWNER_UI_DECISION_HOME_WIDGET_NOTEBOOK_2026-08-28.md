# Arvin Owner UI Decision — Home, Reminder Widget, Simple Note / To-do

Status: **BINDING OWNER-APPROVED PRODUCT/UI DECISION**  
Date: 2026-08-28

This decision records the owner-approved visual/product direction from the current design review. It is more specific than a generic Material implementation and must be read together with `docs/HOME_STYLE_LOCK.md`, `docs/ARVIN_UI_CANONICAL.md`, Issue #357 and `docs/PRODUCT_CONTRACT_MATRIX.md`.

## 1. Final Home direction

The owner-supplied Arvin dashboard reference is the **primary final Home visual target**.

Microsoft To Do is **not** the Home layout authority for Arvin. It may be used only as secondary inspiration for small interaction details, spacing discipline or list simplicity when those details do not conflict with the Arvin Home contract.

### Home structure that must be preserved

- protected identity block at the top:
  - `بسم الله الرحمن الرحیم`
  - `مدیریت کارها و پیگیری آروین`
- notification action on the physical left and navigation/menu on the physical right
- full-width rounded search field
- four equal summary/stat cards in one row
- `کارهای من` list section
- rounded task cards with clear status/category/date metadata
- compact **circular** primary `+` action above the bottom navigation
- persistent bottom navigation
- Persian RTL-first alignment throughout

### Color decision

Color is part of the accepted Home design, not an implementation detail.

The indigo-led palette in `docs/HOME_STYLE_LOCK.md` is binding:
- primary indigo identity and selected state
- near-white / soft light surfaces
- dark navy/charcoal primary text
- muted gray secondary text
- blue for active/in-progress accents
- green for completed accents
- orange for due/attention accents
- red reserved for destructive/critical urgency

Do not replace this direction with generic gray Material surfaces or a Microsoft To Do color/layout clone.

### Visual completion rule

Home is not visually complete until a real-device screenshot is compared against the owner-supplied Arvin dashboard reference and the main hierarchy, spacing, circular `+`, card treatment and color language agree.

## 2. Reminder widget / notification card contract

The owner-supplied reminder reference defines the desired card hierarchy for reminder/widget presentation.

### Collapsed state

- rounded soft/light card
- circular reminder icon on the physical right
- type label `یادآور`
- reminder content/title below it, stronger than the type label
- time displayed as important accent metadata when a time exists
- clear expand affordance

Example hierarchy:

`یادآور`  → type  
`ناهار منزل` → main content  
`۱۲:۰۰` → time metadata

### Expanded state

When expanded, preserve the same header and reveal:
- date (`امروز` or appropriate Persian/Jalali label)
- time when timed
- approved actions:
  - `انجام شد`
  - `تعویق`
  - `ویرایش`
  - `تبدیل به کار`

### All-day state

For an all-day reminder:
- show `تمام‌روز` instead of inventing a time
- do not render a fabricated clock value
- the visual accent may use the approved green/teal all-day treatment while remaining consistent with the Arvin palette

### Widget consistency

Home-screen/keyguard/widget and in-app reminder cards should share the same information hierarchy as platform constraints allow. Platform limitations may simplify layout, but may not change semantics or fabricate date/time.

## 3. Simple Note and To-do editor direction

Simple Note and To-do/checklist should use a calm, content-first editor inspired by the supplied list/editor reference and by the proven notebook/category workflow seen in Joplin.

This is a behavioral inspiration, not permission to copy Joplin code or create a second Arvin storage architecture.

### Required simple-note behavior

- simple uncluttered note surface
- clear read/view state
- explicit `ویرایش` action
- category/notebook selector visible and easy to reach
- selecting a category immediately moves/assigns the note to that category
- the selected category is persisted immediately through the canonical Task path
- no extra confirm step is required solely to apply category selection unless needed to prevent data loss during another unsaved edit

### Required To-do/checklist behavior

- distinct To-do/checklist creation/editor mode from Simple Note
- same category selection behavior as notes
- explicit edit mode/action where appropriate
- checklist items remain canonical `Task.checklist` data

### Canonical category implementation

Arvin already has `Task.category`. The category/notebook UX must reuse that canonical field and existing `TaskStore/arvin.tasks` persistence.

Selecting a new category means updating the same Task's `category`; it must not:
- clone the note into another store
- create `arvin.simple_notes`
- create a parallel Notebook database
- duplicate the note while leaving the original behind

A category change is therefore a canonical move/reassignment of the same Item/Task identity.

### Joplin reference rule

Joplin may be studied for notebook/category UX, searchability and editing patterns. Any code reuse must be separately reviewed for license compatibility, architecture fit and necessity. The default implementation rule for Arvin is to reproduce the approved behavior using Arvin's existing Flutter/Task architecture rather than importing another application's architecture.

## 4. Relationship to existing contracts

This decision strengthens, not replaces:
- `docs/HOME_STYLE_LOCK.md`
- `docs/ARVIN_UI_CANONICAL.md`
- `docs/SIMPLE_NOTEBOOK_PRODUCT_CONTRACT.md`
- `docs/PRODUCT_CONTRACT_MATRIX.md`
- Issue #357 for follow-up-enabled Task detail and add-FollowUp flow

Where an older screenshot, guide page, historical document or generic Material implementation conflicts with this decision, the newer owner-approved decision wins and the stale surface remains **Partial** until reconciled.

## 5. Acceptance gates

A relevant feature may not be marked Done until all applicable checks pass:

1. automated/widget regression for behavior;
2. exact-head CI;
3. short + normal Android viewport checks;
4. real-device screenshot comparison for Home/widget visual work;
5. category move persistence test proving the same Task identity changes `category` without duplicate storage;
6. user guide/help content updated if labels, navigation or visuals change;
7. Product Contract Matrix row updated with current status and owning Issue/PR.
