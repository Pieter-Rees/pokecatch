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
                # Create a temporary directory for images if it doesn't exist
                mkdir -p /tmp/pokemon_images
                
                # Download and display the Pokémon image
                TEMP_IMAGE="/tmp/pokemon_images/${POKEMON_NAME}.png"
                if curl -s -o "$TEMP_IMAGE" "$POKEMON_IMAGE_URL"; then
                    if command -v catimg >/dev/null 2>&1; then
                        # Clear the screen for a better presentation
                        clear
                        print_header
                        print_divider
                        # Center the Pokemon image
                        echo
                        catimg -w 40 "$TEMP_IMAGE" | sed 's/^/    /'
                        echo
                        print_divider
                        # Capitalize first letter of Pokemon name
                        POKEMON_NAME=$(echo "$POKEMON_NAME" | sed 's/^./\U&/')
                        print_pokemon_encounter "$POKEMON_NAME"
                        print_divider
                    else
                        print_warning "Note: Install 'catimg' to see Pokémon sprites"
                        print_pokemon_encounter "$POKEMON_NAME"
                    fi
                fi
                return 0
            fi
        fi

        RETRY_COUNT=$((RETRY_COUNT + 1))
        if [ $RETRY_COUNT -lt $MAX_RETRIES ]; then
            print_warning "Retrying... (Attempt $((RETRY_COUNT + 1)) of $MAX_RETRIES)"
            sleep 1  # Wait a second before retrying
            POKEMON_ID=$(shuf -i 1-898 -n 1)  # Get a new random Pokémon ID
        fi
    done

    print_error "Failed to fetch Pokémon data after $MAX_RETRIES attempts. Please try again."
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

        print_loading "Throwing the Pokeball"

        if [[ $RANDOM_CATCH -lt $CATCH_PROBABILITY ]]; then
            print_success "Gotcha! The $POKEMON_NAME was caught!"
            add_to_pokedex "$POKEMON_NAME"
            MONEY=$((MONEY + 100))
            return 0
        else
            print_warning "The Pokeball failed! Attempt #$THROW_ATTEMPT."
        fi
    done

    print_error "The $POKEMON_NAME escaped!"
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
