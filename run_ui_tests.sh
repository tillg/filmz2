#!/bin/bash

# Run individual UI tests and report results
echo "Running MovieSearchUITests..."

tests=(
    "testEmptyStateDisplay"
    "testKeyboardDismissal"
    "testLoadingState"
    "testMultipleSearches"
    "testNavigationToDetail"
    "testSearchFieldInteraction"
    "testSearchPersistence"
    "testSearchResultsDisplay"
    "testSearchTabExists"
    "testWideSearch_CaseInsensitive"
    "testWideSearch_NavigateToPartialMatchResult"
    "testWideSearch_PartialMatch"
    "testWideSearch_SpecialCharacters"
)

passed=0
failed=0

for test in "${tests[@]}"; do
    echo -n "Testing $test... "
    if xcodebuild test -project filmz2.xcodeproj -scheme filmz2 -destination 'platform=iOS Simulator,name=iPhone 16' -only-testing:filmz2UITests/MovieSearchUITests/$test -quiet 2>&1 | grep -q "passed"; then
        echo "✅ PASSED"
        ((passed++))
    else
        echo "❌ FAILED"
        ((failed++))
    fi
done

echo ""
echo "Summary: $passed passed, $failed failed"