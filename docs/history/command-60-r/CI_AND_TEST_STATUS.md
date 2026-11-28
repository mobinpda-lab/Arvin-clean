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


## Lane D first validation — PR #3547
Head: `1c83db84145675aa31e67feef95c23ddd84c181c`; Build run `44417802140`.
- Analyze: SUCCESS.
- test-0, test-1, test-3, test-4, test-5: SUCCESS.
- test-1 executor lifecycle correction: SUCCESS.
- test-2: FAILURE — Person Directory removal test expected an empty directory but got one PersonReference. This is a real rehydration bug, not a text assertion issue.
- Debug APK and Release APK: SUCCESS.
- Device Smoke run `44417802091`: Home and Quick Capture were running at last poll; remaining scenarios queued.
- Follow-up Persistence `44417801990`: SUCCESS.

Lane A PR #3549 current head `ce9ce1d755ae994d1f2567285304dc23b07aa823` includes the additive tombstone fix, test-1 executor correction, full dialog-copy assertion and file-backed occurrence/person exclusion tests. Build `44418907693`, Device Smoke `44418907517`, Follow-up Persistence `44418907531` are queued/pending at last poll. No pass claimed.


## Lane B validation — PR #3548
Head: `d6c7ebe135e8422fea37a85cd22eb0927e129770`.
- Follow-up File Persistence: SUCCESS.
- Build test-4: SUCCESS.
- Build test-1: FAILURE in the same pre-existing V8→V9 executor lifecycle fixture (`QueryExecutor.ensureOpen()` missing before setup SQL). This is addressed in lane A PR #3549; lane B must be re-run after integration.
- Build test-5: IN PROGRESS at last poll; other jobs queued.
- Device Smoke Quick Capture: IN PROGRESS at last poll; other scenarios queued.
- UI lane remains NOT ACCEPTED.
