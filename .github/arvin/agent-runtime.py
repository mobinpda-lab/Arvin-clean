import json
import math
import os
import subprocess
import sys
import time
import urllib.request
from pathlib import Path
from urllib.error import HTTPError

API = "https://api.openai.com/v1/responses"
MODEL = os.getenv("OPENAI_MODEL", "gpt-5.6")
COPILOT_MODEL = os.getenv("ARVIN_COPILOT_MODEL", "auto")
MAX_FILES = int(os.getenv("ARVIN_MAX_FILES", "20"))
MAX_DIFF = int(os.getenv("ARVIN_MAX_DIFF_CHARS", "30000"))
MAX_FIX_ATTEMPTS = int(os.getenv("ARVIN_MAX_AUTO_FIX_ATTEMPTS", "3"))
PROVIDER_TIMEOUT_SECONDS = int(os.getenv("ARVIN_PROVIDER_TIMEOUT_SECONDS", "180"))
PROVIDER_BUDGET_SECONDS = int(os.getenv("ARVIN_PROVIDER_BUDGET_SECONDS", "540"))
PROVIDER_MAX_429_RETRIES = int(os.getenv("ARVIN_PROVIDER_MAX_429_RETRIES", "3"))
PROVIDER_429_BASE_DELAY_SECONDS = int(os.getenv("ARVIN_PROVIDER_429_BASE_DELAY_SECONDS", "5"))
PROVIDER_429_MAX_DELAY_SECONDS = int(os.getenv("ARVIN_PROVIDER_429_MAX_DELAY_SECONDS", "60"))


def run(cmd, check=True, timeout=None):
    return subprocess.run(cmd, text=True, capture_output=True, check=check, timeout=timeout)


def github_json(url):
    req = urllib.request.Request(url, headers={
        "Authorization": f"Bearer {os.environ['GITHUB_TOKEN']}",
        "Accept": "application/vnd.github+json",
        "X-GitHub-Api-Version": "2022-11-28",
    })
    with urllib.request.urlopen(req) as r:
        return json.load(r)


def _retry_after_seconds(error, retry_index):
    header = error.headers.get("Retry-After") if error.headers else None
    try:
        if header is not None:
            return max(0, min(PROVIDER_429_MAX_DELAY_SECONDS, int(float(header))))
    except (TypeError, ValueError):
        pass
    exponential = PROVIDER_429_BASE_DELAY_SECONDS * (2 ** max(0, retry_index - 1))
    return max(0, min(PROVIDER_429_MAX_DELAY_SECONDS, exponential))


def openai_response(prompt, timeout_seconds):
    # GPT-5.6 is a reasoning-family Responses API model. Keep the request
    # limited to model/input so provider-specific sampling parameters cannot
    # make an otherwise valid worker request fail with HTTP 400.
    payload = {"model": MODEL, "input": prompt}
    req = urllib.request.Request(API, data=json.dumps(payload).encode(), headers={
        "Authorization": f"Bearer {os.environ['OPENAI_API_KEY']}",
        "Content-Type": "application/json",
    }, method="POST")
    deadline = time.monotonic() + timeout_seconds
    retry_index = 0
    while True:
        remaining = deadline - time.monotonic()
        if remaining <= 0:
            raise TimeoutError("OpenAI provider retry budget exhausted")
        try:
            with urllib.request.urlopen(req, timeout=max(1, math.ceil(remaining))) as r:
                data = json.load(r)
            break
        except HTTPError as exc:
            if exc.code != 429 or retry_index >= PROVIDER_MAX_429_RETRIES:
                raise
            retry_index += 1
            delay = _retry_after_seconds(exc, retry_index)
            remaining = deadline - time.monotonic()
            if remaining <= 0:
                raise TimeoutError("OpenAI provider retry budget exhausted") from exc
            delay = min(delay, max(0, remaining - 1))
            print(
                f"ARVIN AI provider returned HTTP 429; bounded retry {retry_index}/"
                f"{PROVIDER_MAX_429_RETRIES} after {delay}s",
                file=sys.stderr,
            )
            if delay > 0:
                time.sleep(delay)

    text = data.get("output_text")
    if not text:
        parts = []
        for item in data.get("output", []):
            for c in item.get("content", []):
                if c.get("type") == "output_text":
                    parts.append(c.get("text", ""))
        text = "\n".join(parts)
    return (text or "").strip()


