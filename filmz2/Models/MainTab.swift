//
//  MainTab.swift
//  filmz2
//
//  Created by Claude on 02.06.25.
//

import Foundation

enum MainTab: Int, CaseIterable {
    case collection = 0
    case search = 1
    case settings = 2
    
    var title: String {
        switch self {
        case .collection: return "Collection"
        case .search: return "Search"
        case .settings: return "Settings"
        }
    }
    
    var icon: String {
        switch self {
        case .collection: return "books.vertical"
        case .search: return "magnifyingglass"
        case .settings: return "gearshape"
        }
    }
}