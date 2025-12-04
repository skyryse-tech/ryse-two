@echo off
echo ========================================
echo   Notification System Diagnostic
echo ========================================
echo.

echo Checking device connection...
adb devices
echo.

echo ========================================
echo Clearing old logs...
adb logcat -c
echo.

echo ========================================
echo Starting log monitoring...
echo Please open the app and add an expense
echo Press Ctrl+C when done to stop logs
echo ========================================
echo.

adb logcat | findstr /I "flutter FCM MongoDB notification"
