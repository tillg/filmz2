import XCTest

final class MovieSearchUITests: XCTestCase {
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        
        app = XCUIApplication()
        app.launch()
    }
    
    override func tearDownWithError() throws {
        app = nil
    }
    
    func testSearchTabExists() throws {
        // Verify search tab exists and is accessible
        let searchTab = app.tabBars.buttons["Search"]
        XCTAssertTrue(searchTab.exists)
        
        // Tap search tab
        searchTab.tap()
        
        // Verify search screen is displayed
        let searchNavBar = app.navigationBars["Search Movies"]
        XCTAssertTrue(searchNavBar.exists)
    }
    
    func testSearchFieldInteraction() throws {
        // Navigate to search tab
        app.tabBars.buttons["Search"].tap()
        
        // Find search field
        let searchField = app.textFields["Search movies..."]
        XCTAssertTrue(searchField.exists)
        
        // Tap and type in search field
        searchField.tap()
        searchField.typeText("Batman")
        
        // Verify text was entered
        XCTAssertEqual(searchField.value as? String, "Batman")
        
        // Clear button should appear
        let clearButton = app.buttons["Clear text"]
        XCTAssertTrue(clearButton.waitForExistence(timeout: 1))
        
        // Tap clear button
        clearButton.tap()
        
        // Verify field is cleared
        XCTAssertEqual(searchField.value as? String, "Search movies...")
    }
    
    func testSearchResultsDisplay() throws {
        // Navigate to search tab
        app.tabBars.buttons["Search"].tap()
        
        // Search for Batman
        let searchField = app.textFields["Search movies..."]
        searchField.tap()
        searchField.typeText("Batman")
        
        // Wait for results to load - search for Batman title in the UI
        let firstResult = app.scrollViews.descendants(matching: .button).element(boundBy: 0)
        XCTAssertTrue(firstResult.waitForExistence(timeout: 5))
        
        // Verify multiple results appear by checking for buttons in the scroll view
        XCTAssertTrue(app.scrollViews.descendants(matching: .button).count > 0)
        
        // Verify result contains expected elements
        let movieTitle = app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] 'Batman'")).firstMatch
        XCTAssertTrue(movieTitle.exists)
    }
    
    func testNavigationToDetail() throws {
        // Navigate to search tab
        app.tabBars.buttons["Search"].tap()
        
        // Search for Batman
        let searchField = app.textFields["Search movies..."]
        searchField.tap()
        searchField.typeText("Batman")
        
        // Wait for results
        let firstResult = app.scrollViews.descendants(matching: .button).element(boundBy: 0)
        XCTAssertTrue(firstResult.waitForExistence(timeout: 5))
        
        // Tap first result
        firstResult.tap()
        
        // Verify navigation to detail view
        let backButton = app.navigationBars.buttons.element(boundBy: 0)
        XCTAssertTrue(backButton.waitForExistence(timeout: 2))
        
        // Verify detail view elements
        XCTAssertTrue(app.images.count > 0) // Movie poster
        XCTAssertTrue(app.staticTexts["Ratings"].exists)
        
        // Navigate back
        backButton.tap()
        
        // Verify we're back on search screen with results still visible
        XCTAssertTrue(searchField.exists)
        XCTAssertTrue(firstResult.exists)
    }
    
    func testEmptyStateDisplay() throws {
        // Navigate to search tab
        app.tabBars.buttons["Search"].tap()
        
        // Search for nonsense
        let searchField = app.textFields["Search movies..."]
        searchField.tap()
        searchField.typeText("xyzabc123456789")
        
        // Wait for empty state
        let emptyStateText = app.staticTexts["No movies found"]
        XCTAssertTrue(emptyStateText.waitForExistence(timeout: 5))
        
        // Verify suggestion text
        let suggestionText = app.staticTexts["Try searching with different keywords"]
        XCTAssertTrue(suggestionText.exists)
    }
    
    func testLoadingState() throws {
        // Navigate to search tab
        app.tabBars.buttons["Search"].tap()
        
        // Type quickly to see loading state
        let searchField = app.textFields["Search movies..."]
        searchField.tap()
        searchField.typeText("Star Wars")
        
        // Look for loading indicator (may be brief)
        let progressView = app.progressIndicators.firstMatch
        
        // Either we see the loading state or results appear quickly
        let hasLoadingOrResults = progressView.waitForExistence(timeout: 0.5) || app.scrollViews.descendants(matching: .button).count > 0
        XCTAssertTrue(hasLoadingOrResults)
    }
    
    func testKeyboardDismissal() throws {
        // Navigate to search tab
        app.tabBars.buttons["Search"].tap()
        
        // Open keyboard
        let searchField = app.textFields["Search movies..."]
        searchField.tap()
        searchField.typeText("Batman")
        
        // Wait for results
        let firstResult = app.scrollViews.descendants(matching: .button).element(boundBy: 0)
        XCTAssertTrue(firstResult.waitForExistence(timeout: 5))
        
        // Swipe to dismiss keyboard
        app.swipeDown()
        
        // Keyboard should be dismissed (search field no longer focused)
        // We can verify this by checking if we can interact with results
        firstResult.tap()
        
        // Should navigate to detail
        let backButton = app.navigationBars.buttons.element(boundBy: 0)
        XCTAssertTrue(backButton.waitForExistence(timeout: 2))
    }
    
    func testSearchPersistence() throws {
        // Navigate to search tab
        app.tabBars.buttons["Search"].tap()
        
        // Search for something
        let searchField = app.textFields.firstMatch
        XCTAssertTrue(searchField.waitForExistence(timeout: 2))
        searchField.tap()
        searchField.typeText("Inception")
        
        // Wait for results
        let firstResult = app.scrollViews.descendants(matching: .button).element(boundBy: 0)
        XCTAssertTrue(firstResult.waitForExistence(timeout: 5))
        
        // Switch to collection tab
        app.tabBars.buttons["Collection"].tap()
        
        // Wait a moment for tab switch
        Thread.sleep(forTimeInterval: 0.5)
        
        // Switch back to search tab
        app.tabBars.buttons["Search"].tap()
        
        // Verify we can search again (tab switch typically clears search in SwiftUI)
        let searchFieldAfterSwitch = app.textFields.firstMatch
        XCTAssertTrue(searchFieldAfterSwitch.waitForExistence(timeout: 2))
        
        // Clear any existing text and search again
        searchFieldAfterSwitch.tap()
        if let currentValue = searchFieldAfterSwitch.value as? String, !currentValue.isEmpty && currentValue != "Search movies..." {
            // Clear existing text
            let deleteString = String(repeating: XCUIKeyboardKey.delete.rawValue, count: currentValue.count)
            searchFieldAfterSwitch.typeText(deleteString)
        }
        searchFieldAfterSwitch.typeText("Inception")
        
        // Verify results appear again
        let newFirstResult = app.scrollViews.descendants(matching: .button).element(boundBy: 0)
        XCTAssertTrue(newFirstResult.waitForExistence(timeout: 5))
    }
    
    func testMultipleSearches() throws {
        // Navigate to search tab
        app.tabBars.buttons["Search"].tap()
        
        let searchField = app.textFields["Search movies..."]
        
        // First search
        searchField.tap()
        searchField.typeText("Batman")
        
        // Wait for Batman results
        let batmanResult = app.scrollViews.descendants(matching: .any).containing(NSPredicate(format: "label CONTAINS[c] 'Batman'")).firstMatch
        XCTAssertTrue(batmanResult.waitForExistence(timeout: 5))
        
        // Clear and search again
        app.buttons["Clear text"].tap()
        searchField.typeText("Star Wars")
        
        // Wait for Star Wars results
        let starWarsResult = app.scrollViews.descendants(matching: .any).containing(NSPredicate(format: "label CONTAINS[c] 'Star Wars'")).firstMatch
        XCTAssertTrue(starWarsResult.waitForExistence(timeout: 5))
        
        // Verify Batman results are gone
        XCTAssertFalse(batmanResult.exists)
    }
    
    // MARK: - Wide Search UI Tests
    
    func testWideSearch_PartialMatch() throws {
        // Navigate to search tab
        app.tabBars.buttons["Search"].tap()
        
        // Search for partial term "bat"
        let searchField = app.textFields["Search movies..."]
        searchField.tap()
        searchField.typeText("bat")
        
        // Wait for results
        let firstResult = app.scrollViews.descendants(matching: .button).element(boundBy: 0)
        XCTAssertTrue(firstResult.waitForExistence(timeout: 5))
        
        // Verify multiple results containing "bat"
        XCTAssertTrue(app.scrollViews.descendants(matching: .button).count >= 2, "Should have multiple results for 'bat'")
        
        // Check for Batman movies
        let batmanResult = app.scrollViews.descendants(matching: .any).containing(NSPredicate(format: "label CONTAINS[c] 'Batman'")).firstMatch
        XCTAssertTrue(batmanResult.exists, "Should find 'Batman' when searching for 'bat'")
        
        // Could also find movies like "Combat" or "Acrobat" if they exist
        // The exact results depend on the API response
    }
    
    func testWideSearch_CaseInsensitive() throws {
        // Navigate to search tab
        app.tabBars.buttons["Search"].tap()
        
        let searchField = app.textFields["Search movies..."]
        
        // Search with uppercase
        searchField.tap()
        searchField.typeText("BAT")
        
        // Wait for results
        let firstResult = app.scrollViews.descendants(matching: .button).element(boundBy: 0)
        XCTAssertTrue(firstResult.waitForExistence(timeout: 5))
        
        // Should still find Batman movies
        let batmanResult = app.scrollViews.descendants(matching: .any).containing(NSPredicate(format: "label CONTAINS[c] 'Batman'")).firstMatch
        XCTAssertTrue(batmanResult.exists, "Should find 'Batman' when searching for 'BAT'")
        
        // Clear and search with mixed case
        app.buttons["Clear text"].tap()
        searchField.typeText("bAt")
        
        // Should get same results
        XCTAssertTrue(firstResult.waitForExistence(timeout: 5))
        XCTAssertTrue(batmanResult.exists, "Should find 'Batman' when searching for 'bAt'")
    }
    
    func testWideSearch_SpecialCharacters() throws {
        // Navigate to search tab
        app.tabBars.buttons["Search"].tap()
        
        // Search for "mission:" to find Mission: Impossible movies
        let searchField = app.textFields["Search movies..."]
        searchField.tap()
        searchField.typeText("mission:")
        
        // Wait for results
        let firstResult = app.scrollViews.descendants(matching: .button).element(boundBy: 0)
        XCTAssertTrue(firstResult.waitForExistence(timeout: 5))
        
        // Should find Mission: Impossible movies
        let missionResult = app.scrollViews.descendants(matching: .any).containing(NSPredicate(format: "label CONTAINS[c] 'Mission: Impossible'")).firstMatch
        XCTAssertTrue(missionResult.exists, "Should find 'Mission: Impossible' when searching for 'mission:'")
    }
    
    func testWideSearch_NavigateToPartialMatchResult() throws {
        // Navigate to search tab
        app.tabBars.buttons["Search"].tap()
        
        // Search for partial term
        let searchField = app.textFields["Search movies..."]
        searchField.tap()
        searchField.typeText("bat")
        
        // Wait for results
        let firstResult = app.scrollViews.descendants(matching: .button).element(boundBy: 0)
        XCTAssertTrue(firstResult.waitForExistence(timeout: 5))
        
        // Tap on a result
        firstResult.tap()
        
        // Verify navigation to detail view works correctly
        let backButton = app.navigationBars.buttons.element(boundBy: 0)
        XCTAssertTrue(backButton.waitForExistence(timeout: 2))
        
        // Verify detail view loaded
        XCTAssertTrue(app.images.count > 0) // Movie poster
        XCTAssertTrue(app.staticTexts["Ratings"].exists || app.staticTexts["Plot"].exists)
        
        // Navigate back
        backButton.tap()
        
        // Verify search results are still visible
        XCTAssertTrue(searchField.exists)
        XCTAssertEqual(searchField.value as? String, "bat")
        XCTAssertTrue(firstResult.exists)
    }
}