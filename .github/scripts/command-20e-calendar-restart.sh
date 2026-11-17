#!/usr/bin/env bash
set -Eeuo pipefail
APP_ID=com.example.arvin
TEST_FILE=integration_test/calendar_link_shared_preferences_restart_test.dart
EVIDENCE=.github/command-20e-evidence
CLEANUP_DONE=0
DEVICE="$(adb devices | awk '$1 ~ /^emulator-/ && $2 == "device" {print $1; exit}')"
mkdir -p "$EVIDENCE"
: > "$EVIDENCE/calendar_restart_stage_a.log"
: > "$EVIDENCE/calendar_restart_stage_b.log"
: > "$EVIDENCE/cleanup_verification.log"
: > "$EVIDENCE/calendar_value_comparison.json"
if [[ -z "$DEVICE" ]]; then echo ANDROID_EMULATOR_DEVICE=NOT_FOUND | tee "$EVIDENCE/cleanup_verification.log"; exit 1; fi
{
  echo "ADB_DEVICE=$DEVICE"
  echo "ANDROID_EMULATOR_API=$(adb -s "$DEVICE" shell getprop ro.build.version.sdk | tr -d '\r')"
  echo "ANDROID_APP_ID=$APP_ID"
  echo "SHARED_PREFERENCES_KEY=arvin.calendar.externalLinks.command20e"
  echo APP_DATA_CLEAR=NOT_PERFORMED
} > "$EVIDENCE/calendar-restart-environment.txt"
run_phase() {
  phase="$1"; log="$2"; require_pid="$3"; runner=""; app_pid=""; rc=0
  flutter test --dart-define="ARVIN_CALENDAR_LINK_PHASE=$phase" "$TEST_FILE" -d "$DEVICE" > "$log" 2>&1 &
  runner=$!
  # Flutter may spend several minutes compiling/installing before the app
  # process exists. Keep observing until the runner exits (or the workflow's
  # job timeout is reached); a fixed 90-second window falsely rejects slow builds.
  for attempt in $(seq 1 1800); do
    app_pid="$(adb -s "$DEVICE" shell pidof "$APP_ID" 2>/dev/null | tr -d '\r' | awk '{print $1}' || true)"
    [[ -n "$app_pid" ]] && break
    runner_state="$(ps -o stat= -p "$runner" 2>/dev/null | tr -d ' ' || true)"
    [[ -z "$runner_state" || "$runner_state" == Z* ]] && break
    sleep 1
  done
  if [[ -n "$app_pid" ]]; then
    printf 'ANDROID_APP_PID_DURING_%s=%s\n' "$phase" "$app_pid" >> "$log"
    PHASE_APP_PID="$app_pid"
  else
    printf 'ANDROID_APP_PID_DURING_%s=NOT_CAPTURED\n' "$phase" >> "$log"
    PHASE_APP_PID=""
  fi
  if wait "$runner"; then rc=0; else rc=$?; fi
  cat "$log"
  if [[ "$require_pid" == "true" && -z "$app_pid" ]]; then return 125; fi
  return "$rc"
}
cleanup() {
  rc=$?
  trap - EXIT
  if [[ "$CLEANUP_DONE" -ne 1 ]]; then
    set +e
    flutter test --dart-define=ARVIN_CALENDAR_LINK_PHASE=cleanup "$TEST_FILE" -d "$DEVICE" > "$EVIDENCE/calendar-restart-cleanup-fallback.log" 2>&1
    cleanup_rc=$?
    cat "$EVIDENCE/calendar-restart-cleanup-fallback.log" >> "$EVIDENCE/cleanup_verification.log"
    if [[ "$cleanup_rc" -eq 0 ]] && grep -q 'CALENDAR_LINK_TEST_KEY_CLEANUP=PASS' "$EVIDENCE/calendar-restart-cleanup-fallback.log"; then
      CLEANUP_DONE=1
      echo TEST_KEY_CLEANUP_FALLBACK=PASS >> "$EVIDENCE/cleanup_verification.log"
    else
      echo TEST_KEY_CLEANUP_FALLBACK=FAIL >> "$EVIDENCE/cleanup_verification.log"
      rc=1
    fi
  fi
  adb -s "$DEVICE" shell am force-stop "$APP_ID" >/dev/null 2>&1 || rc=1
  remaining=""
  for attempt in $(seq 1 15); do
    remaining="$(adb -s "$DEVICE" shell pidof "$APP_ID" 2>/dev/null | tr -d '\r' | awk '{print $1}' || true)"
    [[ -z "$remaining" ]] && break
    sleep 1
  done
  if [[ -z "$remaining" ]]; then echo FINAL_APP_PROCESS_STOP=PASS >> "$EVIDENCE/cleanup_verification.log"; else echo FINAL_APP_PROCESS_STOP=FAIL >> "$EVIDENCE/cleanup_verification.log"; rc=1; fi
  if [[ "$CLEANUP_DONE" -eq 1 ]]; then echo CALENDAR_TEST_KEY_CLEANUP=PASS >> "$EVIDENCE/cleanup_verification.log"; else echo CALENDAR_TEST_KEY_CLEANUP=FAIL >> "$EVIDENCE/cleanup_verification.log"; rc=1; fi
  echo APP_DATA_CLEAR=NOT_PERFORMED >> "$EVIDENCE/cleanup_verification.log"
  exit "$rc"
}
trap cleanup EXIT
PHASE_APP_PID=""
echo CALENDAR_STAGE_A_BEGIN=1 | tee "$EVIDENCE/calendar_restart_stage_a.log"
run_phase write "$EVIDENCE/calendar_restart_stage_a.log" true
echo CALENDAR_STAGE_A_WRITE=PASS | tee -a "$EVIDENCE/calendar_restart_stage_a.log"
test -n "$PHASE_APP_PID"
echo "PROCESS_PID_BEFORE_STOP=$PHASE_APP_PID" | tee -a "$EVIDENCE/calendar_restart_stage_a.log"
# SharedPreferences.apply() persists asynchronously. Allow the platform write
# to settle, then capture the app-private XML before stopping the process.
sleep 3
adb -s "$DEVICE" shell run-as "$APP_ID" sh -c 'ls -la shared_prefs' \
  > "$EVIDENCE/shared-preferences-directory.txt"
