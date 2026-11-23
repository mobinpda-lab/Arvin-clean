# REV10 Unified Experience Architecture — Discovery and Design Proposal

**Mission:** 202-R  
**Repository:** `mobinpda-lab/Arvin-clean`  
**Canonical route:** PR #3495 / `recovery-02/main-based-integration`  
**Discovery baseline:** `f7430482cff8dad45a7a948181c132ddfd4e7e82`  
**Status:** READ-ONLY DISCOVERY COMPLETE / DESIGN PROPOSAL — NOT IMPLEMENTED, NOT TESTED, NOT ACCEPTED  
**Scope boundary:** This document does not authorize a broad UI redesign or changes to product behavior. Center, Home and Backup defect remediation remains the active priority.

## 1. Authority and constraints

- REV10 owner-locked Primary Blue is `#4169A1`; canonical color authority is `lib/arvin_colors.dart`. Do not replace it with historical palette values or local literals.
- The active design-system specification is `docs/rev10/SPEC/DESIGN_SYSTEM_SPEC.md`.
- The current UI font implementation is Vazirmatn, exposed through `lib/theme/app_fonts.dart` and `lib/theme/font_registry.dart`. This document does not authorize a font migration.
- Main remains read-only. No merge, release, deployment, schema change, or test weakening is authorized.
- Existing behavior, navigation destinations, data contracts, accessibility semantics and approved product layouts must be preserved.
- Any future UI work requires its own issue/branch/PR evidence and exact-SHA visual plus functional regression.

## 2. Read-only implementation inventory

The inspected source at the discovery baseline shows:

| Area | Existing source evidence | Discovery |
|---|---|---|
| Brand colors | `lib/arvin_colors.dart` | Central semantic palette exists; it is the sole authority. |
| Typography | `lib/theme/app_fonts.dart`, `lib/theme/font_registry.dart` | Vazirmatn is the current registered family. |
| App theme | `lib/main.dart` | Material theme configuration is hosted in the app entry point; theme extraction is not yet demonstrated. |
| Primary navigation | `lib/widgets/arvin_primary_navigation.dart` | Shared bottom navigation and page shell exist. Some values are still local literals and should be reconciled with canonical tokens only in a separately tested design-system task. |
| Task details | `lib/task_detail_page.dart` | A dedicated detail page exists with task lifecycle and follow-up behavior. |
| Bottom sheets | `lib/widgets/home_my_tasks_sheet.dart`, plus page-local modal sheets | Reusable sheet examples exist, but a universal sheet contract is not established. |
| Date/time | `lib/widgets/persian_date_picker.dart`, `lib/widgets/universal_arvin_time_picker.dart` | Reusable Persian date and 24-hour time picker entry points exist. |
| Taxonomy controls | `lib/widgets/project_selector_field.dart`, `lib/widgets/task_category_field.dart`, `lib/widgets/taxonomy_icon_row.dart` | Some shared selectors/presentation components exist. |
| Center management | `lib/center_management_page.dart` | Dedicated stateful management page; async remediation is separate from this design proposal. |
| Home | `lib/main.dart` | Home loading and broad app composition currently share a large entry-point source file. |
| Routing | `lib/widgets/arvin_primary_navigation.dart`, `lib/main.dart` | Primary destinations are enumerated; several page transitions use direct Navigator/MaterialPageRoute calls. A central route registry is not established by this inspection. |

The source inventory is not a claim that every page or interaction has been audited. It is a bounded discovery snapshot.

## 3. Content-Centered Architecture

### Proposal
Organize screen composition around canonical content and user intent rather than page-specific visual containers.

- Canonical entities remain Task, FollowUp, Reminder, Center, Project, Category and Tag.
- Content projections and view models may compose these entities for display but must not create parallel persistence models or stores.
- Shared content components receive explicit typed data and callbacks; they do not reach into global stores.
- Domain ownership and data mutation remain in existing services/repositories.
- Page shells own navigation and safe-area composition; feature pages own their local interaction state.

### Guardrails
- No change to SQL schema, IDs, migration behavior, backup format or data ownership.
- Do not conflate Task due date, Reminder schedule and FollowUp history.
- Keep existing Center↔Project and Project↔Category many-to-many relationships canonical.

## 4. Shared Action Rows

### Proposal
Create a small shared action-row primitive for repeated, semantically similar action groups.

A row should support:
- Leading icon and localized label.
- Optional concise supporting text.
- Explicit enabled/disabled state.
- A typed callback and semantic action identifier.
- RTL-aware leading/trailing placement.
- Minimum 48 logical-pixel touch target.
- Optional destructive/secondary emphasis through semantic theme roles.

### Guardrails
- Do not combine unrelated actions merely to make pages look uniform.
- Preserve each feature's current confirmation, undo, error and permission behavior.
- No callback may be silently omitted or inferred from a label.

## 5. Universal Bottom Sheet

### Proposal
Introduce a shared sheet host only after the existing page-local sheets have been inventoried and their behavioral differences documented.

The contract should define:
- SafeArea and keyboard/IME inset behavior.
- RTL directionality.
- Drag handle and dismissal semantics.
- Scrollable content and bounded maximum height.
- Consistent title, optional description, content and action slots.
- Explicit dismissal policy for dirty forms.
- Accessibility labels, focus order and large-text behavior.
- Typed result values and cancellation semantics.

### Existing examples
`showHomeMyTasksSheet` in `lib/widgets/home_my_tasks_sheet.dart` is a reusable filter sheet. Center details and project-link editing currently use page-local modal sheets/dialogs. They are references, not proof of a universal contract.

