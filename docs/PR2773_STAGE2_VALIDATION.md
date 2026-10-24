> **Typography authority update (2026-10-24):** This is a dated validation record. Any mention of VazirHarf describes the historical tested build, not the current requirement. Current contract: [`docs/TYPOGRAPHY_CANONICAL.md`](TYPOGRAPHY_CANONICAL.md), Issue #2974.

---

# PR #2773 — Stage 2 Validation Ledger

**Command:** `CMD-20261017-PR2773-STG2`  
**Branch:** `fix/calendar-card-interactions-p0-20261017`  
**Release:** `RELEASE: NO-GO` until fresh CI and emulator evidence is reviewed.

## Scope in this commit
- **Historical validation scope:** the original scenario named the VazirHarf theme. Any future rerun must use canonical Vazirmatn per Issue #2974; preserve this line only to describe the old test intent.
- Add a dedicated calendar scenario to Device Smoke and require its three screenshot files as an artifact.
- Add explicit ADB device/boot readiness checks before running the selected integration scenario.
- Upgrade the checkout, cache and artifact actions used by Build and Device Smoke to their Node 24-compatible major versions.

## Evidence required after this commit
- All six unit/widget shards and Analyze succeed on the exact commit.
- Both APK builds succeed.
- The calendar Device Smoke lane succeeds and uploads `calendar-card-interaction.png`, `calendar-card-completed.png`, and `calendar-persian-time-picker.png`.
- Logs contain the `CALENDAR_SMOKE` checkpoints, `ADB_BOOT_COMPLETED=1`, and no Flutter rendering exception.
- Review the full logs for remaining Node, ADB, framework and plugin warnings; do not infer a clean run from the job conclusion alone.

## Acceptance locks
- Keep PR #2773 Draft/open/unmerged until evidence is reviewed.
- Keep `RELEASE: NO-GO`.
- Do not rewrite unrelated product terms: «یادآوری» remains a distinct concept where it means a reminder, while Follow-up UI uses «پیگیری».
- `CHANGELOG.md` was not present at the inspected branch path; this ledger is the scoped validation record rather than inventing a second changelog convention.
