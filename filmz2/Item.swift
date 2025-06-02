//
//  Item.swift
//  filmz2
//
//  Created by Till Gartner on 29.05.25.
//

/**
 * Item Model - SwiftData Template Placeholder
 *
 * This is a default model that comes with the SwiftData app template.
 * It's not currently used in the filmz2 app but is kept for reference
 * and potential future use.
 *
 * TODO: Consider removing this file if not needed.
 */

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
