import json
import os
import subprocess
import sys
import urllib.request
from pathlib import Path

API = "https://api.openai.com/v1/responses"
MODEL = os.getenv("OPENAI_MODEL", "gpt-5.6")
COPILOT_MODEL = os.getenv("ARVIN_COPILOT_MODEL", "auto")
MAX_FILES = int(os.getenv("ARVIN_MAX_FILES", "20"))
MAX_DIFF = int(os.getenv("ARVIN_MAX_DIFF_CHARS", "30000"))
MAX_FIX_ATTEMPTS = int(os.getenv("ARVIN_MAX_AUTO_FIX_ATTEMPTS", "3"))


def run(cmd, check=True):
    return subprocess.run(cmd, text=True, capture_output=True, check=check)


def github_json(url):
    req = urllib.request.Request(url, headers={
        "Authorization": f"Bearer {os.environ['GITHUB_TOKEN']}",
        "Accept": "application/vnd.github+json",
        "X-GitHub-Api-Version": "2022-11-28",
    })
    with urllib.request.urlopen(req) as r:
        return json.load(r)


def openai_response(prompt):
    payload = {"model": MODEL, "input": prompt, "temperature": 0}
    req = urllib.request.Request(API, data=json.dumps(payload).encode(), headers={
        "Authorization": f"Bearer {os.environ['OPENAI_API_KEY']}",
        "Content-Type": "application/json",
    }, method="POST")
    with urllib.request.urlopen(req) as r:
        data = json.load(r)
    text = data.get("output_text")
    if not text:
        parts = []
        for item in data.get("output", []):
            for c in item.get("content", []):
                if c.get("type") == "output_text":
                    parts.append(c.get("text", ""))
        text = "\n".join(parts)
    return (text or "").strip()


def copilot_response(prompt):
    command = [
        "copilot",
        "-s",
        "--no-ask-user",
        "--disable-builtin-mcps",
        "--available-tools=view,grep,glob",
        "--allow-tool=read",
        "--deny-tool=write",
        "--deny-tool=shell",
        "--deny-tool=url",
        "--model",
        COPILOT_MODEL,
        "-p",
        prompt,
    ]
    result = run(command, check=False)
    if result.returncode != 0:
        evidence = (result.stderr or result.stdout or "Copilot CLI failed")[-12000:]
        raise RuntimeError(f"GitHub Copilot CLI fallback failed:\n{evidence}")
    return result.stdout.strip()


def model_response(prompt):
    if os.getenv("OPENAI_API_KEY", "").strip():
        print("ARVIN AI provider: OpenAI Responses API")
        return openai_response(prompt)
    print("ARVIN AI provider: GitHub Copilot CLI via GITHUB_TOKEN (read-only tools)")
    return copilot_response(prompt)


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


def request_diff(issue_number, title, body, context, failure=""):
    failure_context = ""
    if failure:
        failure_context = f"\nPrevious validation failure:\n{failure}\n"
    prompt = f"""You are the bounded Arvin Code Worker. Work only on the requested GitHub issue.

Issue #{issue_number}: {title}
{body}

Repository file inventory:
{context}
{failure_context}
Inspect only repository files needed for this issue. Return ONLY a unified git diff beginning with `diff --git`. Do not include markdown fences or commentary. Do not modify CI permissions, secrets, authentication, or files outside the issue scope. Prefer the smallest safe change. Reuse canonical models, storage, repositories and UI paths. Add or update focused tests when appropriate. If the issue is not sufficiently specified or cannot be solved safely, return an empty response.
"""
    return model_response(prompt)


def normalize_diff(text):
    value = (text or "").strip()
    if value.startswith("```"):
        first_newline = value.find("\n")
        if first_newline >= 0:
            value = value[first_newline + 1:]
        if value.endswith("```"):
            value = value[:-3].rstrip()
    start = value.find("diff --git ")
    if start > 0:
        value = value[start:]
    return value


def apply_diff(diff):
    diff = normalize_diff(diff)
    if not diff or "diff --git" not in diff:
        return False, "No actionable diff returned"
    if len(diff) > MAX_DIFF:
        return False, "Generated diff exceeds safety limit"
    Path("/tmp/arvin.patch").write_text(diff, encoding="utf-8")
    check = run(["git", "apply", "--check", "/tmp/arvin.patch"], check=False)
    if check.returncode != 0:
        return False, check.stderr[-10000:]
    applied = run(["git", "apply", "--whitespace=fix", "/tmp/arvin.patch"], check=False)
    if applied.returncode != 0:
        return False, applied.stderr[-10000:]
    return True, "patch applied"


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

    for attempt in range(1, MAX_FIX_ATTEMPTS + 1):
        try:
            diff = request_diff(issue_number, title, body, context)
        except Exception as exc:
            print(str(exc), file=sys.stderr)
            return 6
        ok, message = apply_diff(diff)
        if not ok:
            print(f"Attempt {attempt}: {message}", file=sys.stderr)
            if attempt == MAX_FIX_ATTEMPTS:
                return 4
            run(["git", "reset", "--hard", "HEAD"], check=False)
            continue

        passed, evidence = project_test()
        if passed:
            print(f"AI Worker validation PASS on attempt {attempt}")
            print(normalize_diff(diff))
            return 0

        print(f"AI Worker validation FAIL on attempt {attempt}\n{evidence}", file=sys.stderr)
        if attempt == MAX_FIX_ATTEMPTS:
            return 5
        failure_diff = run(["git", "diff"], check=False).stdout
        run(["git", "reset", "--hard", "HEAD"], check=False)
        context = f"{context}\nCurrent failed patch:\n{failure_diff[-12000:]}"
        try:
            diff = request_diff(issue_number, title, body, context, evidence)
        except Exception as exc:
            print(str(exc), file=sys.stderr)
            return 6
        ok, message = apply_diff(diff)
        if not ok:
            print(f"Fix attempt {attempt} patch rejected: {message}", file=sys.stderr)
            run(["git", "reset", "--hard", "HEAD"], check=False)
            continue
        passed, evidence = project_test()
        if passed:
            print(f"AI Worker self-fix PASS on attempt {attempt}")
            print(normalize_diff(diff))
            return 0
        if attempt == MAX_FIX_ATTEMPTS:
            print(evidence, file=sys.stderr)
            return 5
        run(["git", "reset", "--hard", "HEAD"], check=False)
        context = f"{context}\nLatest failed fix evidence:\n{evidence[-12000:]}"

    return 5


if __name__ == "__main__":
    raise SystemExit(main())
