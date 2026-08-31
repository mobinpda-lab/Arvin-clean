# ARVIN AI Code Worker provider fallback — 2026-08-31

## Problem proven live
Issue #529 reached the AI Code Worker correctly, but the worker stopped before implementation because the optional repository secret `OPENAI_API_KEY` was empty.

## Provider policy
1. If `OPENAI_API_KEY` is configured, keep using the existing OpenAI Responses API path.
2. If it is absent, install GitHub Copilot CLI in the GitHub Actions runner and authenticate with the built-in `GITHUB_TOKEN` through `copilot-requests: write`.
3. Copilot is restricted to read-only repository inspection (`view`, `grep`, `glob` / read permission). File writes, shell execution, URL access and built-in MCP servers are denied.
4. The model returns a unified diff only. The existing Arvin runtime remains responsible for checking, applying and validating that diff.
5. The Worker never merges. It opens/updates a Draft PR, triggers exact-head Fast, and delegates promotion to the canonical Production Orchestrator.

## Build reliability
The Worker now sets up Flutter before its own validation and explicitly runs `flutter pub get`, `flutter analyze`, and `flutter test` before producing a PR.

## Failure semantics
Copilot availability is still subject to the repository/account Copilot policy and entitlement. If the GitHub-native provider is unavailable, the Worker fails explicitly rather than silently mutating code or bypassing CI. Product work must then continue through a normal reviewed PR while the provider policy is corrected.
