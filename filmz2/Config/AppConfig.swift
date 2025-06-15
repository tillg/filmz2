//
//  AppConfig.swift
//  filmz2
//
//  Main application configuration
//

import Foundation

/// Main application configuration
struct AppConfig {
    /// App version and build information
    struct App {
        static let name = "Filmz2"
        static let bundleIdentifier = "com.grtnr.filmz2"
    }
    
    /// External services configuration
    struct Services {
        /// OMDb API configuration
        static let omdbAPIKey = APIKeys.omdbAPIKey
        static let omdbBaseURL = "http://www.omdbapi.com/"
        static let omdbPosterURL = "http://img.omdbapi.com/"
        
        /// CloudKit configuration
        static let cloudKitContainer = CloudKitConfig.containerIdentifier
    }
    
    /// Cache configuration
    struct Cache {
        /// Film metadata cache freshness period (30 days)
        static let filmCacheDays = 30
        /// Maximum cache size
        static let maxCacheSize = 1000
    }
}