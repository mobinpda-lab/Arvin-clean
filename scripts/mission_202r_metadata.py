#!/usr/bin/env python3
"""Generate and independently validate the REV10 mission 202-R trace contract."""
from __future__ import annotations
import argparse, hashlib, json, os, re, sys, tempfile, unittest
from pathlib import Path
REQUIRED=("mission_id","repository","branch","commit_sha","workflow_run_id","run_attempt","trace_file","trace_sha256")
def sha256_file(path:Path)->str:
    digest=hashlib.sha256()
    with path.open("rb") as stream:
        for chunk in iter(lambda:stream.read(1024*1024),b""): digest.update(chunk)
    return digest.hexdigest()
def write_metadata(trace_path:Path,metadata_path:Path,values:dict)->dict:
    if not trace_path.is_file(): raise ValueError("required trace file is missing")
    data={"mission_id":"202-R","repository":values["repository"],"branch":values["branch"],
      "commit_sha":values["commit_sha"],"workflow_run_id":values["workflow_run_id"],
      "run_attempt":int(values["run_attempt"]),"trace_file":trace_path.name,"trace_sha256":sha256_file(trace_path)}
    metadata_path.parent.mkdir(parents=True,exist_ok=True)
    metadata_path.write_text(json.dumps(data,indent=2,sort_keys=True)+"\n",encoding="utf-8")
    return data
def validate(trace_path:Path,metadata_path:Path,expected:dict)->dict:
    if not trace_path.is_file() or not metadata_path.is_file(): raise ValueError("required trace or metadata file is missing")
    try: data=json.loads(metadata_path.read_text(encoding="utf-8"))
    except (UnicodeDecodeError,json.JSONDecodeError) as exc: raise ValueError("metadata JSON is malformed") from exc
    if not isinstance(data,dict) or any(k not in data for k in REQUIRED): raise ValueError("required metadata field is absent")
    if data["mission_id"]!="202-R": raise ValueError("mission identity mismatch")
    if data["repository"]!=expected["repository"] or data["branch"]!=expected["branch"]: raise ValueError("repository or branch mismatch")
    if data["commit_sha"]!=expected["commit_sha"] or data["workflow_run_id"]!=expected["workflow_run_id"]: raise ValueError("commit SHA or workflow Run ID mismatch")
    if data["run_attempt"]!=expected["run_attempt"]: raise ValueError("Run Attempt mismatch")
    if not isinstance(data["commit_sha"],str) or not re.fullmatch(r"[0-9a-f]{40}",data["commit_sha"]): raise ValueError("commit SHA is invalid")
    if not isinstance(data["workflow_run_id"],str) or not data["workflow_run_id"].isdigit(): raise ValueError("workflow Run ID is invalid")
    if not isinstance(data["run_attempt"],int) or isinstance(data["run_attempt"],bool) or data["run_attempt"]<1: raise ValueError("Run Attempt is invalid")
    if data["trace_file"]!=trace_path.name: raise ValueError("trace filename mismatch")
    if not isinstance(data["trace_sha256"],str) or not re.fullmatch(r"[0-9a-f]{64}",data["trace_sha256"]): raise ValueError("trace SHA-256 field is invalid")
    if sha256_file(trace_path)!=data["trace_sha256"]: raise ValueError("trace SHA-256 digest mismatch")
    return data
