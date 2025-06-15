---
status: "accepted"
date: 2025-01-06
decision-makers: [Till Gartner]
---

# Use Make for Command Line Build Tools

## Context and Problem Statement

The Filmz2 project needs simple, standardized command line tools for common development tasks like building the app, running tests, and cleaning build artifacts. Currently, developers must remember and type long `xcodebuild` commands with specific parameters for different platforms and test types. This creates friction in the development workflow and increases the likelihood of errors.

## Decision Drivers

* Need for simple, memorable commands like `make build`, `make test`, `make testUI`
* Consistency across different development environments
* Reduced cognitive load for developers working on the project
* Industry standard practices for iOS/macOS projects
* Integration with CI/CD pipelines
* Cross-platform compatibility (works on any Unix-like system)

## Considered Options

* **Make** - Traditional Unix build tool with Makefile
* **npm scripts** - Extend existing package.json with build commands
* **Just** - Modern command runner alternative to Make
* **Shell scripts** - Individual .sh files for each command
* **Xcode schemes** - Rely solely on Xcode's built-in automation

## Decision Outcome

Chosen option: "Make with Makefile", because it provides the best balance of simplicity, industry standard practices, and developer familiarity. Make is universally available on macOS/Linux systems and is widely used in Swift/iOS projects.

### Consequences

* Good, because Make is universally available on development machines
* Good, because Makefile syntax is well-known and documented
* Good, because it integrates seamlessly with CI/CD systems
* Good, because it provides a consistent interface regardless of underlying build system changes
* Good, because it's the de facto standard for command line build tools in Swift projects
* Neutral, because it adds one more file to maintain in the repository
* Bad, because Windows developers would need to install Make (though this is rare for iOS development)

### Confirmation

The implementation can be confirmed by:

1. Testing each Make target successfully executes the intended `xcodebuild` command
2. Verifying commands work across different development environments
3. Ensuring CI/CD pipelines can use the Make targets
4. Code review of the Makefile for correctness and completeness

## Pros and Cons of the Options

### Make with Makefile

A traditional Unix build tool that provides simple command aliases for complex build operations.

* Good, because universally available on macOS and Linux
* Good, because widely adopted standard in iOS/Swift community
* Good, because simple syntax and easy to understand
* Good, because integrates well with CI/CD systems
* Good, because provides dependency management between targets
* Good, because allows for complex build logic when needed
* Neutral, because requires basic Make knowledge for modifications
* Bad, because not natively available on Windows

### npm scripts in package.json

Extend the existing package.json with build commands using npm run.

* Good, because leverages existing npm setup
* Good, because familiar to web developers
* Good, because already have package.json in project
* Neutral, because requires npm to be installed
* Bad, because less common in pure iOS/Swift projects
* Bad, because npm scripts are primarily designed for Node.js workflows
* Bad, because adds dependency on Node.js ecosystem for native app

### Just command runner

Modern alternative to Make with more intuitive syntax.

* Good, because modern and powerful command runner
* Good, because better syntax than Make
* Good, because good documentation and error messages
* Neutral, because relatively new tool
* Bad, because requires separate installation
* Bad, because less familiar to most developers
* Bad, because not as widely adopted in iOS community

### Individual shell scripts

Create separate .sh files for each command (build.sh, test.sh, etc.).

* Good, because very simple and straightforward
* Good, because no additional tools required
* Good, because easy to understand for any developer
* Neutral, because requires marking files as executable
* Bad, because creates multiple files to maintain
* Bad, because no dependency management between scripts
* Bad, because less conventional than Makefile

### Xcode schemes only

Rely on Xcode's built-in automation and schemes.

* Good, because integrated with Xcode
* Good, because no additional files needed
* Bad, because requires Xcode GUI for modifications
* Bad, because not accessible from command line without complex setup
* Bad, because doesn't work well with CI/CD systems
* Bad, because not scriptable or automatable

## More Information

The Makefile includes the following standard targets:

**Build Commands:**
* `build` - Build for macOS (Debug)
* `build-release` - Build for macOS (Release)
* `build-ios` - Build for iOS simulator
* `build-ipados` - Build for iPadOS simulator

**Test Commands:**
* `test-unit` - Run unit tests on macOS (fastest, no simulator)
* `test-macos` - Run unit tests on macOS (alias for test-unit)
* `test-ios` - Run unit tests on iOS simulator
* `test-ipados` - Run unit tests on iPadOS simulator
* `testUI` - Run UI tests on iOS simulator

**Other Commands:**
* `lint` - Run linting checks on documentation
* `lint-fix` - Run linting and auto-fix issues
* `clean` - Clean build artifacts
* `help` - Show available commands (default target)

Note: `make test` shows an error message directing users to use specific test targets.

This decision aligns with common practices in the Swift/iOS development community and provides a foundation for future automation needs.
