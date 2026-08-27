# Arvin — UI Governance / Visual Lock

## Purpose
This document is the canonical guardrail for preserving the approved Arvin appearance across future development, refactoring, migrations, AI handoffs, dependency updates, and automated tooling.

## Non-negotiable principle
**The appearance of Arvin is a protected product requirement.** Functionality may evolve, but the accepted visual language must not drift accidentally.

A visual change is allowed only when it is an explicit product/UI decision, documented before implementation, and checked against the rest of the application so that one screen does not become visually inconsistent with another.

## Canonical direction
- Persian, RTL-first.
- Calm, clean, professional hierarchy with low visual noise.
- Consistent rounded cards, spacing, typography, iconography, touch targets, navigation and component behavior.
- Existing Arvin visual language takes priority over generic templates or newly generated UI suggestions.
- IRANSans/project-approved typography remains part of the visual contract.
- Reminder, FollowUp, Calendar, Home, Widget and Lock Screen surfaces must feel like one product.

## Home contract
The Home screen is additionally governed by `docs/HOME_STYLE_LOCK.md`.
That document is binding for:
- the Bismillah + product-title identity block;
- notification/menu placement;
- search placement and visual style;
- four live summary/filter cards;
- task-card styling;
- indigo-led palette and pastel status accents;
- floating add control and bottom navigation;
- real-device visual acceptance.

A Home refactor must not substitute a generic Material dashboard for that approved composition. Green CI alone does not prove Home visual acceptance.

## Reminder contract
The previously approved Reminder concept is canonical:
- `یادآور` is the primary label.
- Time is shown smaller beside the label when a real time exists.
- Reminder title/content is presented beneath it.
- Details can expand/collapse.
- Quick actions include completion, snooze, edit and conversion to Task/Item where supported.
- All-day reminders never display a fabricated clock time.
- Lock Screen/widget presentation must remain consistent with this contract and use the same source of truth as the application.

## Change gate
Before changing code:
1. Read `docs/DEVELOPMENT_RULES.md`, this document and any screen-specific Style Lock such as `docs/HOME_STYLE_LOCK.md`.
2. Audit the current `main`, relevant implementation, open PRs, recent CI/workflows and project documentation.
3. Identify the exact gap being closed and confirm that no existing foundation is being duplicated.
4. Check whether the change can affect the visual contract, even indirectly.
5. After implementation, validate the relevant tests/workflows and perform a UI regression review.
6. Update project documentation with the rationale and validation result.

## AI handoff rule
Any AI or automated coding system working on Arvin must treat this document and linked screen-specific Style Locks as binding project context. It must not infer permission to redesign the interface from a request to clean up, refactor, migrate, optimize, or modernize code.

## Project identity
**بسم الله الرحمن الرحیم** is an inseparable principle of the Arvin project and must be preserved in project documentation and AI handoff context.
