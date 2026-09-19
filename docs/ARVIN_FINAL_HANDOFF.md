# ARVIN Final Handoff & Closure Plan

## Purpose
ARVIN is the final product. Factory, NIRA, GitHub Automation and five-minute cycles are supporting tools only.

Goal: complete product closure, prove quality, and prepare a release candidate.

---

# Current Product State

## Completed Areas

### Quick Entry
- Main Task creation path implemented.
- Connected to Task Editor.
- Avoid parallel creation paths.

### Task Editor
- Create and edit flows implemented.
- Draft preservation paths handled.

### FollowUp
- FollowUp lifecycle implemented.
- Linked to canonical Task identity.
- History preservation handled.

### Notebook
- Note to Task conversion implemented.
- Identity preservation handled.
- Trash/Restore flow implemented.
- No parallel storage model should be introduced.

### Calendar
- Persian/Jalali visible date handling addressed.
- Persian digit display tests added.

---

# Remaining Work

## 1. Build Reference Gate (High Priority)

Create a trusted build from current main.

Required:
- Analyze
- Tests
- APK build
- Artifact verification
- Device smoke test

Output:
- Stable build reference.

---

## 2. Home Visual Closure (High Priority)

Validate final Home experience against approved references.

Check:
- Layout
- Typography
- RTL behavior
- Colors and contrast
- Spacing
- Task cards
- Quick Add entry
- Removal of outdated UI paths

Required result:
- Home matches final product direction.

---

## 3. Real Installation Experience

User-reported installation and device issues must be treated as acceptance tests.

Check:

### APK Installation
- Install latest APK on real devices.
- Verify package integrity.
- Verify no parsing/install errors.

### Large Screen / Tablet
- Font size
- Contrast
- Spacing
- Persian readability

### Calendar
- Event creation
- Reminder behavior
- Local time handling
- Jalali display

---

## 4. Device Evidence

Required scenario:

Install APK
-> Open App
-> Home
-> Quick Entry
-> Task Editor
-> FollowUp
-> Notebook
-> Calendar
-> RTL/Persian verification
-> Crash check

Evidence must come from real device testing.

---

## 5. Release Candidate

After all gates pass:

- Version creation
- Changelog
- Release artifact
- Final APK archive

---

# Development Rules

No parallel architecture.
No new features before closure.
No direct main changes.

All changes follow:

Branch
-> Change
-> PR
-> Build
-> Test
-> Evidence
-> Merge

---

# Current Main Blocker

The remaining challenge is product closure and proof on real builds/devices, not adding more features.
