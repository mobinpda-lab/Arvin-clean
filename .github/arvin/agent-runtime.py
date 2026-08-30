import json
import os
import subprocess
import sys
import urllib.request
from pathlib import Path

API = "https://api.openai.com/v1/responses"
MODEL = os.getenv("OPENAI_MODEL", "gpt-5.6")
MAX_FILES = int(os.getenv("ARVIN_MAX_FILES", "20"))
MAX_DIFF = int(os.getenv("ARVIN_MAX_DIFF_CHARS", "30000"))


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


def openai(prompt):
    payload = {
        "model": MODEL,
        "input": prompt,
        "temperature": 0,
    }
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
    return text.strip()


def repo_context():
    files = []
    for p in Path(".").rglob("*"):
        if not p.is_file() or ".git" in p.parts or "build" in p.parts or ".dart_tool" in p.parts:
            continue
        files.append(str(p))
        if len(files) >= MAX_FILES:
            break
    return "\n".join(files)


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
    prompt = f"""You are the bounded Arvin Code Worker. Work only on the requested GitHub issue.\n\nIssue #{issue_number}: {title}\n{body}\n\nRepository file inventory:\n{context}\n\nReturn ONLY a unified git diff. Do not include markdown fences. Do not modify CI permissions, secrets, authentication, or files outside the issue scope. Prefer the smallest safe change. Add or update tests when appropriate. If the issue is not sufficiently specified, return an empty diff.\n"""
    diff = openai(prompt)
    if not diff or "diff --git" not in diff:
        print("No actionable diff returned")
        return 0
    if len(diff) > MAX_DIFF:
        print("Generated diff exceeds safety limit", file=sys.stderr)
        return 3
    Path("/tmp/arvin.patch").write_text(diff, encoding="utf-8")
    result = run(["git", "apply", "--check", "/tmp/arvin.patch"], check=False)
    if result.returncode != 0:
        print(result.stderr, file=sys.stderr)
        return 4
    run(["git", "apply", "--whitespace=fix", "/tmp/arvin.patch"])
    print(diff)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
