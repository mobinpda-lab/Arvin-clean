# Arvin Task Creation — Visual Specification

**Status:** Approved design direction; runtime visual acceptance pending.  
**Decision:** [ADR-2026-10-11-ARVIN-TASK-FORM](../ADR/ADR-2026-10-11-ARVIN-TASK-FORM.md)  
**Tracking:** [Issue #2593](https://github.com/mobinpda-lab/Arvin-clean/issues/2593)

## Palette
| Token | Value | Use |
|---|---|---|
| Primary | `#4A4CAB` | Primary action, selected states, key time display |
| Light Primary | `#E9EAFF` | Subtle selected surfaces and supporting emphasis |
| Background | `#F8F8FB` | Main form background |
| Card | `#FDFDFE` | Section surfaces |
| Text | `#232433` | Main text and input values |
| Secondary | `#80829C` | Secondary labels and supporting metadata |

## Quick Add hierarchy
- Keep Quick Add compact and visibly different in density—not in data model—from the Full Editor.
- Title is the primary control, with a clearly placed importance affordance.
- Date, time, repeat and reminder are compact optional controls, visually grouped without competing with the title.
- «جزئیات بیشتر» is a secondary, discoverable transition to the Full Editor; «ثبت» is the primary action.
- Selected date/time and enabled repeat/reminder must be visibly summarized in Persian.
- Avoid placing all professional fields in the initial compact view.

## Full Editor hierarchy and layout
- Task title is the most prominent field.
- Related inputs are grouped into calm cards/sections; avoid excessive nested cards.
- Use consistent spacing, radius, icon size and touch targets.
- Labels and input values must remain readable, particularly on tablets and constrained widths.
- All layouts must be RTL-native; icon placement and trailing/leading actions must follow RTL semantics.
- «ذخیره» is the primary action; «لغو» is secondary.
- Avoid decorative colors per field. Use color for hierarchy and state, not decoration.
- Advanced fields can collapse progressively, but users must be able to find them and existing values must remain visible when editing.
- Responsive behavior must not clip Repeat, priority, date/time, checklist controls, selectors, or bottom actions.

## Runtime visual evidence gate
The owner supplied a textual design contract but no actual approved reference image is attached to this record. Therefore, no pixel-match claim is made. Before visual acceptance:
1. Capture actual Quick Add, Full Editor Create and Full Editor Edit screenshots on representative phone and tablet viewports.
2. Compare with an owner-approved reference image when available.
3. Review RTL, contrast, keyboard overlap, scrolling, selected/disabled/error states and bottom actions.
4. Link screenshot artifacts and review result in #2593 and its implementation PR.
5. Record real-device evidence separately from emulator screenshots.
