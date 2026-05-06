@echo off
REM Compass App - Push to GitHub Script
REM This script will push your code to GitHub

echo.
echo ========================================
echo Compass App - GitHub Push Script
echo ========================================
echo.

REM Navigate to project directory
cd /d "%~dp0"

echo Checking Git status...
git status

echo.
echo ========================================
echo Ready to push to GitHub!
echo ========================================
echo.
echo Repository: https://github.com/saketh-nandu/compass
echo Branch: main
echo.

echo Pushing to GitHub...
echo When prompted:
echo   Username: saketh-nandu
echo   Password: [Use your Personal Access Token]
echo.

git push -u origin main

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ========================================
    echo SUCCESS! Code pushed to GitHub!
    echo ========================================
    echo.
    echo Next steps:
    echo 1. Go to: https://github.com/saketh-nandu/compass
    echo 2. Enable GitHub Actions
    echo 3. Wait for APK build (5-10 minutes)
    echo 4. Download APK from Actions tab
    echo.
    pause
) else (
    echo.
    echo ========================================
    echo ERROR! Push failed!
    echo ========================================
    echo.
    echo Troubleshooting:
    echo 1. Check internet connection
    echo 2. Verify Personal Access Token
    echo 3. Ensure token has 'repo' and 'workflow' scopes
    echo 4. Try again with: git push -u origin main -v
    echo.
    pause
)
