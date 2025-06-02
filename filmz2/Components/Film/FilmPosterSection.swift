//
//  FilmPosterSection.swift
//  filmz2
//
//  Created by Till Gartner on 02.06.25.
//

import SwiftUI

struct FilmPosterSection: View {
    let posterURL: URL?
    let title: String
    
    var body: some View {
        HStack {
            Spacer()
            AsyncImage(url: posterURL) { image in
                image
                    .resizable()
                    .aspectRatio(2/3, contentMode: .fit)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .shadow(radius: 8)
            } placeholder: {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.3))
                    .aspectRatio(2/3, contentMode: .fit)
                    .overlay(
                        VStack {
                            Image(systemName: "photo")
                                .font(.system(size: 40))
                                .foregroundColor(.gray)
                            Text("Poster")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    )
            }
            .frame(maxHeight: 400)
            Spacer()
        }
    }
}

#Preview {
    FilmPosterSection(
        posterURL: URL(string: "https://m.media-amazon.com/images/M/MV5BMTMxNTMwODM0NF5BMl5BanBnXkFtZTcwODAyMTk2Mw@@._V1_SX300.jpg"),
        title: "The Dark Knight"
    )
}