def copilot_response(prompt, timeout_seconds):
    command = [
        "copilot", "-s", "--no-ask-user", "--disable-builtin-mcps",
        "--available-tools=view,grep,glob", "--allow-tool=read",
        "--deny-tool=write", "--deny-tool=shell", "--deny-tool=url",
        "--model", COPILOT_MODEL, "-p", prompt,
    ]
    try:
        result = run(command, check=False, timeout=timeout_seconds)
    except subprocess.TimeoutExpired as exc:
        raise RuntimeError(
            f"GitHub Copilot CLI fallback timed out after {timeout_seconds}s"
        ) from exc
    if result.returncode != 0:
        evidence = (result.stderr or result.stdout or "Copilot CLI failed")[-12000:]
        raise RuntimeError(f"GitHub Copilot CLI fallback failed:\n{evidence}")
    return result.stdout.strip()


def model_response(prompt, timeout_seconds):
    if os.getenv("OPENAI_API_KEY", "").strip():
        print("ARVIN AI provider: OpenAI Responses API")
        return openai_response(prompt, timeout_seconds)
    print("ARVIN AI provider: GitHub Copilot CLI via GITHUB_TOKEN (read-only tools)")
    return copilot_response(prompt, timeout_seconds)


def repo_context():
    files = []
    for p in Path(".").rglob("*"):
        if not p.is_file() or ".git" in p.parts or "build" in p.parts or ".dart_tool" in p.parts:
            continue
        files.append(str(p))
        if len(files) >= MAX_FILES:
            break
    return "\n".join(files)


def project_test():
    if Path("pubspec.yaml").is_file():
        commands = [["flutter", "pub", "get"], ["flutter", "analyze"], ["flutter", "test"]]
    elif Path("package.json").is_file():
        commands = [["npm", "ci"], ["npm", "test", "--if-present"]]
    else:
        return True, "No supported project manifest detected; validation skipped safely."
    output = []
    for command in commands:
        result = run(command, check=False)
        output.append(f"$ {' '.join(command)}\n{result.stdout}\n{result.stderr}")
        if result.returncode != 0:
            return False, "\n".join(output)[-20000:]
    return True, "\n".join(output)[-20000:]


def request_diff(issue_number, title, body, context, failure="", timeout_seconds=None):
    failure_context = ""
    if failure:
        failure_context = f"\nPrevious attempt evidence:\n{failure}\n"
    prompt = f"""You are the bounded Arvin Code Worker. Work only on the requested GitHub issue.

Issue #{issue_number}: {title}
{body}

Repository file inventory:
{context}
{failure_context}
Inspect only repository files needed for this issue. Return ONLY a complete unified git diff beginning with `diff --git`. Every changed file must include its `---` and `+++` file headers followed by complete `@@` hunks. Do not return hunk-only fragments, markdown fences, prose or commentary. Do not modify CI permissions, secrets, authentication, or files outside the issue scope. Prefer the smallest safe change. Reuse canonical models, storage, repositories and UI paths. Add or update focused tests when appropriate. If the issue is not sufficiently specified or cannot be solved safely, return an empty response.
"""
    return model_response(prompt, timeout_seconds)


def normalize_diff(text):
    value = (text or "").replace("\r\n", "\n").replace("\r", "\n").lstrip("\ufeff").strip()
    start = value.find("diff --git ")
    if start < 0:
        return value
    value = value[start:]
    lines = value.splitlines()
    normalized = []
    for line in lines:
        if normalized and line.strip() in {"```", "~~~"}:
            break
        normalized.append(line)
    return "\n".join(normalized).strip()


