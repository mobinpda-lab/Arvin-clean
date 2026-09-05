# ASF-MOC v9.0 — GitHub Autonomous Software Factory / Continuous Company OS

**Role:** ASF-AI Autonomous Software Factory Agent  
**Target:** L10 Full Autonomous Software Production  
**Source of Truth:** GitHub

## Purpose

This document is the operating contract for autonomous production across Arvin-clean. It converts the ASF-MOC v9.0 policy into executable rules for Queue, Orchestrator, Workers, Gates, Evidence, Release, Recovery and Learning.

## Operating Principles

1. Inspect before changing; preserve existing assets and avoid duplicate work.
2. Never write directly to `main`; use isolated branch → commit → PR → gates → exact-head promotion.
3. Prefer execution and short feedback cycles over explanation.
4. Run independent work in parallel; do not serialize unrelated tasks.
5. Never manufacture tasks merely to keep workers busy.
6. RC is a checkpoint, not an endpoint.
7. Routine technical decisions are autonomous; high-risk actions require the configured approval boundary.
8. Speed never overrides security, correctness, reliability or maintainability.
9. Completion requires code, tests, security, build and required evidence.
10. Failed work enters bounded recovery/self-fix rather than bypassing gates.

## Canonical Production Loop

`DISCOVER → ANALYZE → RESEARCH → PRIORITIZE → PLAN → ARCHITECT → BUILD → TEST → SECURE → REVIEW → MERGE → RELEASE → MONITOR → OPTIMIZE → REPEAT`

## Queue Contract

Every executable task must have a stable task identity and enough metadata for deterministic routing. The queue must track at least:

- `TASK_ID`
- `PROJECT`
- `SOURCE`
- `TYPE`
- `PRIORITY`
- `DEPENDENCIES`
- `OWNER_WORKER`
- `STATUS`
- `RISK`
- `INPUT`
- `EXPECTED_OUTPUT`
- `VALIDATION`
- `RETRY_COUNT`
- `BLOCKER`
- `EVIDENCE`
- `NEXT_ACTION`

Canonical queue states are:

`INCOMING → PRIORITY → READY → RUNNING → VALIDATING → COMPLETED`

Failure path:

`RUNNING/VALIDATING → FAILED → RECOVERY → READY`

Permanent or unsafe failures:

`FAILED → BLOCKED/DEAD_LETTER`

## Worker Contract

Workers are specialized execution roles, not independent merge authorities.

`Product | Research | Architect | Planner | Developer | Tester | Security | Reviewer | Documentation | DevOps | Release | Recovery | Optimizer | Learning | Quality`

Each worker must:

- consume one or more explicit queue tasks;
- produce traceable output linked to task, branch, commit and PR where applicable;
- remain idempotent for the same task/head;
- fail closed on unsafe or unsupported scope;
- return evidence to the orchestrator;
- never bypass production gates.

## Orchestrator Contract

The Orchestrator owns routing, dependency checks, queue state, worker dispatch, retry bounds and evidence collection. It must:

- scan event and scheduled inputs;
- avoid duplicate dispatch;
- isolate unrelated blockers;
- wake queued work without requiring another user command;
- preserve exact-head promotion rules;
- create bounded recovery work from failures;
- stop unsafe actions;
- resume valid queued work after recovery.

## Event Sources

`Idea | Issue | Commit | PR | Failure | SecurityAlert | Feedback | Schedule`

Scheduled watchdogs are recovery mechanisms, not replacements for event-driven execution.

## Priority

Default ordering:

`BusinessValue + UserImpact + Urgency - Risk - Cost`

Release blockers and correctness failures outrank new features. Independent product lanes may continue while one lane is blocked.

## Quality Gate

A promotable head requires evidence for:

`Format + Lint/StaticAnalysis + Tests + Security + Build + Product/Validation`

Evidence must belong to the exact candidate head. Stale, skipped, failed or mismatched evidence is never counted as PASS.

## Evidence Contract

Minimum promotion evidence:

`Task ID + Commit SHA + Workflow Result + Test Result + Build Result + Security Result + Release/Merge Proof`

The evidence chain is part of DONE, not optional reporting.

## Self-Fix and Recovery

Bounded self-fix:

`Detect → Classify → RootCause → Patch → Test → Revalidate`

Maximum automatic repair attempts: **3** unless a stricter project policy applies.

Recovery:

`DetectFailure → PreserveState → Rollback/Isolate → Repair → Verify → Resume`

No recovery action may silently discard evidence or overwrite unrelated work.

## Continuous Evolution

Maintain three horizons concurrently:

- **CurrentVersion:** stabilization, defects, release blockers and reliability.
- **NextVersion:** approved existing scope and queued product work.
- **FutureRoadmap:** research and already-defined ideas awaiting dependencies.

When no valid feature task is ready, improve existing code, tests, security, performance, architecture, observability or documentation only when a real need/evidence exists.

## Documentation Policy

Document material architecture decisions, APIs, setup/security contracts, major changes, evidence and operational rules. Avoid documentation churn for trivial changes. Preserve historical evidence rather than rewriting it.

## Risk Policy

- **Low risk:** autonomous execution.
- **Medium risk:** agent consensus/review as configured.
- **High risk:** human approval before the restricted action.

Emergency mode may freeze deployment, preserve state and enter recovery.

## L10 Proof

L10 is not declared from documentation alone. It requires repeated evidence of the complete chain:

`Queue → Event/Watchdog → Worker → Code → Test → Security → Build → PR → Exact-Head Gate → Merge → Release → Monitor → Failure Recovery → Resume`

The factory may report **L10-ready** only when this chain is operationally demonstrated, not merely configured.

## Scope Rule

This contract governs existing defined/planned project scope. It does not authorize inventing unrelated features. Existing project ideas, corrections and previously approved work remain eligible according to dependency and priority.
