#!/bin/bash

# Load the script to test
source ../lib/items.sh

# Mock functions
print_error() { echo "ERROR: $1"; }
print_success() { echo "SUCCESS: $1"; }
print_warning() { echo "WARNING: $1"; }
save_progress() { :; }
catch_pocket_monster() { echo "Caught $1 with probability $2"; }

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

test_throw_ball() {
    echo "Testing throw_ball function..."
    
    # Test with no Pokeballs
    declare -A INVENTORY
    INVENTORY["Pokeball"]=0
    throw_ball
    assert_equal "2" "$?" "Should return 2 when no Pokeballs"
    
    # Test with Pokeballs
    INVENTORY["Pokeball"]=1
    pocket_monster_EATING="false"
    pocket_monster_ANGRY="false"
    pocket_monster_NAME="pikachu"
    
    # Mock RANDOM for successful catch (base catch rate: 30 * 100 / 255 ≈ 11.76%)
    RANDOM=10  # This will make the catch probability check pass (10 < 11.76)
    throw_ball
    assert_equal "0" "$?" "Should return 0 on successful catch"
    assert_equal "0" "${INVENTORY[Pokeball]}" "Should decrease Pokeball count"
    
    # Test with eating status (catch rate: 60 * 100 / 255 ≈ 23.53%)
    INVENTORY["Pokeball"]=1
    pocket_monster_EATING="true"
    RANDOM=20  # This will make the catch probability check pass (20 < 23.53)
    throw_ball
    assert_equal "0" "$?" "Should have higher catch rate when eating"
    
    # Test with angry status (catch rate: 15 * 100 / 255 ≈ 5.88%)
    INVENTORY["Pokeball"]=1
    pocket_monster_EATING="false"
    pocket_monster_ANGRY="true"
    RANDOM=10  # This will make the catch probability check fail (10 > 5.88)
    throw_ball
    assert_equal "1" "$?" "Should have lower catch rate when angry"
}

test_throw_rock() {
    echo "Testing throw_rock function..."
    
    # Test with no Rocks
    declare -A INVENTORY
    INVENTORY["Rock"]=0
    throw_rock
    assert_equal "1" "$?" "Should return 1 when no Rocks"
    
    # Test with Rocks
    INVENTORY["Rock"]=1
    throw_rock
    assert_equal "0" "$?" "Should return 0 on successful throw"
    assert_equal "0" "${INVENTORY[Rock]}" "Should decrease Rock count"
    assert_equal "true" "$MONSTER_ANGRY" "Should set MONSTER_ANGRY to true"
}

test_throw_bait() {
    echo "Testing throw_bait function..."
    
    # Test with no Bait
    declare -A INVENTORY
    INVENTORY["Bait"]=0
    throw_bait
    assert_equal "1" "$?" "Should return 1 when no Bait"
    
    # Test with Bait
    INVENTORY["Bait"]=1
    throw_bait
    assert_equal "0" "$?" "Should return 0 on successful throw"
    assert_equal "0" "${INVENTORY[Bait]}" "Should decrease Bait count"
    assert_equal "true" "$MONSTER_EATING" "Should set MONSTER_EATING to true"
}

# Run all tests
echo "Starting tests..."
echo "================="

test_throw_ball
test_throw_rock
test_throw_bait

echo "================="
echo "Tests completed!" 