//
//  RatingsShowcase.swift
//  filmz2
//
//  Created by Claude on 02.06.25.
//

import SwiftUI

/// A showcase view demonstrating all rating components
struct RatingsShowcase: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 30) {
                // Individual Components
                individualComponents
                
                Divider()
                
                // Ratings Row Examples
                ratingsRowExamples
                
                Divider()
                
                // Integration Examples
                integrationExamples
            }
            .padding()
        }
        .navigationTitle("Ratings Components")
    }
    
    private var individualComponents: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Individual Rating Components")
                .font(.title2)
                .fontWeight(.bold)
            
            VStack(alignment: .leading, spacing: 16) {
                Text("IMDB Ratings").font(.headline)
                HStack(spacing: 20) {
                    IMDBRatingView(rating: "8.5")
                    IMDBRatingView(rating: "10.0")
                    IMDBRatingView(rating: "5.2")
                    IMDBRatingView(rating: nil)
                }
                
                Text("Rotten Tomatoes Ratings").font(.headline)
                HStack(spacing: 20) {
                    RottenTomatoesRatingView(rating: "94%")
                    RottenTomatoesRatingView(rating: "60%")
                    RottenTomatoesRatingView(rating: "35%")
                    RottenTomatoesRatingView(rating: nil)
                }
                
                Text("My Ratings").font(.headline)
                HStack(spacing: 20) {
                    MyRatingView(rating: 10)
                    MyRatingView(rating: 7)
                    MyRatingView(rating: 3)
                    MyRatingView(rating: nil)
                }
            }
        }
    }
    
    private var ratingsRowExamples: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Ratings Row")
                .font(.title2)
                .fontWeight(.bold)
            
            VStack(alignment: .leading, spacing: 16) {
                Text("All Ratings").font(.headline)
                RatingsRow(
                    imdbRating: "8.5",
                    rottenTomatoesRating: "94%",
                    myRating: 9
                )
                
                Text("Partial Ratings").font(.headline)
                VStack(alignment: .leading, spacing: 12) {
                    RatingsRow(imdbRating: "7.2", myRating: 8)
                    RatingsRow(rottenTomatoesRating: "85%")
                    RatingsRow(myRating: 6)
                }
                
                Text("No Ratings").font(.headline)
                RatingsRow()
                    .frame(height: 20)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(4)
                
                Text("Wrapping Layout (Narrow Space)").font(.headline)
                RatingsRow(
                    imdbRating: "8.5",
                    rottenTomatoesRating: "94%",
                    myRating: 9,
                    layout: .wrapping
                )
                .frame(width: 180)
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
            }
        }
    }
    
    private var integrationExamples: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Integration Examples")
                .font(.title2)
                .fontWeight(.bold)
            
            // Film Detail Style
            VStack(alignment: .leading, spacing: 12) {
                Text("Film Detail View Style").font(.headline)
                
                VStack(alignment: .leading, spacing: 16) {
                    Text("The Dark Knight")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("2008 • Action, Crime, Drama")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    RatingsRow(
                        imdbRating: "9.0",
                        rottenTomatoesRating: "94%",
                        myRating: 10
                    )
                    
                    Text("2,654,264 votes")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color.gray.opacity(0.05))
                .cornerRadius(12)
            }
            
            // List Cell Style
            VStack(alignment: .leading, spacing: 12) {
                Text("List Cell Style").font(.headline)
                
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Inception")
                            .font(.headline)
                            .lineLimit(1)
                        Text("2010")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        HStack(spacing: 12) {
                            IMDBRatingView(rating: "8.8")
                            MyRatingView(rating: 9)
                        }
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color.gray.opacity(0.05))
                .cornerRadius(12)
            }
        }
    }
}

#Preview("Ratings Showcase") {
    NavigationView {
        RatingsShowcase()
    }
}

#Preview("Dark Mode") {
    NavigationView {
        RatingsShowcase()
    }
    .preferredColorScheme(.dark)
}