---
status: "accepted"
date: 2025-06-06
decision-makers: development team
---

# Follow Apple Human Interface Guidelines for UI Design

## Context and Problem Statement

As an iOS/macOS application, filmz2 needs to provide a native, intuitive user experience that feels familiar to Apple platform users. The question is whether to follow Apple's Human Interface Guidelines strictly or develop custom UI patterns that may differentiate the app but potentially compromise usability and platform consistency.

## Decision Drivers

* User familiarity and intuitive navigation patterns
* App Store review guidelines compliance
* Accessibility requirements and standards
* Platform-specific design patterns (iOS vs macOS)
* Development efficiency through use of native components
* Future iOS/macOS version compatibility

## Considered Options

* Follow Apple Human Interface Guidelines strictly
* Use custom UI patterns throughout the app
* Hybrid approach with selective HIG compliance

## Decision Outcome

Chosen option: "Follow Apple Human Interface Guidelines strictly", because it ensures the best user experience, meets accessibility standards, and provides long-term maintainability.

### Consequences

* Good, because users will find the interface familiar and intuitive
* Good, because accessibility is built-in through standard components
* Good, because App Store approval is more likely
* Good, because development is faster using native patterns
* Good, because future iOS/macOS updates will be automatically supported
* Neutral, because the app may look similar to other native apps
* Bad, because some creative UI ideas may be constrained by guidelines

### Confirmation

All UI components and interactions should be reviewed against the Apple Human Interface Guidelines before implementation. Code reviews should include HIG compliance checks, and new features should reference relevant HIG sections.

## More Information

Primary reference: [Apple Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines)

Key areas of focus for filmz2:

* Navigation patterns (tab bars, navigation controllers)
* Data presentation (lists, grids, detail views)
* User input and forms
* Accessibility features
* Platform-specific considerations (iOS vs macOS differences)
