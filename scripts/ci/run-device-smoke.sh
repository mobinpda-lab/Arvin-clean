#!/usr/bin/env bash
set -euo pipefail

test_file="$1"
scenario="$2"

dump_android_diagnostics() {
  echo "=== ADB devices ==="
  adb devices -l || true
  echo "=== Activity state ==="
  adb -s "$device" shell dumpsys activity activities || true
  echo "=== Package state ==="
  adb -s "$device" shell dumpsys package com.example.arvin || true
  echo "=== Recent Android logcat ==="
  adb -s "$device" logcat -d -t 500 || true
}

device="$(adb devices | awk '$1 ~ /^emulator-/ && $2 == "device" {print $1; exit}')"
test -n "$device" || { adb devices -l; echo "No ready Android emulator found" >&2; exit 1; }
echo "ADB_DEVICE=$device"
echo "ANDROID_API=$(adb -s "$device" shell getprop ro.build.version.sdk | tr -d '\r')"
echo "ANDROID_BOOT_COMPLETED=$(adb -s "$device" shell getprop sys.boot_completed | tr -d '\r')"
test "$(adb -s "$device" shell getprop sys.boot_completed | tr -d '\r')" = "1"

if [[ "$scenario" == "task-lifecycle" || "$scenario" == "checklist-evolution" ]]; then
  # Flutter drive normally stops the app on completion; keep it running so the
  # next steps can prove a real force-stop/restart against the same data.
  flutter drive --driver=test_driver/integration_test.dart --target="$test_file" -d "$device" --keep-app-running
else
  flutter drive --driver=test_driver/integration_test.dart --target="$test_file" -d "$device"
fi

if [[ "$scenario" == "task-lifecycle" || "$scenario" == "checklist-evolution" ]]; then
  echo "ARVIN_LIFECYCLE_RESTART_BEGIN"
  package_id="$(adb -s "$device" shell pm list packages | tr -d '\r' | sed -n 's/^package://p' | grep -Fx 'com.example.arvin' || true)"
  test "$package_id" = "com.example.arvin" || { dump_android_diagnostics; echo "Expected installed package com.example.arvin" >&2; exit 1; }

  launcher_output="$(adb -s "$device" shell cmd package resolve-activity --brief --user 0 -a android.intent.action.MAIN -c android.intent.category.LAUNCHER -p "$package_id" 2>&1)" || {
    printf '%s\n' "$launcher_output"
    dump_android_diagnostics
    exit 1
  }
  launcher_component="$(printf '%s\n' "$launcher_output" | tr -d '\r' | grep -E "^com\\.example\\.arvin/" | tail -n 1)"
  test -n "$launcher_component" || { printf '%s\n' "$launcher_output"; dump_android_diagnostics; exit 1; }
  case "$launcher_component" in "$package_id/"*) ;; *) printf '%s\n' "$launcher_output"; dump_android_diagnostics; exit 1 ;; esac
  echo "ARVIN_LIFECYCLE_PACKAGE=$package_id"
  echo "ARVIN_LIFECYCLE_LAUNCHER=$launcher_component"

  before_pid="$(adb -s "$device" shell pidof "$package_id" 2>/dev/null | tr -d '\r' || true)"
  test -n "$before_pid" || { echo "Expected running app before force-stop" >&2; dump_android_diagnostics; exit 1; }
  echo "ARVIN_LIFECYCLE_OLD_PID=$before_pid"

  force_stop_output="$(adb -s "$device" shell am force-stop "$package_id" 2>&1)" || {
    printf '%s\n' "$force_stop_output"
    dump_android_diagnostics
    exit 1
  }
  printf '%s\n' "$force_stop_output"
  stopped_pid="$(adb -s "$device" shell pidof "$package_id" 2>/dev/null | tr -d '\r' || true)"
  test -z "$stopped_pid" || { echo "Expected process terminated but pid remains: $stopped_pid" >&2; dump_android_diagnostics; exit 1; }
  echo "ARVIN_LIFECYCLE_STOP_VERIFIED old_pid=$before_pid process_absent=true"

  start_output="$(adb -s "$device" shell am start -W -n "$launcher_component" 2>&1)" || {
    printf '%s\n' "$start_output"
    dump_android_diagnostics
    exit 1
  }
  printf '%s\n' "$start_output"
  printf '%s\n' "$start_output" | grep -q 'Status: ok' || { echo "am start did not report Status: ok" >&2; dump_android_diagnostics; exit 1; }
  sleep 3
  after_pid="$(adb -s "$device" shell pidof "$package_id" 2>/dev/null | tr -d '\r' || true)"
  test -n "$after_pid" || { echo "Launcher returned but app process is absent" >&2; dump_android_diagnostics; exit 1; }
  test "$before_pid" != "$after_pid" || { echo "Process ID unchanged across force-stop/restart: $before_pid" >&2; dump_android_diagnostics; exit 1; }
  echo "ARVIN_LIFECYCLE_RESTART_VERIFIED old_pid=$before_pid new_pid=$after_pid"

  if [[ "$scenario" == "checklist-evolution" ]]; then
    flutter drive --driver=test_driver/integration_test.dart --target=integration_test/android_checklist_evolution_restart_verify_test.dart -d "$device"
  else
    flutter drive --driver=test_driver/integration_test.dart --target=integration_test/android_task_lifecycle_restart_verify_test.dart -d "$device"
  fi
fi
