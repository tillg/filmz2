//
//  MyFilm.swift
//  filmz2
//
//  Created by Till Gartner on 06.01.25.
//

/**
 * MyFilm Model - User's Personal Film Collection Entry
 *
 * This model represents a film in the user's personal collection. It follows the
 * ID-only architecture pattern where we only store the IMDB ID reference and 
 * user-specific data. The actual film metadata (title, actors, plot, etc.) is
 * stored separately in IMDBFilm to avoid data duplication.
 *
 * Architecture Benefits:
 * - Clean separation between user data and movie metadata
 * - No data duplication - each movie's metadata is stored only once
 * - Enables features like shared collections or social features in the future
 * - Smaller storage footprint for user collections
 *
 * User Data Stored:
 * - Personal rating (0-10 stars)
 * - Watch status and date
 * - Audience type (who watched with)
 * - Personal notes
 * - Who recommended the film
 *
 * Usage:
 * - When displaying a MyFilm, fetch the film details using OMDBSearchService
 * - The service will return cached data if available, or fetch from API
 * - Views should handle loading states while fetching film details
 */

import Foundation
import SwiftData

enum AudienceType: String, Codable {
    case meAlone = "Me alone"
    case meAndPartner = "Me and partner"
    case family = "Family"
}

@Model
final class MyFilm {
    // Identity - CloudKit doesn't support unique constraints
    var id: UUID = UUID()
    var imdbID: String = ""
    
    // User Data - All properties must have defaults for CloudKit
    var myRating: Int?
    var dateAdded: Date = Date()
    var watched: Bool = false
    var dateWatched: Date?
    var audience: AudienceType?
    var recommendedBy: String?
    var notes: String?
    
    init() {
        // Required for SwiftData
    }
    
    init(imdbID: String) {
        self.imdbID = imdbID
        // Other properties use their default values
    }
    
    // Convenience initializer from IMDBFilm
    convenience init(from imdbFilm: IMDBFilm) {
        self.init(imdbID: imdbFilm.imdbID)
    }
    
    // Convenience initializer from OMDBSearchItem
    convenience init(from searchItem: OMDBSearchItem) {
        self.init(imdbID: searchItem.imdbID)
    }
}

// MARK: - Computed Properties
extension MyFilm {
    var isRated: Bool {
        myRating != nil
    }
    
    var watchStatusText: String {
        if watched {
            if let date = dateWatched {
                let formatter = DateFormatter()
                formatter.dateStyle = .medium
                return "Watched on \(formatter.string(from: date))"
            }
            return "Watched"
        }
        return "Not watched"
    }
    
    var ratingText: String? {
        guard let rating = myRating else { return nil }
        return "\(rating)/10"
    }
}