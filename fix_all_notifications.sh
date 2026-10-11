#!/usr/bin/env bash
# ========================================================
#   SHARP AQUOS R7 - GLOBAL NOTIFICATION FIX AUTOMATOR
#   Supports Linux, macOS, and Android Termux
# ========================================================

set -e

echo "[1/5] Checking connected device..."
adb devices

echo ""
echo "[2/5] Disabling Android 14 System-Wide Restrictors..."
adb shell "settings put global adaptive_battery_management_enabled 0"
adb shell "settings put global app_standby_enabled 0"
adb shell "settings put global battery_tip_constants app_restriction_enabled=false"
adb shell "settings put global wifi_power_save 0"
adb shell "settings put global wifi_sleep_policy 2"
adb shell "cmd netpolicy set restrict-background false"
adb shell "device_config put activity_manager use_freezer false"
adb shell "device_config put activity_manager max_phantom_processes 2147483647"
adb shell "device_config set_sync_disabled_for_tests persistent"

echo ""
echo "[3/5] Whitelisting all installed user apps for Background Execution..."
adb shell "for pkg in \$(pm list packages -3 --user 0 | cut -d: -f2); do dumpsys deviceidle whitelist +\$pkg >/dev/null 2>&1; cmd appops set \$pkg RUN_IN_BACKGROUND allow >/dev/null 2>&1; cmd appops set \$pkg RUN_ANY_IN_BACKGROUND allow >/dev/null 2>&1; am set-standby-bucket \$pkg active >/dev/null 2>&1; done"

echo ""
echo "[4/5] Adding all user app UIDs to Network Policy Whitelist..."
adb shell "for uid in \$(pm list packages -3 -U --user 0 | grep -o 'uid:[0-9]*' | cut -d: -f2 | sort -u); do cmd netpolicy add restrict-background-whitelist \$uid >/dev/null 2>&1; done"

echo ""
echo "[5/5] Ensuring Google Play Services has peak push priority..."
adb shell "dumpsys deviceidle whitelist +com.google.android.gms >/dev/null 2>&1"
adb shell "cmd appops set com.google.android.gms RUN_IN_BACKGROUND allow >/dev/null 2>&1"
adb shell "cmd appops set com.google.android.gms RUN_ANY_IN_BACKGROUND allow >/dev/null 2>&1"
adb shell "am set-standby-bucket com.google.android.gms active >/dev/null 2>&1"

echo ""
echo "========================================================"
echo "  ALL APPS ARE NOW FULLY OPTIMIZED AND UNRESTRICTED!"
echo "========================================================"
