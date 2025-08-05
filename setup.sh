#!/bin/bash

# Colors for terminal output
RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
BLUE="\033[0;34m"
NC="\033[0m" # No Color

echo "${BLUE}=== SmartSweep Project Setup ===${NC}"

# Check if Tuist is installed
if ! command -v tuist &> /dev/null; then
    echo "${YELLOW}Tuist not found. Installing...${NC}"
    curl -Ls https://install.tuist.io | bash
    if [ $? -ne 0 ]; then
        echo "${RED}Failed to install Tuist. Please install it manually.${NC}"
        exit 1
    fi
    echo "${GREEN}Tuist installed successfully!${NC}"
else
    echo "${GREEN}Tuist is already installed.${NC}"
    
    # Check Tuist version
    CURRENT_VERSION=$(tuist version)
    REQUIRED_VERSION=$(cat .tuist-version)
    
    if [ "$CURRENT_VERSION" != "$REQUIRED_VERSION" ]; then
        echo "${YELLOW}Tuist version mismatch. Current: $CURRENT_VERSION, Required: $REQUIRED_VERSION${NC}"
        echo "${YELLOW}Installing required version...${NC}"
        
        # Install the specific version
        curl -Ls https://install.tuist.io | bash -s $REQUIRED_VERSION
        
        if [ $? -ne 0 ]; then
            echo "${RED}Failed to install Tuist version $REQUIRED_VERSION. Please install it manually.${NC}"
            exit 1
        fi
        echo "${GREEN}Tuist version $REQUIRED_VERSION installed successfully!${NC}"
    else
        echo "${GREEN}Tuist version $REQUIRED_VERSION is already installed.${NC}"
    fi
fi

# Clean any existing generated files
echo "${BLUE}Cleaning existing generated files...${NC}"
rm -rf *.xcodeproj
rm -rf *.xcworkspace
rm -rf .tuist-generated
rm -rf Derived

# Generate the project
echo "${BLUE}Generating project with Tuist...${NC}"
tuist generate

if [ $? -ne 0 ]; then
    echo "${RED}Failed to generate project. Please check the error messages above.${NC}"
    exit 1
fi

echo "${GREEN}Project generated successfully!${NC}"
echo "${BLUE}You can now open the project in Xcode.${NC}"