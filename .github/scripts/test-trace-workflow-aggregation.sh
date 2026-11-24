#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
RUNNER="$SCRIPT_DIR/trace-workflow-aggregate.sh"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
FAKE_BIN="$TMP/fake-bin"
mkdir -p "$FAKE_BIN"
cat > "$FAKE_BIN/flutter" <<'FAKE'
#!/usr/bin/env bash
set -euo pipefail
[[ "$1" == test ]]
suite="$2"
printf '%s\n' "$suite" >> "$FAKE_FLUTTER_CALLS"
case "$suite" in
  test/services/arvin_async_trace_test.dart) rc="\${FAKE_TRACE_RC:-0}" ;;
  test/center_management_page_test.dart) rc="\${FAKE_CENTER_RC:-0}" ;;
  test/widgets/home_page_test.dart) rc="\${FAKE_HOME_RC:-0}" ;;
  test/backup_page_encryption_ux_test.dart) rc="\${FAKE_BACKUP_RC:-0}" ;;
  test/encrypted_backup_service_integration_test.dart) rc="\${FAKE_ENCRYPTED_BACKUP_RC:-0}" ;;
  *) echo "unexpected test path: $suite" >&2; exit 99 ;;
esac
printf 'FAKE_FLUTTER_SUITE=%s EXIT=%s\n' "$suite" "$rc"
exit "$rc"
FAKE
chmod +x "$FAKE_BIN/flutter"
assert_eq() { [[ "$1" == "$2" ]] || { echo "FAIL: $3 expected=$2 actual=$1" >&2; exit 1; }; }
assert_order() {
  local file="$1" expected="$2"
  diff -u <(printf '%s\n' "$expected") "$file" >/dev/null || { echo "FAIL: suite order mismatch" >&2; cat "$file" >&2; exit 1; }
}
run_case() {
  local case_name="$1" expected_exit="$2" trace_rc="$3" center_rc="$4" home_rc="$5" backup_rc="$6" encrypted_rc="$7"
  local case_dir="$TMP/$case_name" actual_exit
  mkdir -p "$case_dir"; : > "$case_dir/calls"; : > "$case_dir/github_env"
  if env PATH="$FAKE_BIN:$PATH" TRACE_EVIDENCE_DIR="$case_dir/evidence" GITHUB_ENV="$case_dir/github_env" FAKE_FLUTTER_CALLS="$case_dir/calls" FAKE_TRACE_RC="$trace_rc" FAKE_CENTER_RC="$center_rc" FAKE_HOME_RC="$home_rc" FAKE_BACKUP_RC="$backup_rc" FAKE_ENCRYPTED_BACKUP_RC="$encrypted_rc" bash "$RUNNER" > "$case_dir/output.log" 2>&1; then actual_exit=0; else actual_exit=$?; fi
  assert_eq "$actual_exit" "$expected_exit" "$case_name aggregate exit"
  assert_order "$case_dir/calls" $'test/services/arvin_async_trace_test.dart\ntest/center_management_page_test.dart\ntest/widgets/home_page_test.dart\ntest/backup_page_encryption_ux_test.dart\ntest/encrypted_backup_service_integration_test.dart'
  for suite in trace center home backup encrypted_backup; do test -s "$case_dir/evidence/$suite.log"; test -s "$case_dir/evidence/$suite-exit-code.txt"; done
  grep -Fqx "TRACE_TEST_EXIT_CODE=$trace_rc" "$case_dir/github_env"
  grep -Fqx "CENTER_TEST_EXIT_CODE=$center_rc" "$case_dir/github_env"
  grep -Fqx "HOME_TEST_EXIT_CODE=$home_rc" "$case_dir/github_env"
  grep -Fqx "BACKUP_TEST_EXIT_CODE=$backup_rc" "$case_dir/github_env"
  grep -Fqx "ENCRYPTED_BACKUP_TEST_EXIT_CODE=$encrypted_rc" "$case_dir/github_env"
  grep -Fqx "REGRESSION_AGGREGATE_EXIT_CODE=$expected_exit" "$case_dir/github_env"
  assert_eq "$(cat "$case_dir/evidence/test-exit-code.txt")" "$expected_exit" "$case_name aggregate artifact"
}
run_case TWA-01 0 0 0 0 0 0
echo TWA-01=PASS
run_case TWA-02 1 7 0 0 0 0
echo TWA-02=PASS
run_case TWA-03 1 0 8 0 0 0
echo TWA-03=PASS
run_case TWA-04 1 0 0 9 0 0
echo TWA-04=PASS
run_case TWA-05 1 0 0 0 10 0
echo TWA-05=PASS
run_case TWA-06 1 0 11 0 12 13
echo TWA-06=PASS
