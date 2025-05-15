#!/bin/bash

# ============================================================================
# Item Usage Functions
# ============================================================================

# Throw a Safari Ball to catch Monster
throw_ball() {
    # Check if player has Pokeballs
    if [[ ${INVENTORY["Pokeball"]} -le 0 ]]; then
        print_error "You don't have any Pokeballs left!"
        return 2  # Special return code for no Pokeballs
    fi

    # Initialize or increment throw attempt counter
    if [[ -z "$THROW_ATTEMPT" ]]; then
        THROW_ATTEMPT=1
    else
        THROW_ATTEMPT=$((THROW_ATTEMPT + 1))
    fi

    # Decrease ball count
    INVENTORY["Pokeball"]=$((INVENTORY["Pokeball"] - 1))
    save_progress  # Save after using a Pokeball
    
    # Calculate catch probability
    local CATCH_RATE=30  # Base catch rate (from original games)
    
    # Modify catch rate based on Monster's status
    if [[ "$MONSTER_EATING" == "true" ]]; then
        CATCH_RATE=$((CATCH_RATE * 2))  # Double catch rate when eating
    elif [[ "$MONSTER_ANGRY" == "true" ]]; then
        CATCH_RATE=$((CATCH_RATE / 2))  # Halve catch rate when angry
    fi
    
    # Calculate final catch probability
    local CATCH_PROBABILITY=$((CATCH_RATE * 100 / 255))
    
    # Attempt to catch
    if catch_monster "$MONSTER_NAME" $CATCH_PROBABILITY $THROW_ATTEMPT; then
        print_success "Gotcha! The $MONSTER_NAME was caught!"
        THROW_ATTEMPT=0  # Reset for next encounter
        return 0  # Return success
    fi
    return 1  # Return failure
}

# Throw a Berry to make the Monster eat
throw_berry() {
    # Check if player has Berries
    if [[ ${INVENTORY["Berry"]} -le 0 ]]; then
        print_error "You don't have any Berries left!"
        return 1
    fi

    # Decrease berry count
    INVENTORY["Berry"]=$((INVENTORY["Berry"] - 1))
    save_progress  # Save after using a Berry
    
    print_success "You threw a Berry!"
    print_warning "The wild Monster is eating the Berry..."
    MONSTER_EATING="true"
    return 0
}

# Throw Mud to make the Monster angry
throw_mud() {
    # Check if player has Mud
    if [[ ${INVENTORY["Mud"]} -le 0 ]]; then
        print_error "You don't have any Mud left!"
        return 1
    fi

    # Decrease mud count
    INVENTORY["Mud"]=$((INVENTORY["Mud"] - 1))
    save_progress  # Save after using Mud
    
    print_success "You threw Mud!"
    print_warning "The wild Monster is getting angry..."
    MONSTER_ANGRY="true"
    return 0
}
