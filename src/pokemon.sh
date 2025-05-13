#!/bin/bash

# Fetch a random Pokémon
get_random_pokemon() {
    POKEMON_ID=$(shuf -i 1-898 -n 1)
    local MAX_RETRIES=3
    local RETRY_COUNT=0

    while [ $RETRY_COUNT -lt $MAX_RETRIES ]; do
        # Fetch Pokémon data with error handling
        RESPONSE=$(curl -s "https://pokeapi.co/api/v2/pokemon/$POKEMON_ID")
        
        # Check if the response is valid JSON
        if echo "$RESPONSE" | jq empty 2>/dev/null; then
            # Extract Pokémon name and image URL with error handling
            POKEMON_NAME=$(echo "$RESPONSE" | jq -r '.name // empty')
            POKEMON_IMAGE_URL=$(echo "$RESPONSE" | jq -r '.sprites.front_default // empty')

            if [[ -n "$POKEMON_NAME" && -n "$POKEMON_IMAGE_URL" ]]; then
                # Download and display the Pokémon image
                TEMP_IMAGE=$(mktemp /tmp/pokemon_image.XXXXXX.png)
                if curl -s -o "$TEMP_IMAGE" "$POKEMON_IMAGE_URL"; then
                    if command -v catimg >/dev/null 2>&1; then
                        catimg -w 40 "$TEMP_IMAGE"
                    else
                        echo "Note: Install 'catimg' to see Pokémon sprites"
                    fi
                fi
                rm -f "$TEMP_IMAGE"

                echo "A wild $POKEMON_NAME appeared!"
                return 0
            fi
        fi

        RETRY_COUNT=$((RETRY_COUNT + 1))
        if [ $RETRY_COUNT -lt $MAX_RETRIES ]; then
            echo "Retrying... (Attempt $((RETRY_COUNT + 1)) of $MAX_RETRIES)"
            sleep 1  # Wait a second before retrying
            POKEMON_ID=$(shuf -i 1-898 -n 1)  # Get a new random Pokémon ID
        fi
    done

    echo "Error: Failed to fetch Pokémon data after $MAX_RETRIES attempts. Please try again."
    return 1
}

# Catch the Pokémon
catch_pokemon() {
    local POKEMON_NAME=$1
    local CATCH_PROBABILITY=$2
    local THROW_ATTEMPT=0
    local MAX_ATTEMPTS=3

    while [ $THROW_ATTEMPT -lt $MAX_ATTEMPTS ]; do
        THROW_ATTEMPT=$((THROW_ATTEMPT + 1))
        RANDOM_CATCH=$((RANDOM % 100))

        echo -n "Throwing the Pokeball... "

        if [[ $RANDOM_CATCH -lt $CATCH_PROBABILITY ]]; then
            echo "You caught the $POKEMON_NAME!"
            add_to_pokedex "$POKEMON_NAME"
            MONEY=$((MONEY + 100))
            return 0
        else
            echo "The Pokeball failed! Attempt #$THROW_ATTEMPT."
        fi
    done

    echo "The $POKEMON_NAME escaped!"
    return 1
}

# Add Pokémon to Pokédex
add_to_pokedex() {
    local POKEMON_NAME=$1
    
    # Check if Pokémon is already in Pokédex
    if [[ ! " ${CAUGHT_POKEMON[@]} " =~ " ${POKEMON_NAME} " ]]; then
        CAUGHT_POKEMON+=("$POKEMON_NAME")
        save_pokedex
    fi
}
