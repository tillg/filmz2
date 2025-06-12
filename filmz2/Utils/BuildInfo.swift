//
//  BuildInfo.swift
//  filmz2
//
//  Created by AI Assistant on 12.06.25.
//

import Foundation

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
    
    static var isValidCommitHash: Bool {
        gitCommitHash != "Unknown" && !gitCommitHash.isEmpty
    }
}