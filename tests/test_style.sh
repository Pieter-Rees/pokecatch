#!/bin/bash

# Load the script to test
source ../lib/style.sh

# Test helper functions
assert_contains() {
    local expected="$1"
    local actual="$2"
    local message="$3"
    
    if [[ "$actual" == *"$expected"* ]]; then
        echo "✓ PASS: $message"
    else
        echo "✗ FAIL: $message"
        echo "  Expected to contain: $expected"
        echo "  Actual:   $actual"
    fi
}

# Test cases

test_print_header() {
    echo "Testing print_header function..."
    
    local output=$(print_header)
    assert_contains "Pocket Monster Safari Zone" "$output" "Should contain game title"
    assert_contains "$MONSTER" "$output" "Should contain monster icon"
}

test_print_menu_option() {
    echo "Testing print_menu_option function..."
    
    local output=$(print_menu_option "1" "$POKEBALL" "Test Option")
    assert_contains "1" "$output" "Should contain option number"
    assert_contains "$POKEBALL" "$output" "Should contain icon"
    assert_contains "Test Option" "$output" "Should contain option text"
}

test_print_inventory_item() {
    echo "Testing print_inventory_item function..."
    
    # Test Pokeball
    local output=$(print_inventory_item "Pokeball" "5")
    assert_contains "$POKEBALL" "$output" "Should contain Pokeball icon"
    assert_contains "Pokeball" "$output" "Should contain item name"
    assert_contains "5" "$output" "Should contain count"
    
    # Test Berry
    local output=$(print_inventory_item "Berry" "3")
    assert_contains "$BERRY" "$output" "Should contain Berry icon"
    assert_contains "Berry" "$output" "Should contain item name"
    assert_contains "3" "$output" "Should contain count"
    
    # Test unknown item
    local output=$(print_inventory_item "Unknown" "1")
    assert_contains "•" "$output" "Should contain default icon"
    assert_contains "Unknown" "$output" "Should contain item name"
    assert_contains "1" "$output" "Should contain count"
}

test_print_money() {
    echo "Testing print_money function..."
    
    MONEY=1000
    CURRENCY_NAME="TestDollars"
    local output=$(print_money)
    assert_contains "1000" "$output" "Should contain money amount"
    assert_contains "TestDollars" "$output" "Should contain currency name"
}

test_print_messages() {
    echo "Testing print message functions..."
    
    # Test success message
    local output=$(print_success "Test success")
    assert_contains "✓" "$output" "Should contain success symbol"
    assert_contains "Test success" "$output" "Should contain success message"
    
    # Test error message
    local output=$(print_error "Test error")
    assert_contains "✗" "$output" "Should contain error symbol"
    assert_contains "Test error" "$output" "Should contain error message"
    
    # Test warning message
    local output=$(print_warning "Test warning")
    assert_contains "⚠" "$output" "Should contain warning symbol"
    assert_contains "Test warning" "$output" "Should contain warning message"
}

test_print_pocket_monster_encounter() {
    echo "Testing print_pocket_monster_encounter function..."
    
    local output=$(print_pocket_monster_encounter "Pikachu")
    assert_contains "$MONSTER" "$output" "Should contain monster icon"
    assert_contains "A wild Pikachu appeared!" "$output" "Should contain encounter message"
}

# Run all tests
echo "Starting tests..."
echo "================="

test_print_header
test_print_menu_option
test_print_inventory_item
test_print_money
test_print_messages
test_print_pocket_monster_encounter

echo "================="
echo "Tests completed!" 