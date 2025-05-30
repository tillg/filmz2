# ADR-001: Use UUIDs for Entity Identifiers

## Status

Accepted

## Context

The Filmz application needs unique identifiers for core entities like MyFilm records. These identifiers must work across different platforms and synchronize reliably through CloudKit. The app needs to support offline operation and eventual consistency when syncing between devices.

Key requirements:

- Unique identification across all devices and platforms
- Compatibility with CloudKit synchronization
- Offline creation of new records
- No dependency on server-generated IDs
- Simple implementation and debugging

## Decision

We will use UUIDs (Universally Unique Identifiers) as the primary identifiers for all core entities in the Filmz application, specifically:

- MyFilm records
- Any future user-generated content entities

UUIDs will be generated client-side using Swift's `UUID()` type when creating new records.

## Consequences

### Positive

- **Offline capability**: Records can be created offline without waiting for server-assigned IDs
- **CloudKit compatibility**: UUIDs work seamlessly with CloudKit's distributed architecture
- **No conflicts**: Extremely low probability of ID collisions across devices
- **Platform independence**: UUIDs are supported across all Apple platforms
- **Debugging friendly**: UUIDs are human-readable and can be easily tracked in logs

### Negative

- **Storage overhead**: UUIDs require more storage space than sequential integers (128 bits vs 32/64 bits)
- **URL unfriendly**: UUIDs in URLs are longer and less user-friendly than sequential IDs
- **Memory usage**: Slightly higher memory footprint compared to integer IDs

### Neutral

- **Migration**: Since this is a new application, no migration from existing ID schemes is required
- **Performance**: Modern devices handle UUID comparison and storage efficiently

## Implementation Notes

- Use Swift's native `UUID()` for generation
- Store as String in CloudKit records for maximum compatibility
- Consider adding helper methods for UUID validation if needed
- Document UUID format expectations in code comments
