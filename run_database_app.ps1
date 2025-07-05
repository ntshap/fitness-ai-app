Write-Host "FITNESS AI APP - DATABASE INTEGRATED VERSION" -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan

Write-Host "Building app with SQLite database integration..." -ForegroundColor Green
Write-Host "This version includes user authentication and data storage." -ForegroundColor Yellow

flutter build apk --debug --no-tree-shake-icons

if ($LASTEXITCODE -eq 0) {
    Write-Host "Setting up APK location..." -ForegroundColor Green
    New-Item -ItemType Directory -Path "build\app\outputs\flutter-apk" -Force | Out-Null
    
    if (Test-Path "android\app\build\outputs\apk\debug\app-debug.apk") {
        Copy-Item "android\app\build\outputs\apk\debug\app-debug.apk" "build\app\outputs\flutter-apk\app-debug.apk" -Force
        
        Write-Host "Installing database-integrated version..." -ForegroundColor Green
        flutter install --debug
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "Launching FITNESS AI APP (Database Version)..." -ForegroundColor Green
            & "C:\Users\natas\AppData\Local\Android\sdk\platform-tools\adb.exe" shell am start -n com.example.fitness_ai_app/.MainActivity
            
            Write-Host "FITNESS AI APP launched successfully!" -ForegroundColor Green
            Write-Host "DATABASE FEATURES AVAILABLE:" -ForegroundColor Yellow
            Write-Host "- User Registration & Login" -ForegroundColor White
            Write-Host "- Workout Data Storage" -ForegroundColor White
            Write-Host "- Exercise Tracking" -ForegroundColor White
            Write-Host "- Progress Monitoring" -ForegroundColor White
            Write-Host "- AI Analysis Storage" -ForegroundColor White
            
            $apkSize = (Get-Item "android\app\build\outputs\apk\debug\app-debug.apk").Length / 1MB
            Write-Host "APK Size: $([math]::Round($apkSize, 2)) MB (Full database version)" -ForegroundColor Cyan
        } else {
            Write-Host "Failed to install APK" -ForegroundColor Red
        }
    } else {
        Write-Host "Database APK not found after build" -ForegroundColor Red
    }
} else {
    Write-Host "Build failed" -ForegroundColor Red
}

Write-Host "Press Enter to continue..." -ForegroundColor Gray
Read-Host
