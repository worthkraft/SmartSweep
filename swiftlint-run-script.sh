#!/bin/bash

# SwiftLint Run Script for Xcode Build Phase
# Add this script to a Run Script Phase in your target's Build Phases

if which swiftlint > /dev/null; then
  swiftlint
else
  echo "warning: SwiftLint not installed, download from https://github.com/realm/SwiftLint"
fi