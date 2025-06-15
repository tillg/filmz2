# Coding Guidelines

[TOC]

## Overview

This document defines the coding standards, guidelines, and criteria that must be met before any feature, user story, or development task can be considered "done" in the Filmz2 project. These standards ensure consistent quality, maintainability, and user experience across all deliverables.

## Documentation Standards

### Markdown Files

#### Markdown Style Guidelines

- **Headings**: Use ATX style (`#` instead of underlines)
- **Lists**: Use consistent indentation (2 spaces)
- **Line Length**: No restrictions - write naturally readable content
- **Links**: Use descriptive link text, avoid "click here" or "read more"
- **Code Blocks**: Always specify language for syntax highlighting
- **Tables**: Keep simple, use Prettier for consistent formatting

#### VSCode Setup

When you open this project in VSCode, you'll automatically get:

- Extension recommendations for markdown editing
- Auto-formatting on save
- Real-time linting feedback
- Spell checking enabled

To install recommended extensions, open the Command Palette (`Cmd+Shift+P`) and run:

```text
Extensions: Show Recommended Extensions
```

## Code Quality

### Architecture Compliance

- [ ] Implementation follows established architectural patterns
- [ ] Adheres to decisions documented in ADRs
- [ ] Uses UUIDs for entity identifiers (per ADR-001)
- [ ] Proper separation of concerns (View/ViewModel/Model)
- [ ] CloudKit integration follows established patterns

### Code

- [ ] If there are visual components, make sure they render nicely in the Xcode preview with appropriate demo data.

## Testing Requirements

### Unit Testing

- [ ] Unit tests written for all new business logic
- [ ] Unit tests should not invoke a simulator
- [ ] Test coverage minimum 80% for new code
- [ ] All tests pass consistently
- [ ] Edge cases and error conditions are tested
- [ ] Mock objects used appropriately for external dependencies

### Integration Testing

- [ ] Critical user paths have integration tests
- [ ] CloudKit synchronization scenarios tested
- [ ] API integration points tested with mock data
- [ ] Navigation flows tested end-to-end

### UI Testing

- [ ] Key user interactions have UI tests
- [ ] Accessibility features tested and working
- [ ] Dynamic type scaling verified
- [ ] VoiceOver navigation tested

## User Experience

### Functionality

- [ ] Feature works as described in acceptance criteria
- [ ] All user stories are fully implemented
- [ ] Error states are handled gracefully
- [ ] Loading states provide appropriate feedback
- [ ] Offline functionality works where applicable

### Accessibility

- [ ] VoiceOver labels are meaningful and complete
- [ ] Semantic content types properly assigned
- [ ] Dynamic type scaling works correctly
- [ ] Minimum contrast ratios met
- [ ] Touch targets meet minimum size requirements (44pt)

### Performance

- [ ] No memory leaks detected
- [ ] Smooth animations (60fps target)
- [ ] Image loading optimized with proper caching
- [ ] Network requests efficient and cached appropriately
- [ ] App launch time not negatively impacted

## Documentation

### Code Documentation

- [ ] Public APIs have proper documentation comments
- [ ] Complex algorithms explained
- [ ] Data models document their purpose and relationships
- [ ] View components document their responsibilities

### Architecture Documentation

- [ ] Code, objects, structs and services are properly reflected in ARCHITECTURE.md
- [ ] In case that there are graphs in ARCHITECTURE.md, they are updated as well.

### Feature Documentation

- [ ] API changes documented if applicable
- [ ] Architecture decisions recorded as ADRs when significant
- [ ] README updated if new setup steps required

## Quality Assurance

### Device Testing

- [ ] Tested on primary target devices (iPhone, iPad)
- [ ] Multiple iOS versions tested (current and previous)
- [ ] Different screen sizes tested and layouts adapt properly
- [ ] Dark mode compatibility verified

### Data Integrity

- [ ] CloudKit sync works correctly across devices
- [ ] Data validation prevents invalid states
- [ ] Migration scripts tested if data model changed
- [ ] Backup and restore functionality unaffected

### Security

- [ ] No sensitive data logged or exposed
- [ ] API keys and secrets properly protected
- [ ] User data privacy requirements met
- [ ] Proper error messages (no internal details exposed)

## Release Readiness

### Version Control

- [ ] All code committed to appropriate branch
- [ ] Commit messages are clear and descriptive
- [ ] No debug code or commented-out sections
- [ ] Branch merged cleanly without conflicts

### Configuration

- [ ] No hardcoded values that should be configurable
- [ ] Development/testing flags removed
- [ ] App Store compliance verified
- [ ] Version numbers updated appropriately

### Deployment

- [ ] Feature flags configured correctly
- [ ] Beta testing completed successfully
- [ ] App Store review guidelines compliance verified
- [ ] Release notes updated

## Exception Handling

### Documenting Exceptions

- All exceptions must be documented with justification
- Technical debt created must be tracked
- Plan for completing skipped items must be established
- Stakeholder approval required for significant exceptions

## Continuous Improvement

This Definition of Done is a living document and should be:

- Reviewed quarterly for effectiveness
- Updated based on lessons learned
- Adjusted for new tools and processes
- Refined based on team feedback

---
