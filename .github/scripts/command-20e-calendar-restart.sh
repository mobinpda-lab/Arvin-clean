#!/usr/bin/env bash
set -Eeuo pipefail

APP_ID="$(sed -nE 's/^[[:space:]]*applicationId[[:space:]]*=[[:space:]]*"([^"]+)".*/\1/p' android/app/build.gradle.kts | head -n 1)"
if [[ -z "$APP_ID" ]]; then
  echo "ANDROID_APPLICATION_ID=NOT_FOUND_IN_GRADLE" >&2
  exit 1
fi
TEST_ENTRYPOINT=integration_test/command20e_calendar_restart_fixture.dart
APK=build/app/outputs/flutter-apk/app-debug.apk
EVIDENCE=.github/command-20e-evidence
DEVICE="$(adb devices | awk '$1 ~ /^emulator-/ && $2 == "device" {print $1; exit}')"
mkdir -p "$EVIDENCE"
for file in calendar_restart_stage_a.log calendar_restart_stage_b.log cleanup_verification.log calendar_value_comparison.json; do
  : > "$EVIDENCE/$file"
done

if [[ -z "$DEVICE" ]]; then
  echo ANDROID_EMULATOR_DEVICE=NOT_FOUND | tee "$EVIDENCE/cleanup_verification.log"
  exit 1
fi

{
  echo "ADB_DEVICE=$DEVICE"
  echo "ANDROID_EMULATOR_API=$(adb -s "$DEVICE" shell getprop ro.build.version.sdk | tr -d '\r')"
  echo "ANDROID_APP_ID=$APP_ID"
  echo "SHARED_PREFERENCES_KEY=arvin.calendar.externalLinks.command20e"
  echo "PROCESS_TEST_MODE=ALTERNATE_DEBUG_ENTRYPOINT"
  echo "APP_DATA_CLEAR=NOT_PERFORMED"
} > "$EVIDENCE/calendar-restart-environment.txt"

stage="build test fixture APK"
flutter build apk --debug --target="$TEST_ENTRYPOINT" 2>&1 | tee "$EVIDENCE/fixture-apk-build.log"
test -s "$APK"
echo "FIXTURE_APK_BUILD=PASS" | tee "$EVIDENCE/calendar_restart_stage_a.log"

stage="install fixture APK on disposable emulator"
adb -s "$DEVICE" uninstall "$APP_ID" >/dev/null 2>&1 || true
adb -s "$DEVICE" install -r "$APK" 2>&1 | tee "$EVIDENCE/fixture-apk-install.log"
package_path="$(adb -s "$DEVICE" shell pm path "$APP_ID" 2>/dev/null | tr -d '\r' || true)"
test -n "$package_path"
printf 'ANDROID_PACKAGE_PATH=%s\n' "$package_path" | tee -a "$EVIDENCE/calendar_restart_stage_a.log"
echo "ANDROID_PACKAGE_INSTALLATION=PASS" | tee -a "$EVIDENCE/calendar_restart_stage_a.log"

wait_for_marker() {
  local marker="$1"
  local output="$2"
  for attempt in $(seq 1 180); do
    adb -s "$DEVICE" logcat -d -v raw > "$output"
    if grep -Fq "$marker" "$output"; then return 0; fi
    sleep 1
  done
  echo "TIMEOUT_WAITING_FOR=$marker" >&2
  return 1
}

stage="launch fixture and persist two Calendar records"
echo "CALENDAR_STAGE_A_BEGIN" | tee -a "$EVIDENCE/calendar_restart_stage_a.log"
adb -s "$DEVICE" logcat -c
adb -s "$DEVICE" shell monkey -p "$APP_ID" 1 >/dev/null
wait_for_marker "CALENDAR_LINK_STAGE_A_WRITE=PASS" "$EVIDENCE/calendar_restart_stage_a.log"
pid_before="$(adb -s "$DEVICE" shell pidof "$APP_ID" 2>/dev/null | tr -d '\r' | awk '{print $1}' || true)"
test -n "$pid_before"
echo "PROCESS_PID_BEFORE_STOP=$pid_before" | tee -a "$EVIDENCE/calendar_restart_stage_a.log"
grep -F 'CALENDAR_LINK_STAGE_A_VALUE=' "$EVIDENCE/calendar_restart_stage_a.log"
echo "CALENDAR_LINK_REAL_BACKEND_WRITE=PASS" | tee -a "$EVIDENCE/calendar_restart_stage_a.log"

stage="verify SharedPreferences reached app-private disk storage"
adb -s "$DEVICE" shell run-as "$APP_ID" ls -la shared_prefs > "$EVIDENCE/shared-preferences-directory.txt"
adb -s "$DEVICE" shell run-as "$APP_ID" cat shared_prefs/FlutterSharedPreferences.xml > "$EVIDENCE/shared-preferences-before-stop.xml"
grep -F 'flutter.arvin.calendar.externalLinks.command20e' "$EVIDENCE/shared-preferences-before-stop.xml" >/dev/null
echo "SHARED_PREFERENCES_DISK_WRITE=PASS" | tee -a "$EVIDENCE/calendar_restart_stage_a.log"

stage="stop the same installed app process"
adb -s "$DEVICE" shell am force-stop "$APP_ID"
pid_after_stop=""
for attempt in $(seq 1 30); do
  pid_after_stop="$(adb -s "$DEVICE" shell pidof "$APP_ID" 2>/dev/null | tr -d '\r' | awk '{print $1}' || true)"
  [[ -z "$pid_after_stop" ]] && break
  sleep 1
done
test -z "$pid_after_stop"
echo "ANDROID_PROCESS_STOP=PASS" | tee -a "$EVIDENCE/calendar_restart_stage_a.log"
echo "ANDROID_PROCESS_ABSENT_AFTER_FORCE_STOP=PASS" | tee -a "$EVIDENCE/calendar_restart_stage_a.log"

stage="fresh launch and read from persisted SharedPreferences"
echo "CALENDAR_STAGE_B_BEGIN" | tee -a "$EVIDENCE/calendar_restart_stage_b.log"
adb -s "$DEVICE" logcat -c
adb -s "$DEVICE" shell monkey -p "$APP_ID" 1 >/dev/null
wait_for_marker "CALENDAR_LINK_STAGE_B_READ=PASS" "$EVIDENCE/calendar_restart_stage_b.log"
# The read marker is emitted before fixture-key cleanup; wait for the final marker too.
wait_for_marker "CALENDAR_LINK_TEST_KEY_CLEANUP=PASS" "$EVIDENCE/calendar_restart_stage_b.log"
pid_after_restart="$(adb -s "$DEVICE" shell pidof "$APP_ID" 2>/dev/null | tr -d '\r' | awk '{print $1}' || true)"
test -n "$pid_after_restart"
test "$pid_after_restart" != "$pid_before"
echo "PROCESS_PID_AFTER_RESTART=$pid_after_restart" | tee -a "$EVIDENCE/calendar_restart_stage_b.log"
echo "FRESH_ANDROID_PROCESS_AFTER_VERIFIED_STOP=PASS" | tee -a "$EVIDENCE/calendar_restart_stage_b.log"
grep -F 'CALENDAR_LINK_STAGE_B_VALUE=' "$EVIDENCE/calendar_restart_stage_b.log"
grep -F 'CALENDAR_LINK_TEST_KEY_CLEANUP=PASS' "$EVIDENCE/calendar_restart_stage_b.log"

python3 - "$EVIDENCE/calendar_restart_stage_a.log" "$EVIDENCE/calendar_restart_stage_b.log" "$EVIDENCE/calendar_value_comparison.json" <<'PY'
import json, pathlib, re, sys
stage_a_text = pathlib.Path(sys.argv[1]).read_text(encoding="utf-8")
stage_b_text = pathlib.Path(sys.argv[2]).read_text(encoding="utf-8")
stage_a = [json.loads(m.group(1)) for m in re.finditer(r"CALENDAR_LINK_STAGE_A_VALUE=(\{.*\})", stage_a_text)]
stage_b = [json.loads(m.group(1)) for m in re.finditer(r"CALENDAR_LINK_STAGE_B_VALUE=(\{.*\})", stage_b_text)]
fields = {"reminderId", "calendarId", "eventId", "lastSyncedFingerprint"}
if len(stage_a) != 2 or len(stage_b) != 2:
    raise SystemExit(f"Expected two stage-A and stage-B Link records; got {len(stage_a)} and {len(stage_b)}")
for i in range(2):
    if stage_a[i].get("index") != i or stage_b[i].get("index") != i:
        raise SystemExit(f"Unexpected Link order at index {i}")
    if set(stage_a[i].get("actual", {})) != fields or set(stage_b[i].get("actual", {})) != fields:
        raise SystemExit(f"Four-field evidence incomplete at index {i}")
    if stage_a[i]["actual"] != stage_b[i]["actual"]:
        raise SystemExit(f"Calendar Link value mismatch at index {i}")
result = {
    "status": "PASS",
    "links_compared": 2,
    "fields_per_link": sorted(fields),
    "total_values_compared": 8,
    "process_pid_before_stop": pathlib.Path(sys.argv[1]).read_text().split("PROCESS_PID_BEFORE_STOP=")[-1].splitlines()[0],
    "process_pid_after_restart": pathlib.Path(sys.argv[2]).read_text().split("PROCESS_PID_AFTER_RESTART=")[-1].splitlines()[0],
    "stage_a_saved_values": [row["actual"] for row in stage_a],
    "stage_b_restored_values": [row["actual"] for row in stage_b],
}
pathlib.Path(sys.argv[3]).write_text(json.dumps(result, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
PY

stage="cleanup disposable emulator app"
adb -s "$DEVICE" shell am force-stop "$APP_ID" >/dev/null 2>&1 || true
pid_final=""
for attempt in $(seq 1 30); do
  pid_final="$(adb -s "$DEVICE" shell pidof "$APP_ID" 2>/dev/null | tr -d '\r' | awk '{print $1}' || true)"
  [[ -z "$pid_final" ]] && break
  sleep 1
done
test -z "$pid_final"
echo "FINAL_APP_PROCESS_STOP=PASS" | tee "$EVIDENCE/cleanup_verification.log"
echo "APP_DATA_CLEAR=NOT_PERFORMED" | tee -a "$EVIDENCE/cleanup_verification.log"
grep -F 'CALENDAR_LINK_TEST_KEY_CLEANUP=PASS' "$EVIDENCE/calendar_restart_stage_b.log" >/dev/null
adb -s "$DEVICE" uninstall "$APP_ID" 2>&1 | tee -a "$EVIDENCE/cleanup_verification.log"
if adb -s "$DEVICE" shell pm path "$APP_ID" 2>/dev/null | grep -q "$APP_ID"; then
  echo "EMULATOR_FIXTURE_UNINSTALL=FAIL" | tee -a "$EVIDENCE/cleanup_verification.log"
  exit 1
fi
echo "EMULATOR_FIXTURE_UNINSTALL=PASS" | tee -a "$EVIDENCE/cleanup_verification.log"
echo "CALENDAR_TEST_KEY_CLEANUP=PASS" | tee -a "$EVIDENCE/cleanup_verification.log"
echo "CALENDAR_LINK_PROCESS_RESTART=PASS" | tee -a "$EVIDENCE/calendar_restart_stage_b.log"
