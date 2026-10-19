#!/usr/bin/env bash
set -Eeuo pipefail

evidence_dir=".github/calendar-provider-evidence"
mkdir -p "$evidence_dir"
trap 'rc=$?; if [[ ! -s "$evidence_dir/result.txt" ]]; then printf "RESULT=FAIL_SCRIPT_EXIT_%s\\n" "$rc" > "$evidence_dir/result.txt"; fi' ERR

printf 'CHECKOUT_SHA=%s\\n' "$(git rev-parse HEAD)" >> "$evidence_dir/environment.txt"
printf 'PR_HEAD_SHA=%s\\n' "${ARVIN_PR_HEAD_SHA:-unknown}" >> "$evidence_dir/environment.txt"
device="$(adb devices | awk '$1 ~ /^emulator-/ && $2 == "device" { print $1; exit }')"
if [[ -z "$device" ]]; then
  echo "No booted Android emulator found." | tee "$evidence_dir/test-output.txt"
  echo 'RESULT=FAIL_NO_EMULATOR' > "$evidence_dir/result.txt"
  exit 1
fi
printf 'ADB_DEVICE=%s\\n' "$device" >> "$evidence_dir/environment.txt"
printf 'EMULATOR_API=%s\\n' "$(adb -s "$device" shell getprop ro.build.version.sdk | tr -d '\\r')" >> "$evidence_dir/environment.txt"
adb -s "$device" shell dumpsys package providers 2>&1 | grep -i -E 'calendar|com.android.providers.calendar' >> "$evidence_dir/environment.txt" || true

flutter build apk --debug -t lib/main.dart
adb -s "$device" install -r build/app/outputs/flutter-apk/app-debug.apk
adb -s "$device" shell pm grant com.example.arvin android.permission.READ_CALENDAR
adb -s "$device" shell pm grant com.example.arvin android.permission.WRITE_CALENDAR

# The full command is passed as one remote-shell string; quote the URI so
# account query parameters are not parsed as shell background operators.
seed_uri='content://com.android.calendar/calendars?caller_is_syncadapter=true&account_name=arvin-acceptance&account_type=LOCAL'
set +e
seed_output="$(adb -s "$device" shell "content insert --uri '$seed_uri' --bind account_name:s:arvin-acceptance --bind account_type:s:LOCAL --bind name:s:arvin-acceptance --bind calendar_displayName:s:ArvinAcceptance --bind calendar_color:i:-16776961 --bind calendar_access_level:i:700 --bind ownerAccount:s:arvin-acceptance --bind visible:i:1 --bind sync_events:i:1" 2>&1)"
seed_rc=$?
set -e

destination_seed_uri='content://com.android.calendar/calendars?caller_is_syncadapter=true&account_name=arvin-acceptance-destination&account_type=LOCAL'
set +e
destination_seed_output="$(adb -s "$device" shell "content insert --uri '$destination_seed_uri' --bind account_name:s:arvin-acceptance-destination --bind account_type:s:LOCAL --bind name:s:arvin-acceptance-destination --bind calendar_displayName:s:ArvinAcceptanceDestination --bind calendar_color:i:-16776960 --bind calendar_access_level:i:700 --bind ownerAccount:s:arvin-acceptance-destination --bind visible:i:1 --bind sync_events:i:1" 2>&1)"
destination_seed_rc=$?
set -e

calendar_rows="$(adb -s "$device" shell content query --uri content://com.android.calendar/calendars --projection _id:account_name:account_type:calendar_displayName:calendar_access_level 2>&1 || true)"
{
  printf 'CALENDAR_SEED_EXIT=%s\n' "$seed_rc"
  printf 'CALENDAR_SEED_OUTPUT_BEGIN\n%s\nCALENDAR_SEED_OUTPUT_END\n' "$seed_output"
  printf 'CALENDAR_DESTINATION_SEED_EXIT=%s\n' "$destination_seed_rc"
  printf 'CALENDAR_DESTINATION_SEED_OUTPUT_BEGIN\n%s\nCALENDAR_DESTINATION_SEED_OUTPUT_END\n' "$destination_seed_output"
  printf 'CALENDAR_ROWS_BEGIN\n%s\nCALENDAR_ROWS_END\n' "$calendar_rows"
} >> "$evidence_dir/environment.txt"

