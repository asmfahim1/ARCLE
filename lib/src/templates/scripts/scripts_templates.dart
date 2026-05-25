class ScriptsTemplates {
  static String setupSh() => r'''
#!/bin/bash
# ARCLE Project Setup Script
# Run this script to set up the development environment.

set -e

echo "🚀 ARCLE Project Setup"
echo "====================="

# Check Flutter
if ! command -v flutter &> /dev/null; then
  echo "❌ Flutter not found. Install from https://flutter.dev"
  exit 1
fi
echo "✅ Flutter: $(flutter --version | head -1)"

# Check Dart
if ! command -v dart &> /dev/null; then
  echo "❌ Dart not found. Install from https://dart.dev"
  exit 1
fi
echo "✅ Dart: $(dart --version)"

# Install dependencies
echo ""
echo "📦 Installing dependencies..."
flutter pub get

echo ""
echo "✅ Setup complete! Run 'flutter run' to start."
''';

  static String setupPs1() => r'''
# ARCLE Project Setup Script (PowerShell)
# Run this script to set up the development environment.

Write-Host "🚀 ARCLE Project Setup" -ForegroundColor Cyan
Write-Host "=====================" -ForegroundColor Cyan

# Check Flutter
$flutter = Get-Command flutter -ErrorAction SilentlyContinue
if (-not $flutter) {
  Write-Host "❌ Flutter not found. Install from https://flutter.dev" -ForegroundColor Red
  exit 1
}
Write-Host "✅ Flutter found" -ForegroundColor Green

# Check Dart
$dart = Get-Command dart -ErrorAction SilentlyContinue
if (-not $dart) {
  Write-Host "❌ Dart not found. Install from https://dart.dev" -ForegroundColor Red
  exit 1
}
Write-Host "✅ Dart found" -ForegroundColor Green

# Install dependencies
Write-Host ""
Write-Host "📦 Installing dependencies..." -ForegroundColor Yellow
flutter pub get

Write-Host ""
Write-Host "✅ Setup complete! Run 'flutter run' to start." -ForegroundColor Green
''';

  static String doctorSh() => r'''
#!/bin/bash
# ARCLE Project Doctor Script
# Validates your development environment and project health.

set -e

echo "🏥 ARCLE Project Doctor"
echo "======================"

ERRORS=0

# Flutter check
if command -v flutter &> /dev/null; then
  echo "✅ Flutter installed"
else
  echo "❌ Flutter not found"
  ERRORS=$((ERRORS + 1))
fi

# Dart check
if command -v dart &> /dev/null; then
  echo "✅ Dart installed"
else
  echo "❌ Dart not found"
  ERRORS=$((ERRORS + 1))
fi

# pubspec.yaml check
if [ -f "pubspec.yaml" ]; then
  echo "✅ pubspec.yaml found"
else
  echo "❌ pubspec.yaml not found — are you in a Flutter project?"
  ERRORS=$((ERRORS + 1))
fi

# arcle.yaml check
if [ -f "arcle.yaml" ]; then
  echo "✅ arcle.yaml found"
else
  echo "⚠️  arcle.yaml not found — run 'arcle init' to scaffold"
fi

# .ai/ check
if [ -d ".ai" ]; then
  echo "✅ .ai/ configuration found"
else
  echo "⚠️  .ai/ not found — run 'arcle ai init' to generate AI config"
fi

echo ""
if [ $ERRORS -eq 0 ]; then
  echo "✅ All checks passed!"
else
  echo "❌ $ERRORS error(s) found. Please fix them before continuing."
  exit 1
fi
''';

  static String doctorPs1() => r'''
# ARCLE Project Doctor Script (PowerShell)
# Validates your development environment and project health.

Write-Host "🏥 ARCLE Project Doctor" -ForegroundColor Cyan
Write-Host "======================" -ForegroundColor Cyan

$errors = 0

# Flutter check
if (Get-Command flutter -ErrorAction SilentlyContinue) {
  Write-Host "✅ Flutter installed" -ForegroundColor Green
} else {
  Write-Host "❌ Flutter not found" -ForegroundColor Red
  $errors++
}

# Dart check
if (Get-Command dart -ErrorAction SilentlyContinue) {
  Write-Host "✅ Dart installed" -ForegroundColor Green
} else {
  Write-Host "❌ Dart not found" -ForegroundColor Red
  $errors++
}

# pubspec.yaml check
if (Test-Path "pubspec.yaml") {
  Write-Host "✅ pubspec.yaml found" -ForegroundColor Green
} else {
  Write-Host "❌ pubspec.yaml not found — are you in a Flutter project?" -ForegroundColor Red
  $errors++
}

# arcle.yaml check
if (Test-Path "arcle.yaml") {
  Write-Host "✅ arcle.yaml found" -ForegroundColor Green
} else {
  Write-Host "⚠️  arcle.yaml not found — run 'arcle init' to scaffold" -ForegroundColor Yellow
}

# .ai/ check
if (Test-Path ".ai") {
  Write-Host "✅ .ai/ configuration found" -ForegroundColor Green
} else {
  Write-Host "⚠️  .ai/ not found — run 'arcle ai init' to generate AI config" -ForegroundColor Yellow
}

Write-Host ""
if ($errors -eq 0) {
  Write-Host "✅ All checks passed!" -ForegroundColor Green
} else {
  Write-Host "❌ $errors error(s) found. Please fix them before continuing." -ForegroundColor Red
  exit 1
}
''';
}
