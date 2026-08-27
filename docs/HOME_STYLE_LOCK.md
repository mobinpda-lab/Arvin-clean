# Arvin Home — Approved Style Lock

Status: **BINDING UI CONTRACT**
Approved reference: user-supplied Home concept, 2026-08-27.

This document is the canonical visual contract for the Arvin Home screen. Product work, refactors, AI coding, dependency updates and Material migrations must not replace this direction with a generic dashboard or raw/default Material layout.

## 1. Home composition — locked

Top-to-bottom order:
1. Safe-area / system status bar.
2. Centered `بسم الله الرحمن الرحیم` in a subtle rounded, low-contrast capsule/surface.
3. Centered product title directly below it: `مدیریت کارها و پیگیری آروین`.
4. Notification bell on the physical left and hamburger/navigation menu on the physical right.
5. Full-width rounded search field.
6. Four equal summary cards in one row.
7. `کارهای من` section heading with a compact secondary action such as `مشاهده همه` when useful.
8. Rounded task cards with clear title, optional project/category metadata, due date/time and status chip.
9. Purple primary floating add button in the lower-right area above bottom navigation.
10. Persistent white bottom navigation in the approved minimal style.

The Bismillah and app title are a single visual identity block. They must not collide with the status bar, be pushed into a generic AppBar title, or be reordered around utility icons.

## 2. Home header — locked

- Bismillah: centered above the app title, light visual weight, small rounded surface, generous whitespace.
- Product title: centered, stronger weight, dark navy/charcoal text.
- Notification bell: left utility action; reserved for reminders/notifications.
- Hamburger: right navigation action; drawer/menu entry point.
- Backup is **not** a Home header action.
- Quick-capture and selection utilities must not displace the approved header identity; expose them through the approved Home action hierarchy or menu.

## 3. Core palette — locked tokens

The approved reference is a bright, soft, indigo-led interface. Baseline tokens:

| Token | Target | Use |
|---|---|---|
| `home.primary` | `#4A4CAB` | Primary actions, active nav, selected filters, key icons |
| `home.primarySoft` | `#E9EAFF` | Selected/soft indigo surfaces |
| `home.background` | `#F8F8FB` | Main page background |
| `home.surface` | `#FDFDFE` | Cards, search, bottom bar |
| `home.border` | `#E5E7ED` | Hairline/card/input boundaries |
| `home.textPrimary` | `#232433` | Main titles/content |
| `home.textSecondary` | `#80829C` | Metadata, hints, dates |
| `home.success` | `#409B51` | Completed state |
| `home.successSoft` | `#EAF7ED` | Completed chip/surface |
| `home.warning` | `#DB8B23` | Due today / waiting attention |
| `home.warningSoft` | `#FDF1E9` | Warning/waiting chip surface |
| `home.info` | `#2F80ED` | In-progress / informational state |
| `home.infoSoft` | `#EAF4FF` | In-progress chip surface |
| `home.danger` | `#FF5F52` | Destructive/urgent state only |
| `home.dangerSoft` | `#FFF0EE` | Urgent/destructive chip surface |

Do not introduce saturated rainbow colors across ordinary controls. Status colors are accents; indigo remains the product identity.

## 4. Summary cards — locked behavior + visual contract

One row of four equal cards. Labels map to live filters, not decorative counters:
- `کل` / `همه کارها`: all current non-trashed, non-archived work.
- `فعال` / `در حال انجام`: incomplete active work.
- `انجام‌شده` / `تکمیل شده`: completed work.
- `عقب‌افتاده` or approved due-today equivalent: overdue/due attention according to the product rule.

Each card:
- is fully tappable;
- changes the task list immediately;
- shows selected state visibly using indigo outline/soft surface;
- keeps count, icon and label aligned vertically;
- uses soft shadow, 14–18 px corner radius and no heavy border.

Reference accent intent:
- all/current: indigo;
- active/in progress: blue;
- completed: green;
- due/overdue: orange (danger red reserved for destructive/critical urgency).

## 5. Search — locked

- Full-width rounded field directly below header.
- Soft white/near-white surface.
- Search icon inside the field.
- Persian hint text; no dense Material underline-only field.
- Searches canonical Task/Item data and combines correctly with the selected summary filter.

## 6. Task cards — locked

- White/near-white rounded surface on the soft page background.
- Low/elegant shadow; no harsh elevation.
- Primary title is the strongest element.
- Optional project/category line appears below in indigo/secondary styling.
- Jalali due date and, when present, time are visible as metadata.
- Status/priority chips are pastel and compact.
- Completion control remains easy to hit without dominating the card.
- Swipe actions remain functional but must not distort the resting card appearance.

## 7. Add action + bottom navigation — locked

- Primary add control: circular/compact floating button using `home.primary` with white plus icon.
- Place it above the bottom navigation with safe spacing.
- Bottom navigation: white surface, subtle top boundary/shadow, gray inactive icons and indigo active icon/label.
- Approved destinations should converge on the product navigation model (`خانه`, work/projects/calendar/more as finalized); temporary debug or duplicate destinations are forbidden.

## 8. Geometry and visual density

- Corner radii: generally 14–18 px for cards/fields; floating add is circular.
- Page horizontal padding target: 16–20 px.
- Component gaps target: 8–16 px depending on hierarchy.
- Shadows: low opacity, large blur, minimal vertical offset.
- Touch targets: minimum practical mobile target ~44–48 dp.
- Avoid cramped stat cards or header collisions on smaller Android devices.

## 9. Typography

- Persian/RTL first.
- Project-approved Persian font (Vazirmatn/IRANSans according to the canonical typography gate) only; no random fallback styling.
- App title: bold/semibold.
- Section title: semibold.
- Task title: semibold.
- Metadata: regular, smaller, secondary color.
- Bismillah: lighter/smaller than the product title, but clearly legible.

## 10. Prohibited drift

The following are explicitly not acceptable without a new user-approved UI decision:
- generic Material dashboard replacing the approved composition;
- moving Bismillah into the status bar area or removing its identity surface;
- placing Backup in the Home header;
- summary cards that are display-only/non-interactive;
- Gregorian date UI as the primary Iran-facing date picker;
- heavy gray surfaces, black-heavy cards or high-contrast shadows;
- random accent colors on ordinary controls;
- removing bottom navigation solely because a drawer exists;
- replacing the approved Home with an AI-generated redesign because it is easier to implement.

## 11. Validation gate

A Home-changing PR is not UI-complete until:
1. widget tests verify the four summary cards are tappable and filter correctly;
2. Home header regression verifies Bismillah/product-title order and safe placement;
3. Home contains no Backup header shortcut;
4. Jalali date metadata remains Persian-first;
5. the layout is checked on a short Android viewport and a normal phone viewport;
6. exact-head CI passes;
7. a real-device screenshot is compared against the approved Home reference before claiming final visual acceptance.

Functional green CI alone is **not** sufficient evidence that Home matches this Style Lock.
