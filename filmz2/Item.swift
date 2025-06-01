//
//  Item.swift
//  filmz2
//
//  Created by Till Gartner on 29.05.25.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
