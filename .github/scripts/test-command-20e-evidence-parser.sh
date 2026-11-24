#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/command-20e-evidence-parser.sh"
tmp="$(mktemp -d)"; trap 'rm -rf "$tmp"' EXIT
assert_eq(){ [[ "$1" == "$2" ]] || { echo "FAIL: $3 expected=$2 actual=$1" >&2; exit 1; }; }
printf 'TEST_STARTED=1\nTEST_STATUS=PASS\n' > "$tmp/pass"
assert_eq "$(classify_evidence_file "$tmp/pass" COMPLETED TEST_STARTED TEST_STATUS=PASS TEST_FAILURE)" PASS pass
printf 'TEST_STARTED=1\nPLACEHOLDER=real evidence pending\nTEST_STATUS=PASS\n' > "$tmp/placeholder"
assert_eq "$(classify_evidence_file "$tmp/placeholder" COMPLETED TEST_STARTED TEST_STATUS=PASS TEST_FAILURE)" 'INCOMPLETE EVIDENCE' placeholder
assert_eq "$(classify_required_artifact "$tmp/missing" COMPLETED)" 'INCOMPLETE EVIDENCE' missing_artifact
assert_eq "$(classify_required_artifact "$tmp/missing" NOT_STARTED)" 'NOT TESTED' unstarted_artifact
printf 'TODO=fill later\n' > "$tmp/artifact"
assert_eq "$(classify_required_artifact "$tmp/artifact" COMPLETED)" 'INCOMPLETE EVIDENCE' placeholder_artifact
assert_eq "$(validate_process_pid_pair 123 456)" PASS pid_valid
for pair in '0 456' 'abc 456' '123 123' '123 empty'; do read -r a b <<< "$pair"; assert_eq "$(validate_process_pid_pair "$a" "$b")" 'INCOMPLETE EVIDENCE' "pid_$pair"; done
cat > "$tmp/a" <<'EOF'
CALENDAR_STAGE_A_BEGIN
TEST_STARTED=1
CALENDAR_LINK_REAL_BACKEND_WRITE=PASS
ANDROID_PROCESS_STOP=PASS
ANDROID_PROCESS_ABSENT_AFTER_FORCE_STOP=PASS
PROCESS_PID_BEFORE_STOP=123
EOF
cat > "$tmp/b" <<'EOF'
CALENDAR_STAGE_B_BEGIN
CALENDAR_LINK_STAGE_B_READ=PASS
PROCESS_PID_AFTER_RESTART=456
FRESH_ANDROID_PROCESS_AFTER_VERIFIED_STOP=PASS
CALENDAR_LINK_PROCESS_RESTART=PASS
EOF
cat > "$tmp/c" <<'EOF'
CLEANUP_TEST_STARTED=1
FINAL_APP_PROCESS_STOP=PASS
EMULATOR_FIXTURE_UNINSTALL=PASS
CALENDAR_TEST_KEY_CLEANUP=PASS
TEST_STATUS=PASS
EOF
python3 - "$tmp/comparison.json" <<'PY'
import json,pathlib,sys
fields=("reminderId","calendarId","eventId","lastSyncedFingerprint")
rows=[{"link_id":f"link-{i}","field":f,"status":"PASS","value":f"{f}-{i}"} for i in range(8) for f in fields]
pathlib.Path(sys.argv[1]).write_text(json.dumps({"status":"PASS","links_compared":8,"total_values_compared":32,"independent_processes":True,"process_a_pid":"123","process_b_pid":"456","comparisons":rows}))
PY
assert_eq "$(classify_calendar_restart_evidence "$tmp/a" "$tmp/b" "$tmp/c" "$tmp/comparison.json")" PASS calendar_complete
for missing in a b c; do
  cp "$tmp/a" "$tmp/ma"; cp "$tmp/b" "$tmp/mb"; cp "$tmp/c" "$tmp/mc"
  case "$missing" in a) : > "$tmp/ma";; b) : > "$tmp/mb";; c) : > "$tmp/mc";; esac
  assert_eq "$(classify_calendar_restart_evidence "$tmp/ma" "$tmp/mb" "$tmp/mc" "$tmp/comparison.json")" 'INCOMPLETE EVIDENCE' "missing_stage_$missing"
