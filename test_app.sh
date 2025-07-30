#!/bin/bash

# Build and Test Fitness AI App
echo "🏗️ Building Fitness AI App with Camera and AI Fixes..."

# Clean build to ensure fresh start
echo "🧹 Cleaning previous build..."
flutter clean

echo "📦 Getting dependencies..."
flutter pub get

echo "🔧 Building debug APK..."
flutter build apk --debug

echo "📱 Installing on device..."
flutter install

echo "✅ Build complete!"
echo ""
echo "🔍 Testing Instructions:"
echo "1. Open the app on your device"
echo "2. Navigate to Training tab"
echo "3. Select 'Real-time Training'"
echo "4. Grant camera permissions when prompted"
echo "5. Test camera switching with the button in top-left"
echo "6. Verify that 'POINT AT BODY' shows when no person detected"
echo "7. Point camera at your body and verify 'AI ACTIVE' appears"
echo "8. Try doing squats and check if counting only works with real detection"
echo ""
echo "🎯 Expected Behavior:"
echo "- Back camera should work when toggled"
echo "- Squat counting should only work when body is detected"
echo "- AI status indicator should show detection state"
echo "- No false counting when camera shows empty space"
