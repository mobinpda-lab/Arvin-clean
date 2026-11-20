#!/usr/bin/env bash
# Shared explicit-state parser for COMMAND 20-E evidence.
# Usage: classify_evidence_file FILE EXECUTION_STATE START_MARKER PASS_MARKER FAILURE_MARKER
classify_evidence_file() {
  local file="$1" execution_state="$2" start_marker="$3" pass_marker="$4" failure_marker="$5"
  local has_start=false has_pass=false has_failure=false has_not_tested=false
  if [[ -f "$file" && -s "$file" ]]; then
    if grep -Eiq '^[[:space:]]*(PLACEHOLDER|TODO|TBD|FIXME)(=|:|[[:space:]]|$)' "$file"; then
      printf 'INCOMPLETE EVIDENCE'; return
    fi
    if [[ -n "$start_marker" ]] && grep -Fq "$start_marker" "$file"; then has_start=true; fi
    if [[ -n "$pass_marker" ]] && grep -Fq "$pass_marker" "$file"; then has_pass=true; fi
    if [[ -n "$failure_marker" ]] && grep -Fq "$failure_marker" "$file"; then has_failure=true; fi
    if grep -Fq 'TEST_STATUS=FAILURE' "$file"; then has_failure=true; fi
    if grep -Fxq 'TEST_STATUS=NOT TESTED' "$file" ||
       grep -Fxq 'Cleanup verification NOT TESTED.' "$file" ||
       grep -Fxq 'Calendar stage A NOT TESTED.' "$file" ||
       grep -Fxq 'Calendar stage B NOT TESTED.' "$file"; then
      has_not_tested=true
    fi
    if [[ "$has_not_tested" == true ]]; then
      if [[ "$has_start" == true || "$execution_state" != NOT_STARTED ]]; then
        printf 'INCOMPLETE EVIDENCE'
      else
        printf 'NOT TESTED'
      fi
      return
    fi
    if [[ "$has_pass" == true && "$has_failure" == true ]]; then printf 'INCOMPLETE EVIDENCE'; return; fi
    if [[ "$has_failure" == true ]]; then
      if grep -Fq 'TEST_STATUS=FAILURE' "$file" &&
         grep -Eq '^FAILURE_REASON=.+$|^TEST_FAILURE=.+$|^FAILURE_EVIDENCE=.+$' "$file"; then
        printf 'FAILURE'
      else
        printf 'INCOMPLETE EVIDENCE'
      fi
      return
    fi
    if [[ "$has_pass" == true && "$execution_state" == COMPLETED ]]; then printf 'PASS'; return; fi
    if [[ "$has_start" == true || "$execution_state" == STARTED || "$execution_state" == COMPLETED ]]; then
      printf 'INCOMPLETE EVIDENCE'; return
    fi
    printf 'NOT TESTED'; return
  fi
  if [[ "$execution_state" == NOT_STARTED ]]; then printf 'NOT TESTED'; else printf 'INCOMPLETE EVIDENCE'; fi
}


# Required artifacts are separate gates: an unexecuted optional artifact is NOT
# TESTED, but an artifact missing after execution is incomplete evidence.
classify_required_artifact() {
  local file="$1" execution_state="$2"
  if [[ -s "$file" ]]; then
    if grep -Eiq '^[[:space:]]*(PLACEHOLDER|TODO|TBD|FIXME)(=|:|[[:space:]]|$)' "$file"; then
      printf 'INCOMPLETE EVIDENCE'
    else
      printf 'PASS'
    fi
    return
  fi
  if [[ "$execution_state" == NOT_STARTED ]]; then
    printf 'NOT TESTED'
  else
    printf 'INCOMPLETE EVIDENCE'
  fi
}

validate_process_pid_pair() {
  local pid_a="$1" pid_b="$2"
  if [[ "$pid_a" =~ ^[1-9][0-9]*$ && "$pid_b" =~ ^[1-9][0-9]*$ && "$pid_a" != "$pid_b" ]]; then
    printf 'PASS'
  else
    printf 'INCOMPLETE EVIDENCE'
  fi
}