### Guardrails
- Do not migrate every modal in the defect-remediation wave.
- Do not change navigation stack or dismissal semantics during extraction.
- Add golden, widget and keyboard/IME regression tests before adoption.

## 6. Shared Detail Components

### Proposal
Build reusable presentation components around stable semantic sections, not a single generic detail page.

Candidate components:
- Entity identity header.
- Status and priority indicators.
- Metadata summary row.
- Related-entity list.
- Timeline/event row.
- Empty/loading/error state.
- Inline action group.

TaskDetailPage remains the behavior owner for Task-specific edit, completion, checklist and FollowUp operations. Shared components must not own Task persistence or create duplicate edit state.

## 7. Central Design Tokens

### Current authority
`lib/arvin_colors.dart` is the canonical color source. Owner-locked values include:
- Primary Blue: `#4169A1`
- Primary Soft: `#E9EAFF`
- Background: `#F8F8FB`
- Surface: `#FDFDFE`
- Primary text: `#232433`
- Secondary text: `#80829C`

Vazirmatn remains the current registered UI font family.

### Proposal
If token extraction is undertaken, define semantic token groups for:
- Color roles (brand, surface, text, border, status, focus, disabled).
- Typography roles (family, size, weight, line height, letter spacing).
- Spacing scale and page gutters.
- Shape/radius and elevation.
- Motion duration/curve.
- Minimum touch targets and responsive breakpoints.

### Guardrails
- Preserve `ArvinColors.primaryName == 'Primary Blue'` and `ArvinColors.primary == Color(0xFF4169A1)`.
- Do not silently reintroduce historical `#4A4CAB` as the brand primary.
- Token extraction must be incremental and backed by a literal-usage inventory and tests.
- Do not change all pages in one migration.

## 8. Unified Navigation

### Current evidence
`ArvinPrimaryNavigation` defines Home, Calendar, Notebook, Reports and More. The enum also contains `nextAction`, while the current visible destination list does not render it. Existing page transitions are not proven to use one central route registry.

### Proposal
- Keep the current canonical destination contract until product-owner review authorizes a change.
- Define a typed navigation destination/argument contract.
- Centralize route construction and route observation without moving feature logic into the router.
- Preserve deep-link/widget entry behavior, back-stack semantics and restoration.
- Keep destination visibility separate from the enum so hidden/conditional destinations are explicit and tested.

### Guardrails
No destination addition, removal, reordering or relabeling is authorized by this document.

## 9. Responsive Layout

Define layout behavior by available width and text scale, not device model:
- Compact phones: single-column content, bounded sheets, vertical scrolling.
- Wider phones/tablets: optional constrained content width and intentional two-column sections only where information hierarchy benefits.
- Preserve minimum touch targets and avoid horizontal overflow.
- Respect safe areas, keyboard/IME insets and scroll-to-focused-field behavior.
- Test at 360, 390 and 412 logical-pixel widths plus a wider viewport and large text scale.
- Long Persian labels, mixed Persian/Latin IDs and numeric values must remain readable.

These are future acceptance dimensions, not evidence that current screens already pass them.

## 10. RTL behavior

- Apply Directionality at stable application/page boundaries; avoid per-control direction overrides unless a control has a documented mixed-direction requirement.
- Use directional padding/alignment APIs where layout intent is leading/trailing.
- Keep Persian reading order and action order consistent.
- Isolate Latin identifiers, URLs, email addresses and code-like values with appropriate bidi handling.
- Verify icon semantics: directional icons may mirror; identity/status icons generally should not.
- Test sheets, dialogs, navigation, date/time pickers, forms and text fields in RTL.

## 11. Consistent interaction patterns

Establish reusable behavior contracts for:
- Loading, success, empty, error and retry states.
- Confirmation and destructive actions.
- Save/cancel and dirty-form dismissal.
- Snackbar/message placement and duration.
- Search/filter/sort state.
- Disabled controls and progress feedback.
- Keyboard submission, focus movement and IME dismissal.
- Async operations: one owner, explicit lifecycle, preserved exceptions and no duplicate completion callbacks.

The 202-R async instrumentation and defect remediation must be completed independently before any interaction refactor is considered.

## 12. Recommended adoption sequence — proposal only

1. Complete Center/Home/Backup async defect diagnosis and acceptance.
2. Inventory page-level repeated patterns with source references and screenshot baselines.
3. Reconcile all visual values against the owner-locked token source.
4. Define and test Shared Action Rows.
5. Define Universal Bottom Sheet contract and migrate one low-risk example.
6. Extract Shared Detail Components from one representative page.
7. Establish typed navigation registry without changing destination behavior.
8. Validate responsive and RTL contracts across representative screens.
9. Expand only through independent issues and exact-SHA regression gates.

## 13. Acceptance checklist for any future implementation

- [ ] Product-owner approval for any visible behavior or destination change.
- [ ] No parallel models, stores or persistence.
- [ ] Canonical tokens and Vazirmatn preserved.
- [ ] RTL and mixed-direction content verified.
- [ ] 360/390/412 widths and larger text scale verified.
- [ ] Keyboard/IME and safe-area behavior verified.
- [ ] Accessibility semantics and 48dp targets verified.
- [ ] Existing widget, integration and golden tests retained.
- [ ] Exact-SHA Analyze, all six test shards and relevant device smoke pass.
- [ ] Before/after screenshots and modified-file inventory attached.
- [ ] No regression in Center, Home, Backup, Calendar, Task Detail or navigation.
- [ ] Separate IMPLEMENTED / TESTED / VERIFIED / ACCEPTED status recorded.

**Final status:** Design proposal documented. No UI implementation, product acceptance, release authorization or GO decision is implied.
