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
        CATCH_RATE=$((CATCH_RATE / 2))  # Halve catch rate when eating
    elif [[ "$MONSTER_ANGRY" == "true" ]]; then
        CATCH_RATE=$((CATCH_RATE * 2))  # Double catch rate when angry
    fi
    
    # Calculate final catch probability
    local CATCH_PROBABILITY=$((CATCH_RATE * 100 / 255))
    
    # Attempt to catch
    if [ $((RANDOM % 100)) -lt $CATCH_PROBABILITY ]; then
        print_success "Gotcha! The Monster was caught!"
        catch_pocket_monster "$MONSTER_NAME" $CATCH_PROBABILITY
        return 0
    else
        print_warning "Oh no! The Monster broke free!"
        return 1
    fi
    return 1  # Return failure
}

# Throw a Rock to make the Monster angry
throw_rock() {
    # Check if player has Rocks
    if [[ ${INVENTORY["Rock"]} -le 0 ]]; then
        print_error "You don't have any Rocks left!"
        return 1
    fi

    # Decrease rock count
    INVENTORY["Rock"]=$((INVENTORY["Rock"] - 1))
    save_progress  # Save after using a Rock
    
    print_success "You threw a Rock!"
    print_warning "The wild Monster is getting angry..."
    MONSTER_ANGRY="true"
    return 0
}

# Throw Bait to make the Monster eat
throw_bait() {
    # Check if player has Bait
    if [[ ${INVENTORY["Bait"]} -le 0 ]]; then
        print_error "You don't have any Bait left!"
        return 1
    fi

    # Decrease bait count
    INVENTORY["Bait"]=$((INVENTORY["Bait"] - 1))
    save_progress  # Save after using Bait
    
    print_success "You threw Bait!"
    print_warning "The wild Monster is eating the Bait..."
    MONSTER_EATING="true"
    return 0
}
