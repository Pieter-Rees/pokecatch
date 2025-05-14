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
POKEBALL="⚪"
BERRY="🍓"
MUD="💩"
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
    assert_equal "$BERRY" "$(get_item_icon "Berry")" "Should return Berry icon"
    assert_equal "$MUD" "$(get_item_icon "Mud")" "Should return Mud icon"
    assert_equal "•" "$(get_item_icon "Unknown")" "Should return default icon for unknown item"
}

test_buy_item() {
    echo "Testing buy_item function..."
    
    # Test successful purchase
    MONEY=1000
    MIN_MONEY=0
    declare -A INVENTORY
    
    buy_item "Pokeball" 200
    assert_equal "800" "$MONEY" "Should deduct correct amount of money"
    assert_equal "1" "${INVENTORY[Pokeball]}" "Should add item to inventory"
    
    # Test insufficient funds
    MONEY=100
    buy_item "Pokeball" 200
    assert_equal "100" "$MONEY" "Should not deduct money when insufficient funds"
    assert_equal "1" "${INVENTORY[Pokeball]}" "Should not change inventory when insufficient funds"
    
    # Test minimum money limit
    MONEY=50
    MIN_MONEY=50
    buy_item "Mud" 50
    assert_equal "50" "$MONEY" "Should not go below minimum money"
    assert_equal "1" "${INVENTORY[Mud]}" "Should add item to inventory even at minimum money"
}

# Run all tests
echo "Starting tests..."
echo "================="

test_get_item_icon
test_buy_item

echo "================="
echo "Tests completed!" 