def validate_diff_structure(diff):
    value = normalize_diff(diff)
    if not value.startswith("diff --git "):
        return False, "Patch must begin with a complete `diff --git` file section"
    lines = value.splitlines()
    starts = [index for index, line in enumerate(lines) if line.startswith("diff --git ")]
    if not starts:
        return False, "No `diff --git` file section found"
    if len(starts) > MAX_FILES:
        return False, "Generated diff exceeds file-count safety limit"
    starts.append(len(lines))
    for section_index in range(len(starts) - 1):
        section = lines[starts[section_index]:starts[section_index + 1]]
        minus = next((i for i, line in enumerate(section) if line.startswith("--- ")), None)
        plus = next((i for i, line in enumerate(section) if line.startswith("+++ ")), None)
        hunk = next((i for i, line in enumerate(section) if line.startswith("@@ ")), None)
        if minus is None or plus is None:
            return False, "Each file section must include both `---` and `+++` headers"
        if hunk is None:
            return False, "Each file section must include at least one complete `@@` hunk"
        if not (minus < plus < hunk):
            return False, "Patch file headers must precede the first hunk"
    return True, "patch structure valid"


def apply_diff(diff):
    diff = normalize_diff(diff)
    if not diff:
        return False, "No actionable diff returned"
    if len(diff) > MAX_DIFF:
        return False, "Generated diff exceeds safety limit"
    valid, structure_message = validate_diff_structure(diff)
    if not valid:
        return False, structure_message
    Path("/tmp/arvin.patch").write_text(f"{diff}\n", encoding="utf-8")
    check = run(
        ["git", "apply", "--check", "--recount", "/tmp/arvin.patch"],
        check=False,
    )
    if check.returncode != 0:
        return False, check.stderr[-10000:]
    applied = run(
        ["git", "apply", "--recount", "--whitespace=fix", "/tmp/arvin.patch"],
        check=False,
    )
    if applied.returncode != 0:
        return False, applied.stderr[-10000:]
    return True, "patch applied"


def next_provider_timeout(deadline):
    remaining = deadline - time.monotonic()
    if remaining <= 0:
        raise TimeoutError("AI provider retry budget exhausted")
    return max(1, min(PROVIDER_TIMEOUT_SECONDS, math.ceil(remaining)))


def main():
    issue_number = os.environ.get("ARVIN_ISSUE_NUMBER")
    if not issue_number:
        print("ARVIN_ISSUE_NUMBER is required", file=sys.stderr)
        return 2
    repo = os.environ["GITHUB_REPOSITORY"]
    issue = github_json(f"https://api.github.com/repos/{repo}/issues/{issue_number}")
    title = issue.get("title", "")
    body = issue.get("body", "") or ""
    context = repo_context()
    provider_deadline = time.monotonic() + PROVIDER_BUDGET_SECONDS
    failure = ""

    for attempt in range(1, MAX_FIX_ATTEMPTS + 1):
        try:
            timeout_seconds = next_provider_timeout(provider_deadline)
            diff = request_diff(
                issue_number, title, body, context, failure,
                timeout_seconds=timeout_seconds,
            )
        except Exception as exc:
            message = f"Attempt {attempt} provider failure: {exc}"
            print(message, file=sys.stderr)
            failure = message
            if attempt == MAX_FIX_ATTEMPTS or time.monotonic() >= provider_deadline:
                return 6
            continue

        ok, message = apply_diff(diff)
        if not ok:
            print(f"Attempt {attempt}: {message}", file=sys.stderr)
            run(["git", "reset", "--hard", "HEAD"], check=False)
            failure = (
                "Previous generated patch was rejected before apply: "
                f"{message}. Return a complete unified diff with `diff --git`, `---`, `+++` "
                "and full `@@` hunks for every file."
            )
            if attempt == MAX_FIX_ATTEMPTS:
                return 4
            continue

        passed, evidence = project_test()
        if passed:
            print(f"AI Worker validation PASS on attempt {attempt}")
            print(normalize_diff(diff))
            return 0

        print(f"AI Worker validation FAIL on attempt {attempt}\n{evidence}", file=sys.stderr)
        failed_patch = run(["git", "diff"], check=False).stdout
        run(["git", "reset", "--hard", "HEAD"], check=False)
        failure = (
            f"Previous patch applied but project validation failed:\n{evidence[-12000:]}\n"
            f"Failed patch for repair context:\n{failed_patch[-12000:]}"
        )
        if attempt == MAX_FIX_ATTEMPTS:
            return 5

    return 5


if __name__ == "__main__":
    raise SystemExit(main())
