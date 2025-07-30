# Build and Test Fitness AI App
Write-Host "🏗️ Building Fitness AI App with Camera and AI Fixes..." -ForegroundColor Green

# Clean build to ensure fresh start
Write-Host "🧹 Cleaning previous build..." -ForegroundColor Yellow
flutter clean

Write-Host "📦 Getting dependencies..." -ForegroundColor Yellow
flutter pub get

Write-Host "🔧 Building debug APK..." -ForegroundColor Yellow
flutter build apk --debug

Write-Host "📱 Installing on device..." -ForegroundColor Yellow
flutter install

Write-Host "✅ Build complete!" -ForegroundColor Green
Write-Host ""
Write-Host "🔍 Testing Instructions:" -ForegroundColor Cyan
Write-Host "1. Open the app on your device"
Write-Host "2. Navigate to Training tab"
Write-Host "3. Select 'Real-time Training'"
Write-Host "4. Grant camera permissions when prompted"
Write-Host "5. Test camera switching with the button in top-left"
Write-Host "6. Verify that 'POINT AT BODY' shows when no person detected"
Write-Host "7. Point camera at your body and verify 'AI ACTIVE' appears"
Write-Host "8. Try doing squats and check if counting only works with real detection"
Write-Host ""
Write-Host "🎯 Expected Behavior:" -ForegroundColor Magenta
Write-Host "- Back camera should work when toggled"
Write-Host "- Squat counting should only work when body is detected"
Write-Host "- AI status indicator should show detection state"
Write-Host "- No false counting when camera shows empty space"
