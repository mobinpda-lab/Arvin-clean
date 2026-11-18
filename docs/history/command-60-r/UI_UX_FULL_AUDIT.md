# UI/UX FULL AUDIT — INITIAL INVENTORY
**Status:** IN PROGRESS — not exhaustive yet.

## Known page families to enumerate against source
- Home / Dashboard and five-filter surfaces
- Calendar: day, week, month, agenda and event details
- Task: list, create, edit, details, checklist, occurrence and recurrence
- Reminder and reminder scheduling
- Project and Center management/details
- Category and Tag management/selectors
- People directory and person details
- Follow-up list, create/edit and details
- Notebook / notes, note editor and taxonomy selectors
- Quick Add / quick capture
- Search, filters, sorting and selection sheets
- Reports and report filters
- Settings and appearance/typography
- Backup, restore and recovery/confirmation surfaces
- Navigation drawer, bottom navigation, dialogs, sheets, menus, empty/error/loading states, widgets and notification/lock-screen surfaces

## Confirmed known regressions from PR #1901
Home visual mismatch/clipped cards/missing filters; Calendar integration actions/settings missing; font picker and font-size control absent; Project/category/tag catalog management and immediate refresh issues; Notebook taxonomy mismatch and non-working tag flow; Quick Add date/time selectors blank; Task Edit date/time alignment; Checklist enable/disable issue; Date/Time picker clock-dial appearance regression.

## Audit dimensions per page
Current implementation, visual hierarchy, interaction, Persian RTL, typography, contrast, responsive behavior, repeated components, empty/error/loading states, accessibility, persistence, feature completeness, screenshot evidence.

## Limitation
This first pass lists known product surfaces from the command and live regression record. It does not yet claim every source route/widget has been enumerated. Lane B must perform a complete source-tree route scan and add discovered pages.
