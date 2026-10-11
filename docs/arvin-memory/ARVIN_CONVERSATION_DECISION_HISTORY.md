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
