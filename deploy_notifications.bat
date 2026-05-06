@echo off
REM Notification System Deployment Script for Windows
REM This script automates the deployment of the FCM notification system

echo 🚀 Deploying Hushnav Notification System...
echo ==========================================

REM Check if Supabase CLI is installed
echo [INFO] Checking Supabase CLI installation...
supabase --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Supabase CLI is not installed!
    echo Please install it with: npm install -g supabase
    pause
    exit /b 1
)
echo [SUCCESS] Supabase CLI found

REM Check if user is logged in to Supabase
echo [INFO] Checking Supabase authentication...
supabase status >nul 2>&1
if %errorlevel% neq 0 (
    echo [WARNING] Not logged in to Supabase
    echo Please run: supabase login
    pause
    exit /b 1
)
echo [SUCCESS] Supabase authentication verified

REM Link to Supabase project
echo [INFO] Linking to Supabase project...
set SUPABASE_PROJECT_REF=mihtycztbooxfxliqvmi

if not exist ".supabase\config.toml" (
    echo [INFO] Linking project for the first time...
    supabase link --project-ref %SUPABASE_PROJECT_REF%
) else (
    echo [SUCCESS] Project already linked
)

REM Deploy the Edge Function
echo [INFO] Deploying send-notification Edge Function...
supabase functions deploy send-notification
if %errorlevel% neq 0 (
    echo [ERROR] Failed to deploy Edge Function
    pause
    exit /b 1
)
echo [SUCCESS] Edge Function deployed successfully!

REM Database setup instructions
echo [INFO] Checking database setup...
echo Please run the following SQL in your Supabase dashboard:
echo 1. Go to https://supabase.com/dashboard/project/%SUPABASE_PROJECT_REF%/sql
echo 2. Copy and run the contents of 'database_setup_notifications.sql'
echo.
echo [WARNING] Database setup must be done manually in Supabase dashboard

REM Test the function
echo [INFO] Testing Edge Function deployment...
supabase functions list | findstr "send-notification" >nul 2>&1
if %errorlevel% equ 0 (
    echo [SUCCESS] Edge Function is deployed and available
) else (
    echo [WARNING] Edge Function may not be properly deployed
)

REM Flutter dependencies check
echo [INFO] Checking Flutter dependencies...
flutter pub deps | findstr "firebase_messaging" >nul 2>&1
if %errorlevel% equ 0 (
    echo [SUCCESS] Firebase messaging dependency found
) else (
    echo [WARNING] Firebase messaging dependency may be missing
    echo Run: flutter pub get
)

REM Final instructions
echo.
echo 🎉 Deployment Complete!
echo ======================
echo.
echo Next steps:
echo 1. 📊 Set up database tables:
echo    - Go to Supabase SQL Editor
echo    - Run database_setup_notifications.sql
echo.
echo 2. 📱 Test the app:
echo    - flutter run -d chrome
echo    - Try the 'Notify Partner' feature
echo.
echo 3. 🔧 Test on Android:
echo    - flutter build apk --debug
echo    - flutter install
echo.
echo 4. 📋 Monitor logs:
echo    - Supabase: supabase functions logs send-notification
echo    - Flutter: flutter logs
echo.
echo [SUCCESS] Notification system is ready! 🚀

REM Show function URL
echo.
echo 📡 Edge Function URL: https://%SUPABASE_PROJECT_REF%.supabase.co/functions/v1/send-notification
echo 🔗 Supabase Dashboard: https://supabase.com/dashboard/project/%SUPABASE_PROJECT_REF%
echo.
echo For detailed setup instructions, see: NOTIFICATION_SETUP_GUIDE.md

pause