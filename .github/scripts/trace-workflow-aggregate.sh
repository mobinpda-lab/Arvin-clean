#!/usr/bin/env bash
set -euo pipefail
TRACE_EVIDENCE_DIR="${TRACE_EVIDENCE_DIR:-arvin-trace}"
mkdir -p "$TRACE_EVIDENCE_DIR"
TRACE_TEST_EXIT_CODE=1
CENTER_TEST_EXIT_CODE=1
HOME_TEST_EXIT_CODE=1
BACKUP_TEST_EXIT_CODE=1
ENCRYPTED_BACKUP_TEST_EXIT_CODE=1
TRACE_EXTRACTION_EXIT_CODE=0
REGRESSION_AGGREGATE_EXIT_CODE=0
persist_exit_code() {
  local variable_name="$1" file_name="$2" exit_code="$3"
  printf -v "$variable_name" '%s' "$exit_code"
  export "$variable_name"
  printf '%s\n' "$exit_code" > "$TRACE_EVIDENCE_DIR/${file_name}-exit-code.txt"
  if [[ -n "${GITHUB_ENV:-}" ]]; then printf '%s=%s\n' "$variable_name" "$exit_code" >> "$GITHUB_ENV"; fi
}
extract_widget_trace_events() {
  local log_path="$1"
  local output_path="${ARVIN_TRACE_OUTPUT:-}"
  [[ -n "$output_path" ]] || return 0
  python3 - "$log_path" "$output_path" <<'PY'
import json
import os
import pathlib
import sys

log_path = pathlib.Path(sys.argv[1])
output_path = pathlib.Path(sys.argv[2])
marker = "[ARVIN_TRACE_JSONL] "
expected_mission = os.environ.get("ARVIN_MISSION_ID")
records = []
for line_number, line in enumerate(log_path.read_text(encoding="utf-8", errors="replace").splitlines(), 1):
    marker_index = line.find(marker)
    if marker_index < 0:
        continue
    raw = line[marker_index + len(marker):].strip()
    try:
        record = json.loads(raw)
    except json.JSONDecodeError as exc:
        raise SystemExit(f"TRACE_JSONL_EXTRACT=FAIL malformed record at {log_path}:{line_number}") from exc
    if not isinstance(record, dict) or record.get("event") not in {"START", "END", "ERROR"}:
        raise SystemExit(f"TRACE_JSONL_EXTRACT=FAIL invalid event at {log_path}:{line_number}")
    if record.get("event_type", record.get("event")) != record.get("event"):
        raise SystemExit(f"TRACE_JSONL_EXTRACT=FAIL event_type mismatch at {log_path}:{line_number}")
    if expected_mission and record.get("mission_id") != expected_mission:
        raise SystemExit(f"TRACE_JSONL_EXTRACT=FAIL mission mismatch at {log_path}:{line_number}")
    if record.get("exception_message") not in (None, ""):
        raise SystemExit(f"TRACE_JSONL_EXTRACT=FAIL exception text is not permitted at {log_path}:{line_number}")
    records.append(raw)

if records:
    output_path.parent.mkdir(parents=True, exist_ok=True)
    with output_path.open("a", encoding="utf-8") as output:
        for raw in records:
            output.write(raw + "\n")
print(f"TRACE_JSONL_EXTRACTED={len(records)} source={log_path.name}")
PY
}

run_suite() {
  local variable_name="$1" suite_name="$2" suite_path="$3"
  local log_path="$TRACE_EVIDENCE_DIR/${suite_name}.log"
  local -a pipeline_status=()
  local suite_exit_code log_exit_code
  set +e
  # Keep the file-backed trace sink scoped to the non-widget trace suite.
  # Widget tests use FakeAsync; awaiting IOSink.flush there prevents their pumps from progressing.
  local -a flutter_command=(flutter test "$suite_path" --reporter expanded)
  if [[ "$suite_name" != trace ]]; then
    flutter_command=(env -u ARVIN_TRACE_OUTPUT ARVIN_TRACE_CONSOLE_JSONL=1 "${flutter_command[@]}")
  fi
  "${flutter_command[@]}" 2>&1 | tee "$log_path"
  pipeline_status=("${PIPESTATUS[@]}")
  set -e
  suite_exit_code="${pipeline_status[0]:-1}"
  log_exit_code="${pipeline_status[1]:-1}"
  if [[ "$suite_name" != trace ]] && ! extract_widget_trace_events "$log_path"; then
    TRACE_EXTRACTION_EXIT_CODE=1
  fi
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
persist_exit_code TRACE_EXTRACTION_EXIT_CODE trace-extraction "$TRACE_EXTRACTION_EXIT_CODE"
for code in "$TRACE_TEST_EXIT_CODE" "$CENTER_TEST_EXIT_CODE" "$HOME_TEST_EXIT_CODE" "$BACKUP_TEST_EXIT_CODE" "$ENCRYPTED_BACKUP_TEST_EXIT_CODE" "$TRACE_EXTRACTION_EXIT_CODE"; do
  if [[ ! "$code" =~ ^[0-9]+$ || "$code" -ne 0 ]]; then REGRESSION_AGGREGATE_EXIT_CODE=1; fi
done
printf '%s\n' "$REGRESSION_AGGREGATE_EXIT_CODE" > "$TRACE_EVIDENCE_DIR/test-exit-code.txt"
printf '%s\n' "$REGRESSION_AGGREGATE_EXIT_CODE" > "$TRACE_EVIDENCE_DIR/REGRESSION_AGGREGATE_EXIT_CODE.txt"
if [[ -n "${GITHUB_ENV:-}" ]]; then printf 'REGRESSION_AGGREGATE_EXIT_CODE=%s\n' "$REGRESSION_AGGREGATE_EXIT_CODE" >> "$GITHUB_ENV"; fi
printf 'REGRESSION_AGGREGATE_EXIT_CODE=%s\n' "$REGRESSION_AGGREGATE_EXIT_CODE"
exit "$REGRESSION_AGGREGATE_EXIT_CODE"
