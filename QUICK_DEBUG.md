# Quick Notification Debug Guide

## Step 1: Connect Your Device
1. Connect phone via USB
2. Enable USB debugging on phone
3. Run: `adb devices` (should show your device)

## Step 2: Check Current State

### A. Verify Environment Variables
Open `.env` file and check:
```
FCM_PROJECT_ID=ryse-two  ← Should match your Firebase project
FCM_PRIVATE_KEY=-----BEGIN PRIVATE KEY-----\n...  ← Must have \n characters
FCM_CLIENT_EMAIL=firebase-adminsdk-...@ryse-two.iam.gserviceaccount.com
```

### B. Check google-services.json
Open `android/app/google-services.json` and verify:
```json
{
  "client": [{
    "client_info": {
      "android_client_info": {
        "package_name": "com.skyryse.ryse_two"  ← Must match
      }
    }
  }]
}
```

## Step 3: Run Diagnostic

### Option A: Using Batch Script (Easiest)
```cmd
check_notifications.bat
```
Then open the app and add an expense. Watch for these logs:

### Option B: Manual Commands
```cmd
# Clear logs
adb logcat -c

# Watch logs
adb logcat | findstr /I "flutter FCM MongoDB notification"
```

## What to Look For

### ✅ GOOD - Everything Working:
```
✅ Environment variables loaded
✅ Firebase initialized
✅ FCM Service initialized
🔑 FCM Token: [long token string]
💾 Token saved to database
✅ MongoDB Connected Successfully!
📋 Loaded X cofounders from database
📋 Loaded X expenses from database

[After adding expense:]
➕ Adding new expense: Test - ₹100.0
💾 Inserting expense: Test - ₹100.0
✅ Expense inserted with ID: [id]
📤 Sending notification for expense...
📤 Sending notification to all devices...
📱 Found 1 device(s) to notify
✅ Notification sent successfully to device
✅ Notification broadcast completed
```

### ❌ PROBLEM SCENARIOS:

#### Scenario 1: No FCM Token
```
⚠️ FCM Token is null
```
**Fix:**
1. Check `google-services.json` exists in `android/app/`
2. Package name must be `com.skyryse.ryse_two`
3. Rebuild app: `flutter clean && flutter build apk`

#### Scenario 2: No Device Tokens in Database
```
⚠️ No device tokens found in database
```
**Fix:**
1. Check MongoDB connection logs
2. Close and reopen app to trigger token save
3. Verify internet connection

#### Scenario 3: OAuth Token Error
```
❌ Failed to get OAuth access token
💡 Please configure service account credentials in .env file
```
**Fix:**
1. Go to Firebase Console → Project Settings → Service Accounts
2. Click "Generate New Private Key"
3. Download JSON file
4. Copy these values to `.env`:
   - `project_id` → `FCM_PROJECT_ID`
   - `private_key` → `FCM_PRIVATE_KEY` (keep the `\n` characters!)
   - `client_email` → `FCM_CLIENT_EMAIL`

#### Scenario 4: FCM API Error
```
❌ FCM V1 request failed: 401
```
**Fix:** OAuth credentials are wrong. Re-download service account JSON.

```
❌ FCM V1 request failed: 404
```
**Fix:** Project ID is wrong. Check `FCM_PROJECT_ID` matches Firebase.

```
❌ FCM V1 request failed: 400
```
**Fix:** Device token is invalid. Close and reopen app to get new token.

#### Scenario 5: MongoDB Connection Failed
```
❌ MongoDB Connection Error: [error]
```
**Fix:**
1. Check internet connection
2. Check MongoDB Atlas IP whitelist includes your IP
3. Verify username/password in `mongodb_helper.dart`

#### Scenario 6: No Logs at All
**Fix:**
1. Make sure you rebuilt the app after applying fixes
2. Ensure you installed the new APK
3. Check if app is actually running

## Step 4: Common Quick Fixes

### Fix 1: Rebuild Everything
```cmd
cd r:\skyrise\skyryse\ryse_two
flutter clean
flutter pub get
flutter build apk --release --split-per-abi
adb install build\app\outputs\flutter-apk\app-arm64-v8a-release.apk
```

### Fix 2: Force Close and Reopen App
```cmd
adb shell am force-stop com.skyryse.ryse_two
adb shell am start -n com.skyryse.ryse_two/.MainActivity
```

### Fix 3: Check Notification Permission
```cmd
adb shell dumpsys notification | findstr "com.skyryse.ryse_two"
```
Should show notifications enabled.

### Fix 4: Test Internet Connection (if using emulator)
```cmd
adb shell ping -c 3 8.8.8.8
```
Should get replies. If not, restart emulator.

## Step 5: Manual Notification Test

If logs show notification sent but not received, test if FCM works at all:

1. Go to Firebase Console → Cloud Messaging
2. Click "Send test message"
3. Enter your FCM token (from logs: `🔑 FCM Token: ...`)
4. Send notification
5. If this doesn't work → Problem is with Firebase setup, not code

## Most Common Issue: .env Configuration

**The #1 reason notifications fail is incorrect `.env` setup.**

Your `.env` should look like this (with real values):
```env
FCM_PROJECT_ID=ryse-two
FCM_PRIVATE_KEY=-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkq...(very long)...4qDS0bdX\n-----END PRIVATE KEY-----\n
FCM_CLIENT_EMAIL=firebase-adminsdk-xxxxx@ryse-two.iam.gserviceaccount.com
```

**Critical:**
- `\n` must be in the private key (not actual newlines)
- No extra spaces
- No quotes around values
- Private key is one long line with `\n` characters

## Still Not Working?

Run this to save all logs to a file:
```cmd
adb logcat > notification_debug.txt
```

Then:
1. Open the app
2. Add an expense
3. Wait 10 seconds
4. Press Ctrl+C
5. Open `notification_debug.txt` and search for:
   - "FCM"
   - "notification"
   - "❌"
   - "⚠️"

Share the relevant error lines for further debugging.
