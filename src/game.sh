#!/bin/bash

# Import necessary scripts
source ./pokemon.sh
source ./items.sh
source ./status.sh
source ./shop.sh

# Initialize game data
load_progress
load_pokedex

# Function to start the Safari Zone
safari() {
    local POKEMON_ENCOUNTERED=false
    local POKEMON_ANGRY=false
    local POKEMON_EATING=false
    
    while true; do
        if [ "$POKEMON_ENCOUNTERED" = false ]; then
            echo "You are in the Safari Zone!"
            echo "[1] Look for Pokémon"
            echo "[2] Go Back"
            read -p "What will you do? " SAFARI_CHOICE
            
            case $SAFARI_CHOICE in
                1)
                    # 30% chance to encounter a Pokémon
                    if [ $((RANDOM % 100)) -lt 30 ]; then
                        POKEMON_ENCOUNTERED=true
                        get_random_pokemon
                    else
                        echo "You search the area but find no Pokémon..."
                    fi
                    ;;
                2)
                    echo "You decide to go back to the main area."
                    return
                    ;;
                *)
                    echo "Invalid choice. Please choose again."
                    ;;
            esac
        else
            echo "A wild Pokémon appears! What will you do?"
            echo "[1] Throw a Ball"
            echo "[2] Throw a Berry"
            echo "[3] Throw Mud"
            echo "[4] Run Away"
            read -p "What will you do? " SAFARI_CHOICE

            case $SAFARI_CHOICE in
                1)
                    throw_ball
                    if [ $? -eq 0 ]; then
                        POKEMON_ENCOUNTERED=false
                    fi
                    ;;
                2)
                    throw_berry
                    POKEMON_EATING=true
                    POKEMON_ANGRY=false
                    ;;
                3)
                    throw_mud
                    POKEMON_ANGRY=true
                    POKEMON_EATING=false
                    ;;
                4)
                    echo "You ran away from the wild Pokémon."
                    POKEMON_ENCOUNTERED=false
                    MUD_THROWN="false"
                    BERRY_THROWN="false"
                    ;;
                *)
                    echo "Invalid choice. Please choose again."
                    ;;
            esac
            
            # Check if Pokémon flees (higher chance if angry, lower if eating)
            if [ "$POKEMON_ENCOUNTERED" = true ]; then
                local FLEE_CHANCE=20
                if [ "$POKEMON_ANGRY" = true ]; then
                    FLEE_CHANCE=40
                elif [ "$POKEMON_EATING" = true ]; then
                    FLEE_CHANCE=10
                fi
                
                if [ $((RANDOM % 100)) -lt $FLEE_CHANCE ]; then
                    echo "The wild Pokémon fled!"
                    POKEMON_ENCOUNTERED=false
                    MUD_THROWN="false"
                    BERRY_THROWN="false"
                fi
            fi
        fi
    done
}

# Main Game Loop
while true; do
    echo "Welcome to the Safari Zone!"
    echo -e "[1] Enter Safari Zone | [2] View Pokédex | [3] Check Status | [4] Visit Shop | [5] Exit"
    read -p "What will you do? " CHOICE

    case $CHOICE in
        1)
            safari  # Enter the Safari Zone
            ;;
        2)
            show_pokedex  # View the Pokédex
            ;;
        3)
            show_status  # Check player status
            ;;
        4)
            show_shop  # Visit the shop
            ;;
        5)
            echo "Exiting the game. Goodbye!"
            save_progress  # Save game progress
            save_pokedex  # Save the Pokédex data
            exit 0
            ;;
        *)
            echo "Invalid option. Please choose again."
            ;;
    esac
done
