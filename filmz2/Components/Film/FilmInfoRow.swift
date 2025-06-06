//
//  FilmInfoRow.swift
//  filmz2
//
//  Created by Till Gartner on 02.06.25.
//

import SwiftUI

struct FilmInfoRow: View {
    let title: String
    let content: String?
    
    var body: some View {
        if let content = content, !content.isEmpty, content != "N/A" {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                Text(content)
                    .font(.body)
            }
        }
    }
}

#Preview {
    VStack(alignment: .leading, spacing: 16) {
        FilmInfoRow(title: "Director", content: "Christopher Nolan")
        FilmInfoRow(title: "Starring", content: "Christian Bale, Heath Ledger, Aaron Eckhart")
        FilmInfoRow(title: "Released", content: "July 18, 2008")
        // These won't display
        FilmInfoRow(title: "Empty", content: "")
        FilmInfoRow(title: "Nil", content: nil)
        FilmInfoRow(title: "N/A", content: "N/A")
    }
    .padding()
}