# ARVIN DESIGN SYSTEM — WORKING BASELINE
**Status:** IN PROGRESS / NOT ACCEPTED. No production UI code changed in this phase.

## Current implementation facts
- Font declaration: Vazirmatn; family exposed by AppFonts.
- Registered weights in pubspec: 400, 500, 700.
- Build font package audit passed on baseline SHA.
- Color source centralization and page-wide token coverage are not yet proven.

## Proposed design-system inventory
Typography: family, weight scale, line heights, Persian numerals, Latin numerals, mixed-direction text, truncation and accessibility scaling.
Color: primary, secondary, background, surface, text, muted text, outline, success, warning, error, disabled and focus states.
Spacing: 4-point base scale, screen gutters, section spacing and control gaps.
Shape: card/input/button/sheet/dialog radii, elevation and border rules.
Components: buttons, text fields, selectors, date/time picker, cards, chips, icons, bottom sheets, dialogs, menus, navigation, empty/error/loading/skeleton states.
Layout: RTL directionality, responsive widths, keyboard/IME insets, scroll and safe areas.
Accessibility: touch target, contrast, semantic labels, text scaling and focus order.

## Existing product palette reference
A prior approved product visual reference recorded: primary #4A4CAB, soft #E9EAFF, background #F8F8FB, card #FDFDFE, main text #232433, secondary #80829C. These are reference tokens pending comparison against current source and REV10 visuals; not yet certified as the current implementation.

## Gate
No global redesign commit until page inventory, font-source reconciliation and shared-component ownership are documented. Each page requires before/after screenshot evidence and functional regression tests.
