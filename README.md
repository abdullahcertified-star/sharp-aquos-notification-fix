# Sharp AQUOS R7 Background Notification & Push Fix 🚀

![Android 14](https://img.shields.io/badge/Android-14-green.svg)
![Platform](https://img.shields.io/badge/Platform-Windows%20%7C%20Linux%20%7C%20macOS-blue.svg)
![License](https://img.shields.io/badge/License-MIT-yellow.svg)
![Device](https://img.shields.io/badge/Device-Sharp%20AQUOS%20R7%20(A202SH)-orange.svg)

A complete diagnostic framework and automated script to resolve **delayed push notifications, Google FCM desync ("single grey tick"), and aggressive background killing** on the **Sharp AQUOS R7** (and other Japanese OEM Android devices).

---

## 🛑 The Problem

On imported Japanese devices like the Sharp AQUOS R7 running Android 14:
* **WhatsApp Business / WhatsApp:** Messages are not delivered when the screen is locked. Senders only see **one single grey tick** until the app is manually opened.
* **Snapchat & Messaging Apps:** Notifications are delayed for hours until unlocked.
* **5GHz Wi-Fi Missing:** The phone cannot see 5GHz Wi-Fi networks broadcasted on high-band channels (149+).

---

## 🔍 Root Cause Analysis

Through low-level ADB diagnostic inspection:
1. **Google FCM Push Token Desync:**  
   Apps migrated from older phones retain dead push tokens. Checking `dumpsys activity service GcmService` revealed that `com.whatsapp.w4b` was completely absent from Google FCM's `Apps supporting client queue`.
2. **Android 14 Linux Kernel Cached App Freezer:**  
   Android 14's kernel cgroup freezer (`use_freezer = true`) places cached background apps into a `SIGSTOP`-style state, dropping background broadcast wakeups.
3. **Network Policy Firewall:**  
   `cmd netpolicy list restrict-background-whitelist` omitted user app UIDs, cutting off background internet sockets during sleep.
4. **Japanese Radio Law (電波法) Channel Lock:**  
   The device only scans 5GHz channels 36–144. Outside Japan, routers default to channels 149–165, making the 5GHz network invisible.

---

## ⚡ Quick Start (Automated Fix)

### On Windows:
1. Enable **Developer Options** and **USB Debugging** on your phone.
2. Connect your phone to your PC.
3. Double-click `fix_all_notifications.bat`.

### On Linux / macOS / Termux:
```bash
chmod +x fix_all_notifications.sh
./fix_all_notifications.sh
```

---

## 🛠️ Step-by-Step Manual Fix

If you prefer running commands manually via ADB:

```bash
# 1. Disable Kernel App Freezer & Uncap Phantom Processes
adb shell device_config put activity_manager use_freezer false
adb shell device_config put activity_manager max_phantom_processes 2147483647
adb shell device_config set_sync_disabled_for_tests persistent

# 2. Disable App Standby & Adaptive Battery Throttling
adb shell settings put global app_standby_enabled 0
adb shell settings put global adaptive_battery_management_enabled 0
adb shell settings put global wifi_power_save 0
adb shell settings put global wifi_sleep_policy 2

# 3. Whitelist All Installed 3rd-Party User Apps
adb shell "for pkg in $(pm list packages -3 --user 0 | cut -d: -f2); do dumpsys deviceidle whitelist +$pkg; cmd appops set $pkg RUN_IN_BACKGROUND allow; cmd appops set $pkg RUN_ANY_IN_BACKGROUND allow; am set-standby-bucket $pkg active; done"

# 4. Whitelist All App UIDs in Network Policy
adb shell "for uid in $(pm list packages -3 -U --user 0 | grep -o 'uid:[0-9]*' | cut -d: -f2 | sort -u); do cmd netpolicy add restrict-background-whitelist $uid; done"
```

### 🔴 Critical Step for WhatsApp Business:
Because the app was migrated with an outdated token, perform a clean re-registration:
1. **Back up your chats:** (WhatsApp Business -> Settings -> Chats -> Chat backup).
2. **Re-register:** Run `adb shell pm clear com.whatsapp.w4b` (or uninstall and reinstall from Google Play Store).
3. Log in and restore your backup. Google Play Services will immediately issue a fresh FCM token, restoring instant delivery (**33ms latency**) and double grey ticks.

---

## 📶 5GHz Wi-Fi Fix (Channels 149–165 vs 36–48)

Japanese devices only support **Band W52 (Channels 36, 40, 44, 48)**.
If your 5GHz Wi-Fi is missing:
1. Open your router portal (`http://192.168.1.1` or `http://192.168.0.1`).
2. Go to **5GHz Wireless Settings**.
3. Change **Channel** from `Auto` / `149+` to **Channel 36** (or 40, 44, 48).
4. Set **Channel Width** to **80 MHz**.
5. Save. Your phone will immediately see and connect to the 5GHz network.

---

## 📄 License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

**Maintained by:** [Muhammad Abdullah Rashid](https://github.com/)  
*Contributions and PRs are welcome!*
