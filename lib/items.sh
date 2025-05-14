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

    # Decrease ball count
    INVENTORY["Pokeball"]=$((INVENTORY["Pokeball"] - 1))
    save_progress  # Save after using a Pokeball
    
    # Calculate catch probability
    local CATCH_RATE=30  # Base catch rate (from original games)
    
    # Modify catch rate based on Monster's status
    if [[ "$pocket_monster_EATING" == "true" ]]; then
        CATCH_RATE=$((CATCH_RATE * 2))  # Double catch rate when eating
    elif [[ "$pocket_monster_ANGRY" == "true" ]]; then
        CATCH_RATE=$((CATCH_RATE / 2))  # Halve catch rate when angry
    fi
    
    # Calculate final catch probability
    local CATCH_PROBABILITY=$((CATCH_RATE * 100 / 255))
    
    # Attempt to catch
    if [ $((RANDOM % 100)) -lt $CATCH_PROBABILITY ]; then
        print_success "Gotcha! The Monster was caught!"
        catch_monster "$pocket_monster_NAME" $CATCH_PROBABILITY
        return 0
    else
        print_warning "Oh no! The Monster broke free!"
        return 1
    fi
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
    BERRY_THROWN="true"
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
    MUD_THROWN="true"
    return 0
}
