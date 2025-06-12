# Dynamic Build Numbers with Git Integration

## Problem Statement

Currently, the About page always shows "Build 2025.06.02" which is hardcoded and provides no useful information about the actual build. We need a dynamic system that shows meaningful build information including the git commit hash and build date.

## Current State

- **Version**: Hardcoded "1.0.0" in AboutView.swift
- **Build**: Hardcoded "2025.06.02" in AboutView.swift  
- **Xcode Project**: MARKETING_VERSION = 1.0, CURRENT_PROJECT_VERSION = 1
- **Info.plist**: No version keys defined (using GENERATE_INFOPLIST_FILE = YES)

## Desired Outcome

Display dynamic build information like:
```
Version: 1.0.0
Build: 2025-06-12 (a1b2c3d) [Link to GitHub commit]
```

## Implementation Options

### Option 1: Build Script with Git Integration (Recommended)

**Approach**: Use Xcode build phases to generate build information from git at compile time.

**Implementation**:
1. **Add Build Phase Script**:
   ```bash
   # Build Phase: Generate Build Info
   PLIST="${TARGET_BUILD_DIR}/${INFOPLIST_PATH}"
   
   # Get git info
   GIT_COMMIT=$(git rev-parse --short HEAD)
   GIT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
   BUILD_DATE=$(date +"%Y-%m-%d")
   BUILD_NUMBER="${BUILD_DATE}-${GIT_COMMIT}"
   
   # Update Info.plist
   /usr/libexec/PlistBuddy -c "Set :CFBundleVersion $BUILD_NUMBER" "$PLIST"
   /usr/libexec/PlistBuddy -c "Set :GitCommitHash $GIT_COMMIT" "$PLIST"
   /usr/libexec/PlistBuddy -c "Set :BuildDate $BUILD_DATE" "$PLIST"
   ```

2. **Create BuildInfo Helper**:
   ```swift
   struct BuildInfo {
       static var version: String {
           Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "Unknown"
       }
       
       static var buildNumber: String {
           Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "Unknown"
       }
       
       static var gitCommitHash: String {
           Bundle.main.object(forInfoDictionaryKey: "GitCommitHash") as? String ?? "Unknown"
       }
       
       static var buildDate: String {
           Bundle.main.object(forInfoDictionaryKey: "BuildDate") as? String ?? "Unknown"
       }
       
       static var githubCommitURL: String {
           "https://github.com/tillg/filmz2/commit/\(gitCommitHash)"
       }
       
       static var formattedBuildInfo: String {
           "\(buildDate) (\(gitCommitHash))"
       }
   }
   ```

3. **Update AboutView**:
   ```swift
   HStack {
       Text("Build")
       Spacer()
       Link(BuildInfo.formattedBuildInfo, destination: URL(string: BuildInfo.githubCommitURL)!)
           .foregroundColor(.blue)
   }
   ```

**Pros**:
- Fully automated - no manual updates needed
- Real git commit information
- Clickable link to GitHub commit
- Works with any git workflow
- Build date reflects actual build time

**Cons**:
- Requires git repository for builds
- Build script adds complexity
- May need fallbacks for CI/CD environments

---

### Option 2: Manual Version File with Make Integration

**Approach**: Use Make commands to update a version file before building.

**Implementation**:
1. **Create Version.swift**:
   ```swift
   struct Version {
       static let version = "1.0.0"
       static let build = "2025-06-12"
       static let commit = "a1b2c3d"
       static let githubURL = "https://github.com/tillg/filmz2/commit/a1b2c3d"
   }
   ```

2. **Add Make Target**:
   ```makefile
   update-version:
   	@echo "Updating version info..."
   	@GIT_COMMIT=$$(git rev-parse --short HEAD); \
   	BUILD_DATE=$$(date +"%Y-%m-%d"); \
   	sed -i '' "s/static let build = \".*\"/static let build = \"$$BUILD_DATE\"/" filmz2/Version.swift; \
   	sed -i '' "s/static let commit = \".*\"/static let commit = \"$$GIT_COMMIT\"/" filmz2/Version.swift; \
   	sed -i '' "s|static let githubURL = \".*\"|static let githubURL = \"https://github.com/tillg/filmz2/commit/$$GIT_COMMIT\"|" filmz2/Version.swift
   
   build-with-version: update-version build
   ```

3. **Update AboutView to use Version.swift**

**Pros**:
- Simple implementation
- No build script complexity
- Easy to understand and debug
- Version info is visible in source code

**Cons**:
- Requires manual `make build-with-version` command
- Version file gets dirty in git (needs .gitignore or pre-commit hook)
- Easy to forget to update

---

### Option 3: Environment-Based Build Info

**Approach**: Use environment variables to inject build information.

**Implementation**:
1. **Update Xcode Scheme**:
   - Edit Scheme → Run → Arguments
   - Add Environment Variables:
     - `BUILD_DATE`: $(date +"%Y-%m-%d")
     - `GIT_COMMIT`: $(git rev-parse --short HEAD)

2. **Create BuildInfo Helper**:
   ```swift
   struct BuildInfo {
       static var buildDate: String {
           ProcessInfo.processInfo.environment["BUILD_DATE"] ?? "Unknown"
       }
       
       static var gitCommit: String {
           ProcessInfo.processInfo.environment["GIT_COMMIT"] ?? "Unknown"
       }
       
       static var formattedBuildInfo: String {
           "\(buildDate) (\(gitCommit))"
       }
   }
   ```

**Pros**:
- No source code changes
- Works well with different environments
- Clean separation of build info from code

**Cons**:
- Environment variables need manual setup
- Not automatic in Xcode builds
- Harder to share across team

---

### Option 4: Hybrid Approach with Fallbacks

**Approach**: Combine build script automation with manual fallbacks.

**Implementation**:
1. **Build Script** (as in Option 1) with error handling
2. **Fallback Values** in code for when git is unavailable
3. **Development Mode** detection for local builds

```swift
struct BuildInfo {
    static var isDebugBuild: Bool {
        #if DEBUG
        return true
        #else
        return false
        #endif
    }
    
    static var buildNumber: String {
        if let bundleBuild = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String,
           bundleBuild != "1" {
            return bundleBuild
        }
        
        // Fallback for development builds
        return isDebugBuild ? "dev-\(Date().formatted(.iso8601.year().month().day()))" : "release"
    }
}
```

**Pros**:
- Best of both worlds
- Graceful degradation
- Works in all environments

**Cons**:
- Most complex implementation
- Multiple code paths to maintain

## Recommendation

**Option 1 (Build Script with Git Integration)** is the recommended approach because:

1. **Fully Automated**: No manual intervention required
2. **Always Accurate**: Build info reflects actual build state
3. **Professional**: Standard practice in iOS development
4. **User-Friendly**: Clickable links to commit history
5. **CI/CD Ready**: Works with automated build systems

The build script can be enhanced with error handling for environments without git, ensuring it never breaks the build process.

## Implementation Plan

1. Add build phase script to Xcode project
2. Create BuildInfo helper struct
3. Update AboutView to use dynamic build info
4. Test with local builds and different git states
5. Add error handling for edge cases
6. Update documentation with new build process

## Testing Scenarios

- [ ] Local development builds
- [ ] Clean repository builds
- [ ] Dirty working directory builds
- [ ] Detached HEAD state
- [ ] CI/CD environment builds
- [ ] Archive/release builds