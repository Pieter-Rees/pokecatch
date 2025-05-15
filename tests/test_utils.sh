#!/bin/bash

# ============================================================================
# Test Helper Functions
# ============================================================================

# Assert that two values are equal
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

# Assert that a string contains a substring
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

# ============================================================================
# Mock Functions
# ============================================================================

# Mock display functions
print_header() { echo "=== Header ==="; }
print_divider() { echo "---"; }
print_warning() { echo "WARNING: $1"; }
print_error() { echo "ERROR: $1"; }
print_success() { echo "SUCCESS: $1"; }
print_loading() { echo "LOADING: $1"; }
print_pocket_monster_encounter() { echo "A wild $1 appeared!"; }
print_menu_option() { echo "$2: $3"; }
print_money() { echo "Money: $MONEY"; }

# Mock game functions
save_progress() { :; }
save_pokedex() { :; }
show_shop() { :; }

# Mock icons
POKEBALL="⚫"
ROCK="🪨"
BAIT="🍖"
EXIT="🚪"
MONSTER="🐾"
MONEY="💰"
SHOP="🏪"
SAFARI="🌴"
POKEDEX="📱"
STATUS="📊"
SEARCH="🔍"
BACK="⬅️"

# Export mock functions and variables
export -f print_header
export -f print_divider
export -f print_warning
export -f print_error
export -f print_success
export -f print_loading
export -f print_pocket_monster_encounter
export -f print_menu_option
export -f print_money
export -f save_progress
export -f save_pokedex
export -f show_shop

# Export mock icons
export POKEBALL
export ROCK
export BAIT
export EXIT
export MONSTER
export MONEY
export SHOP
export SAFARI
export POKEDEX
export STATUS
export SEARCH
export BACK 