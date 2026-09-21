# ARVIN Continuation Ledger

## Purpose
This document preserves the implementation context extracted from the long ARVIN review conversation. It is a continuity reference; completion must always be proven by code, tests, builds, and evidence.

## Source of Truth
GitHub code + PR + tests + APK/device evidence are authoritative.

## Home
- Keep canonical visual shell.
- Validate against reference screenshots.
- Verify cards, RTL, typography, spacing, search, and primary add action.
- Expected flow:

Home Card -> Task Detail -> Edit / FollowUp

## Task Flow
All creation and editing paths must converge:

Quick Entry / Create / Edit -> Unified Task Editor -> Canonical Repository -> arvin.tasks

Avoid parallel models, stores, or write paths.

## Task Detail
Required:
- Task information
- FollowUp Timeline
- Add FollowUp
- Edit flow

## FollowUp
Required:
- Multiple followups per task
- History preservation
- Latest FollowUp projection
- Persian/Jalali handling
- Empty states

## Quick Entry
Quick capture must use the same canonical task path and not create a separate storage model.

## Notebook
Simple Note and Checklist must respect canonical architecture. Avoid duplicate storage paths.

## Calendar
Validate:
- No date means no calendar event
- Date only means all-day behavior
- Date plus time means timed event

## Visual Validation Gate
Before release:
1. Code
2. Tests
3. Build
4. Install
5. Screenshot comparison
6. Evidence

## Execution Order
1. Audit remaining Home routes and Task navigation.
2. Verify Unified Editor paths.
3. Verify FollowUp evidence.
4. Run tests.
5. Build APK.
6. Record evidence.

## Rule
Do not report a feature as completed without a GitHub artifact (commit/PR/test/build/evidence).

## Exact-head continuation gate — 2026-09-21
Issue #1267: exact-head continuation gate and prevention of redundant re-audits.

Current live continuation point at audit start:
- Base main: 25c2ecf7e935ac7a75cfa0d386e1e5eb1d342d47
- Active branch: fix/home-owner-reference-20260920
- Active PR: #1177
- Audit head: 996dd3c63ce28b792840a13a11c411515839fc4b
- The active branch is the only implementation path for this owner contract; do not open a second branch/PR for the same scope.

### Re-audit rule
1. Before every new change, read only the latest branch SHA, PR state and CI result.
2. Compare the proposed change against the last validated SHA.
3. Re-open only files/services/tests that are dependencies of the changed behavior.
4. Do not repeat a full-project audit when neither the requirement nor its dependency graph changed.
5. After a change, record the new exact SHA and validate only the affected gate plus the mandatory final gates.
6. A failed gate remains open until a newer exact-head run proves it; no previous green run is carried forward.

### Current blocker carried forward
At audit head 996dd3c63ce28b792840a13a11c411515839fc4b, Build was green but Android Device Smoke failed in sequential Quick Capture at کار دوم. The failure remains an active acceptance blocker. The smoke assertion must not be weakened; the next change distinguishes native persistence from engine-local cache and keeps final restart verification.

### Single-pass Android gate
Home four-mode visual evidence and Quick Capture persistence are validated in one Android integration entrypoint/session. This avoids starting a second emulator session for the same Home state and prevents duplicate Android checks while preserving required evidence.

### Completion rule
No feature is called کامل until the same exact SHA has code + tests + Build + Android evidence. The latest exact SHA, workflow run IDs and evidence names are the only carried-forward validation record.
