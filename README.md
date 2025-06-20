# Filmz2

A SwiftUI iOS app for tracking films and series. Keep track of what you've watched, what you want to see, and your ratings to recommend films to friends.

Why is it Filmz2? Guess what, there was another Filmz before 😀

## 🚀 Getting Started

### Prerequisites

- **Xcode 15.0+** (for iOS 17+ support)
- **macOS 13.0+** (Ventura or later)
- **iOS 17.0+** device or simulator
- **Node.js 18+** (for documentation tools)

### Development Tools

#### XcodeBuildMCP Setup

For enhanced Xcode development with AI assistance, install XcodeBuildMCP:

1. **Prerequisites:**
   - macOS 14.5+ and Xcode 16.x+ (for XcodeBuildMCP)
   - mise package manager: `brew install mise`

2. **Optional UI automation** (beta):

   ```bash
   brew tap facebook/fb
   brew install idb-companion
   pipx install fb-idb==1.1.7
   ```

### Quick Setup

1. **Clone the repository**

   ```bash
   git clone https://github.com/tillg/filmz2.git
   cd filmz2
   ```

2. **Install development dependencies**

   ```bash
   npm install
   ```

3. **Open in Xcode**

   ```bash
   open filmz2.xcodeproj
   ```

4. **Select your target device/simulator and run**
   - Choose your preferred device from the scheme selector
   - Press `Cmd+R` or click the Run button

## 🛠️ Development

### Project Structure

```
filmz2/
├── filmz2.xcodeproj/         # Xcode project file
├── filmz2/                   # Main app target
│   ├── Models/               # Data models (IMDBFilm, OMDBModels)
│   ├── Services/             # API services (OMDBSearchService)
│   ├── Views/                # SwiftUI views
│   ├── ViewModels/           # MVVM view models
│   ├── Components/           # Reusable UI components
│   │   ├── Pills/           # Genre and rating pills
│   │   └── Layouts/         # Custom layout components
│   └── Assets.xcassets/     # App icons and images
├── filmz2Tests/             # Unit tests
├── filmz2UITests/           # UI tests
└── docs/                    # Project documentation
    ├── features/            # Feature specifications
    ├── decisions/           # Architecture Decision Records (ADRs)
    └── ARCHITECTURE.md      # Technical architecture guide
```

### Build Commands

Use Make commands for common development tasks:

```bash
# Build the app
make build          # Build for macOS (Debug)
make build-release  # Build for macOS (Release)
make build-ios      # Build for iOS simulator
make build-ipados   # Build for iPadOS simulator

# Run tests
make test-unit      # Run unit tests on macOS (fastest, no simulator)
make test-macos     # Run unit tests on macOS (alias for test-unit)
make test-ios       # Run unit tests on iOS simulator
make test-ipados    # Run unit tests on iPadOS simulator
make testUI         # Run UI tests on iOS simulator

# Code quality
make lint           # Run linting checks on documentation
make lint-fix       # Run linting and auto-fix issues

# Utilities
make clean          # Clean build artifacts
make help           # Show all available commands
```

### Testing

**Quick Testing:**

```bash
# Use Make commands (recommended)
make test-unit      # Run unit tests
make test-ios       # Run unit tests on iOS simulator  
make testUI         # Run UI tests on iOS simulator
```

**Test Coverage:**

- View test results in Xcode's Test Navigator
- Aim for >80% code coverage on new features
- All business logic should have unit tests

### Code Quality

**Quick Linting:**

```bash
# Use Make commands (recommended)
make lint           # Check markdown formatting and linting
make lint-fix       # Auto-fix markdown issues
```

**Swift Linting:**

```bash
# Install SwiftLint (if not already installed)
brew install swiftlint

# Run linting
swiftlint
```

**Manual Markdown Linting:**

```bash
# Check markdown formatting
npm run lint:md

# Auto-fix markdown issues
npm run lint:md:fix

# Format all markdown files
npm run format:md
```

### Architecture & Patterns

This project follows:

- **MVVM Architecture**: Views, ViewModels, and Models are clearly separated
- **SwiftUI**: Modern declarative UI framework
- **Component-Based Design**: Reusable UI components in `/Components`
- **ADR Documentation**: Architecture decisions in `/docs/decisions`

Key architectural decisions:

