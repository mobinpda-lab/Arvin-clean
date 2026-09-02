import json, math, os, re, subprocess, sys, time, urllib.request
from pathlib import Path

API = "https://api.openai.com/v1/responses"
MODEL = os.getenv("OPENAI_MODEL", "gpt-5.6")
MAX_FILES = int(os.getenv("ASF_MAX_CONTEXT_FILES", "60"))
MAX_FILE_CHARS = int(os.getenv("ASF_MAX_FILE_CHARS", "6000"))
MAX_CONTEXT_CHARS = int(os.getenv("ASF_MAX_CONTEXT_CHARS", "120000"))
MAX_DIFF = int(os.getenv("ASF_MAX_DIFF_CHARS", "50000"))
MAX_FIX_ATTEMPTS = int(os.getenv("ARVIN_MAX_AUTO_FIX_ATTEMPTS", "3"))
PROVIDER_TIMEOUT = int(os.getenv("ARVIN_PROVIDER_TIMEOUT_SECONDS", "180"))
PROVIDER_BUDGET = int(os.getenv("ARVIN_PROVIDER_BUDGET_SECONDS", "540"))
LEASE_SECONDS = int(os.getenv("ASF_LEASE_SECONDS", "1800"))
SECRET_PATTERNS = re.compile(r"(^|/)(\.env|.*\.pem|.*\.p12|.*\.jks|.*\.keystore|.*credentials.*|.*secret.*)$", re.I)
TEXT_EXTENSIONS = {".dart", ".kt", ".kts", ".java", ".xml", ".gradle", ".yaml", ".yml", ".json", ".md", ".txt", ".properties", ".toml", ".py", ".sh"}

def run(cmd, check=True, timeout=None):
    return subprocess.run(cmd, text=True, capture_output=True, check=check, timeout=timeout)

def github_json(url):
    req = urllib.request.Request(url, headers={"Authorization": f"Bearer {os.environ['GITHUB_TOKEN']}", "Accept": "application/vnd.github+json", "X-GitHub-Api-Version": "2022-11-28"})
    with urllib.request.urlopen(req, timeout=30) as response: return json.load(response)

def post_comment(issue_number, body):
    repo = os.environ["GITHUB_REPOSITORY"]
    req = urllib.request.Request(f"https://api.github.com/repos/{repo}/issues/{issue_number}/comments", data=json.dumps({"body": body}).encode(), headers={"Authorization": f"Bearer {os.environ['GITHUB_TOKEN']}", "Accept": "application/vnd.github+json", "X-GitHub-Api-Version": "2022-11-28", "Content-Type": "application/json"}, method="POST")
    with urllib.request.urlopen(req, timeout=30): pass

def lease(issue_number):
    now = int(time.time()); marker = f"<!-- asf-lease:{issue_number} -->"
    comments = github_json(f"https://api.github.com/repos/{os.environ['GITHUB_REPOSITORY']}/issues/{issue_number}/comments?per_page=100")
    for comment in comments:
        body = comment.get("body") or ""
        if marker in body:
            match = re.search(r"expires=(\d+)", body)
            if match and int(match.group(1)) > now: raise RuntimeError(f"active worker lease already exists for issue #{issue_number}")
    post_comment(issue_number, f"{marker}\nworker={os.getenv('GITHUB_RUN_ID','unknown')}\nexpires={now + LEASE_SECONDS}\nstatus=RUNNING")

def openai_response(prompt, timeout_seconds):
    key = os.getenv("OPENAI_API_KEY", "").strip()
    if not key: raise RuntimeError("WAITING_AI_PROVIDER: OPENAI_API_KEY is not configured")
    payload = {"model": MODEL, "input": prompt, "temperature": 0}
    req = urllib.request.Request(API, data=json.dumps(payload).encode(), headers={"Authorization": f"Bearer {key}", "Content-Type": "application/json"}, method="POST")
    with urllib.request.urlopen(req, timeout=timeout_seconds) as response: data = json.load(response)
    text = data.get("output_text")
    if not text: text = "\n".join(c.get("text", "") for item in data.get("output", []) for c in item.get("content", []) if c.get("type") == "output_text")
    return (text or "").strip()

def build_context(title, body):
    terms = set(re.findall(r"[A-Za-z0-9_]{3,}", f"{title} {body}".lower())); paths=[]
    for path in run(["git", "ls-files"], check=False).stdout.splitlines():
        p=Path(path)
        if SECRET_PATTERNS.search(path) or p.suffix.lower() not in TEXT_EXTENSIONS: continue
        low=path.lower(); score=0
        if low in {"readme.md","pubspec.yaml"}: score+=20
        if low.startswith("docs/"): score+=8
        if any(term in low for term in terms): score+=4
        if any(part in low for part in ("lib/","test/",".github/")): score+=3
        paths.append((score,path))
    paths.sort(key=lambda x:(-x[0],x[1])); out=[]; total=0
    for _,path in paths[:MAX_FILES]:
        try:text=Path(path).read_text(encoding="utf-8")[:MAX_FILE_CHARS]
        except (OSError,UnicodeDecodeError):continue
        chunk=f"\n===== {path} =====\n{text}\n"
        if total+len(chunk)>MAX_CONTEXT_CHARS: break
        out.append(chunk); total+=len(chunk)
    return "".join(out)

