#!/usr/bin/env bash
# Release smoke test.
#
# Analyze and unit tests cannot catch failures that only exist after R8 or
# plugin registration, and the UI swallows preference errors. This script
# installs the built artifact on a device image, starts it and fails if the
# process dies, the activity is not resumed, or persistence reported an error.
set -euo pipefail

APP_ID="io.github.marodriguezd.hairwashtracker"
APK="${1:?usage: release-smoke.sh <apk path>}"
WAIT_SECONDS="${SMOKE_WAIT_SECONDS:-15}"

# A dozing or locked screen hands focus back to the launcher, which would look
# like a failed launch.
adb shell input keyevent KEYCODE_WAKEUP || true
adb shell wm dismiss-keyguard || true
sleep 2

adb install -r "$APK"
adb logcat -c
adb shell am start -W -n "$APP_ID/.MainActivity"
sleep "$WAIT_SECONDS"

PID=$(adb shell pidof "$APP_ID" | tr -d '\r')
if [ -z "$PID" ]; then
  echo "::error::The app process died after launch."
  adb logcat -d | tail -200
  exit 1
fi

# Window focus survives the different dumpsys layouts across API levels, while
# the activity dump moved its resumed marker between releases.
FOCUSED=0
for _ in $(seq 1 10); do
  if adb shell dumpsys window \
    | grep -E "mCurrentFocus|mFocusedApp" \
    | grep -q hairwashtracker; then
    FOCUSED=1
    break
  fi
  sleep 3
done
if [ "$FOCUSED" -ne 1 ]; then
  echo "::error::The app never took focus after launch."
  adb shell dumpsys window | grep -E "mCurrentFocus|mFocusedApp" || true
  exit 1
fi

adb exec-out screencap -p > smoke.png

APP_LOG=$(adb logcat -d --pid="$PID")
if echo "$APP_LOG" | grep -qE "Error loading persisted state|NoSuchMethodError"; then
  echo "::error::Persistence failed at startup; the build would lose user data."
  echo "$APP_LOG"
  exit 1
fi

echo "Smoke test passed: process $PID running, no persistence errors."
