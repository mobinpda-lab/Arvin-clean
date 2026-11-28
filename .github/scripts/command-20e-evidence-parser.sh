#!/usr/bin/env bash
# Shared explicit-state parser for COMMAND 20-E evidence.
# Evidence is PASS only when every required artifact is real and complete.
classify_evidence_file() {
  local file="$1" execution_state="$2" start_marker="$3" pass_marker="$4" failure_marker="$5"
  local has_start=false has_pass=false has_failure=false has_not_tested=false
  if [[ -f "$file" && -s "$file" ]]; then
    if grep -Eiq '^[[:space:]]*(PLACEHOLDER|TODO|TBD|FIXME)(=|:|[[:space:]]|$)' "$file"; then
      printf 'INCOMPLETE EVIDENCE'; return
    fi
    [[ -n "$start_marker" ]] && grep -Fq "$start_marker" "$file" && has_start=true
    [[ -n "$pass_marker" ]] && grep -Fq "$pass_marker" "$file" && has_pass=true
    [[ -n "$failure_marker" ]] && grep -Fq "$failure_marker" "$file" && has_failure=true
    grep -Fq 'TEST_STATUS=FAILURE' "$file" && has_failure=true
    if grep -Fxq 'TEST_STATUS=NOT TESTED' "$file" ||
       grep -Fxq 'Cleanup verification NOT TESTED.' "$file" ||
       grep -Fxq 'Calendar stage A NOT TESTED.' "$file" ||
       grep -Fxq 'Calendar stage B NOT TESTED.' "$file"; then has_not_tested=true; fi
    if [[ "$has_not_tested" == true ]]; then
      if [[ "$has_start" == true || "$execution_state" != NOT_STARTED ]]; then printf 'INCOMPLETE EVIDENCE'; else printf 'NOT TESTED'; fi
      return
    fi
    if [[ "$has_pass" == true && "$has_failure" == true ]]; then printf 'INCOMPLETE EVIDENCE'; return; fi
    if [[ "$has_failure" == true ]]; then
      if grep -Fq 'TEST_STATUS=FAILURE' "$file" &&
         grep -Eq '^FAILURE_REASON=.+$|^TEST_FAILURE=.+$|^FAILURE_EVIDENCE=.+$' "$file"; then printf 'FAILURE'; else printf 'INCOMPLETE EVIDENCE'; fi
      return
    fi
    if [[ "$has_pass" == true && "$execution_state" == COMPLETED ]]; then printf 'PASS'; return; fi
    if [[ "$has_start" == true || "$execution_state" == STARTED || "$execution_state" == COMPLETED ]]; then printf 'INCOMPLETE EVIDENCE'; return; fi
    printf 'NOT TESTED'; return
  fi
  if [[ "$execution_state" == NOT_STARTED ]]; then printf 'NOT TESTED'; else printf 'INCOMPLETE EVIDENCE'; fi
}
classify_required_artifact() {
  local file="$1" execution_state="$2"
  if [[ -s "$file" ]]; then
    if grep -Eiq '^[[:space:]]*(PLACEHOLDER|TODO|TBD|FIXME)(=|:|[[:space:]]|$)' "$file"; then printf 'INCOMPLETE EVIDENCE'; else printf 'PASS'; fi
  elif [[ "$execution_state" == NOT_STARTED ]]; then printf 'NOT TESTED'; else printf 'INCOMPLETE EVIDENCE'; fi
}
validate_process_pid_pair() {
  local pid_a="$1" pid_b="$2"
  if [[ "$pid_a" =~ ^[1-9][0-9]*$ && "$pid_b" =~ ^[1-9][0-9]*$ && "$pid_a" != "$pid_b" ]]; then printf PASS; else printf 'INCOMPLETE EVIDENCE'; fi
}
classify_calendar_restart_evidence() {
  local stage_a="$1" stage_b="$2" cleanup="$3" comparison="$4"
  local started=false file pid_a pid_b
  for file in "$stage_a" "$stage_b" "$cleanup"; do
    if [[ -s "$file" ]] && grep -Eq 'TEST_STARTED=1|CALENDAR_STAGE_[AB]_BEGIN|CLEANUP_TEST_STARTED=1' "$file"; then started=true; fi
  done
  if [[ "$started" == false ]]; then
    for file in "$stage_a" "$stage_b" "$cleanup"; do
      if [[ -s "$file" ]] && grep -Eq '(^|=)(PASS|FAILURE)$|TEST_STATUS=(PASS|FAILURE)' "$file"; then printf 'INCOMPLETE EVIDENCE'; return; fi
    done
    printf 'NOT TESTED'; return
  fi
  for file in "$stage_a" "$stage_b" "$cleanup"; do
    [[ -s "$file" ]] || { printf 'INCOMPLETE EVIDENCE'; return; }
    if grep -Eiq '^[[:space:]]*(PLACEHOLDER|TODO|TBD|FIXME)(=|:|[[:space:]]|$)' "$file"; then printf 'INCOMPLETE EVIDENCE'; return; fi
    if grep -Fq 'TEST_STATUS=FAILURE' "$file"; then
      if grep -Eq '^FAILURE_REASON=.+$|^TEST_FAILURE=.+$|^FAILURE_EVIDENCE=.+$' "$file"; then printf FAILURE; else printf 'INCOMPLETE EVIDENCE'; fi
      return
    fi
  done
  for marker in CALENDAR_LINK_REAL_BACKEND_WRITE=PASS ANDROID_PROCESS_STOP=PASS ANDROID_PROCESS_ABSENT_AFTER_FORCE_STOP=PASS; do
    grep -Fq "$marker" "$stage_a" || { printf 'INCOMPLETE EVIDENCE'; return; }
  done
  for marker in CALENDAR_LINK_STAGE_B_READ=PASS FRESH_ANDROID_PROCESS_AFTER_VERIFIED_STOP=PASS CALENDAR_LINK_PROCESS_RESTART=PASS; do
    grep -Fq "$marker" "$stage_b" || { printf 'INCOMPLETE EVIDENCE'; return; }
  done
  for marker in CLEANUP_TEST_STARTED=1 FINAL_APP_PROCESS_STOP=PASS EMULATOR_FIXTURE_UNINSTALL=PASS CALENDAR_TEST_KEY_CLEANUP=PASS TEST_STATUS=PASS; do
    grep -Fq "$marker" "$cleanup" || { printf 'INCOMPLETE EVIDENCE'; return; }
  done
  pid_a="$(sed -n 's/^PROCESS_PID_BEFORE_STOP=//p' "$stage_a" | tail -n 1)"
  pid_b="$(sed -n 's/^PROCESS_PID_AFTER_RESTART=//p' "$stage_b" | tail -n 1)"
  [[ "$(validate_process_pid_pair "$pid_a" "$pid_b")" == PASS ]] || { printf 'INCOMPLETE EVIDENCE'; return; }
  python3 - "$comparison" "$pid_a" "$pid_b" <<'PY'
import json, pathlib, re, sys
p=pathlib.Path(sys.argv[1])
if not p.is_file() or not p.stat().st_size: raise SystemExit(1)
d=json.loads(p.read_text(encoding="utf-8"))
fields={"reminderId","calendarId","eventId","lastSyncedFingerprint"}
rows=d.get("comparisons",[])
if d.get("status")!="PASS" or d.get("links_compared")!=8 or d.get("total_values_compared")!=32 or len(rows)!=32 or d.get("independent_processes") is not True: raise SystemExit(1)
by={}
for r in rows:
    lid=r.get("link_id")
    if not isinstance(lid,str) or not lid or r.get("field") not in fields or r.get("status")!="PASS" or "value" not in r: raise SystemExit(1)
    by.setdefault(lid,set()).add(r["field"])
if len(by)!=8 or any(v!=fields for v in by.values()): raise SystemExit(1)
a,b=sys.argv[2:]
if not re.fullmatch(r"[1-9][0-9]*",a) or not re.fullmatch(r"[1-9][0-9]*",b) or a==b: raise SystemExit(1)
if str(d.get("process_a_pid"))!=a or str(d.get("process_b_pid"))!=b: raise SystemExit(1)
PY
  [[ $? -eq 0 ]] || { printf 'INCOMPLETE EVIDENCE'; return; }
  printf PASS
}


