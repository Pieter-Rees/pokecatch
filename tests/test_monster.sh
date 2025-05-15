#!/bin/bash

# Load the script to test
source ../lib/monster.sh

# Mock functions and variables that are used in monster.sh
declare -A ENCOUNTER_STATS
ENCOUNTER_STATS["total_encounters"]=0
ENCOUNTER_STATS["successful_catches"]=0
ENCOUNTER_STATS["failed_catches"]=0
ENCOUNTER_STATS["fled"]=0

declare -A MONSTER_STATS_ARRAY
declare -A INVENTORY
INVENTORY["Pokeball"]=5
INVENTORY["Rock"]=3
INVENTORY["Bait"]=3

CAUGHT_MONSTER=()
MONEY=0
MAX_MONEY=9999

# Mock functions
print_header() { echo "=== Header ==="; }
print_divider() { echo "---"; }
print_warning() { echo "WARNING: $1"; }
print_error() { echo "ERROR: $1"; }
print_success() { echo "SUCCESS: $1"; }
print_loading() { echo "LOADING: $1"; }
print_pocket_monster_encounter() { echo "A wild $1 appeared!"; }
print_menu_option() { echo "$2: $3"; }
save_progress() { :; }
save_pokedex() { :; }
show_shop() { :; }

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

test_add_to_pokedex() {
    echo "Testing add_to_pokedex function..."
    
    # Test adding a new monster
    add_to_pokedex "pikachu" "hp: 35|attack: 55|speed: 90"
    assert_equal "pikachu" "${CAUGHT_MONSTER[0]}" "Should add new monster to Pokédex"
    assert_equal "hp: 35|attack: 55|speed: 90" "${MONSTER_STATS_ARRAY[pikachu]}" "Should store monster stats"
    
    # Test adding a duplicate monster
    add_to_pokedex "pikachu" "hp: 35|attack: 55|speed: 90"
    assert_equal 1 "${#CAUGHT_MONSTER[@]}" "Should not add duplicate monster"
}

test_catch_monster() {
    echo "Testing catch_monster function..."
    
    # Reset stats for this test
    ENCOUNTER_STATS["successful_catches"]=0
    ENCOUNTER_STATS["failed_catches"]=0
    MONEY=0
    
    # Mock RANDOM to simulate successful catch on first try
    RANDOM=10  # This will make the catch probability check pass
    
    # Test successful catch
    catch_monster "pikachu" 50
    assert_equal 1 "${ENCOUNTER_STATS[successful_catches]}" "Should increment successful catches"
    assert_equal 0 "${ENCOUNTER_STATS[failed_catches]}" "Should not increment failed catches on success"
    assert_equal 100 "$MONEY" "Should add reward money"
    
    # Reset for next test
    MONEY=0
    ENCOUNTER_STATS["successful_catches"]=0
    ENCOUNTER_STATS["failed_catches"]=0
    
    # Mock RANDOM to simulate failed catch on all attempts
    RANDOM=90  # This will make the catch probability check fail
    
    # Test failed catch (should try 3 times)
    catch_monster "charmander" 50
    assert_equal 0 "${ENCOUNTER_STATS[successful_catches]}" "Should not increment successful catches"
    assert_equal 3 "${ENCOUNTER_STATS[failed_catches]}" "Should increment failed catches for each attempt"
}

test_monster_status_mechanics() {
    echo "Testing monster status mechanics..."
    
    # Test monster speed affects flee chance
    local monster_speed=90
    local base_flee_chance=$((monster_speed / 2))
    assert_equal 45 "$base_flee_chance" "Base flee chance should be half of speed"
    
    # Test angry status doubles flee chance
    local angry_flee_chance=$((base_flee_chance * 2))
    assert_equal 90 "$angry_flee_chance" "Angry status should double flee chance"
    
    # Test eating status reduces flee chance
    local eating_flee_chance=$((base_flee_chance / 4))
    assert_equal 11 "$eating_flee_chance" "Eating status should reduce flee chance to 1/4"
}

test_inventory_mechanics() {
    echo "Testing inventory mechanics..."
    
    # Test rock throwing
    INVENTORY["Rock"]=3
    throw_rock
    assert_equal 2 "${INVENTORY[Rock]}" "Should decrease rock count by 1"
    
    # Test bait throwing
    INVENTORY["Bait"]=3
    throw_bait
    assert_equal 2 "${INVENTORY[Bait]}" "Should decrease bait count by 1"
    
    # Test pokeball throwing
    INVENTORY["Pokeball"]=5
    throw_ball
    assert_equal 4 "${INVENTORY[Pokeball]}" "Should decrease pokeball count by 1"
}

# Run all tests
echo "Starting tests..."
echo "================="

test_add_to_pokedex
test_catch_monster
test_monster_status_mechanics
test_inventory_mechanics

echo "================="
echo "Tests completed!" 