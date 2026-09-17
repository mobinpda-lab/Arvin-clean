# ARVIN UI Reference Authority Note

## Visual Source of Truth

The primary authority for Arvin appearance is not only general UI contracts or older documentation.

The highest-priority visual reference is:

1. The Arvin application after installation (the real installed application state).
2. The screenshots/images provided by the owner as the desired target appearance.
3. The approved comparison between installed state and target images.

All future visual validation must compare implementation against these references.

Generic UI patterns must not override the approved visual target.

## Validation Rule

A UI change is accepted only after:
- implementation matches the target visual reference,
- behavior remains correct,
- screenshot/device evidence confirms the result.
