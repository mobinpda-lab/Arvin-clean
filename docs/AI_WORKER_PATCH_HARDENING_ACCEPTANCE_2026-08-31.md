# AI Worker hardening acceptance checklist

- [x] Branch starts from current main containing PR #575.
- [x] Provider call has an explicit per-call timeout.
- [x] Provider retries have a total budget below the workflow job timeout.
- [x] Malformed unified diffs are structurally rejected before `git apply`.
- [x] Read-only Copilot tool boundary is unchanged.
- [x] Worker still cannot merge.
- [x] Contract test locks timeout, patch-header and single-request-per-attempt behavior.
- [ ] Exact-head Fast succeeds.
- [ ] Ready promotion occurs through the normal orchestrator.
- [ ] Exact-head Build/APK succeeds.
- [ ] Exact-head Home and People Device Smoke succeeds.
- [ ] Guarded merge lands on unchanged current main.
- [ ] A later real `arvin-auto` issue proves bounded Worker behavior end-to-end.
