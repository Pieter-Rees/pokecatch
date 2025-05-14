#!/bin/bash

# Load the script to test
source ../lib/monster.sh

# Mock functions and variables that are used in monster.sh
declare -A ENCOUNTER_STATS
ENCOUNTER_STATS["total_encounters"]=0
ENCOUNTER_STATS["successful_catches"]=0
ENCOUNTER_STATS["failed_catches"]=0

declare -A MONSTER_STATS_ARRAY
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
save_progress() { :; }
save_pokedex() { :; }

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
    add_to_pokedex "pikachu" "hp: 35|attack: 55"
    assert_equal "pikachu" "${CAUGHT_MONSTER[0]}" "Should add new monster to Pokédex"
    assert_equal "hp: 35|attack: 55" "${MONSTER_STATS_ARRAY[pikachu]}" "Should store monster stats"
    
    # Test adding a duplicate monster
    add_to_pokedex "pikachu" "hp: 35|attack: 55"
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

# Run all tests
echo "Starting tests..."
echo "================="

test_add_to_pokedex
test_catch_monster

echo "================="
echo "Tests completed!" 