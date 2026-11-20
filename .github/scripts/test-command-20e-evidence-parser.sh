#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/command-20e-evidence-parser.sh"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
assert_status() {
  local name="$1" expected="$2" file="$3" state="$4" start="$5" pass="$6" failure="$7"
  local actual
  actual="$(classify_evidence_file "$file" "$state" "$start" "$pass" "$failure")"
  if [[ "$actual" != "$expected" ]]; then
    echo "FAIL: $name expected=$expected actual=$actual" >&2
    exit 1
  fi
  echo "PASS: $name => $actual"
}
printf 'TEST_STARTED=1\nTEST_STATUS=PASS\n' > "$tmp/pass"
assert_status "PASS" "PASS" "$tmp/pass" COMPLETED TEST_STARTED 'TEST_STATUS=PASS' TEST_FAILURE
printf 'TEST_STARTED=1\nTEST_STATUS=FAILURE\nFAILURE_REASON=assertion mismatch\n' > "$tmp/failure"
assert_status "FAILURE" "FAILURE" "$tmp/failure" COMPLETED TEST_STARTED 'TEST_STATUS=PASS' TEST_FAILURE
printf 'Cleanup verification NOT TESTED.\n' > "$tmp/not-tested"
assert_status "NOT TESTED" "NOT TESTED" "$tmp/not-tested" NOT_STARTED TEST_STARTED 'TEST_STATUS=PASS' TEST_FAILURE
printf 'TEST_STARTED=1\n' > "$tmp/incomplete"
assert_status "INCOMPLETE EVIDENCE" "INCOMPLETE EVIDENCE" "$tmp/incomplete" STARTED TEST_STARTED 'TEST_STATUS=PASS' TEST_FAILURE
: > "$tmp/empty"
assert_status "empty file" "NOT TESTED" "$tmp/empty" NOT_STARTED TEST_STARTED 'TEST_STATUS=PASS' TEST_FAILURE
assert_status "missing file" "NOT TESTED" "$tmp/missing" NOT_STARTED TEST_STARTED 'TEST_STATUS=PASS' TEST_FAILURE
printf 'TEST_STARTED=1\npartial output\n' > "$tmp/report"
assert_status "incomplete report" "INCOMPLETE EVIDENCE" "$tmp/report" COMPLETED TEST_STARTED 'TEST_STATUS=PASS' TEST_FAILURE
printf 'TEST_STARTED=1\nTEST_STATUS=PASS\nTEST_STATUS=FAILURE\nFAILURE_REASON=contradictory\n' > "$tmp/contradictory"
assert_status "contradictory report" "INCOMPLETE EVIDENCE" "$tmp/contradictory" COMPLETED TEST_STARTED 'TEST_STATUS=PASS' 'TEST_STATUS=FAILURE'
echo "COMMAND_20E_PARSER_UNIT_TESTS=PASS"

printf 'TEST_STARTED=1\nPLACEHOLDER=replace with real evidence\n' > "$tmp/placeholder"
assert_status "placeholder" "INCOMPLETE EVIDENCE" "$tmp/placeholder" COMPLETED TEST_STARTED 'TEST_STATUS=PASS' TEST_FAILURE

artifact_status="$(classify_required_artifact "$tmp/missing-artifact" COMPLETED)"
[[ "$artifact_status" == "INCOMPLETE EVIDENCE" ]] || { echo "FAIL: missing artifact => $artifact_status" >&2; exit 1; }
artifact_status="$(classify_required_artifact "$tmp/missing-artifact" NOT_STARTED)"
[[ "$artifact_status" == "NOT TESTED" ]] || { echo "FAIL: unstarted artifact => $artifact_status" >&2; exit 1; }
printf 'PLACEHOLDER=artifact pending\n' > "$tmp/placeholder-artifact"
artifact_status="$(classify_required_artifact "$tmp/placeholder-artifact" COMPLETED)"
[[ "$artifact_status" == "INCOMPLETE EVIDENCE" ]] || { echo "FAIL: placeholder artifact => $artifact_status" >&2; exit 1; }
echo "PASS: required artifact states"

