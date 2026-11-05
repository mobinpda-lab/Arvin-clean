# Arvin Calendar — Canonical UI/UX Specification
**Decision date:** 2026-11-05 — ۱۴۰۵/۰۸/۱۴  
**Authority:** Product-owner approved conversation decisions, including the final placement corrections made on 2026-11-05.  
**Status:** APPROVED — CANONICAL DESIGN REFERENCE  
**Scope:** Calendar screen presentation and interaction contract only. This document does not authorize runtime implementation, data-model changes, provider changes, schema changes, or release.
## 1. Design authority and scope
This file is the canonical reference for the approved Arvin Calendar screen UI/UX. It supersedes conflicting older Calendar header/layout proposals only within the screen areas explicitly defined here. Existing calendar data, provider, synchronization, event identity, and persistence contracts remain unchanged unless separately approved.
## 2. Header composition and sacred phrase
The header has three balanced RTL zones:
- **Center:** the exact phrase «أُفَوِّضُ أَمْرِي إِلَى اللَّهِ», visually centered and balanced in prominence with the Home screen's Bismillah treatment. It replaces the Calendar app-title/header label.
- **Right:** calendar search icon.
- **Left:** the full Persian current-date pill and the «برو به تاریخ» date-picker icon, kept together as the date/navigation cluster.
The help button is removed. Do not reintroduce a help icon or a redundant Calendar title.
## 3. Header date pill — Today shortcut
The full Persian date is displayed in the top-left header cluster. It is the Today shortcut: tapping the date pill returns the calendar selection to the current day. Its visual size must harmonize with the calendar typography and it belongs at the highest/topmost calendar area on the left, not displaced into the content-filter row.
## 4. Go to Date control
The «برو به تاریخ» icon is adjacent to the full-date pill in the top-left cluster and opens date selection/navigation. Keep it distinct from the Today shortcut: the date pill returns to today; the picker icon lets the user choose a date. The final approved correction keeps the date and picker adjacent in the corrected top-left arrangement; do not swap their roles.
## 5. Selected-date display bar
A separate, prominent selected-date display appears above the calendar navigation/grid area:
- **Center:** selected Jalali date, bold and visually dominant.
- **Right:** corresponding Gregorian date.
- **Left:** corresponding Hijri lunar date.
This is the selected calendar date, not a duplicate of the Today shortcut. The selected Jalali date is also reflected in the calendar's month/date heading.
## 6. View-mode control row
Place exactly four view segments **above the calendar grid**:
«روزانه» | «هفتگی» | «ماهانه» | «سالانه»
The default selected mode is «هفتگی». These are mutually exclusive calendar presentation modes, not content filters.
## 7. Calendar grid structure
The grid is a seven-column Persian-week layout, Saturday through Friday. In RTL visual order, Saturday begins at the right and Friday ends at the left. The grid presents the calendar dates for the active view and selected period.
## 8. Triple-calendar date cells
Each date cell displays three corresponding calendar values:
1. Jalali/Solar Hijri — primary, bold, largest.
2. Gregorian — secondary, smaller.
3. Hijri lunar — secondary, smaller.
The three values must remain visually distinguishable and aligned within the same date cell. Do not let Gregorian or Hijri lunar values compete visually with the Jalali date.
## 9. Date-cell selection and date identity
The selected date is represented consistently between the selected-date display bar and the grid. A selected day must remain identifiable independently of the Today shortcut. Detailed selection colors, animation, and multi-date range-selection behavior are not specified by this approval and must not be invented as locked requirements.
## 10. Content-filter row placement and options
Place the five content filters **strictly below the calendar grid and above the agenda/list**. Their exact order is:
«همه» → «تقویم آروین» → «تقویم گوشی» → «یادآورها» → «انجام‌نشده»
These five chips filter the content shown in the agenda. They are not view modes and must never be moved above the grid or merged into the four-segment view-mode row.
## 11. Agenda/list content
Below the content-filter row, show the agenda for the selected day. It contains the applicable task, event, and reminder cards, subject to the selected content category. The agenda is date-scoped and must not visually overlap or stack cards on top of one another.
## 12. Non-overlapping card and content separation
Task, calendar-event, and reminder entries remain individually readable, with separate card boundaries and no overlap. Filtering must not cause cards to cover one another or obscure the selected date, grid, or filter row. Detailed card field inventory, ordering within a mixed agenda, and empty-state copy are not defined by this approval; retain existing canonical data semantics and do not fabricate new fields.
## 13. Calendar search
The top-right search icon opens the calendar's dynamic search experience. It replaces any prior header search placement and must remain in the top-right header zone. Exact search scope, matching rules, result ranking, and empty-state wording are not specified in this design decision and require a separate product decision if they are to change.
## 14. Hijri adjustment, RTL and implementation boundary
Calendar settings provide the Hijri lunar-date adjustment choices:
- +1 day
- −1 day
- Official Iranian Calendar Match
The adjustment affects the displayed Hijri lunar date alignment only; it must not mutate Jalali/Gregorian source dates, task due dates, reminders, event identity, or provider data. Preserve Persian RTL presentation and the established Vazirmatn application typography. This is a documentation-only registration: no runtime implementation or test changes are authorized by this document.
## Non-negotiable vertical hierarchy
Header → selected-date display → view-mode segments → calendar grid → content-filter chips → selected-day agenda.  
The view-mode row belongs above the grid; the five content filters belong below the grid. These rows are architecturally and visually separate.
## Acceptance and governance
- Treat this file as the single canonical Calendar UI/UX reference for the decisions above.
- Where a detail is explicitly marked unspecified, preserve current behavior pending a separate owner decision; do not infer a new product rule.
- Existing calendar/provider/data/persistence contracts remain in force.
- PR #3052 stays OPEN / DRAFT / UNMERGED; do not modify main, merge, publish or release.
- **BLOCKED — RELEASE: NO-GO.**
