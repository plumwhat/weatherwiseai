#!/bin/bash

# WeatherWiseAI Local Development Setup Script
# Run this script on macOS for local development setup

set -e

echo "🌤️ Setting up WeatherWiseAI iOS Development Environment..."

# Check if Xcode is installed
if ! command -v xcodebuild &> /dev/null; then
    echo "❌ Xcode is not installed. Please install Xcode from the App Store."
    exit 1
fi

echo "✅ Xcode found"

# Check if CocoaPods is installed
if ! command -v pod &> /dev/null; then
    echo "📦 Installing CocoaPods..."
    sudo gem install cocoapods
else
    echo "✅ CocoaPods found"
fi

# Check if we're in the right directory
if [ ! -f "Package.swift" ]; then
    echo "❌ Please run this script from the WeatherWiseAI project root directory"
    exit 1
fi

# Create iOS directory structure
echo "📁 Creating iOS project structure..."
mkdir -p ios/WeatherWiseAI
mkdir -p ios/WeatherWiseAITests
mkdir -p ios/WeatherWiseAIUITests

# Create Podfile if it doesn't exist
if [ ! -f "ios/Podfile" ]; then
    echo "📝 Creating Podfile..."
    cat > ios/Podfile << EOF
# Uncomment the next line to define a global platform for your project
platform :ios, '16.0'

target 'WeatherWiseAI' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Firebase pods
  pod 'Firebase/Auth'
  pod 'Firebase/Firestore'
  pod 'Firebase/Analytics'
  pod 'Firebase/Crashlytics'
  pod 'Firebase/Performance'

  target 'WeatherWiseAITests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'WeatherWiseAIUITests' do
    # Pods for testing
  end
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '16.0'
    end
  end
end
EOF
fi

# Install CocoaPods dependencies
echo "📦 Installing CocoaPods dependencies..."
cd ios
pod install --repo-update
cd ..

# Check if Firebase configuration exists
if [ ! -f "ios/WeatherWiseAI/GoogleService-Info.plist" ]; then
    echo "⚠️  Firebase configuration missing!"
    echo "Please download GoogleService-Info.plist from Firebase Console and place it in ios/WeatherWiseAI/"
    echo "https://console.firebase.google.com"
fi

# Create .gitignore if it doesn't exist
if [ ! -f ".gitignore" ]; then
    echo "📝 Creating .gitignore..."
    cat > .gitignore << EOF
# Xcode
*.xcodeproj/project.xcworkspace/
*.xcodeproj/xcuserdata/
*.xcworkspace/xcuserdata/
DerivedData/
.build/

# CocoaPods
ios/Pods/
ios/*.xcworkspace/xcuserdata/

# Firebase
GoogleService-Info.plist

# Swift Package Manager
.swiftpm/
Package.resolved

# macOS
.DS_Store

# Archives
*.xcarchive

# Build products
*.ipa
*.app

# Fastlane
ios/fastlane/report.xml
ios/fastlane/Preview.html
ios/fastlane/screenshots/**/*.png
ios/fastlane/test_output
EOF
fi

echo ""
echo "🎉 Setup complete!"
echo ""
echo "Next steps:"
echo "1. 🔥 Add GoogleService-Info.plist to ios/WeatherWiseAI/"
echo "2. 🍎 Update Bundle Identifier in Xcode project settings"
echo "3. 🔐 Add WeatherKit capability in Xcode"
echo "4. 🔨 Build and run: open ios/WeatherWiseAI.xcworkspace"
echo ""
echo "For deployment setup, see DEPLOYMENT_GUIDE.md"
echo ""
