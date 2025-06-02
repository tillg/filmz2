//
//  MyFilm.swift
//  filmz2
//
//  Created by Till Gartner on 06.01.25.
//

import Foundation
import SwiftData

enum AudienceType: String, Codable {
    case meAlone = "Me alone"
    case meAndPartner = "Me and partner"
    case family = "Family"
}

@Model
final class MyFilm {
    // Identity
    @Attribute(.unique) var id: UUID
    @Attribute(.unique) var imdbID: String
    
    // User Data
    var myRating: Int?
    var dateAdded: Date
    var watched: Bool
    var dateWatched: Date?
    var audience: AudienceType?
    var recommendedBy: String?
    var notes: String?
    
    init(imdbID: String) {
        self.id = UUID()
        self.imdbID = imdbID
        
        // Default values
        self.dateAdded = Date()
        self.watched = false
        self.myRating = nil
        self.dateWatched = nil
        self.audience = nil
        self.recommendedBy = nil
        self.notes = nil
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