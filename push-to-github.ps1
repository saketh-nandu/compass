# Compass App - Push to GitHub PowerShell Script

Write-Host "========================================" -ForegroundColor Green
Write-Host "Compass App - GitHub Push Script" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""

# Navigate to project directory
$projectPath = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $projectPath

Write-Host "Project Path: $projectPath" -ForegroundColor Cyan
Write-Host ""

# Check Git status
Write-Host "Checking Git status..." -ForegroundColor Yellow
git status
Write-Host ""

# Verify remote
Write-Host "Verifying remote..." -ForegroundColor Yellow
git remote -v
Write-Host ""

# Check commits
Write-Host "Recent commits:" -ForegroundColor Yellow
git log --oneline -3
Write-Host ""

# Push to GitHub
Write-Host "========================================" -ForegroundColor Green
Write-Host "Pushing to GitHub..." -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Repository: https://github.com/saketh-nandu/compass" -ForegroundColor Cyan
Write-Host "Branch: main" -ForegroundColor Cyan
Write-Host ""
Write-Host "When prompted for credentials:" -ForegroundColor Yellow
Write-Host "  Username: saketh-nandu" -ForegroundColor Yellow
Write-Host "  Password: [Your Personal Access Token]" -ForegroundColor Yellow
Write-Host ""

# Execute push
git push -u origin main

# Check result
if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "SUCCESS! Code pushed to GitHub!" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Cyan
    Write-Host "1. Go to: https://github.com/saketh-nandu/compass" -ForegroundColor Cyan
    Write-Host "2. Enable GitHub Actions" -ForegroundColor Cyan
    Write-Host "3. Wait for APK build (5-10 minutes)" -ForegroundColor Cyan
    Write-Host "4. Download APK from Actions tab" -ForegroundColor Cyan
    Write-Host ""
} else {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Red
    Write-Host "ERROR! Push failed!" -ForegroundColor Red
    Write-Host "========================================" -ForegroundColor Red
    Write-Host ""
    Write-Host "Troubleshooting:" -ForegroundColor Yellow
    Write-Host "1. Check internet connection" -ForegroundColor Yellow
    Write-Host "2. Verify Personal Access Token" -ForegroundColor Yellow
    Write-Host "3. Ensure token has 'repo' and 'workflow' scopes" -ForegroundColor Yellow
    Write-Host "4. Try again with: git push -u origin main" -ForegroundColor Yellow
    Write-Host ""
}

Read-Host "Press Enter to exit"
