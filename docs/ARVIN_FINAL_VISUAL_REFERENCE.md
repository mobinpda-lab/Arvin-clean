# Arvin Final Visual Reference Authority

## Status

Owner-approved visual reference document.

This document defines the final visual and interaction direction of Arvin based on:

1. Real installed Arvin application evidence provided by the owner.
2. Existing canonical UI contracts.
3. Approved product behavior requirements.

This is not only a screenshot reference. It is the design authority for implementation validation.

## Authority Rules

Priority order:

1. Real installed Arvin behavior and approved reference screens.
2. Current canonical UI contracts.
3. Product architecture constraints.
4. Historical documents only for traceability.

Conflicting old documents must not redirect implementation.

## Global Visual Language

- Persian RTL-first application.
- Calm professional productivity experience.
- White/light surfaces.
- Indigo/purple primary identity.
- Soft status colors.
- Rounded cards.
- Clear hierarchy.
- Consistent typography and spacing.

Protected identity:

- Bismillah identity block.
- Arvin title/header.
- Bottom navigation.
- Approved layout hierarchy.

## Home Screen

Home must contain:

- Header.
- Search.
- Summary/stat cards.
- Task/work cards.
- Quick action access.
- Bottom navigation.

Rules:

- Home consumes canonical data.
- No duplicate dashboard model.
- Quick creation enters the same Task system.

## Navigation

Primary navigation:

- خانه
- تقویم
- دفترچه
- اقدام بعدی
- بیشتر

No duplicate paths are allowed.

## Quick Entry

Required:

- Title input.
- Project.
- Category.
- Date/time.
- Tags.
- Fast save.
- Full editor expansion.

Quick entry and full creation must share one canonical Task model.

## Task Detail and Follow-up

Task detail supports:

- Title.
- Description.
- Project.
- Category.
- Tags.
- Reminder.
- Follow-up.
- History.
- Completion state.

Follow-up rules:

- Add follow-up without losing history.
- Timeline visibility.
- Clear pending state.

## Notebook

Notebook includes:

- Simple notes.
- Checklists.
- Categories.
- Search.
- Organization.

Simple note and checklist remain distinct UX modes.

## Calendar

Requirements:

- Jalali calendar.
- Day/week/month views.
- Task connection.
- Follow-up visibility.
- Reminder visibility.

## Projects, Categories and Tags

Keep concepts separate:

- Project = container.
- Category = grouping.
- Tag = flexible label.

## Icons

- Consistent icon family.
- Functional meaning.
- Clear action discovery.
- No unnecessary decoration.

## Validation Checklist

Every screen must match:

- Layout.
- Colors.
- Typography.
- RTL.
- Buttons.
- Icons.
- Navigation.
- User flow.
- Data behavior.

Visual similarity alone is not acceptance.

## Production Roadmap

### Phase 1: Authority stabilization

- Freeze visual direction.
- Reconcile documents.
- Update contract matrix.

### Phase 2: UI convergence

- Home.
- Navigation.
- Quick entry.
- Task detail.
- Follow-up.

### Phase 3: Feature completion

- Notebook.
- Calendar.
- Projects.
- Categories.
- Tags.

### Phase 4: Production readiness

- Device testing.
- RTL testing.
- Performance.
- Crash fixing.
- Release build.

This document is the visual acceptance reference for Arvin production implementation.
