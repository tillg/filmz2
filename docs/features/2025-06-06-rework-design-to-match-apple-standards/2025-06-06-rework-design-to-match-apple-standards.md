# Rework Design to Match Apple Standards

[TOC]

## Overview

Our current screens do not fully align with Apple Human Interface Guidelines. Following ADR-004, we need to systematically rework the UI to provide a native, intuitive experience that feels familiar to Apple platform users.

## Objectives

- Align all UI components with Apple Human Interface Guidelines
- Improve accessibility through standard components
- Ensure consistent typography, spacing, and layout patterns
- Optimize for both iOS and macOS platforms
- Create a cohesive visual language throughout the app

## Scope

### Primary Views to Rework

1. **MovieSearchView** - Search interface and results
2. **CollectionView** - User's film collection with tabs
3. **IMDBFilmDetailView** - Film details from search/IMDB
4. **MyFilmDetailView** - User's personal film details with editing
5. **SettingsView** - App settings and preferences

### Secondary Views to Review

6. **FilmCell** - List item component
7. **MyFilmCell** - Collection item component
8. **MovieSearchResultCellWithCache** - Search result item
9. **GenreFilterSheet** - Filter interface
10. **AboutView** - App information
11. **CacheView** - Cache management
12. **SyncStatusView** - iCloud sync status

## Design Standards to Implement

### Typography

- Use system fonts (SF Pro, SF Compact) with semantic styles
- Implement proper font weight hierarchy (Regular, Medium, Semibold)
- Follow Apple's type size recommendations
- Ensure proper contrast ratios for accessibility

### Layout & Spacing

- Use standard Apple spacing values (8, 16, 20, 24 pts)
- Implement proper margins and safe areas
- Follow grid systems and alignment principles
- Responsive layout for different screen sizes

### Navigation Patterns

- Standard tab bar for main navigation
- Proper use of navigation controllers and back buttons
- Sheet presentations for modal content
- Consistent navigation bar styling

### Components

- Replace custom components with native SwiftUI equivalents where possible
- Use system colors and materials
- Implement proper button styles and feedback
- Standard form controls and input fields

### Platform-Specific Considerations

- iOS: Focus on touch interactions, larger tap targets
- macOS: Keyboard navigation, menu bar integration, window management

## Implementation Strategy

### Phase 1: Foundation

- Establish design tokens (colors, fonts, spacing)
- Create reusable component library following HIG
- Update core navigation structure

### Phase 2: Primary Views

- Rework main screens one by one
- Focus on high-impact, user-facing interfaces
- Ensure accessibility compliance

### Phase 3: Polish & Refinement

- Review secondary views and components
- Conduct usability testing
- Fine-tune animations and transitions

## Success Criteria

- All screens pass Apple's accessibility audit
- UI components follow HIG specifications
- Consistent visual language across the app
- Improved user experience metrics
- App Store approval with no design-related rejections

## References

- [Apple Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines)
- ADR-004: Follow Apple Human Interface Guidelines for UI Design
- [SwiftUI Design Guidelines](https://developer.apple.com/design/human-interface-guidelines/designing-for-ios)
