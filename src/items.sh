#!/bin/bash

# Throw a Safari Ball to catch Pokémon
throw_ball() {
    if [[ ${INVENTORY["Pokeball"]} -le 0 ]]; then
        echo "You don't have any Pokeballs left!"
        return 1
    fi

    # Decrease ball count
    INVENTORY["Pokeball"]=$((INVENTORY["Pokeball"] - 1))
    
    # Base catch rate (from original games)
    local CATCH_RATE=30
    
    # Modify catch rate based on status
    if [[ "$POKEMON_EATING" == "true" ]]; then
        CATCH_RATE=$((CATCH_RATE * 2))  # Double catch rate when eating
    elif [[ "$POKEMON_ANGRY" == "true" ]]; then
        CATCH_RATE=$((CATCH_RATE / 2))  # Halve catch rate when angry
    fi
    
    # Calculate final catch probability
    local CATCH_PROBABILITY=$((CATCH_RATE * 100 / 255))
    
    # Attempt to catch
    if [ $((RANDOM % 100)) -lt $CATCH_PROBABILITY ]; then
        echo "Gotcha! The Pokémon was caught!"
        catch_pokemon "$POKEMON_NAME" $CATCH_PROBABILITY
        return 0
    else
        echo "Oh no! The Pokémon broke free!"
        return 1
    fi
}

# Throw a Berry to make the Pokémon eat
throw_berry() {
    if [[ ${INVENTORY["Berry"]} -le 0 ]]; then
        echo "You don't have any Berries left!"
        return 1
    fi

    # Decrease berry count
    INVENTORY["Berry"]=$((INVENTORY["Berry"] - 1))
    
    echo "You threw a Berry!"
    echo "The wild Pokémon is eating the Berry..."
    BERRY_THROWN="true"
    return 0
}

# Throw Mud to make the Pokémon angry
throw_mud() {
    if [[ ${INVENTORY["Mud"]} -le 0 ]]; then
        echo "You don't have any Mud left!"
        return 1
    fi

    # Decrease mud count
    INVENTORY["Mud"]=$((INVENTORY["Mud"] - 1))
    
    echo "You threw Mud!"
    echo "The wild Pokémon is getting angry..."
    MUD_THROWN="true"
    return 0
}
