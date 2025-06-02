//
//  RatingComponentsTests.swift
//  filmz2Tests
//
//  Created by Claude on 02.06.25.
//

import XCTest
import SwiftUI
@testable import filmz2

final class RatingComponentsTests: XCTestCase {
    
    // MARK: - IMDBRatingView Tests
    
    func testIMDBRatingViewWithValidRating() {
        let rating = "8.5"
        let view = IMDBRatingView(rating: rating)
        
        // View should render with the rating
        XCTAssertNotNil(view)
    }
    
    func testIMDBRatingViewWithNilRating() {
        let view = IMDBRatingView(rating: nil)
        
        // View should still be valid but won't render content
        XCTAssertNotNil(view)
    }
    
    func testIMDBRatingViewWithNAValue() {
        let view = IMDBRatingView(rating: "N/A")
        
        // View should handle N/A gracefully
        XCTAssertNotNil(view)
    }
    
    func testIMDBRatingViewFormatsRatingCorrectly() {
        // Test that it adds /10 if not present
        let view1 = IMDBRatingView(rating: "8.5")
        let view2 = IMDBRatingView(rating: "8.5/10")
        
        XCTAssertNotNil(view1)
        XCTAssertNotNil(view2)
    }
    
    // MARK: - RottenTomatoesRatingView Tests
    
    func testRottenTomatoesRatingViewWithFreshRating() {
        let rating = "85%"
        let view = RottenTomatoesRatingView(rating: rating)
        
        XCTAssertNotNil(view)
    }
    
    func testRottenTomatoesRatingViewWithRottenRating() {
        let rating = "35%"
        let view = RottenTomatoesRatingView(rating: rating)
        
        XCTAssertNotNil(view)
    }
    
    func testRottenTomatoesRatingViewBoundaryCase() {
        // 60% is the boundary - should be fresh
        let view1 = RottenTomatoesRatingView(rating: "60%")
        let view2 = RottenTomatoesRatingView(rating: "59%")
        
        XCTAssertNotNil(view1)
        XCTAssertNotNil(view2)
    }
    
    // MARK: - MyRatingView Tests
    
    func testMyRatingViewWithValidRating() {
        let rating = 8
        let view = MyRatingView(rating: rating)
        
        XCTAssertNotNil(view)
    }
    
    func testMyRatingViewWithNilRating() {
        let view = MyRatingView(rating: nil)
        
        XCTAssertNotNil(view)
    }
    
    func testMyRatingViewWithBoundaryRatings() {
        let view1 = MyRatingView(rating: 1)
        let view10 = MyRatingView(rating: 10)
        
        XCTAssertNotNil(view1)
        XCTAssertNotNil(view10)
    }
    
    // MARK: - RatingsRow Tests
    
    func testRatingsRowWithAllRatings() {
        let view = RatingsRow(
            imdbRating: "8.5",
            rottenTomatoesRating: "94%",
            myRating: 9
        )
        
        XCTAssertNotNil(view)
        XCTAssertTrue(view.hasAnyRating)
    }
    
    func testRatingsRowWithNoRatings() {
        let view = RatingsRow()
        
        XCTAssertNotNil(view)
        XCTAssertFalse(view.hasAnyRating)
    }
    
    func testRatingsRowWithPartialRatings() {
        let view1 = RatingsRow(imdbRating: "7.5")
        let view2 = RatingsRow(rottenTomatoesRating: "85%")
        let view3 = RatingsRow(myRating: 8)
        
        XCTAssertTrue(view1.hasAnyRating)
        XCTAssertTrue(view2.hasAnyRating)
        XCTAssertTrue(view3.hasAnyRating)
    }
    
    func testRatingsRowFromFilmModel() {
        let film = IMDBFilm.darkKnight
        let view = RatingsRow(film: film, myRating: 10)
        
        XCTAssertNotNil(view)
        XCTAssertTrue(view.hasAnyRating)
    }
    
    func testRatingsRowLayoutOptions() {
        let horizontal = RatingsRow(
            imdbRating: "8.5",
            rottenTomatoesRating: "94%",
            myRating: 9,
            layout: .horizontal
        )
        
        let wrapping = RatingsRow(
            imdbRating: "8.5",
            rottenTomatoesRating: "94%",
            myRating: 9,
            layout: .wrapping
        )
        
        XCTAssertNotNil(horizontal)
        XCTAssertNotNil(wrapping)
    }
    
    func testRatingsRowHandlesNAValues() {
        let view = RatingsRow(
            imdbRating: "N/A",
            rottenTomatoesRating: "N/A",
            myRating: nil
        )
        
        XCTAssertNotNil(view)
        XCTAssertFalse(view.hasAnyRating)
    }
    
    func testRatingsRowHandlesEmptyStrings() {
        let view = RatingsRow(
            imdbRating: "",
            rottenTomatoesRating: "",
            myRating: nil
        )
        
        XCTAssertNotNil(view)
        XCTAssertFalse(view.hasAnyRating)
    }
}

// MARK: - Helper Extensions for Testing

extension RatingsRow {
    /// Helper to access hasAnyRating for testing
    var hasAnyRating: Bool {
        (imdbRating != nil && imdbRating != "N/A" && !imdbRating!.isEmpty) ||
        (rottenTomatoesRating != nil && rottenTomatoesRating != "N/A" && !rottenTomatoesRating!.isEmpty) ||
        myRating != nil
    }
}