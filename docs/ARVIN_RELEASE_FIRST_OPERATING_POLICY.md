# ARVIN Release-First Operating Policy

**Status:** Proposed policy for controlled adoption
**Source:** Owner operating directive, 2026-09-10
**Base:** current `main` HEAD at policy-branch creation
**Primary objective:** maximize time-to-proven completion while preserving release safety and avoiding false progress.

## 1. Mission

- Maximize time-to-proven completion.
- Arvin release readiness is the first target.
- Prefer verified output over activity.
- Minimize human input.
- Zero false progress, duplicate work, and blind retries.
- Do not invoke AI when deterministic or known fixes are sufficient.

## 2. Scope and priority

Repositories in the broader operating scope:

1. `mobinpda-lab/Arvin-clean` — primary target.
2. `mobinpda-lab/ASF-Core`.
3. `mobinpda-lab/YadNegar`.
4. `mobinpda-lab/NetworkCenterMonitor`.

Capacity policy: Arvin owns the release path first. Nira/other factory work may consume capacity only when it directly accelerates Arvin release or removes a release blocker.

## 3. Source of truth

Current live GitHub state is authoritative. Old reports, old SHAs, old percentages, and old CI results do not change current status unless revalidated against the current head.

A status may advance only from evidence produced for the relevant current head:

- real code;
- real tests;
- real CI;
- real build;
- real artifact;
- real acceptance evidence.

Never claim `done`, `tested`, `built`, `proven`, `release-ready`, or `released` without corresponding evidence.

## 4. Arvin release-closure mode

While a release blocker exists:

- freeze non-essential new features;
- deterministic checks and known fixes precede AI work;
- factory improvements are allowed only when they remove a blocker, reduce release time, or provide required evidence;
- do not weaken or disable tests to obtain a pass.

Release closure order:

`freeze non-essential work → verify final main SHA → zero release blocker → analyze → test → integration test → device/system validation where required → security/data-safety check → release APK build → checksum → traceable evidence → Release Ready`

Physical-device validation must respect the current owner policy: where physical hardware is explicitly deferred, record it as `NOT VERIFIED / Deferred` rather than blocking release or claiming it passed.

## 5. Reconciliation before work

Before creating code work, a worker must reconcile current state:

1. read current `main`;
2. search existing implementation;
3. inspect recent PRs and current issues;
4. check whether the requirement is already implemented;
5. check whether an equivalent fix already exists;
6. check for duplicate branches, PRs, and workers;
7. classify stale work before spending heavy CI/AI capacity.

An old-SHA failure is not evidence of a current failure. Reproduce against current `main` first. If current `main` already solves the problem, close or supersede the stale task with traceable reasoning rather than recreating the fix.

## 6. Controlled parallelism

Maximum active code lanes: **2**.

- Lane 1: Arvin release lane.
- Lane 2: one non-conflicting support lane only when it has measurable release value.

No simultaneous writes to the same scope. Every worker must declare:

- project;
- scope/write boundary;
- acceptance criteria;
- test requirement;
- evidence requirement.

## 7. Worker and AI policy

Preferred repair order:

`check → known fix → template/deterministic fix → AI fix`

AI is used only when required by the problem. Provider `429` or equivalent pressure enters cooldown; repeated retry storms are prohibited.

Failures are classified as:

`CODE | TEST | BUILD | DEVICE | INFRA | PROVIDER | PERMISSION | DEPENDENCY | CONFLICT | STALE`

Retry only when the failure class and retry are known to be safe. Repeated failures stop and escalate rather than loop blindly.

## 8. Diff and merge guard

Before heavy CI or merge, verify expected scope and diff. Quarantine changes with:

- mass deletion;
- unrelated modifications;
- scope mismatch;
- unexpected dependency or configuration changes.

Merge only when:

`current base OK + clean diff + required checks green + security OK + acceptance met + dependencies ready`

Normal development must remain branch/PR based; do not bypass the repository's existing merge and quality gates.

## 9. Continuous loop

The operating loop is:

`read state → reconcile → select highest-value action → execute → verify → merge if ready → read new main → continue`

The desired state machine is:

`DISCOVERED → PLANNED → IMPLEMENTED → EXECUTED → VERIFIED → PROVEN → ACCEPTED → RELEASE_READY → RELEASED`

A state transition requires its corresponding evidence.

## 10. Factory role

The Arvin factory is primarily responsible for:

- test automation;
- CI recovery;
- failure classification;
- diff checking;
- evidence collection;
- artifact/checksum verification;
- release automation.

Factory work is justified only when it decreases Arvin release time, removes a blocker, or supplies required release evidence.

Nira is a generic factory accelerator only. It must not duplicate Arvin product logic.

## 11. Human escalation and stop definition

Escalate only for a genuine human-required blocker, security stop, destructive/irreversible action, or unresolved product ambiguity.

Stop when no safe high-value action remains, not merely because a worker completed an activity. Do not create work solely to keep the factory busy.

## 12. Evidence package for Release Ready

Release Ready requires traceable evidence tied to the exact final main SHA, including as applicable:

- workflow/run identifiers;
- relevant jobs and logs;
- test results;
- integration/device evidence;
- security/data-safety result;
- release APK;
- artifact identity;
- checksum;
- GitHub Release evidence;
- final-head validation.

If a required evidence item is missing, status remains below Release Ready.

## 13. Non-interference adoption rule

This document is a **policy layer**, not a replacement for existing workflows. It must not interrupt, cancel, disable, or rewrite an in-flight workflow.

Adoption must be incremental:

1. document the policy on a branch;
2. review and merge it through the normal PR path;
3. only then make targeted workflow/factory changes that implement a specific policy clause;
4. each implementation change must be independently validated;
5. existing working release automation remains intact unless a proven defect requires a controlled change.

This prevents a policy rollout from becoming a release blocker itself.

## 14. Current first mission

The first operational proof target is the existing Arvin release chain on the **current `main` HEAD**. Do not create a parallel release system merely to satisfy this policy.

The required proof is an actual end-to-end cycle:

`current main → queue → worker → PR → quality gate → merge → build/artifact → release → final-head validation`

Only execution evidence can promote the factory from implemented policy to proven automation.
