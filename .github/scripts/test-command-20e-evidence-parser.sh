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