- [ADR-001: Use UUIDs for Entity Identifiers](docs/decisions/ADR-001-use-uuids-for_ids.md)
- [ADR-002: Use Mermaid for Diagrams](docs/decisions/ADR-002-use-mermaid-for-diagrams.md)
- [ADR-003: Use Make for Build Commands](docs/decisions/ADR-003-use-make-for-build-commands.md)

## 📚 Documentation

### For Developers

- **[Architecture Guide](docs/ARCHITECTURE.md)** - Technical architecture overview
- **[Coding Guidelines](docs/CODING_GUIDELINES.md)** - Development standards and definition of done
- **[Data Structures](docs/DATA_STRUCTURES.md)** - Core data models
- **[Glossary](docs/GLOSSARY.md)** - Domain terminology

### For Features

Feature specifications are in `/docs/features/`:

- **[IMDB Film Detail View](docs/features/2025-05-30-imdb-film-detail-view.md)** - Complete feature spec with UI, testing, and requirements

### API Setup

The app uses the [OMDb API](https://www.omdbapi.com/) for film data:

**Getting Your API Key:**

1. Visit [omdbapi.com/apikey.aspx](https://www.omdbapi.com/apikey.aspx)
2. Choose FREE plan (1,000 daily requests) or Patron ($1-$5/month)
3. Register with your email and verify via activation link
4. You'll receive your API key via email

**Setting Up Your API Key:**

```swift
// filmz2/Config/APIKeys.swift (already configured in project)
struct APIKeys {
    static let omdbAPIKey = "YOUR_API_KEY_HERE"
}
```

**Important:** The API key is already configured in the project for development use. For production deployments, ensure you:

- Never commit API keys to version control
- Use environment variables for CI/CD
- Monitor usage in OMDb dashboard

**Rate Limits:** 1,000 requests/day on free tier

## 🧩 Component System

The app uses a comprehensive component system for consistency:

**Pills Components:**

- `GenrePill` / `GenrePills` - For displaying film genres
- `RatingPill` / `RatingPills` - For showing film ratings

**Usage Example:**

```swift
// Genre pills
GenrePills(["Action", "Drama", "Thriller"])

// Rating pills
RatingPills(ratings, layout: .horizontal)
```

See `ComponentLibrary.swift` for interactive examples.

## 🔧 Troubleshooting

### Common Issues

**"Cannot find X in scope"**

- Clean build folder: `Cmd+Shift+K`
- Reset package cache: `File > Packages > Reset Package Caches`

**Simulator Issues**

- Reset simulator: `Device > Erase All Content and Settings`
- Clear derived data: `~/Library/Developer/Xcode/DerivedData`

**Build Errors**

- Ensure Xcode 15+ is installed
- Check iOS deployment target is set to 17.0+
- Verify all dependencies are resolved

### Getting Help

1. Check existing [Issues](https://github.com/tillg/filmz2/issues)
2. Review the [Architecture Documentation](docs/ARCHITECTURE.md)
3. Check the [Coding Guidelines](docs/CODING_GUIDELINES.md)
4. Create a new issue with:
   - Steps to reproduce
   - Expected vs actual behavior
   - Environment details (Xcode version, iOS version, device)

## 🤝 Contributing

1. **Read the [Coding Guidelines](docs/CODING_GUIDELINES.md)** - Understanding our definition of done
2. **Check existing issues** - See if your feature/bug is already tracked
3. **Create a feature branch** - Follow naming: `feature/description` or `fix/description`
4. **Write tests** - Maintain >80% coverage for new code
5. **Update documentation** - Keep docs in sync with code changes
6. **Follow the component system** - Use existing patterns and components
7. **Test on device** - Verify functionality on real iOS device when possible

### Pull Request Process

1. Ensure all tests pass: `npm run test`
2. Lint documentation: `npm run lint:md`
3. Update relevant documentation
4. Create pull request with clear description
5. Address review feedback

## 📱 Features

### Current Features

- **IMDB Film Detail View** - Comprehensive film information display
- **Component Library** - Reusable UI components for consistent design
- **Robust Data Handling** - Graceful handling of incomplete API data

### Planned Features

- Film search and discovery
- Personal film collection management
- Rating and review system
- CloudKit synchronization
- Recommendations engine

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- [OMDb API](https://www.omdbapi.com/) for film data
- [SwiftUI](https://developer.apple.com/swiftui/) framework
- [Claude Code](https://claude.ai/code) for development assistance