classify_github_execution_state() {
  local raw_status="${1:-}" raw_conclusion="${2:-}" record_exists="${3:-true}"
  if [[ "$record_exists" != true ]]; then printf 'NOT_RUN'; return; fi
  case "$raw_status" in
    queued|requested|waiting|pending) printf 'QUEUED' ;;
    in_progress) printf 'IN_PROGRESS' ;;
    completed)
      case "$raw_conclusion" in
        success) printf 'SUCCESS' ;;
        failure|startup_failure) printf 'FAILURE' ;;
        cancelled) printf 'CANCELLED' ;;
        skipped) printf 'SKIPPED' ;;
        timed_out) printf 'TIMED_OUT' ;;
        action_required) printf 'ACTION_REQUIRED' ;;
        neutral) printf 'NEUTRAL' ;;
        stale) printf 'STALE' ;;
        *) printf 'UNKNOWN' ;;
      esac ;;
    *) printf 'UNKNOWN' ;;
  esac
}
command20e_acceptance_gate() {
  local expected_sha="$1" observed_sha="$2" collection_state="$3"
  shift 3
  if [[ "$expected_sha" != "$observed_sha" || "$collection_state" != COMPLETED ]]; then printf 'NO-GO'; return; fi
  local state
  for state in "$@"; do if [[ "$state" != SUCCESS ]]; then printf 'NO-GO'; return; fi; done
  printf 'PASS'
}
write_command20e_regression_summary() {
  local input_json="$1" output_json="$2" expected_sha="$3"
  jq --arg expected_sha "$expected_sha" '
    def job_success: (.state == "SUCCESS") and (.job_id != null);
    . as $document
    | (
        (.target_sha == $expected_sha)
        and (.repository.full_name == "mobinpda-lab/Arvin-clean")
        and (.repository.repository_id == 1331763954)
        and (.authorized_branch == "recovery-02/main-based-integration")
        and (.evidence_collection.status == "COMPLETED")
        and (.evidence_collection.repository_identity_valid == true)
        and (.evidence_collection.phase_artifact_valid == true)
        and (.evidence_collection.phase_artifact.artifact_id != null)
        and (.evidence_collection.phase_artifact.artifact_digest != null)
        and (.evidence_collection.phase_artifact.artifact_expired == false)
        and (.workflow_completion.build.state == "SUCCESS")
        and (.workflow_completion.build.head_sha == $expected_sha)
        and (.workflow_completion.build.repository_id == 1331763954)
        and (.workflow_completion.build.repository_full_name == "mobinpda-lab/Arvin-clean")
        and (.workflow_completion.build.head_branch == "recovery-02/main-based-integration")
        and ((.workflow_completion.build.run_attempt // 0) >= 1)
        and (.workflow_completion.device_smoke.state == "SUCCESS")
        and (.workflow_completion.device_smoke.head_sha == $expected_sha)
        and (.workflow_completion.device_smoke.repository_id == 1331763954)
        and (.workflow_completion.device_smoke.repository_full_name == "mobinpda-lab/Arvin-clean")
        and (.workflow_completion.device_smoke.head_branch == "recovery-02/main-based-integration")
        and ((.workflow_completion.device_smoke.run_attempt // 0) >= 1)
        and (.workflow_completion.follow_up.state == "SUCCESS")
        and (.workflow_completion.follow_up.head_sha == $expected_sha)
        and (.workflow_completion.follow_up.repository_id == 1331763954)
        and (.workflow_completion.follow_up.repository_full_name == "mobinpda-lab/Arvin-clean")
        and (.workflow_completion.follow_up.head_branch == "recovery-02/main-based-integration")
        and ((.workflow_completion.follow_up.run_attempt // 0) >= 1)
        and (.gates.trace_aggregation | job_success)
        and (.gates.trace_aggregation.artifact_id != null)
        and (.gates.trace_aggregation.artifact_digest != null)
        and (.gates.trace_aggregation.artifact_expired == false)
        and (.gates.flutter_analyze.dedicated.state == "SUCCESS")
        and (.gates.flutter_analyze.dedicated.job_id != null)
        and (.gates.flutter_analyze.build | job_success)
        and ((.gates.test_shards | length) == 6)
        and (all(.gates.test_shards[]; job_success))
        and (.gates.apk_debug | job_success)
        and (.gates.apk_debug.artifact_id != null)
        and (.gates.apk_debug.artifact_digest != null)
        and (.gates.apk_debug.artifact_expired == false)
        and (.gates.apk_release | job_success)
        and (.gates.apk_release.artifact_id != null)
        and (.gates.apk_release.artifact_digest != null)
        and (.gates.apk_release.artifact_expired == false)
        and (.gates.project_store_file_persistence.state == "PASS")
        and (.gates.project_store_file_persistence.source_job_id != null)
        and (.gates.calendar_process_restart.state == "PASS")
        and (.gates.calendar_process_restart.source_job_id != null)
        and (.gates.cleanup.state == "PASS")
        and (.gates.cleanup.source_job_id != null)
        and (.gates.follow_up_persistence | job_success)
        and ((.gates.device_smoke | length) == 7)
        and (all(.gates.device_smoke[]; job_success))
      ) as $passed
    | $document + {overall:(if $passed then "PASS" else "NO-GO" end)}
  ' "$input_json" > "$output_json"
}
