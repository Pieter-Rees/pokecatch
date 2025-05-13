#!/bin/bash

# Define a collection to store caught Pokémon and money
declare -A POKEDEX
MONEY=1000  # Starting money
CAUGHT_POKEMON=()  # List of caught Pokémon

# Function to fetch a random Pokémon
get_random_pokemon() {
    # Get a random Pokémon ID (1-898)
    POKEMON_ID=$(shuf -i 1-898 -n 1)

    # Fetch the Pokémon data from the API
    RESPONSE=$(curl -s https://pokeapi.co/api/v2/pokemon/$POKEMON_ID)

    # Check if the response is empty
    if [[ -z "$RESPONSE" ]]; then
        echo "Failed to fetch data for Pokémon ID $POKEMON_ID. The response is empty."
        exit 1
    fi

    # Check if the response contains the 'name' and 'sprites' fields
    if echo "$RESPONSE" | jq -e '.name' >/dev/null && echo "$RESPONSE" | jq -e '.sprites.front_default' >/dev/null; then
        # Get the Pokémon name and image URL
        POKEMON_NAME=$(echo "$RESPONSE" | jq -r '.name')
        POKEMON_IMAGE_URL=$(echo "$RESPONSE" | jq -r '.sprites.front_default')

        # Download the Pokémon image to a temporary file
        TEMP_IMAGE=$(mktemp /tmp/pokemon_image.XXXXXX.png)
        curl -s -o $TEMP_IMAGE $POKEMON_IMAGE_URL

        # Display the Pokémon image using catimg with smaller width (e.g., 40 columns)
        catimg -w 40 $TEMP_IMAGE

        # Remove the temporary image file
        rm $TEMP_IMAGE

        # Print the Pokémon name
        echo "A wild $POKEMON_NAME appeared!"
    else
        echo "Failed to fetch valid Pokémon data for ID $POKEMON_ID. Response: $RESPONSE"
        exit 1
    fi
}

# Function to simulate catching the Pokémon
catch_pokemon() {
    local POKEMON_NAME=$1
    local CATCH_PROBABILITY=$2
    local THROW_ATTEMPT=0
    local MAX_ATTEMPTS=3

    # Simulate throwing a ball
    while [ $THROW_ATTEMPT -lt $MAX_ATTEMPTS ]; do
        THROW_ATTEMPT=$((THROW_ATTEMPT + 1))
        RANDOM_CATCH=$((RANDOM % 100))
        
        echo -n "Throwing the Pokéball... "

        if [[ $RANDOM_CATCH -lt $CATCH_PROBABILITY ]]; then
            echo "You caught the $POKEMON_NAME!"
            CAUGHT_POKEMON+=("$POKEMON_NAME")
            POKEDEX["$POKEMON_NAME"]=1
            MONEY=$((MONEY + 100))  # Reward for catching Pokémon
            return 0
        else
            echo "The Pokéball failed! Attempt #$THROW_ATTEMPT."
        fi
    done

    echo "The $POKEMON_NAME escaped! Try again next time."
    return 1
}

# Function for throwing Bait (increases catch chance)
throw_bait() {
    echo "You threw Bait! The Pokémon seems interested..."
}

# Function for throwing Mud (increases catch chance and may cause Pokémon to flee)
throw_mud() {
    echo "You threw Mud! The Pokémon got annoyed..."
    local FLEE_CHANCE=$((RANDOM % 100))
    if [[ $FLEE_CHANCE -lt 30 ]]; then
        echo "The Pokémon fled in anger!"
        return 2
    else
        return 0
    fi
}

# Function to show the player's current status (money, caught Pokémon)
show_status() {
    echo "💰 Money: \$${MONEY}"
    echo "Caught Pokémon: ${#CAUGHT_POKEMON[@]}"
    echo "Pokédex: ${!POKEDEX[@]}"
}

# Function to handle Safari Zone actions
safari() {
    get_random_pokemon
    local POKEMON_NAME=$POKEMON_NAME
    local CATCH_PROBABILITY=30  # 30% base catch rate

    # Main safari encounter loop
    while true; do
        echo -e "[1] 🎯 Throw Ball | [2] 🍓 Throw Bait | [3] 💩 Throw Mud | [4] 🏃‍♂️ Run | [5] 🔙 Go Back"
        read -p "What will you do? " ACTION

        case $ACTION in
            1)
                catch_pokemon "$POKEMON_NAME" "$CATCH_PROBABILITY"
                if [[ $? -eq 0 ]]; then
                    break  # Break if the Pokémon is caught
                fi
                ;;
            2)
                throw_bait
                CATCH_PROBABILITY=$((CATCH_PROBABILITY + 20))  # Increase catch chance
                ;;
            3)
                throw_mud
                if [[ $? -eq 2 ]]; then
                    break  # Break if the Pokémon fled
                else
                    CATCH_PROBABILITY=$((CATCH_PROBABILITY + 15))  # Increase catch chance
                fi
                ;;
            4)
                echo "🏃 You ran away in panic!"
                break  # End encounter if the player runs away
                ;;
            5)
                echo "🔙 You carefully backed away."
                break  # Go back to the previous menu
                ;;
            *)
                echo "Invalid option! Please choose a valid action."
                ;;
        esac
    done
}

# Main Game Loop
while true; do
    echo "Welcome to the Safari Zone!"
    echo -e "[1] Enter Safari Zone | [2] View Pokédex | [3] Check Status | [4] Exit"
    read -p "What will you do? " CHOICE

    case $CHOICE in
        1)
            safari  # Enter the Safari Zone
            ;;
        2)
            echo "Pokédex: ${!POKEDEX[@]}"
            ;;
        3)
            show_status
            ;;
        4)
            echo "Exiting the game. Goodbye!"
            exit 0
            ;;
        *)
            echo "Invalid option. Please choose again."
            ;;
    esac
done