class MetadataContractTests(unittest.TestCase):
    def setUp(self):
        self.tmp=tempfile.TemporaryDirectory(); self.root=Path(self.tmp.name)
        self.trace=self.root/"arvin-async-trace.jsonl"; self.meta=self.root/"metadata.json"
        self.trace.write_text('{"event_type":"START"}\n',encoding="utf-8")
        self.expected={"repository":"mobinpda-lab/Arvin-clean","branch":"recovery-02/main-based-integration","commit_sha":"a"*40,"workflow_run_id":"123456789","run_attempt":1}
        write_metadata(self.trace,self.meta,self.expected)
    def tearDown(self): self.tmp.cleanup()
    def test_01_calculates_digest_from_actual_jsonl(self): self.assertEqual(json.loads(self.meta.read_text())["trace_sha256"],sha256_file(self.trace))
    def test_02_independent_digest_check_rejects_changed_trace(self):
        self.trace.write_text(self.trace.read_text()+"{}\n")
        with self.assertRaisesRegex(ValueError,"digest mismatch"): validate(self.trace,self.meta,self.expected)
    def test_03_rejects_wrong_mission_identity(self):
        d=json.loads(self.meta.read_text()); d["mission_id"]="189-R"; self.meta.write_text(json.dumps(d))
        with self.assertRaisesRegex(ValueError,"mission identity"): validate(self.trace,self.meta,self.expected)
    def test_04_rejects_repository_or_branch_mismatch(self):
        d=json.loads(self.meta.read_text()); d["branch"]="main"; self.meta.write_text(json.dumps(d))
        with self.assertRaisesRegex(ValueError,"repository or branch"): validate(self.trace,self.meta,self.expected)
    def test_05_rejects_wrong_commit_sha_or_run_id(self):
        d=json.loads(self.meta.read_text()); d["commit_sha"]="b"*40; self.meta.write_text(json.dumps(d))
        with self.assertRaisesRegex(ValueError,"commit SHA or workflow Run ID"): validate(self.trace,self.meta,self.expected)
    def test_06_rejects_wrong_run_attempt(self):
        d=json.loads(self.meta.read_text()); d["run_attempt"]=2; self.meta.write_text(json.dumps(d))
        with self.assertRaisesRegex(ValueError,"Run Attempt mismatch"): validate(self.trace,self.meta,self.expected)
    def test_07_fails_when_required_file_is_missing(self):
        self.meta.unlink()
        with self.assertRaisesRegex(ValueError,"file is missing"): validate(self.trace,self.meta,self.expected)
    def test_08_fails_when_json_is_malformed(self):
        self.meta.write_text("{broken",encoding="utf-8")
        with self.assertRaisesRegex(ValueError,"malformed"): validate(self.trace,self.meta,self.expected)
    def test_09_fails_when_required_field_is_absent(self):
        d=json.loads(self.meta.read_text()); del d["trace_file"]; self.meta.write_text(json.dumps(d))
        with self.assertRaisesRegex(ValueError,"field is absent"): validate(self.trace,self.meta,self.expected)
    def test_10_fails_when_required_field_is_invalid(self):
        d=json.loads(self.meta.read_text()); d["trace_sha256"]="invalid"; self.meta.write_text(json.dumps(d))
        with self.assertRaisesRegex(ValueError,"SHA-256 field is invalid"): validate(self.trace,self.meta,self.expected)
def main():
    p=argparse.ArgumentParser()
    p.add_argument("--write",action="store_true"); p.add_argument("--validate",action="store_true"); p.add_argument("--self-test",action="store_true")
    p.add_argument("--trace-file",type=Path,default=Path("arvin-trace/arvin-async-trace.jsonl"))
    p.add_argument("--metadata-file",type=Path,default=Path("arvin-trace/metadata.json"))
    p.add_argument("--repository",default=os.environ.get("GITHUB_REPOSITORY",""))
    p.add_argument("--branch",default=os.environ.get("GITHUB_HEAD_REF") or os.environ.get("GITHUB_REF_NAME",""))
    p.add_argument("--commit-sha",default=os.environ.get("TARGET_SHA",""))
    p.add_argument("--workflow-run-id",default=os.environ.get("GITHUB_RUN_ID",""))
    p.add_argument("--run-attempt",default=os.environ.get("GITHUB_RUN_ATTEMPT",""))
    a=p.parse_args()
    if a.self_test:
        suite=unittest.defaultTestLoader.loadTestsFromTestCase(MetadataContractTests)
        return 0 if unittest.TextTestRunner(verbosity=2).run(suite).wasSuccessful() else 1
    values={"repository":a.repository,"branch":a.branch,"commit_sha":a.commit_sha,"workflow_run_id":a.workflow_run_id,"run_attempt":a.run_attempt}
    if not all(values.values()): raise SystemExit("required GitHub execution identity is unavailable")
    if a.write: write_metadata(a.trace_file,a.metadata_file,values)
    if a.validate: validate(a.trace_file,a.metadata_file,{**values,"run_attempt":int(a.run_attempt)})
    print("MISSION_202R_METADATA=VALID"); return 0
if __name__=="__main__":
    try: sys.exit(main())
    except (ValueError,OSError) as exc:
        print(f"MISSION_202R_METADATA=INVALID: {exc}",file=sys.stderr); sys.exit(1)
