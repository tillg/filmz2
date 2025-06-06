# Filmz2 Build Commands
.PHONY: build build-ios test test-ios testUI clean lint lint-fix help

# Default target
help:
	@echo "Available commands:"
	@echo "  build     - Build for macOS"
	@echo "  build-ios - Build for iOS simulator"
	@echo "  test      - Run unit tests on macOS"
	@echo "  test-ios  - Run unit tests on iOS simulator"
	@echo "  testUI    - Run UI tests on iOS simulator"
	@echo "  lint      - Run linting checks on documentation"
	@echo "  lint-fix  - Run linting and auto-fix issues"
	@echo "  clean     - Clean build artifacts"

# Build targets
build:
	xcodebuild -project filmz2.xcodeproj -scheme filmz2 -destination 'platform=macOS'

build-ios:
	xcodebuild -project filmz2.xcodeproj -scheme filmz2 -destination 'platform=iOS Simulator,id=ED40D210-AC39-4CD0-943A-D6485FFB3416'

# Test targets
test:
	xcodebuild test -project filmz2.xcodeproj -scheme filmz2 -destination 'platform=macOS'

test-ios:
	xcodebuild test -project filmz2.xcodeproj -scheme filmz2 -destination 'platform=iOS Simulator,name=iPhone 16,OS=18.5'

testUI:
	xcodebuild test -project filmz2.xcodeproj -scheme filmz2 -destination 'platform=iOS Simulator,id=ED40D210-AC39-4CD0-943A-D6485FFB3416' -only-testing:filmz2UITests

# Linting targets
lint:
	npm run check:md

lint-fix:
	npm run fix:md

# Utility targets
clean:
	xcodebuild clean -project filmz2.xcodeproj -scheme filmz2