primary_calendar_id="$(printf '%s\n' "$calendar_rows" | grep -F 'calendar_displayName=ArvinAcceptance,' | sed -n 's/.*_id=\([0-9][0-9]*\).*/\1/p' | head -n1 | tr -d '\r' || true)"
destination_calendar_id="$(printf '%s\n' "$calendar_rows" | grep -F 'calendar_displayName=ArvinAcceptanceDestination,' | sed -n 's/.*_id=\([0-9][0-9]*\).*/\1/p' | head -n1 | tr -d '\r' || true)"
if [[ -z "$primary_calendar_id" ]]; then
  echo 'RESULT=FAIL_PRIMARY_CALENDAR_NOT_SEEDED' > "$evidence_dir/result.txt"
  echo "::error::Primary writable acceptance calendar was not seeded."
  exit 1
fi

seed_unrelated_event() {
  local calendar_id="$1"
  local title="ARVIN_UNRELATED_PRESERVATION_SENTINEL_$calendar_id"
  local start_ms=$(( $(date +%s) * 1000 + 14400000 ))
  local end_ms=$(( start_ms + 1800000 ))
  local output
  local rc
  set +e
  output="$(adb -s "$device" shell "content insert --uri content://com.android.calendar/events --bind calendar_id:i:$calendar_id --bind title:s:$title --bind dtstart:l:$start_ms --bind dtend:l:$end_ms --bind eventTimezone:s:UTC --bind allDay:i:0 --bind description:s:unrelated-preservation-sentinel" 2>&1)"
  rc=$?
  set -e
  {
    printf 'UNRELATED_SENTINEL_CALENDAR_ID=%s\n' "$calendar_id"
    printf 'UNRELATED_SENTINEL_TITLE=%s\n' "$title"
    printf 'UNRELATED_SENTINEL_START_MS=%s\n' "$start_ms"
    printf 'UNRELATED_SENTINEL_INSERT_EXIT=%s\n' "$rc"
    printf 'UNRELATED_SENTINEL_INSERT_OUTPUT_BEGIN\n%s\nUNRELATED_SENTINEL_INSERT_OUTPUT_END\n' "$output"
  } >> "$evidence_dir/environment.txt"
  if [[ "$rc" -ne 0 ]]; then
    echo 'RESULT=FAIL_UNRELATED_SENTINEL_SEED' > "$evidence_dir/result.txt"
    echo "::error::Failed to seed unrelated event sentinel for calendar $calendar_id."
    exit 1
  fi
}
seed_unrelated_event "$primary_calendar_id"
if [[ -n "$destination_calendar_id" ]]; then
  seed_unrelated_event "$destination_calendar_id"
fi

set +e
flutter test integration_test/android_calendar_provider_acceptance_test.dart -d "$device" > "$evidence_dir/test-output.txt" 2>&1
test_rc=$?
set -e
cat "$evidence_dir/test-output.txt" 2>/dev/null || true

if [[ "$test_rc" -ne 0 ]]; then
  printf 'RESULT=FAIL_PROVIDER_TEST_EXIT_%s\\n' "$test_rc" > "$evidence_dir/result.txt"
  exit "$test_rc"
fi
if grep -q 'CALENDAR_PROVIDER_ACCEPTANCE=PASS' "$evidence_dir/test-output.txt"; then
  echo 'RESULT=PASS_REAL_PROVIDER_CREATE_NOOP_UPDATE_DELETE' > "$evidence_dir/result.txt"
  exit 0
fi
if grep -q 'CALENDAR_PROVIDER_ACCEPTANCE=LIMITATION_NO_WRITABLE_CALENDAR_ON_STOCK_EMULATOR' "$evidence_dir/test-output.txt"; then
  echo 'RESULT=BLOCKED_NO_WRITABLE_CALENDAR_PROVIDER' > "$evidence_dir/result.txt"
  echo "::error::Calendar Provider acceptance is blocked: no writable calendar was discovered. This is not a pass."
  exit 1
fi
echo 'RESULT=FAIL_NO_EXPLICIT_ACCEPTANCE_MARKER' > "$evidence_dir/result.txt"
echo "::error::Provider test produced no explicit PASS marker."
exit 1
