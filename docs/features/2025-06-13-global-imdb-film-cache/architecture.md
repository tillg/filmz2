# Global IMDB Film Cache - Architecture

## Overview

This document describes the architecture for implementing a multilayered cache system to minimize OMDB API usage by leveraging a shared global cache via CloudKit.

## Current State

The application currently has a single-layer local cache (`CachedIMDBFilm`) that stores film metadata for 30 days to reduce API calls for individual users.

## Proposed Architecture

### Three-Tier Cache Strategy

The new architecture implements a hierarchical cache lookup system:

1. **Local Cache** (Existing) - Device-level storage
2. **Global Cache** (New) - CloudKit shared storage across all users  
3. **OMDB API** (Fallback) - External data source

### Cache Hierarchy Flow

```
Film Data Request
        ↓
Local Cache Hit? → Return Data
        ↓ No
Global Cache Hit? → Update Local Cache → Return Data
        ↓ No
OMDB API Call → Update Global Cache → Update Local Cache → Return Data
```

## Data Model Structure

### Renamed Models for Clarity

**Before:**
- `IMDBFilm` (struct) - API response format
- `CachedIMDBFilm` (class) - Persistent storage format

**After:**
- `IMDBFilmDTO` (struct) - Data Transfer Object for OMDB API responses
- `IMDBFilm` (class) - Canonical persistent film data model

### Model Responsibilities

**`IMDBFilmDTO`:**
- Handles OMDB API response parsing
- Temporary data structure for network layer
- Converts to `IMDBFilm` for persistence

**`IMDBFilm`:**
- Single source of truth for film data
- Used across all cache layers (local SwiftData, global CloudKit)
- Provides conversion methods and computed properties
- Contains cache metadata (lastFetched, dataVersion, isStale)

## Component Architecture

### 1. Cache Manager Service

A centralized service orchestrating the three-tier lookup:

- **Responsibilities**:
  - Coordinate cache lookups across tiers
  - Handle cache updates and synchronization
  - Manage fallback strategies
  - Abstract complexity from consumers

### 2. Global Cache Service (CloudKit)

New service for shared film metadata storage:

- **Data Model**: `IMDBFilm` persistent model with CloudKit backing
- **Sync Strategy**: Automatic CloudKit synchronization
- **Access Pattern**: Read-heavy with occasional writes
- **Privacy**: No user-specific data, only public film metadata

### 3. Unified Data Model

Refactor data models for clarity and consistency:

- **`IMDBFilm`**: Canonical persistent film data model (rename from `CachedIMDBFilm`)
- **`IMDBFilmDTO`**: Data transfer object for API responses (rename from `IMDBFilm`)
- **Dual Persistence**: Same `IMDBFilm` model with SwiftData for local, CloudKit for global
- **Source Agnostic**: Cache manager abstracts the storage layer

## Data Flow Patterns

### Film Lookup Pattern

1. Check local cache for fresh data
2. If local cache miss/stale, query global cache
3. If global cache hit, update local cache and return
4. If global cache miss, fetch from OMDB API
5. Update both global and local caches with fresh data

### Cache Update Pattern

1. New data retrieved from OMDB API
2. Asynchronously update global cache (CloudKit)
3. Synchronously update local cache
4. Handle update failures gracefully

## Technical Considerations

### CloudKit Integration

- **Database**: Public CloudKit database for shared access
- **Storage Account**: Uses Filmz2 app developer's iCloud account for shared storage
- **Record Type**: `IMDBFilm` mapped to CloudKit records
- **Indexing**: Index on `imdbID` for efficient lookups
- **Permissions**: Public read access, authenticated write access
- **Cost**: Storage and bandwidth costs borne by app developer, not individual users

### Performance Optimization

- **Async Operations**: All cache operations non-blocking
- **Batch Requests**: Bundle multiple cache lookups when possible
- **Background Sync**: Update caches during app idle time
- **Local Prioritization**: Always prioritize local cache for immediate response

### Error Handling

- **Network Failures**: Graceful degradation to lower cache tiers
- **CloudKit Limits**: Rate limiting and quota management
- **Data Corruption**: Validation and recovery mechanisms
- **API Failures**: Robust fallback to cached data

## Implementation Strategy

### Phase 1: Foundation

- Rename `CachedIMDBFilm` → `IMDBFilm` and `IMDBFilm` → `IMDBFilmDTO`
- Create CloudKit schema for `IMDBFilm` model
- Implement global cache service with basic CRUD operations
- Add CloudKit integration to existing cache manager

### Phase 2: Integration

- Modify existing cache lookup logic to use three-tier strategy
- Update `OMDBSearchService` to use new cache manager
- Implement cache update propagation

### Phase 3: Optimization

- Add background synchronization
- Implement batch operations
- Add analytics and monitoring

## Migration Strategy

The implementation will be backward compatible:

- Existing local cache continues to function
- Global cache integration is additive
- No breaking changes to existing interfaces
- Gradual rollout with feature flags