adb -s "$DEVICE" shell run-as "$APP_ID" cat shared_prefs/FlutterSharedPreferences.xml \
  > "$EVIDENCE/shared-preferences-before-stop.xml"
grep -F 'flutter.arvin.calendar.externalLinks.command20e' \
  "$EVIDENCE/shared-preferences-before-stop.xml" >/dev/null
echo SHARED_PREFERENCES_DISK_WRITE=PASS | tee -a "$EVIDENCE/calendar_restart_stage_a.log"
adb -s "$DEVICE" shell am force-stop "$APP_ID"
remaining=""
for attempt in $(seq 1 20); do
  remaining="$(adb -s "$DEVICE" shell pidof "$APP_ID" 2>/dev/null | tr -d '\r' | awk '{print $1}' || true)"
  [[ -z "$remaining" ]] && break
  sleep 1
done
test -z "$remaining"
echo ANDROID_PROCESS_STOP=PASS | tee -a "$EVIDENCE/calendar_restart_stage_a.log"
echo ANDROID_PROCESS_ABSENT_AFTER_FORCE_STOP=PASS | tee -a "$EVIDENCE/calendar_restart_stage_a.log"
PHASE_APP_PID=""
echo CALENDAR_STAGE_B_BEGIN=1 | tee "$EVIDENCE/calendar_restart_stage_b.log"
run_phase read "$EVIDENCE/calendar_restart_stage_b.log" true
echo CALENDAR_STAGE_B_READ=PASS | tee -a "$EVIDENCE/calendar_restart_stage_b.log"
test -n "$PHASE_APP_PID"
echo "PROCESS_PID_DURING_FRESH_READ=$PHASE_APP_PID" | tee -a "$EVIDENCE/calendar_restart_stage_b.log"
echo FRESH_ANDROID_PROCESS_AFTER_VERIFIED_STOP=PASS | tee -a "$EVIDENCE/calendar_restart_stage_b.log"
python3 - "$EVIDENCE/calendar_restart_stage_a.log" "$EVIDENCE/calendar_restart_stage_b.log" "$EVIDENCE/calendar_value_comparison.json" <<'PY'
import json, pathlib, re, sys
stage_a_text = pathlib.Path(sys.argv[1]).read_text(encoding="utf-8")
stage_b_text = pathlib.Path(sys.argv[2]).read_text(encoding="utf-8")
stage_a = [json.loads(m.group(1)) for m in re.finditer(r"CALENDAR_LINK_STAGE_A_VALUE=(\{.*\})", stage_a_text)]
stage_b = [json.loads(m.group(1)) for m in re.finditer(r"CALENDAR_LINK_VALUE_COMPARISON=(\{.*\})", stage_b_text)]
fields = {"reminderId", "calendarId", "eventId", "lastSyncedFingerprint"}
if len(stage_a) != 2 or len(stage_b) != 2:
    raise SystemExit(f"Expected two stage-A and two stage-B Link records; got {len(stage_a)} and {len(stage_b)}")
for i in range(2):
    if stage_a[i].get("index") != i or stage_b[i].get("index") != i:
        raise SystemExit(f"Unexpected Link order at index {i}")
    if set(stage_a[i].get("actual", {})) != fields or set(stage_b[i].get("expected", {})) != fields or set(stage_b[i].get("actual", {})) != fields:
        raise SystemExit(f"Four-field evidence incomplete at index {i}")
    if stage_a[i]["actual"] != stage_b[i]["expected"] or stage_b[i]["expected"] != stage_b[i]["actual"]:
        raise SystemExit(f"Calendar Link value mismatch at index {i}")
result = {"status":"PASS","links_compared":2,"fields_per_link":sorted(fields),"total_values_compared":8,"stage_a_saved_values":[row["actual"] for row in stage_a],"stage_b_restored_values":[row["actual"] for row in stage_b],"comparisons":stage_b}
pathlib.Path(sys.argv[3]).write_text(json.dumps(result, ensure_ascii=False, indent=2)+"\n", encoding="utf-8")
PY
run_phase cleanup "$EVIDENCE/calendar-restart-cleanup.log" false
grep -q 'CALENDAR_LINK_TEST_KEY_CLEANUP=PASS' "$EVIDENCE/calendar-restart-cleanup.log"
CLEANUP_DONE=1
echo CALENDAR_TEST_KEY_CLEANUP=PASS | tee -a "$EVIDENCE/cleanup_verification.log"
echo CALENDAR_LINK_PROCESS_RESTART=PASS | tee -a "$EVIDENCE/calendar_restart_stage_b.log"
