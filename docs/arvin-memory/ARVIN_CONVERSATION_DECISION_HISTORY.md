# Arvin Conversation Decision History

Repository: `mobinpda-lab/Arvin-clean`
Purpose: Durable index of product decisions and owner-reported acceptance findings captured in ChatGPT conversations. This file supplements—not replaces—the canonical protocol, ADRs, Issues, PRs, tests, or live CI evidence.

## Recordkeeping rules

- GitHub is the source of truth. Re-check live Issues, PRs, branches, commits, Actions and artifacts before relying on any status below.
- Record the decision, user-visible impact, protected behavior, and durable GitHub reference. Prefer updating an existing record; avoid duplicate Issues, models, stores, UI flows and architectures.
- A code change, passing test, merged PR, or built APK alone does not establish product acceptance.
- Never call a feature complete without evidence from the exact commit/artifact and the relevant user flow. For visual changes, require an Android screenshot and visual review; for release, require the defined data-safety, device and owner-approval gates.
- Treat owner reports about the installed app as real acceptance failures until reproduced and resolved with evidence.

## 2026-10-11 — Installed APK does not reflect the agreed task-form redesign

### Owner-reported finding
After installing the delivered Arvin APK, the owner reported that the main visible change was stronger colors. The agreed Category/Project/Tag icon arrangement and substantial task-entry-form redesign were not visible. This is an acceptance failure; do not dismiss it because similar code or a widget test exists in the repository.