pid_status="$(validate_process_pid_pair 123 456)"
[[ "$pid_status" == PASS ]] || { echo "FAIL: valid PID pair => $pid_status" >&2; exit 1; }
for invalid in "0 456" "abc 456" "123 123" "123 ''"; do
  read -r a b <<< "$invalid"
  pid_status="$(validate_process_pid_pair "$a" "$b")"
  [[ "$pid_status" == "INCOMPLETE EVIDENCE" ]] || { echo "FAIL: invalid PID pair $invalid => $pid_status" >&2; exit 1; }
done
echo "PASS: PID validation"

cat > "$tmp/stage-a" <<'EOF'
CALENDAR_STAGE_A_BEGIN
TEST_STARTED=1
CALENDAR_LINK_REAL_BACKEND_WRITE=PASS
ANDROID_PROCESS_STOP=PASS
ANDROID_PROCESS_ABSENT_AFTER_FORCE_STOP=PASS
PROCESS_PID_BEFORE_STOP=123
EOF
cat > "$tmp/stage-b" <<'EOF'
CALENDAR_STAGE_B_BEGIN
CALENDAR_LINK_STAGE_B_READ=PASS
PROCESS_PID_AFTER_RESTART=456
FRESH_ANDROID_PROCESS_AFTER_VERIFIED_STOP=PASS
CALENDAR_LINK_PROCESS_RESTART=PASS
EOF
cat > "$tmp/cleanup" <<'EOF'
CLEANUP_TEST_STARTED=1
FINAL_APP_PROCESS_STOP=PASS
EMULATOR_FIXTURE_UNINSTALL=PASS
CALENDAR_TEST_KEY_CLEANUP=PASS
TEST_STATUS=PASS
EOF
python3 - "$tmp/comparison.json" <<'PY'
import json, pathlib, sys
comparisons = []
for i in range(8):
    values = {
        "reminderId": f"reminder-{i}",
        "calendarId": f"calendar-{i}",
        "eventId": f"event-{i}",
        "lastSyncedFingerprint": f"fingerprint-{i}",
    }
    for field, value in values.items():
        comparisons.append({"link_id": f"link-{i}", "field": field, "status": "PASS", "value": value})
data = {
    "status": "PASS", "links_compared": 8, "fields_per_link": [
        "reminderId", "calendarId", "eventId", "lastSyncedFingerprint"
    ],
    "total_values_compared": 32, "process_a_pid": "123", "process_b_pid": "456",
    "independent_processes": True, "comparisons": comparisons
}
pathlib.Path(sys.argv[1]).write_text(json.dumps(data), encoding="utf-8")
PY
calendar_status="$(classify_calendar_restart_evidence "$tmp/stage-a" "$tmp/stage-b" "$tmp/cleanup" "$tmp/comparison.json")"
[[ "$calendar_status" == PASS ]] || { echo "FAIL: complete calendar evidence => $calendar_status" >&2; exit 1; }
calendar_status="$(classify_calendar_restart_evidence "$tmp/missing-stage-a" "$tmp/stage-b" "$tmp/cleanup" "$tmp/comparison.json")"
[[ "$calendar_status" == "INCOMPLETE EVIDENCE" ]] || { echo "FAIL: missing Stage A => $calendar_status" >&2; exit 1; }
calendar_status="$(classify_calendar_restart_evidence "$tmp/stage-a" "$tmp/missing-stage-b" "$tmp/cleanup" "$tmp/comparison.json")"
[[ "$calendar_status" == "INCOMPLETE EVIDENCE" ]] || { echo "FAIL: missing Stage B => $calendar_status" >&2; exit 1; }
calendar_status="$(classify_calendar_restart_evidence "$tmp/missing-stage-a" "$tmp/missing-stage-b" "$tmp/cleanup" "$tmp/comparison.json")"
[[ "$calendar_status" == "INCOMPLETE EVIDENCE" ]] || { echo "FAIL: cleanup without execution => $calendar_status" >&2; exit 1; }
echo "PASS: Calendar Stage A/B, 32 values, PID and cleanup validation"
