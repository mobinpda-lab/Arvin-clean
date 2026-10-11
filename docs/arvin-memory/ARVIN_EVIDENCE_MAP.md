# Arvin Evidence Map
**Checkpoint:** 2026-10-11  
**Rule:** Evidence applies only to the exact commit/PR head and workflow result named.

| Feature / area | Code / reference | Test/build evidence | Validation status |
|---|---|---|---|
| Backup/restore preservation | Main commit [a6ced276](https://github.com/mobinpda-lab/Arvin-clean/commit/a6ced27660d34cd87dd8915aff68d3a7555fd57a) | Commit message reports Build and Android Device Smoke validation | Commit-level evidence exists; still verify user restore flow on the target installed version |
| Shared Universal Arvin Time Picker | [PR #2591](https://github.com/mobinpda-lab/Arvin-clean/pull/2591), head `eae0394163a958223b79fc3b7aa914f79b664b8a` | Arvin Build success; Device Smoke skipped | Not device-accepted; Report PR integration still needs reconciliation |
| Report pastel UI/date filter | [PR #2607](https://github.com/mobinpda-lab/Arvin-clean/pull/2607), head `7526dc186a26d099368fb288fdc7891ed57222ce` | Arvin Build success; Device Smoke skipped | Draft; generic time picker was identified as a gap before the shared-picker reconciliation |
| Task Editor taxonomy/progressive disclosure | [PR #2602](https://github.com/mobinpda-lab/Arvin-clean/pull/2602), earlier head `15c40a81ec7e45fe690de40ebbd9cf005e57af80`; test fixes now on branch | Release/Debug APK and Analyze succeeded on run `38139809938`; test shard 5 failed with 4 tests and shards 0/4 were still in progress at last check | Fresh exact-head CI is pending for head `879c2bf618e53f3f0bf57f7592e60ea4b8cdde6d` |
| Recurrence default/date-time | [PR #2606](https://github.com/mobinpda-lab/Arvin-clean/pull/2606), head `323b5a6afddd7977450ead87467e5d9dac206b04` | Build success; Device Smoke skipped | Draft; device acceptance pending |
| Installed-device Calendar identity/actions | [#2248](https://github.com/mobinpda-lab/Arvin-clean/issues/2248), [#2535](https://github.com/mobinpda-lab/Arvin-clean/issues/2535) | Owner-reported issues remain open | No fresh owner/device evidence to close |
| Release readiness | [draft release entries](https://github.com/mobinpda-lab/Arvin-clean/releases) | No stable published release was returned by current release query | Not proven release-ready |

## Evidence gaps
- Physical device validation/owner acceptance for the currently open UI and report changes.
- Final exact-head full tests for Task Editor test fixes.
- Combined report filter + shared time picker exact-head validation.
- Fresh install/restore/calendar/recurrence acceptance on the release candidate.