**Durable record:** [Issue #1139 — product acceptance tracking](https://github.com/mobinpda-lab/Arvin-clean/issues/1139).

### Existing decision authority
- [Issue #2162 — form and colored selector requirements](https://github.com/mobinpda-lab/Arvin-clean/issues/2162).
- [Product Contract Matrix](../PRODUCT_CONTRACT_MATRIX.md).
- [Master Execution Protocol](../ARVIN_MASTER_EXECUTION_PROTOCOL.md).
- [PCTADP architecture decision / Issue #2582](https://github.com/mobinpda-lab/Arvin-clean/issues/2582).

### Product decisions to preserve
1. The taxonomy consists of the three canonical concepts **Project, Category, Tag**. “گروه” is not a separate domain entity; it is an alternate Persian term for Category where appropriate. Do not create a parallel Group model/store.
2. In the task-entry form, Project, Category and Tag controls should be grouped together in one coherent RTL row, in the approved order **Project → Category → Tag** when read from right to left. The controls must remain understandable and directly usable; tag selection remains multi-select.
3. Task Create/Edit should be Persian, RTL, grouped, calm and practical. Put common information first. Advanced/less frequently used fields should use progressive disclosure rather than crowding the initial form.
4. Quick Capture remains minimal; the full task form retains the canonical task capabilities: title, description, project, category, tags, priority, date/time, reminder, repeat, checklist, follow-up and next action. Do not create a second task engine.
5. Preserve entered data when validation fails or the user navigates back. Creating/editing a task must continue to use canonical persistence and existing data compatibility. Turning off checklist UI must not delete saved checklist rows.
6. The approved Arvin visual identity and VazirHarf font remain protected. Color adjustment alone does not satisfy the task-form redesign.

### Execution record
- The old candidate APK was associated with commit `dd95132cca2cbc3b20e3318f3f52a84875609f08`; current main was recorded as `72a2f4cc24df7a38eff9856ce403461615db5280`, 25 commits ahead at the time of audit. This establishes that the old APK is stale, not that the newer app is accepted.
- The release workflow previously stopped at the explicit product-release-approval gate; no successful release artifact was established from that run.
- A focused draft PR was opened: [PR #2602](https://github.com/mobinpda-lab/Arvin-clean/pull/2602), branch `fix/task-editor-progressive-taxonomy-order-20261011`, head at opening `dd7d976f994f57ab57b640775d1cf15e04880e5a`.
- That PR changes the full-form taxonomy order to Project/Category/Tag in an RTL row, adds stable selector keys, and makes “جزئیات بیشتر” collapsed by default. It also updates/adds widget acceptance tests for disclosure and row order.
- At the last recorded checkpoint, no fresh PR workflow run or commit status was returned for that exact head. Therefore Analyze, tests, APK build, Android visual review and owner acceptance remain **NOT VERIFIED**. Do not mark PR #2602 complete or claim that a new APK was delivered.

### Acceptance checklist for this issue
- [ ] Verify PR #2602 against the current form and existing PCTADP/ADR contract; avoid conflicts with other open PRs.
- [ ] Obtain fresh Analyze and all test-shard results for the exact PR head.
- [ ] Obtain Debug and Release APK build evidence for that exact head.
- [ ] Run Android Device Smoke and inspect the actual task form screenshot at a target phone viewport.
- [ ] Verify Project/Category/Tag selector order, visual consistency, multi-select tags, and advanced-fields expand/collapse.
- [ ] Verify Quick Capture remains minimal and full-form data survives validation/back-navigation and save/reopen.
- [ ] Verify checklist rows are not deleted when the checklist toggle is turned off.
- [ ] Produce a uniquely identifiable APK tied to a verified commit; compare its identity/version with the installed build.
- [ ] Keep Report Center, Calendar, Backup/Restore and remaining release gates open until their own evidence and owner acceptance are present.

## Related permanent requirements

- Product first; GitHub, CI, automation and Factory are tools, not the product.
- Do not start new feature work while a release-impacting acceptance blocker is open unless the work is independent and safely parallelizable.
- Do not claim “fixed”, “done”, “release-ready” or “final APK” based only on source-code presence.
- Follow the live remaining-work ledger and release gate; status in this document is a historical snapshot and must be refreshed from GitHub.

## 2026-10-11 — Master conversation decisions: product, UX, architecture, memory and delivery

This section records the owner-provided decision inventory as durable requirements. It is an index of intent, not proof that every requirement is implemented or accepted. Where a newer canonical ADR, Issue, Product Contract, or verified code behavior is more specific, reconcile the records rather than creating conflicting or duplicate systems.

### A. Execution command and project memory

1. **“ادامه آروین” is an execution trigger, not a request to restate the protocol.** Read the current GitHub reality, find the latest completed/blocked step, and continue from there. Do not restart analysis or rewrite settled decisions without new evidence.
2. **GitHub is the durable project memory.** Keep decisions, defects, implementation notes, tests, installation/device observations, evidence and remaining work in the relevant existing Issues, PRs, ADRs, logs and workflow artifacts.
3. **Use the decision history before action.** Before each meaningful change, read this file as well as the governing execution protocol and the relevant current Issue/ADR/PR/code/tests. Re-check live state; this file is not a substitute for live status.
4. **Maintain a durable user-experience log.** Proposed path: `docs/arvin-memory/ARVIN_USER_EXPERIENCE_LOG.md`. Record real installation results, device-specific behavior, user-visible defects, reproduction steps, screenshots/artifact identity, feedback and follow-up. First check whether an equivalent live log already exists before creating it; avoid duplicate logs.
5. **Anti-repeat workflow:** inspect → compare against decisions and current implementation → decide → implement/reuse existing work → validate exact change → record evidence and remaining work. Prefer FIX EXISTING, not rebuild.

### B. Canonical Task and data ownership

6. **One canonical Task engine.** Arvin Tasks have one source of truth; Home, Arvin Calendar projections, Search, Reports, notifications and other task surfaces must reuse canonical Task data rather than create a second Task Manager. Device-owned calendar events remain device-owned unless explicitly linked to an Arvin Task.
7. **No parallel systems.** Do not create a second Task Manager, standalone Checklist system, separate Tracking/CRM, independent Repeat engine, or duplicate Calendar ownership/store when existing canonical models and integrations cover the capability.
8. **Project / Category / Group / Tag.** Project, Category and Tag are the canonical taxonomy concepts. “Group/گروه” is a synonym/legacy product term for Category, not a separate entity, model or store. Tag remains independent and multi-select; its Task relationship is many-to-many where supported by the canonical schema. Preserve actual schema semantics; do not infer extra foreign-key constraints from UX language.

### C. Quick Capture and full Task form

9. **Quick Capture is the fastest path to the canonical Task**, not a separate incomplete task system or storage model.
10. **Quick Capture → same Task → Full Form.** Expanding/opening the full form continues editing the same Task; it must not create a duplicate. Save/reopen and navigation flows must preserve entered data.
11. Keep the existing **“فرم کامل”** route available as the progressive path from quick entry when the user needs more detail.
12. Quick Capture should remain **one-row, minimal and low-friction**, with only the fields needed to create a simple task quickly.
13. Quick Capture and Full Form must feel like one product family: consistent Persian RTL, typography, semantic colors, spacing, controls and feedback.
14. Use **progressive disclosure**: frequent/common fields first; advanced fields are revealed when needed rather than crowding the initial form. The full form must still support the canonical Task capabilities, including description, Project/Category/Tag, priority, date/time, reminder, repeat, checklist, follow-up and next action.

### D. Home and daily use

15. Home is not a statistics-only dashboard. It is the user's **Daily Command Center** for deciding what needs attention now.
16. Preserve the agreed **four-axis Home model**: Time, Project, Category and Tag. The intended four-card/selector experience should make it easy to inspect a chosen time window, project, category or tag at a glance. Keep this consistent with the live Home contract and existing filter implementation; do not introduce a competing Home model.
17. Home should answer, in practical terms: **What do I have now? What matters? What is overdue? What is the next action?**
18. The four axes are Time / Project / Category / Tag. Combined filters follow the canonical contract (AND where specified); Home grouping is a display/projection, not a second data model.

### E. Checklist and Repeat

19. Checklist is optional functionality **inside the canonical Task**, not a standalone task/list system.
20. For recurring Tasks, each occurrence must have its own execution/checklist state; completing one occurrence must not mark future occurrences complete.
21. Repeat is a capability/definition of a canonical Task, not a separate product or task-copy workflow.
22. Preserve the lifecycle contract: canonical Task → Repeat Definition → projected Occurrence → occurrence execution state/history. Reuse the governing Repeat ADR/Issue and existing implementation.
23. Do not create a new independent Task copy for every repeat. Calendar occurrences are projections unless the canonical architecture explicitly documents otherwise.
24. Historical execution is immutable; changes to a repeat definition affect future occurrences, not already-recorded history.

### F. Calendar and synchronization

25. Arvin Calendar is a projection/integration surface, not the owner of canonical Arvin Tasks. Preserve the distinction between Arvin Tasks and device-owned calendar events.
26. Calendar synchronization must use stable identity/link IDs, not title/date/time matching. Create once, then update the same verified linked event.
27. Sync should be idempotent. If a link is missing, broken or unverifiable, fail safely and offer an explicit recovery choice rather than silently creating a duplicate.

### G. Tracking and Follow-up

28. Tracking is a defining Arvin capability for commitments and items that need attention over time.
29. Keep the user-facing distinction clear: **Tracking = current state/status; Follow-up = next step/action**. Reuse the existing Task and Follow-up model.
30. Tracking must not grow into a separate CRM or independent customer/contract/payment system. Cover varied use cases with the canonical Task capabilities and progressive disclosure.

### H. UX and visual quality

31. Arvin should feel like a **Personal Assistant**, not a generic task database.
32. The visual experience should remain simple, calm, clear, fast and low-friction.
33. Persian language and RTL are baseline requirements throughout, not a late polish step.
34. Cards and screens need clear hierarchy, appropriate spacing, legibility and low visual clutter.
35. Quick Capture, Full Form and Task Detail should share consistent color, spacing, typography, interaction patterns and feedback. Preserve the approved Arvin identity and VazirHarf font.

### I. Change control and release

36. Before a significant change, inspect the live GitHub state, relevant code, commits, Issues, PRs, tests, workflows and documentation. Verify that equivalent work does not already exist.
37. **FIX EXISTING — NOT REBUILD.** Repair and extend canonical implementations before considering new models, stores, engines, screens or automation.
38. Follow the full loop: Analyze → Compare → Decide → Implement → Validate → Record. Execute independent, non-conflicting tracks in parallel when safe.
39. **Done means product evidence, not code presence.** Require relevant tests, exact-commit build/validation, real flow checks and artifacts; visual changes additionally require a real Android screenshot and visual review. Release also requires data-safety, Backup/Restore, device acceptance and explicit owner approval.
40. Final delivery must include installation/real-device verification, Backup/Restore and data-integrity checks, user-flow acceptance, documentation and evidence. Do not label an APK final/release-ready before those gates pass.

### High-risk “do not forget” checklist

- [ ] Quick Capture and Full Form edit the same canonical Task; no duplicates.
- [ ] Quick Capture stays one-row, minimal and fast.
- [ ] Home preserves the four Time / Project / Category / Tag axes and daily-management purpose.
- [ ] Category and Group are synonyms; no separate Group entity.
- [ ] Canonical Task remains the source of truth for Arvin Tasks.
- [ ] Repeat does not create independent Task copies; past execution/history is preserved.
- [ ] Calendar is a projection for Arvin Tasks; sync uses stable link identity and is idempotent.
- [ ] Checklist remains part of Task, with independent per-occurrence execution state.
- [ ] Tracking and Follow-up remain canonical Task capabilities; do not build a parallel CRM.
- [ ] GitHub is durable memory; read this history before meaningful action.
- [ ] Installation/device/user feedback is recorded in the existing issue and user-experience log.
- [ ] Review the repository before creating or rebuilding anything.
- [ ] Continue from the latest live GitHub state; do not repeat completed work.
- [ ] No “done”, “final APK” or “release-ready” claim without exact-artifact evidence and acceptance.

### Status boundary

The decisions above are recorded as product intent. They do **not** assert that all are currently implemented, that the installed APK satisfies them, or that the project is release-ready. Verify each requirement against current code, relevant existing Issue/ADR, exact commit, CI/artifacts and owner/device acceptance. Resolve contradictions by updating the canonical decision record with evidence, not by silently overriding prior decisions.