# Calendar restart is accepted only when both process stages, all 32 value
# comparisons, distinct numeric PIDs, and real cleanup evidence are present.
classify_calendar_restart_evidence() {
  local stage_a="$1" stage_b="$2" cleanup="$3" comparison="$4"
  local started=false file pid_a pid_b pid_status failure
  for file in "$stage_a" "$stage_b" "$cleanup"; do
    if [[ -s "$file" ]] && grep -Eq 'TEST_STARTED=1|CALENDAR_STAGE_[AB]_BEGIN|CLEANUP_TEST_STARTED=1' "$file"; then
      started=true
    fi
  done
  if [[ "$started" == false ]]; then
    for file in "$stage_a" "$stage_b" "$cleanup"; do
      if [[ -s "$file" ]] && grep -Eq '(^|=)(PASS|FAILURE)$|TEST_STATUS=(PASS|FAILURE)' "$file"; then
        printf 'INCOMPLETE EVIDENCE'; return
      fi
    done
    printf 'NOT TESTED'; return
  fi

  for file in "$stage_a" "$stage_b" "$cleanup"; do
    if [[ -s "$file" ]] && grep -Eiq '^[[:space:]]*(PLACEHOLDER|TODO|TBD|FIXME)(=|:|[[:space:]]|$)' "$file"; then
      printf 'INCOMPLETE EVIDENCE'; return
    fi
    if [[ -s "$file" ]] && grep -Fq 'TEST_STATUS=FAILURE' "$file"; then
      if grep -Eq '^FAILURE_REASON=.+$|^TEST_FAILURE=.+$|^FAILURE_EVIDENCE=.+$' "$file"; then
        printf 'FAILURE'
      else
        printf 'INCOMPLETE EVIDENCE'
      fi
      return
    fi
  done

  [[ -s "$stage_a" && -s "$stage_b" && -s "$cleanup" ]] || { printf 'INCOMPLETE EVIDENCE'; return; }
  grep -Fq 'CALENDAR_LINK_REAL_BACKEND_WRITE=PASS' "$stage_a" || { printf 'INCOMPLETE EVIDENCE'; return; }
  grep -Fq 'ANDROID_PROCESS_STOP=PASS' "$stage_a" || { printf 'INCOMPLETE EVIDENCE'; return; }
  grep -Fq 'ANDROID_PROCESS_ABSENT_AFTER_FORCE_STOP=PASS' "$stage_a" || { printf 'INCOMPLETE EVIDENCE'; return; }
  grep -Fq 'CALENDAR_LINK_STAGE_B_READ=PASS' "$stage_b" || { printf 'INCOMPLETE EVIDENCE'; return; }
  grep -Fq 'FRESH_ANDROID_PROCESS_AFTER_VERIFIED_STOP=PASS' "$stage_b" || { printf 'INCOMPLETE EVIDENCE'; return; }
  grep -Fq 'CALENDAR_LINK_PROCESS_RESTART=PASS' "$stage_b" || { printf 'INCOMPLETE EVIDENCE'; return; }
  grep -Fq 'CLEANUP_TEST_STARTED=1' "$cleanup" || { printf 'INCOMPLETE EVIDENCE'; return; }
  grep -Fq 'FINAL_APP_PROCESS_STOP=PASS' "$cleanup" || { printf 'INCOMPLETE EVIDENCE'; return; }
  grep -Fq 'EMULATOR_FIXTURE_UNINSTALL=PASS' "$cleanup" || { printf 'INCOMPLETE EVIDENCE'; return; }
  grep -Fq 'CALENDAR_TEST_KEY_CLEANUP=PASS' "$cleanup" || { printf 'INCOMPLETE EVIDENCE'; return; }
  grep -Fq 'TEST_STATUS=PASS' "$cleanup" || { printf 'INCOMPLETE EVIDENCE'; return; }

  pid_a="$(sed -n 's/^PROCESS_PID_BEFORE_STOP=//p' "$stage_a" | tail -n 1)"
  pid_b="$(sed -n 's/^PROCESS_PID_AFTER_RESTART=//p' "$stage_b" | tail -n 1)"
  pid_status="$(validate_process_pid_pair "$pid_a" "$pid_b")"
  [[ "$pid_status" == PASS ]] || { printf 'INCOMPLETE EVIDENCE'; return; }

  if ! python3 - "$comparison" "$pid_a" "$pid_b" <<'PY'
import json, pathlib, re, sys
path = pathlib.Path(sys.argv[1])
if not path.is_file() or path.stat().st_size == 0:
    raise SystemExit(1)
data = json.loads(path.read_text(encoding="utf-8"))
if data.get("status") != "PASS":
    raise SystemExit(1)
if data.get("links_compared") != 8 or data.get("total_values_compared") != 32:
    raise SystemExit(1)
if len(data.get("comparisons", [])) != 32:
    raise SystemExit(1)
if any(row.get("status") != "PASS" for row in data["comparisons"]):
    raise SystemExit(1)
pid_a, pid_b = sys.argv[2], sys.argv[3]
if not re.fullmatch(r"[1-9][0-9]*", pid_a) or not re.fullmatch(r"[1-9][0-9]*", pid_b) or pid_a == pid_b:
    raise SystemExit(1)
if str(data.get("process_a_pid")) != pid_a or str(data.get("process_b_pid")) != pid_b:
    raise SystemExit(1)
PY
  then
    printf 'INCOMPLETE EVIDENCE'; return
  fi
  printf 'PASS'
}
