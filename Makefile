# Filmz2 Build Commands
.PHONY: build build-release build-ios build-ipados test test-unit test-macos test-ios test-ipados testUI clean lint lint-fix help

# Default target
help:
	@echo "Available commands:"
	@echo ""
	@echo "Build Commands:"
	@echo "  build         - Build for macOS (Debug)"
	@echo "  build-release - Build for macOS (Release)"
	@echo "  build-ios     - Build for iOS simulator"
	@echo "  build-ipados  - Build for iPadOS simulator"
	@echo ""
	@echo "Test Commands:"
	@echo "  test-unit     - Run unit tests on macOS (fastest, no simulator)"
	@echo "  test-macos    - Run unit tests on macOS (alias for test-unit)"
	@echo "  test-ios      - Run unit tests on iOS simulator"
	@echo "  test-ipados   - Run unit tests on iPadOS simulator"
	@echo "  testUI        - Run UI tests on iOS simulator"
	@echo ""
	@echo "Other Commands:"
	@echo "  lint          - Run linting checks on documentation"
	@echo "  lint-fix      - Run linting and auto-fix issues"
	@echo "  clean         - Clean build artifacts"

# Build targets
build:
	xcodebuild -project filmz2.xcodeproj -scheme filmz2 -destination 'platform=macOS' -configuration Debug

build-release:
	xcodebuild -project filmz2.xcodeproj -scheme filmz2 -destination 'platform=macOS' -configuration Release

build-ios:
	xcodebuild -project filmz2.xcodeproj -scheme filmz2 -destination 'platform=iOS Simulator,name=iPhone 16'

build-ipados:
	xcodebuild -project filmz2.xcodeproj -scheme filmz2 -destination 'platform=iOS Simulator,name=iPad Pro 11-inch (M4)'

# Test targets
test:
	@echo "Error: 'make test' is ambiguous. Please use one of:"
	@echo "  make test-unit     - Run unit tests on macOS (fastest)"
	@echo "  make test-macos    - Run unit tests on macOS" 
	@echo "  make test-ios      - Run unit tests on iOS simulator"
	@echo "  make test-ipados   - Run unit tests on iPadOS simulator"
	@echo "  make testUI        - Run UI tests on iOS simulator"
	@exit 1

test-unit:
	xcodebuild test -project filmz2.xcodeproj -scheme filmz2 -destination 'platform=macOS' -only-testing:filmz2Tests

test-macos:
	xcodebuild test -project filmz2.xcodeproj -scheme filmz2 -destination 'platform=macOS' -only-testing:filmz2Tests

test-ios:
	xcodebuild test -project filmz2.xcodeproj -scheme filmz2 -destination 'platform=iOS Simulator,name=iPhone 16' -only-testing:filmz2Tests

test-ipados:
	xcodebuild test -project filmz2.xcodeproj -scheme filmz2 -destination 'platform=iOS Simulator,name=iPad Pro 11-inch (M4)' -only-testing:filmz2Tests

testUI:
	xcodebuild test -project filmz2.xcodeproj -scheme filmz2 -destination 'platform=iOS Simulator,name=iPhone 16' -only-testing:filmz2UITests

# Linting targets
lint:
	npm run check:md

lint-fix:
	npm run fix:md

# Utility targets
clean:
	xcodebuild clean -project filmz2.xcodeproj -scheme filmz2