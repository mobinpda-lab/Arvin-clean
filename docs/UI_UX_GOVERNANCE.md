# Arvin UI/UX Governance

## Purpose
Protect the approved Arvin visual direction as a first-class project requirement. UI quality is part of the product architecture and release acceptance, not cosmetic polish.

## Non-negotiable rules
- The approved Arvin visual direction must not be changed substantially by an AI, developer, refactor, dependency update, or tooling change without an explicit design review.
- Before any UI change, review the current screen, the existing visual acceptance contract, the overall product direction, and the impact on Unified Task/Reminder/FollowUp architecture.
- Prefer small, isolated UI changes over broad rewrites.
- Do not change UI merely to make CI green.
- Do not introduce a parallel UI foundation, data model, repository, storage path, or dual-write mechanism to implement visual changes.
- Any UI change that materially alters navigation, layout, information hierarchy, typography, spacing, iconography, or interaction patterns must be checked against this document and `docs/contracts/UI_VISUAL_ACCEPTANCE.md`.

## Approved direction
- Persian and RTL-first.
- Clean, fast, modern, and task-focused.
- Right-side navigation/drawer as the approved navigation direction.
- Simple, clear access to primary actions and quick entry.
- ChatGPT-like simplicity and clarity may be used as a UX reference, without copying proprietary implementation.
- Home should remain focused rather than becoming dashboard-heavy.
- Calendar, Items, FollowUps, and Reminders must share one visual language.
- Reminder presentation must remain concise and readable, with no fake or misleading time display.
- Light/dark appearance must preserve hierarchy and readability.
- Motion must remain subtle and purposeful.

## Architecture boundary
UI must consume the authoritative Unified Task foundation. Calendar, Notification, Widget, Google Calendar and future integrations must not create competing data sources merely to support their UI.

## Mandatory UI review path
Audit current UI
→ compare with approved direction
→ make the smallest safe change
→ run tests/analyze
→ run relevant GitHub Actions
→ inspect APK on a real Android device when visual impact is material
→ document the decision and result.

## AI/developer continuity rule
Future contributors and AI agents must treat this document and the visual acceptance contract as project constraints. When a proposed change conflicts with the approved visual direction, stop and review before implementation. For significant design decisions, obtain an independent DeepSeek cross-review before merging.

## Release gate
A feature is not visually complete merely because its logic and CI pass. Relevant screens must be checked against the approved visual direction before release acceptance.

## Relationship to existing documentation
`docs/contracts/UI_VISUAL_ACCEPTANCE.md` remains the detailed visual acceptance contract. This document adds governance: it protects that direction from accidental or unauthorized drift during future development.
