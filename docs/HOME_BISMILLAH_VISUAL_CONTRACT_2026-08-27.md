# Arvin Home Bismillah + Visual Evidence Contract

Date: 2026-08-27
Status: User-approved product/UI decision

## 1. Fixed Home placement
The Persian/Arabic phrase below is a permanent Home-screen product requirement:

`بسم الله الرحمن الرحیم`

Placement is fixed at the top-center of the Home screen, above the main title/header (`مدیریت کارها و پیگیری آروین`) and below the system status area, matching the user-approved composition.

Rules:
- centered horizontally
- visually calm and secondary to the main page title
- readable in light/dark themes
- RTL-safe
- must not overlap status bar, menu, notification, search, or content controls
- must remain part of the real Flutter UI, not be painted onto screenshots or mockups

## 2. Real-output screenshot rule
Any future image presented as "محیط آروین", "خروجی آروین", "اسکرین‌شات آروین" or equivalent must be a screenshot captured from an actual built/running Arvin app artifact.

Mockups, AI-generated UI images, design concepts, Figma-like compositions, or illustrative phone frames must never be represented as real Arvin output.

If a conceptual image is ever used, it must be explicitly labelled as conceptual before presentation.

## 3. Acceptance
Before this requirement is declared complete:
- implement the phrase in the real Home UI
- add/adjust automated UI coverage for presence and placement hierarchy
- build the Android APK on the exact implementation head
- capture real emulator/device screenshot evidence from that APK
- verify the screenshot visibly shows the phrase above the Home title
- only then may the screenshot be used as real software-output evidence

## 4. Non-regression
Future Home redesigns must preserve this placement unless the owner explicitly changes the decision.
