#!/bin/bash

# Load test utilities
source test_utils.sh

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
    INVENTORY["Pokeball"]=5
    INVENTORY["Rock"]=3
    INVENTORY["Bait"]=3
    ENCOUNTER_STATS["total_encounters"]=10
    ENCOUNTER_STATS["successful_catches"]=5
    ENCOUNTER_STATS["fled"]=2
    
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
    assert_equal "5" "${INVENTORY[Pokeball]}" "Should load correct pokeball count"
    assert_equal "3" "${INVENTORY[Rock]}" "Should load correct rock count"
    assert_equal "3" "${INVENTORY[Bait]}" "Should load correct bait count"
    assert_equal "10" "${ENCOUNTER_STATS[total_encounters]}" "Should load correct total encounters"
    assert_equal "5" "${ENCOUNTER_STATS[successful_catches]}" "Should load correct successful catches"
    assert_equal "2" "${ENCOUNTER_STATS[fled]}" "Should load correct fled count"
    
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
    MONSTER_STATS_ARRAY["pikachu"]="hp: 35|attack: 55|speed: 90"
    MONSTER_STATS_ARRAY["charmander"]="hp: 39|attack: 52|speed: 65"
    
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
    assert_equal "hp: 35|attack: 55|speed: 90" "${MONSTER_STATS_ARRAY[pikachu]}" "Should load pikachu stats"
    assert_equal "hp: 39|attack: 52|speed: 65" "${MONSTER_STATS_ARRAY[charmander]}" "Should load charmander stats"
    
    # Go back to original directory
    cd ..
}

test_monster_status_effects() {
    echo "Testing monster status effects..."
    
    # Test angry status
    local angry_turns=3
    local monster_speed=90
    local base_flee_chance=$((monster_speed / 2))
    local angry_flee_chance=$((base_flee_chance * 2))
    
    assert_equal 45 "$base_flee_chance" "Base flee chance should be half of speed"
    assert_equal 90 "$angry_flee_chance" "Angry status should double flee chance"
    
    # Test eating status
    local eating_turns=2
    local eating_flee_chance=$((base_flee_chance / 4))
    assert_equal 11 "$eating_flee_chance" "Eating status should reduce flee chance to 1/4"
    
    # Test status turn counting
    angry_turns=$((angry_turns - 1))
    assert_equal 2 "$angry_turns" "Should decrease angry turns by 1"
    
    eating_turns=$((eating_turns - 1))
    assert_equal 1 "$eating_turns" "Should decrease eating turns by 1"
}

test_show_status() {
    echo "Testing show_status function..."
    
    # Set up test data
    MONEY=1000
    declare -A INVENTORY
    INVENTORY["Pokeball"]=5
    INVENTORY["Rock"]=3
    INVENTORY["Bait"]=2
    
    # Test status display
    local output=$(show_status)
    assert_contains "1000" "$output" "Should show correct money amount"
    assert_contains "5" "$output" "Should show correct Pokeball count"
    assert_contains "3" "$output" "Should show correct Rock count"
    assert_contains "2" "$output" "Should show correct Bait count"
}

test_show_pokedex() {
    echo "Testing show_pokedex function..."
    
    # Set up test data
    CAUGHT_MONSTER=("pikachu" "charmander")
    declare -A MONSTER_STATS_ARRAY
    MONSTER_STATS_ARRAY["pikachu"]="hp: 35|attack: 55|speed: 90"
    MONSTER_STATS_ARRAY["charmander"]="hp: 39|attack: 52|speed: 65"
    
    # Test Pokédex display
    local output=$(show_pokedex)
    assert_contains "pikachu" "$output" "Should show Pikachu"
    assert_contains "charmander" "$output" "Should show Charmander"
    assert_contains "hp: 35" "$output" "Should show Pikachu's stats"
    assert_contains "hp: 39" "$output" "Should show Charmander's stats"
}

test_search_monster() {
    echo "Testing search_monster function..."
    
    # Set up test data
    CAUGHT_MONSTER=("pikachu" "raichu" "pichu")
    declare -A MONSTER_STATS_ARRAY
    MONSTER_STATS_ARRAY["pikachu"]="hp: 35|attack: 55|speed: 90"
    MONSTER_STATS_ARRAY["raichu"]="hp: 60|attack: 90|speed: 110"
    MONSTER_STATS_ARRAY["pichu"]="hp: 20|attack: 40|speed: 60"
    
    # Test searching for "pi"
    local output=$(search_monster "pi")
    assert_contains "pikachu" "$output" "Should find Pikachu"
    assert_contains "pichu" "$output" "Should find Pichu"
    assert_contains "hp: 35" "$output" "Should show Pikachu's stats"
    assert_contains "hp: 20" "$output" "Should show Pichu's stats"
}

# Run all tests
echo "Starting tests..."
echo "================="

test_load_config
test_save_and_load_progress
test_save_and_load_pokedex
test_monster_status_effects
test_show_status
test_show_pokedex
test_search_monster

# Cleanup
rm -rf "$TEST_DIR"

echo "================="
echo "Tests completed!" 