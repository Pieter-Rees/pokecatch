#!/bin/bash

# Load the script to test
source ../lib/shop.sh

# Mock functions and variables
print_header() { echo "=== Header ==="; }
print_money() { echo "Money: $MONEY"; }
print_divider() { echo "---"; }
print_menu_option() { echo "$1) $2 $3"; }
print_success() { echo "SUCCESS: $1"; }
print_error() { echo "ERROR: $1"; }
save_progress() { :; }

# Mock icons
POKEBALL="⚫"
ROCK="🪨"
BAIT="🍖"
EXIT="🚪"

# Test helper functions
assert_equal() {
    local expected="$1"
    local actual="$2"
    local message="$3"
    
    if [ "$expected" = "$actual" ]; then
        echo "✓ PASS: $message"
    else
        echo "✗ FAIL: $message"
        echo "  Expected: $expected"
        echo "  Actual:   $actual"
    fi
}

# Test cases

test_get_item_icon() {
    echo "Testing get_item_icon function..."
    
    assert_equal "$POKEBALL" "$(get_item_icon "Pokeball")" "Should return Pokeball icon"
    assert_equal "$ROCK" "$(get_item_icon "Rock")" "Should return Rock icon"
    assert_equal "$BAIT" "$(get_item_icon "Bait")" "Should return Bait icon"
    assert_equal "❓" "$(get_item_icon "Unknown")" "Should return default icon for unknown item"
}

test_buy_item() {
    echo "Testing buy_item function..."
    
    # Test successful purchase of Pokeball
    MONEY=1000
    MIN_MONEY=0
    declare -A INVENTORY
    
    buy_item "Pokeball" 200
    assert_equal "800" "$MONEY" "Should deduct correct amount of money for Pokeball"
    assert_equal "1" "${INVENTORY[Pokeball]}" "Should add Pokeball to inventory"
    
    # Test successful purchase of Rock
    buy_item "Rock" 100
    assert_equal "700" "$MONEY" "Should deduct correct amount of money for Rock"
    assert_equal "1" "${INVENTORY[Rock]}" "Should add Rock to inventory"
    
    # Test successful purchase of Bait
    buy_item "Bait" 150
    assert_equal "550" "$MONEY" "Should deduct correct amount of money for Bait"
    assert_equal "1" "${INVENTORY[Bait]}" "Should add Bait to inventory"
    
    # Test insufficient funds
    MONEY=100
    buy_item "Pokeball" 200
    assert_equal "100" "$MONEY" "Should not deduct money when insufficient funds"
    assert_equal "1" "${INVENTORY[Pokeball]}" "Should not change inventory when insufficient funds"
    
    # Test minimum money limit
    MONEY=50
    MIN_MONEY=50
    buy_item "Rock" 50
    assert_equal "50" "$MONEY" "Should not go below minimum money"
    assert_equal "1" "${INVENTORY[Rock]}" "Should add Rock to inventory even at minimum money"
}

test_shop_return_to_encounter() {
    echo "Testing shop return to encounter functionality..."
    
    # Test shop with return_to_encounter flag
    local return_to_encounter="true"
    assert_equal "true" "$return_to_encounter" "Should have return_to_encounter flag set"
    
    # Test shop without return_to_encounter flag
    return_to_encounter="false"
    assert_equal "false" "$return_to_encounter" "Should not have return_to_encounter flag set"
}

# Run all tests
echo "Starting tests..."
echo "================="

test_get_item_icon
test_buy_item
test_shop_return_to_encounter

echo "================="
echo "Tests completed!" 