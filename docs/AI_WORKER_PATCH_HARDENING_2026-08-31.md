# AI Worker patch hardening — 2026-08-31

## Live evidence

After PR #574 removed the mandatory external OpenAI secret, issue #529 reached the GitHub Copilot provider successfully. The provider authenticated and ran, but its generated patch was malformed and `git apply` rejected it repeatedly. Product delivery continued through the bounded manual current-main path and PR #575, so automation failure did not block Calendar delivery.

## Hardening in this slice

- keep OpenAI Responses when `OPENAI_API_KEY` is configured;
- keep GitHub Copilot CLI as the GitHub-native fallback;
- retain read-only model tools and keep all repository writes in the trusted runtime/workflow layer;
- require complete unified-diff sections with `diff --git`, `---`, `+++`, and at least one `@@` hunk per file before calling `git apply`;
- normalize CRLF/BOM and strip trailing model fences safely;
- cap each provider call with `ARVIN_PROVIDER_TIMEOUT_SECONDS` (default 180 seconds);
- cap the aggregate provider retry budget with `ARVIN_PROVIDER_BUDGET_SECONDS` (default 540 seconds);
- use one provider request per bounded attempt, eliminating the old nested self-fix request path that could multiply provider calls;
- feed rejected-patch or failed-validation evidence into the next bounded attempt;
- preserve the normal Draft PR → Fast → Ready → Build/APK + Device → Production Orchestrator promotion contract.

## Safety boundary

The model still cannot push, merge, change authentication, or bypass CI. Generated output is treated as untrusted text until structural validation, `git apply --check`, project analyze/test, and the normal repository delivery gates succeed.

## Completion proof

This change is complete only after its exact head passes Fast and the normal Heavy/Device gates, is merged from current main, and a later real `arvin-auto` issue demonstrates either successful PR generation or a bounded, classified failure without stalling Production.
