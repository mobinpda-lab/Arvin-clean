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