def project_test():
    if Path("pubspec.yaml").is_file(): commands=[["flutter","pub","get"],["flutter","analyze"],["flutter","test"]]
    elif Path("gradlew").is_file(): commands=[["./gradlew","test"]]
    elif Path("package.json").is_file(): commands=[["npm","ci"],["npm","test","--if-present"]]
    else:return True,"No supported project manifest."
    evidence=[]
    for command in commands:
        result=run(command,check=False,timeout=900); evidence.append(f"$ {' '.join(command)}\n{result.stdout}\n{result.stderr}")
        if result.returncode!=0:return False,"\n".join(evidence)[-30000:]
    return True,"\n".join(evidence)[-30000:]

def normalize_diff(text):
    value=(text or "").replace("\r\n","\n").replace("\r","\n").lstrip("\ufeff").strip(); start=value.find("diff --git ")
    if start<0:return value
    lines=[]
    for line in value[start:].splitlines():
        if lines and line.strip() in {"```","~~~"}:break
        lines.append(line)
    return "\n".join(lines).strip()

def validate_diff_structure(diff):
    value=normalize_diff(diff)
    if not value.startswith("diff --git "):return False,"Patch must begin with a complete `diff --git` file section"
    lines=value.splitlines(); starts=[i for i,l in enumerate(lines) if l.startswith("diff --git ")]
    if not starts:return False,"No `diff --git` file section found"
    if len(starts)>MAX_FILES:return False,"Generated diff exceeds file-count safety limit"
    starts.append(len(lines))
    for section_start,section_end in zip(starts,starts[1:]):
        section=lines[section_start:section_end]
        minus=next((i for i,l in enumerate(section) if l.startswith("--- ")),None)
        plus=next((i for i,l in enumerate(section) if l.startswith("+++ ")),None)
        hunk=next((i for i,l in enumerate(section) if l.startswith("@@ ")),None)
        if minus is None or plus is None:return False,"Each file section must include both `---` and `+++` headers"
        if hunk is None:return False,"Each file section must include at least one complete `@@` hunk"
        if not(minus<plus<hunk):return False,"Patch file headers must precede the first hunk"
    return True,"patch structure valid"

def apply_diff(diff):
    diff=normalize_diff(diff)
    if not diff:return False,"No actionable diff returned"
    if len(diff)>MAX_DIFF:return False,"Generated diff exceeds safety limit"
    valid,message=validate_diff_structure(diff)
    if not valid:return False,message
    Path("/tmp/arvin-worker.patch").write_text(diff+"\n",encoding="utf-8")
    check=run(["git","apply","--check","--recount","/tmp/arvin-worker.patch"],check=False)
    if check.returncode!=0:return False,check.stderr[-12000:]
    applied=run(["git","apply","--recount","--whitespace=fix","/tmp/arvin-worker.patch"],check=False)
    if applied.returncode!=0:return False,applied.stderr[-12000:]
    return True,"patch applied"

def prompt(issue_number,title,body,context,failure):
    repair=f"\nPrevious failure evidence:\n{failure}\n" if failure else ""
    return f"""You are the bounded autonomous Code Worker for {os.environ['GITHUB_REPOSITORY']}.\nImplement ONLY GitHub Issue #{issue_number}.\nTitle: {title}\nIssue body:\n{body}\n{repair}\nRepository context:\n{context}\nRules: preserve canonical architecture; do not invent scope; do not touch secrets/credentials or unrelated CI controls; prefer the smallest safe implementation and focused tests; return ONLY a complete unified git diff beginning with diff --git; every changed file needs --- +++ and complete @@ hunks; return empty output if the task cannot be safely solved from context."""

def main():
    raw=os.getenv("ARVIN_ISSUE_NUMBER")
    if not raw:return 2
    issue_number=int(raw); expected=os.getenv("ARVIN_EXPECTED_MAIN_SHA","").strip(); repo=os.environ["GITHUB_REPOSITORY"]
    main_sha=github_json(f"https://api.github.com/repos/{repo}/branches/main")["commit"]["sha"]
    if expected and main_sha!=expected:
        post_comment(issue_number,f"<!-- arvin-worker-result -->\nstatus=REQUEUED\nreason=MAIN_MOVED\nexpected={expected}\nactual={main_sha}"); return 7
    issue=github_json(f"https://api.github.com/repos/{repo}/issues/{issue_number}")
    if "arvin-auto" not in {x.get("name") for x in issue.get("labels",[])}:raise RuntimeError("Issue is not opted into Arvin autonomous execution")
    lease(issue_number); title,body=issue.get("title",""),issue.get("body","") or ""; context=build_context(title,body); deadline=time.monotonic()+PROVIDER_BUDGET; failure=""
    for attempt in range(1,MAX_FIX_ATTEMPTS+1):
        remaining=deadline-time.monotonic()
        if remaining<=0:break
        try:diff=openai_response(prompt(issue_number,title,body,context,failure),max(1,min(PROVIDER_TIMEOUT,math.ceil(remaining))))
        except Exception as exc:failure=str(exc);continue
        if not diff:failure="AI returned no actionable diff";continue
        ok,message=apply_diff(diff)
        if not ok:run(["git","reset","--hard","HEAD"],check=False);failure=f"Patch rejected: {message}";continue
        passed,evidence=project_test()
        if passed:print("ARVIN_CODE_WORKER_PASS");return 0
        failed_patch=run(["git","diff"],check=False).stdout[-20000:];run(["git","reset","--hard","HEAD"],check=False);failure=f"Tests failed:\n{evidence}\nFailed patch:\n{failed_patch}"
    post_comment(issue_number,f"<!-- arvin-worker-result -->\nstatus=WAITING_AI_PROVIDER_OR_RETRY\nreason={failure[-5000:]}");return 6

if __name__=="__main__":raise SystemExit(main())