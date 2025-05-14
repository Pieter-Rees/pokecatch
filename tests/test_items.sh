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

test_throw_berry() {
    echo "Testing throw_berry function..."
    
    # Test with no Berries
    declare -A INVENTORY
    INVENTORY["Berry"]=0
    throw_berry
    assert_equal "1" "$?" "Should return 1 when no Berries"
    
    # Test with Berries
    INVENTORY["Berry"]=1
    throw_berry
    assert_equal "0" "$?" "Should return 0 on successful throw"
    assert_equal "0" "${INVENTORY[Berry]}" "Should decrease Berry count"
    assert_equal "true" "$BERRY_THROWN" "Should set BERRY_THROWN to true"
}

test_throw_mud() {
    echo "Testing throw_mud function..."
    
    # Test with no Mud
    declare -A INVENTORY
    INVENTORY["Mud"]=0
    throw_mud
    assert_equal "1" "$?" "Should return 1 when no Mud"
    
    # Test with Mud
    INVENTORY["Mud"]=1
    throw_mud
    assert_equal "0" "$?" "Should return 0 on successful throw"
    assert_equal "0" "${INVENTORY[Mud]}" "Should decrease Mud count"
    assert_equal "true" "$MUD_THROWN" "Should set MUD_THROWN to true"
}

# Run all tests
echo "Starting tests..."
echo "================="

test_throw_ball
test_throw_berry
test_throw_mud

echo "================="
echo "Tests completed!" 