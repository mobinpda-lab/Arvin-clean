# CI AND TEST STATUS — INITIAL EXACT-SHA BASELINE
**SHA:** `871abadc158464b6059d88350b1cb6fb48def7df`

| Workflow | Run | Result | Meaning |
|---|---:|---|---|
| Build | 44408378276 | FAILURE | Analyze and both APKs passed; test-1 and test-2 failed |
| Device Smoke | 44408378348 | SUCCESS | Seven emulator scenarios; not physical phone acceptance |
| COMMAND 20-E | 44408378416 | FAILURE | ProjectStore file persistence and fresh-process SharedPreferences phase passed; final acceptance JSON not PASS |
| Follow-up File Persistence | 44408378334 | SUCCESS | Focused persistence lane only |

## Build details
- Analyze: SUCCESS.
- Test-0: SUCCESS.
- Test-1: FAILURE — Drift executor lifecycle in V8→V9 test.
- Test-2: FAILURE — Person Directory delete dialog expected text missing.
- Test-3: SUCCESS.
- Test-4: SUCCESS.
- Test-5: SUCCESS.
- Debug APK: SUCCESS.
- Release APK build/package verification: SUCCESS. This is a CI validation artifact, not an owner-signed release candidate.

## Required follow-up
Preserve all six shards and fix the two actual failures. Re-run full Build, Device Smoke, COMMAND 20-E and persistence workflows on one exact new SHA.
