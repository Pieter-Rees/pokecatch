#!/bin/bash

# Load the script to test
source ../lib/status.sh

# Mock functions
print_header() { echo "=== Header ==="; }
print_divider() { echo "---"; }
print_warning() { echo "WARNING: $1"; }
print_inventory_item() { echo "  $1: $2"; }

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

# Create temporary test directory
TEST_DIR="test_data"
mkdir -p "$TEST_DIR"
mkdir -p "$TEST_DIR/config"

# Create test config file
cat > "$TEST_DIR/config/game_config.json" << EOF
{
    "starting_money": 1000,
    "currency_name": "TestDollars",
    "min_money": 0,
    "max_money": 9999
}
EOF

# Test cases

test_load_config() {
    echo "Testing load_config function..."
    
    # Change to test directory
    cd "$TEST_DIR"
    
    # Load config
    load_config
    
    # Test config values
    assert_equal "1000" "$STARTING_MONEY" "Should load correct starting money"
    assert_equal "TestDollars" "$CURRENCY_NAME" "Should load correct currency name"
    assert_equal "0" "$MIN_MONEY" "Should load correct min money"
    assert_equal "9999" "$MAX_MONEY" "Should load correct max money"
    
    # Go back to original directory
    cd ..
}

test_save_and_load_progress() {
    echo "Testing save_progress and load_progress functions..."
    
    # Change to test directory
    cd "$TEST_DIR"
    
    # Set up test data
    MONEY=500
    INVENTORY["pokeball"]=5
    INVENTORY["potion"]=3
    ENCOUNTER_STATS["total_encounters"]=10
    ENCOUNTER_STATS["successful_catches"]=5
    
    # Save progress
    save_progress
    
    # Reset variables
    MONEY=0
    declare -A INVENTORY
    declare -A ENCOUNTER_STATS
    
    # Load progress
    load_progress
    
    # Test loaded values
    assert_equal "500" "$MONEY" "Should load correct money amount"
    assert_equal "5" "${INVENTORY[pokeball]}" "Should load correct pokeball count"
    assert_equal "3" "${INVENTORY[potion]}" "Should load correct potion count"
    assert_equal "10" "${ENCOUNTER_STATS[total_encounters]}" "Should load correct total encounters"
    assert_equal "5" "${ENCOUNTER_STATS[successful_catches]}" "Should load correct successful catches"
    
    # Go back to original directory
    cd ..
}

test_save_and_load_pokedex() {
    echo "Testing save_pokedex and load_pokedex functions..."
    
    # Change to test directory
    cd "$TEST_DIR"
    
    # Set up test data
    CAUGHT_MONSTER=("pikachu" "charmander")
    declare -A MONSTER_STATS_ARRAY
    MONSTER_STATS_ARRAY["pikachu"]="hp: 35|attack: 55"
    MONSTER_STATS_ARRAY["charmander"]="hp: 39|attack: 52"
    
    # Save pokedex
    save_pokedex
    
    # Reset variables
    CAUGHT_MONSTER=()
    declare -A MONSTER_STATS_ARRAY
    
    # Load pokedex
    load_pokedex
    
    # Test loaded values
    assert_equal "pikachu" "${CAUGHT_MONSTER[0]}" "Should load first monster"
    assert_equal "charmander" "${CAUGHT_MONSTER[1]}" "Should load second monster"
    assert_equal "hp: 35|attack: 55" "${MONSTER_STATS_ARRAY[pikachu]}" "Should load pikachu stats"
    assert_equal "hp: 39|attack: 52" "${MONSTER_STATS_ARRAY[charmander]}" "Should load charmander stats"
    
    # Go back to original directory
    cd ..
}

# Run all tests
echo "Starting tests..."
echo "================="

test_load_config
test_save_and_load_progress
test_save_and_load_pokedex

# Cleanup
rm -rf "$TEST_DIR"

echo "================="
echo "Tests completed!" 