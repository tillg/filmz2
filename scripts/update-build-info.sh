#!/bin/bash

# Build Phase Script: Generate Build Info
# This script generates dynamic build information from git and updates the Info.plist

set -e  # Exit on any error

echo "🔨 Generating build info from git..."

# Check if we're in a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo "⚠️  Not in a git repository, using fallback values"
    GIT_COMMIT="dev"
    GIT_BRANCH="local"
    BUILD_DATE=$(date +"%Y-%m-%d")
else
    # Get git info
    GIT_COMMIT=$(git rev-parse --short HEAD 2>/dev/null || echo "dev")
    GIT_BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "local")
    BUILD_DATE=$(date +"%Y-%m-%d")
    
    # Check if working directory is dirty
    if ! git diff-index --quiet HEAD -- 2>/dev/null; then
        GIT_COMMIT="${GIT_COMMIT}-dirty"
    fi
fi

BUILD_NUMBER="${BUILD_DATE}-${GIT_COMMIT}"

echo "📝 Build info:"
echo "   Date: ${BUILD_DATE}"
echo "   Commit: ${GIT_COMMIT}"
echo "   Branch: ${GIT_BRANCH}"
echo "   Build Number: ${BUILD_NUMBER}"

# Get the Info.plist path - target the source file instead of built file
SOURCE_PLIST="${SRCROOT}/filmz2/Info.plist"
if [ -n "${INFOPLIST_PATH}" ]; then
    PLIST="${TARGET_BUILD_DIR}/${INFOPLIST_PATH}"
elif [ -n "${PRODUCT_NAME}" ]; then
    # Fallback using product name
    PLIST="${TARGET_BUILD_DIR}/${PRODUCT_NAME}.app/Contents/Info.plist"
else
    # Fallback for generated Info.plist
    PLIST="${TARGET_BUILD_DIR}/filmz2.app/Contents/Info.plist"
fi

echo "📄 Updating source Info.plist: ${SOURCE_PLIST}"

# Update source Info.plist first
if [ -f "${SOURCE_PLIST}" ]; then
    # Update source Info.plist with build information
    /usr/libexec/PlistBuddy -c "Delete :CFBundleVersion" "${SOURCE_PLIST}" 2>/dev/null || true
    /usr/libexec/PlistBuddy -c "Add :CFBundleVersion string ${BUILD_NUMBER}" "${SOURCE_PLIST}"

    /usr/libexec/PlistBuddy -c "Delete :GitCommitHash" "${SOURCE_PLIST}" 2>/dev/null || true
    /usr/libexec/PlistBuddy -c "Add :GitCommitHash string ${GIT_COMMIT}" "${SOURCE_PLIST}"

    /usr/libexec/PlistBuddy -c "Delete :BuildDate" "${SOURCE_PLIST}" 2>/dev/null || true
    /usr/libexec/PlistBuddy -c "Add :BuildDate string ${BUILD_DATE}" "${SOURCE_PLIST}"

    /usr/libexec/PlistBuddy -c "Delete :GitBranch" "${SOURCE_PLIST}" 2>/dev/null || true
    /usr/libexec/PlistBuddy -c "Add :GitBranch string ${GIT_BRANCH}" "${SOURCE_PLIST}"
    
    echo "✅ Source Info.plist updated successfully"
else
    echo "⚠️  Source Info.plist not found at ${SOURCE_PLIST}"
fi

echo "📄 Also updating built Info.plist: ${PLIST}"

# Also update the built Info.plist if it exists
if [ -f "${PLIST}" ]; then
    /usr/libexec/PlistBuddy -c "Delete :CFBundleVersion" "${PLIST}" 2>/dev/null || true
    /usr/libexec/PlistBuddy -c "Add :CFBundleVersion string ${BUILD_NUMBER}" "${PLIST}"

    /usr/libexec/PlistBuddy -c "Delete :GitCommitHash" "${PLIST}" 2>/dev/null || true
    /usr/libexec/PlistBuddy -c "Add :GitCommitHash string ${GIT_COMMIT}" "${PLIST}"

    /usr/libexec/PlistBuddy -c "Delete :BuildDate" "${PLIST}" 2>/dev/null || true
    /usr/libexec/PlistBuddy -c "Add :BuildDate string ${BUILD_DATE}" "${PLIST}"

    /usr/libexec/PlistBuddy -c "Delete :GitBranch" "${PLIST}" 2>/dev/null || true
    /usr/libexec/PlistBuddy -c "Add :GitBranch string ${GIT_BRANCH}" "${PLIST}"
    
    echo "✅ Built Info.plist updated successfully"
else
    echo "⚠️  Built Info.plist not found at ${PLIST}, will be created during build"
fi

echo "✅ Build info update completed"