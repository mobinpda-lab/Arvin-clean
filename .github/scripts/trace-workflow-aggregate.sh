#!/usr/bin/env bash
set -euo pipefail
TRACE_EVIDENCE_DIR="${TRACE_EVIDENCE_DIR:-arvin-trace}"
mkdir -p "$TRACE_EVIDENCE_DIR"
TRACE_TEST_EXIT_CODE=1
CENTER_TEST_EXIT_CODE=1
HOME_TEST_EXIT_CODE=1
BACKUP_TEST_EXIT_CODE=1
ENCRYPTED_BACKUP_TEST_EXIT_CODE=1
REGRESSION_AGGREGATE_EXIT_CODE=0
persist_exit_code() {
  local variable_name="$1" file_name="$2" exit_code="$3"
  printf -v "$variable_name" '%s' "$exit_code"
  export "$variable_name"
  printf '%s\n' "$exit_code" > "$TRACE_EVIDENCE_DIR/${file_name}-exit-code.txt"
  if [[ -n "${GITHUB_ENV:-}" ]]; then printf '%s=%s\n' "$variable_name" "$exit_code" >> "$GITHUB_ENV"; fi
}
run_suite() {
  local variable_name="$1" suite_name="$2" suite_path="$3"
  local log_path="$TRACE_EVIDENCE_DIR/${suite_name}.log"
  local -a pipeline_status=()
  local suite_exit_code log_exit_code
  set +e
  flutter test "$suite_path" --reporter expanded 2>&1 | tee "$log_path"
  pipeline_status=("${PIPESTATUS[@]}")
  set -e
  suite_exit_code="${pipeline_status[0]:-1}"
  log_exit_code="${pipeline_status[1]:-1}"
  persist_exit_code "$variable_name" "$suite_name" "$suite_exit_code"
  printf '%s\n' "$log_exit_code" > "$TRACE_EVIDENCE_DIR/${suite_name}-log-capture-exit-code.txt"
  printf '%s_EXIT_CODE=%s\n' "$suite_name" "$suite_exit_code"
  printf '%s_LOG_CAPTURE_EXIT_CODE=%s\n' "$suite_name" "$log_exit_code"
  if [[ "$suite_exit_code" -ne 0 || "$log_exit_code" -ne 0 ]]; then REGRESSION_AGGREGATE_EXIT_CODE=1; fi
}
run_suite TRACE_TEST_EXIT_CODE trace test/services/arvin_async_trace_test.dart
run_suite CENTER_TEST_EXIT_CODE center test/center_management_page_test.dart
run_suite HOME_TEST_EXIT_CODE home test/widgets/home_page_test.dart
run_suite BACKUP_TEST_EXIT_CODE backup test/backup_page_encryption_ux_test.dart
run_suite ENCRYPTED_BACKUP_TEST_EXIT_CODE encrypted_backup test/encrypted_backup_service_integration_test.dart
for code in "$TRACE_TEST_EXIT_CODE" "$CENTER_TEST_EXIT_CODE" "$HOME_TEST_EXIT_CODE" "$BACKUP_TEST_EXIT_CODE" "$ENCRYPTED_BACKUP_TEST_EXIT_CODE"; do
  if [[ ! "$code" =~ ^[0-9]+$ || "$code" -ne 0 ]]; then REGRESSION_AGGREGATE_EXIT_CODE=1; fi
done
printf '%s\n' "$REGRESSION_AGGREGATE_EXIT_CODE" > "$TRACE_EVIDENCE_DIR/test-exit-code.txt"
printf '%s\n' "$REGRESSION_AGGREGATE_EXIT_CODE" > "$TRACE_EVIDENCE_DIR/REGRESSION_AGGREGATE_EXIT_CODE.txt"
if [[ -n "${GITHUB_ENV:-}" ]]; then printf 'REGRESSION_AGGREGATE_EXIT_CODE=%s\n' "$REGRESSION_AGGREGATE_EXIT_CODE" >> "$GITHUB_ENV"; fi
printf 'REGRESSION_AGGREGATE_EXIT_CODE=%s\n' "$REGRESSION_AGGREGATE_EXIT_CODE"
exit "$REGRESSION_AGGREGATE_EXIT_CODE"
