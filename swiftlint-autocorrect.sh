#!/bin/bash

# SwiftLint Auto-correction Script
# This script automatically fixes SwiftLint violations that can be auto-corrected

echo "Running SwiftLint auto-correction..."

if which swiftlint > /dev/null; then
  swiftlint --fix
  echo "Auto-correction complete. Running SwiftLint again to check remaining violations..."
  swiftlint
else
  echo "Error: SwiftLint not installed. Please install it using 'brew install swiftlint'."
  exit 1
fi