@echo off
REM ============================================================================
REM CREATE TEST USERS VIA SUPABASE CLI (Windows)
REM ============================================================================
REM This script creates test users directly via CLI
REM Usage: create_users_cli.bat
REM ============================================================================

setlocal enabledelayedexpansion

echo.
echo 🚀 Creating test users via Supabase CLI...
echo.

REM Create Male User
echo 📌 Creating male user...
call supabase auth admin create-user --email saketh_nandu127@example.com --password SupriyaSaketh127 --autoconfirm

if %ERRORLEVEL% NEQ 0 (
    echo ❌ Failed to create male user
    pause
    exit /b 1
)

echo ✅ Male user created: saketh_nandu127@example.com
echo.

REM Create Female User
echo 📌 Creating female user...
call supabase auth admin create-user --email srirenu127@example.com --password #filmmaking --autoconfirm

if %ERRORLEVEL% NEQ 0 (
    echo ❌ Failed to create female user
    pause
    exit /b 1
)

echo ✅ Female user created: srirenu127@example.com
echo.

REM Insert user profiles
echo 📌 Inserting user profiles...
call supabase db execute ^< supabase/setup_users.sql

if %ERRORLEVEL% NEQ 0 (
    echo ❌ Failed to insert user profiles
    pause
    exit /b 1
)

echo ✅ User profiles inserted
echo.

echo 🎉 All users created successfully!
echo.
echo Test credentials:
echo   Male: saketh_nandu127@example.com / SupriyaSaketh127
echo   Female: srirenu127@example.com / #filmmaking
echo.

pause