done
python3 - "$tmp/comparison.json" <<'PY'
import json,pathlib,sys
p=pathlib.Path(sys.argv[1]); d=json.loads(p.read_text()); d["comparisons"].pop(); p.write_text(json.dumps(d))
PY
assert_eq "$(classify_calendar_restart_evidence "$tmp/a" "$tmp/b" "$tmp/c" "$tmp/comparison.json")" 'INCOMPLETE EVIDENCE' comparison_31
echo COMMAND_20E_PARSER_UNIT_TESTS=PASS


# C20-01..C20-14: GitHub execution state, provenance gate and summary output.
assert_state() {
  local expected="$1" raw_status="$2" raw_conclusion="$3" exists="\${4:-true}" label="$5"
  assert_eq "$(classify_github_execution_state "$raw_status" "$raw_conclusion" "$exists")" "$expected" "$label"
}
assert_state QUEUED queued '' true C20-01
assert_state IN_PROGRESS in_progress '' true C20-02
assert_state SUCCESS completed success true C20-03
assert_state FAILURE completed failure true C20-04
assert_state CANCELLED completed cancelled true C20-05
assert_state SKIPPED completed skipped true C20-06
assert_state NOT_RUN '' '' false C20-07
assert_state TIMED_OUT completed timed_out true C20-08
assert_state ACTION_REQUIRED completed action_required true C20-09
assert_state NEUTRAL completed neutral true C20-10
assert_state STALE completed stale true C20-11
assert_state UNKNOWN completed '' true C20-12-missing-conclusion
assert_state UNKNOWN mystery '' true C20-12-unknown-status
assert_eq "$(command20e_acceptance_gate sha-a sha-a INCOMPLETE SUCCESS SUCCESS SUCCESS)" NO-GO C20-13-incomplete-workflow
assert_eq "$(command20e_acceptance_gate sha-a sha-b COMPLETED SUCCESS SUCCESS SUCCESS)" NO-GO C20-13-wrong-sha
assert_eq "$(command20e_acceptance_gate sha-a sha-a COMPLETED SUCCESS NOT_RUN SUCCESS)" NO-GO C20-13-missing-job
assert_eq "$(command20e_acceptance_gate sha-a sha-a COMPLETED SUCCESS FAILURE SUCCESS)" NO-GO C20-14-mixed-results
assert_eq "$(command20e_acceptance_gate sha-a sha-a COMPLETED SUCCESS SUCCESS SUCCESS)" PASS C20-14-all-success
python3 - "$tmp/summary-input.json" <<'PYFIX'
import json, pathlib, sys
sha = "a" * 40
workflow = lambda name: {"workflow_name":name,"workflow_run_id":"100","run_attempt":1,"repository_id":1331763954,"repository_full_name":"mobinpda-lab/Arvin-clean","head_branch":"recovery-02/main-based-integration","head_sha":sha,"raw_status":"completed","raw_conclusion":"success","state":"SUCCESS","job_id":"200","artifacts":[{"artifact_id":"300","name":"evidence.zip","digest":"sha256:"+"b"*64}],"evidence_provenance":"GitHub Actions REST API"}
job={"job_id":"400","raw_status":"completed","raw_conclusion":"success","state":"SUCCESS"}
doc={"target_sha":sha,"repository":{"full_name":"mobinpda-lab/Arvin-clean","repository_id":1331763954},"authorized_branch":"recovery-02/main-based-integration",
"evidence_collection":{"status":"COMPLETED","repository_identity_valid":True,"phase_artifact_valid":True,"phase_artifact":{"artifact_id":"501","artifact_digest":"sha256:"+"c"*64,"artifact_expired":False},"collector_run_id":"500","collector_run_attempt":1},
"workflow_completion":{"build":workflow("build"),"device_smoke":workflow("device"),"follow_up":workflow("followup")},
"gates":{"trace_aggregation":dict(job,artifact_id="300",artifact_digest="sha256:"+"b"*64,artifact_expired=False),
"flutter_analyze":{"dedicated":dict(job,state="SUCCESS"),"build":job},"test_shards":[dict(job,shard=i) for i in range(6)],
"apk_debug":dict(job,artifact_id="301",artifact_digest="sha256:"+"c"*64,artifact_expired=False),
"apk_release":dict(job,artifact_id="302",artifact_digest="sha256:"+"d"*64,artifact_expired=False),
"project_store_file_persistence":{"state":"PASS","source_job_id":"400"},"calendar_process_restart":{"state":"PASS","source_job_id":"400"},"cleanup":{"state":"PASS","source_job_id":"400"},
"follow_up_persistence":job,"device_smoke":[dict(job,job_name=f"device-{i}") for i in range(7)]}}
pathlib.Path(sys.argv[1]).write_text(json.dumps(doc))
PYFIX
summary_sha="$(printf '%040d' 0 | tr '0' 'a')"
write_command20e_regression_summary "$tmp/summary-input.json" "$tmp/regression_summary.json" "$summary_sha"
assert_eq "$(jq -r '.overall' "$tmp/regression_summary.json")" PASS C20-14-summary-all-success
assert_eq "$(jq -r '.workflow_completion.build.raw_status' "$tmp/regression_summary.json")" completed C20-14-summary-raw-status
assert_eq "$(jq -r '.workflow_completion.build.raw_conclusion' "$tmp/regression_summary.json")" success C20-14-summary-raw-conclusion
assert_eq "$(jq -r '.workflow_completion.build.run_attempt' "$tmp/regression_summary.json")" 1 C20-14-summary-run-attempt
assert_eq "$(jq -r '.gates.trace_aggregation.job_id' "$tmp/regression_summary.json")" 400 C20-14-summary-job-id
assert_eq "$(jq -r '.gates.trace_aggregation.artifact_id' "$tmp/regression_summary.json")" 300 C20-14-summary-artifact-id
jq '.gates.test_shards[0].state = "FAILURE"' "$tmp/summary-input.json" > "$tmp/summary-mixed.json"
write_command20e_regression_summary "$tmp/summary-mixed.json" "$tmp/regression_summary-mixed.json" "$summary_sha"
assert_eq "$(jq -r '.overall' "$tmp/regression_summary-mixed.json")" NO-GO C20-14-summary-mixed
jq '.workflow_completion.build.raw_status = "in_progress" | .workflow_completion.build.raw_conclusion = null | .workflow_completion.build.state = "IN_PROGRESS"' "$tmp/summary-input.json" > "$tmp/summary-incomplete.json"
write_command20e_regression_summary "$tmp/summary-incomplete.json" "$tmp/regression_summary-incomplete.json" "$summary_sha"
assert_eq "$(jq -r '.overall' "$tmp/regression_summary-incomplete.json")" NO-GO C20-14-summary-incomplete
jq '.workflow_completion.build.head_branch = "main"' "$tmp/summary-input.json" > "$tmp/summary-wrong-branch.json"
write_command20e_regression_summary "$tmp/summary-wrong-branch.json" "$tmp/regression_summary-wrong-branch.json" "$summary_sha"
assert_eq "$(jq -r '.overall' "$tmp/regression_summary-wrong-branch.json")" NO-GO C20-14-summary-wrong-branch
jq '.gates.trace_aggregation.artifact_digest = null' "$tmp/summary-input.json" > "$tmp/summary-missing-artifact.json"
write_command20e_regression_summary "$tmp/summary-missing-artifact.json" "$tmp/regression_summary-missing-artifact.json" "$summary_sha"
assert_eq "$(jq -r '.overall' "$tmp/regression_summary-missing-artifact.json")" NO-GO C20-14-summary-missing-artifact
jq '.repository.repository_id = 1' "$tmp/summary-input.json" > "$tmp/summary-wrong-repo.json"
write_command20e_regression_summary "$tmp/summary-wrong-repo.json" "$tmp/regression_summary-wrong-repo.json" "$summary_sha"
assert_eq "$(jq -r '.overall' "$tmp/regression_summary-wrong-repo.json")" NO-GO C20-14-summary-wrong-repo
write_command20e_regression_summary "$tmp/summary-input.json" "$tmp/regression_summary-wrong-sha.json" "$(printf '%040d' 1 | tr '0' 'a')"
assert_eq "$(jq -r '.overall' "$tmp/regression_summary-wrong-sha.json")" NO-GO C20-13-summary-wrong-sha
for id in $(seq -w 1 14); do echo "C20-$id=PASS"; done
