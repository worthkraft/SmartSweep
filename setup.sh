#!/bin/bash

# Colors for terminal output
RED=$'\033[0;31m'
GREEN=$'\033[0;32m'
YELLOW=$'\033[0;33m'
BLUE=$'\033[0;34m'
NC=$'\033[0m' # No Color
# Colors for terminal output
# Use `tput` when available (terminfo-aware). If stdout is not a TTY, disable colors.
if [ -t 1 ]; then
    if command -v tput >/dev/null 2>&1; then
        RED=$(tput setaf 1)
        GREEN=$(tput setaf 2)
        YELLOW=$(tput setaf 3)
        BLUE=$(tput setaf 4)
        NC=$(tput sgr0)
    else
        # Fallback to ANSI escape sequences
        RED=$'\033[0;31m'
        GREEN=$'\033[0;32m'
        YELLOW=$'\033[0;33m'
        BLUE=$'\033[0;34m'
        NC=$'\033[0m'
    fi
else
    # Not a TTY (piped or CI); disable colors
    RED=''
    GREEN=''
    YELLOW=''
    BLUE=''
    NC=''
fi

echo "${BLUE}=== SmartSweep Project Setup ===${NC}"

# Check if Tuist is installed
if ! command -v tuist &> /dev/null; then
    printf "%b\n" "${YELLOW}Tuist not found. Installing...${NC}"
    curl -Ls https://install.tuist.io | bash
    if [ $? -ne 0 ]; then
        printf "%b\n" "${RED}Failed to install Tuist. Please install it manually.${NC}"
        exit 1
    fi
    printf "%b\n" "${GREEN}Tuist installed successfully!${NC}"
else
    echo "${GREEN}Tuist is already installed.${NC}"
    
    # Check Tuist version
    CURRENT_VERSION=$(tuist version)
    REQUIRED_VERSION=$(cat .tuist-version)
    
    if [ "$CURRENT_VERSION" != "$REQUIRED_VERSION" ]; then
        printf "%b\n" "${YELLOW}Tuist version mismatch. Current: $CURRENT_VERSION, Required: $REQUIRED_VERSION${NC}"
        printf "%b\n" "${YELLOW}Installing required version...${NC}"
        
        # Install the specific version
        curl -Ls https://install.tuist.io | bash -s $REQUIRED_VERSION
        
        if [ $? -ne 0 ]; then
            printf "%b\n" "${RED}Failed to install Tuist version $REQUIRED_VERSION. Please install it manually.${NC}"
            exit 1
        fi
        printf "%b\n" "${GREEN}Tuist version $REQUIRED_VERSION installed successfully!${NC}"
    else
        printf "%b\n" "${GREEN}Tuist version $REQUIRED_VERSION is already installed.${NC}"
    fi
fi

# Clean any existing generated files
printf "%b\n" "${BLUE}Cleaning existing generated files...${NC}"
rm -rf *.xcodeproj
rm -rf *.xcworkspace
rm -rf .tuist-generated
rm -rf Derived

# Generate the project
printf "%b\n" "${BLUE}Generating project with Tuist...${NC}"
tuist generate

if [ $? -ne 0 ]; then
    printf "%b\n" "${RED}Failed to generate project. Please check the error messages above.${NC}"
    exit 1
fi

printf "%b\n" "${GREEN}Project generated successfully!${NC}"
printf "%b\n" "${BLUE}You can now open the project in Xcode.${NC}"

open SmartSweep.xcworkspace