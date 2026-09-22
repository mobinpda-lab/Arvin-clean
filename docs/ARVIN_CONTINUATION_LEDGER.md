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

## G1 Checkpoint — 2026-09-22
- PR: #1271
- Branch: feature/arvin-final-integration-20260921
- Previous head: 25f6baa18afe1af536352d26ce9783b67bc39ff8
- Previous Build: Arvin Build #2898 failed at Analyze.
- Exact Analyze finding: lib/main.dart:1777:76 unnecessary_non_null_assertion on dueDate!.
- Root cause: local dueDate is nullable and the surrounding condition checked task.dueDate instead of the promoted local.
- G1-only fix committed: 6f108cb95facb2e27eb37bc7b3505cb0851b93ad
- Fix: condition now checks dueDate != null and date/time formatting uses dueDate without redundant null assertions.
- No migration, Home redesign, parallel storage, or unrelated change was introduced by this fix.
- Required next gate: GitHub Analyze on exact new head 6f108cb95facb2e27eb37bc7b3505cb0851b93ad.
- G1 remains in progress; Test/Migration/Backup/Build acceptance and merge remain blocked until the required gates pass on the same final SHA.
