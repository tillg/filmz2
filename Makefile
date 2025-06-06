# Filmz2 Build Commands
.PHONY: build build-ios test test-ios testUI clean help

# Default target
help:
	@echo "Available commands:"
	@echo "  build     - Build for macOS"
	@echo "  build-ios - Build for iOS simulator"
	@echo "  test      - Run unit tests on macOS"
	@echo "  test-ios  - Run unit tests on iOS simulator"
	@echo "  testUI    - Run UI tests on iOS simulator"
	@echo "  clean     - Clean build artifacts"

# Build targets
build:
	xcodebuild -project filmz2.xcodeproj -scheme filmz2 -destination 'platform=macOS'

build-ios:
	xcodebuild -project filmz2.xcodeproj -scheme filmz2 -destination 'platform=iOS Simulator,name=iPhone 16'

# Test targets
test:
	xcodebuild test -project filmz2.xcodeproj -scheme filmz2 -destination 'platform=macOS'

test-ios:
	xcodebuild test -project filmz2.xcodeproj -scheme filmz2 -destination 'platform=iOS Simulator,name=iPhone 16'

testUI:
	xcodebuild test -project filmz2.xcodeproj -scheme filmz2 -destination 'platform=iOS Simulator,name=iPhone 16' -only-testing:filmz2UITests

# Utility targets
clean:
	xcodebuild clean -project filmz2.xcodeproj -scheme filmz2