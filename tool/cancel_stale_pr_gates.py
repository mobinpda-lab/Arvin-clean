#!/usr/bin/env python3
"""Cancel only stale heavy PR gates after main advances.

Runs on a push to main/master. It inspects queued/in-progress pull-request
runs for Arvin Build and Arvin Device Smoke. A run is cancelled only when
GitHub proves that the PR head no longer contains the current main commit.
Uncertain API evidence is logged and skipped rather than cancelled.
"""

from __future__ import annotations

import json
import os
import sys
import urllib.error
import urllib.request
from typing import Any

API_ROOT = "https://api.github.com"
HEAVY_WORKFLOWS = {"Arvin Build", "Arvin Device Smoke"}
ACTIVE_STATUSES = ("queued", "in_progress")


def _request(
    method: str,
    path: str,
    *,
    token: str,
    payload: dict[str, Any] | None = None,
) -> Any:
    data = None if payload is None else json.dumps(payload).encode("utf-8")
    request = urllib.request.Request(
        f"{API_ROOT}{path}",
        data=data,
        method=method,
        headers={
            "Accept": "application/vnd.github+json",
            "Authorization": f"Bearer {token}",
            "X-GitHub-Api-Version": "2022-11-28",
            "User-Agent": "arvin-stale-gate-guard",
        },
    )
    with urllib.request.urlopen(request, timeout=30) as response:
        raw = response.read()
        return None if not raw else json.loads(raw.decode("utf-8"))


def head_contains_current_main(compare_payload: dict[str, Any], current_main: str) -> bool:
    """Return True only when compare evidence proves head contains main."""
    status = compare_payload.get("status")
    if status in {"ahead", "identical"}:
        return True
    merge_base = compare_payload.get("merge_base_commit") or {}
    return merge_base.get("sha") == current_main


def _pr_number(run: dict[str, Any]) -> int | None:
    pull_requests = run.get("pull_requests") or []
    if not pull_requests:
        return None
    number = pull_requests[0].get("number")
    return number if isinstance(number, int) else None


def _list_active_runs(repository: str, token: str) -> list[dict[str, Any]]:
    runs: list[dict[str, Any]] = []
    for status in ACTIVE_STATUSES:
        payload = _request(
            "GET",
            f"/repos/{repository}/actions/runs?status={status}&per_page=100",
            token=token,
        )
        runs.extend(payload.get("workflow_runs") or [])
    return runs


def run_guard(repository: str, token: str, current_main: str) -> int:
    cancelled = 0
    seen: set[int] = set()

    for run in _list_active_runs(repository, token):
        run_id = run.get("id")
        if not isinstance(run_id, int) or run_id in seen:
            continue
        seen.add(run_id)

        name = run.get("name")
        event = run.get("event")
        if name not in HEAVY_WORKFLOWS or event != "pull_request":
            continue

        pr_number = _pr_number(run)
        if pr_number is None:
            print(f"skip run={run_id} workflow={name}: no PR number evidence")
            continue

        try:
            pr = _request(
                "GET",
                f"/repos/{repository}/pulls/{pr_number}",
                token=token,
            )
            head_sha = ((pr.get("head") or {}).get("sha") or "").strip()
            if not head_sha:
                print(f"skip run={run_id} pr=#{pr_number}: no head SHA")
                continue

            comparison = _request(
                "GET",
                f"/repos/{repository}/compare/{current_main}...{head_sha}",
                token=token,
            )
            status = comparison.get("status")
            merge_base = (comparison.get("merge_base_commit") or {}).get("sha")

            if head_contains_current_main(comparison, current_main):
                print(
                    f"keep run={run_id} workflow={name} pr=#{pr_number} "
                    f"head={head_sha} main={current_main} status={status} "
                    f"merge_base={merge_base}"
                )
                continue

            print(
                f"cancel run={run_id} workflow={name} pr=#{pr_number} "
                f"head={head_sha} main={current_main} status={status} "
                f"merge_base={merge_base}"
            )
            _request(
                "POST",
                f"/repos/{repository}/actions/runs/{run_id}/cancel",
                token=token,
            )
            cancelled += 1
        except (urllib.error.URLError, urllib.error.HTTPError, KeyError, TypeError) as error:
            print(
                f"skip run={run_id} workflow={name} pr=#{pr_number}: "
                f"uncertain API evidence ({error})",
                file=sys.stderr,
            )

    print(f"Arvin stale heavy gate guard: cancelled={cancelled}")
    return cancelled


def _self_test() -> None:
    main = "main-sha"
    assert head_contains_current_main({"status": "identical"}, main)
    assert head_contains_current_main({"status": "ahead"}, main)
    assert head_contains_current_main(
        {"status": "diverged", "merge_base_commit": {"sha": main}}, main
    )
    assert not head_contains_current_main(
        {"status": "behind", "merge_base_commit": {"sha": "older"}}, main
    )
    assert not head_contains_current_main(
        {"status": "diverged", "merge_base_commit": {"sha": "older"}}, main
    )
    print("Arvin stale heavy gate guard self-test: OK")


def main() -> int:
    if "--self-test" in sys.argv:
        _self_test()
        return 0

    repository = os.environ.get("GITHUB_REPOSITORY", "").strip()
    token = os.environ.get("GITHUB_TOKEN", "").strip()
    current_main = os.environ.get("GITHUB_SHA", "").strip()
    if not repository or not token or not current_main:
        print("GITHUB_REPOSITORY, GITHUB_TOKEN and GITHUB_SHA are required", file=sys.stderr)
        return 2

    run_guard(repository, token, current_main)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
