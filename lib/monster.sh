#!/bin/bash

# ============================================================================
# Monster Encounter Functions
# ============================================================================

# Fetch and display a random Monster from the PokeAPI
get_random_monster() {
    MONSTER_ID=$(shuf -i 1-898 -n 1)
    local MAX_RETRIES=3
    local RETRY_COUNT=0

    while [ $RETRY_COUNT -lt $MAX_RETRIES ]; do
        # Fetch Monster data with error handling
        RESPONSE=$(curl -s "https://pokeapi.co/api/v2/pokemon/$MONSTER_ID")
        
        # Check if the response is valid JSON
        if echo "$RESPONSE" | jq empty 2>/dev/null; then
            # Extract Monster name, image URL, and stats with error handling
            MONSTER_NAME=$(echo "$RESPONSE" | jq -r '.name // empty')
            MONSTER_IMAGE_URL=$(echo "$RESPONSE" | jq -r '.sprites.front_default // empty')
            # Store stats in a more reliable format
            MONSTER_STATS=$(echo "$RESPONSE" | jq -r '.stats[] | "\(.stat.name): \(.base_stat)"' | tr '\n' '|')

            if [[ -n "$MONSTER_NAME" && -n "$MONSTER_IMAGE_URL" && -n "$MONSTER_STATS" ]]; then
                # Increment total encounters
                ENCOUNTER_STATS["total_encounters"]=$((ENCOUNTER_STATS["total_encounters"] + 1))
                save_progress
                # Export MONSTER_STATS to make it available to child processes
                export MONSTER_STATS
                display_monster "$MONSTER_NAME" "$MONSTER_IMAGE_URL" "$MONSTER_STATS"
                return 0
            fi
        fi

        RETRY_COUNT=$((RETRY_COUNT + 1))
        if [ $RETRY_COUNT -lt $MAX_RETRIES ]; then
            print_warning "Retrying... (Attempt $((RETRY_COUNT + 1)) of $MAX_RETRIES)"
            sleep 1  # Wait a second before retrying
            MONSTER_ID=$(shuf -i 1-898 -n 1)  # Get a new random Monster ID
        fi
    done

    print_error "Failed to fetch Monster data after $MAX_RETRIES attempts. Please try again."
    return 1
}

# Display the Monster image and encounter message
display_monster() {
    MONSTER_NAME=$1
    MONSTER_IMAGE_URL=$2
    MONSTER_STATS=$3

    # Create a temporary directory for images if it doesn't exist
    mkdir -p /tmp/monster_images
    
    # Download and display the Monster image
    TEMP_IMAGE="/tmp/monster_images/${MONSTER_NAME}.png"
    if curl -s -o "$TEMP_IMAGE" "$MONSTER_IMAGE_URL"; then
        if command -v catimg >/dev/null 2>&1; then
            # Clear the screen for a better presentation
            clear
            print_header
            print_divider
            # Center the Monster image
            echo
            catimg -w 40 "$TEMP_IMAGE" | sed 's/^/    /'
            echo
            print_divider
            # Capitalize first letter of Monster name
            MONSTER_NAME=$(echo "$MONSTER_NAME" | sed 's/^./\U&/')
            print_pocket_monster_encounter "$MONSTER_NAME"
            
            # Display Monster stats
            echo -e "${CYAN}Stats:${NC}"
            echo "$MONSTER_STATS" | tr '|' '\n' | while IFS=':' read -r stat_name stat_value; do
                # Capitalize and format stat name
                stat_name=$(echo "$stat_name" | sed 's/^./\U&/')
                echo -e "  ${YELLOW}$stat_name${NC}: $stat_value"
            done
            
            print_divider
        else
            print_warning "Note: Install 'catimg' to see Monster sprites"
            print_pocket_monster_encounter "$MONSTER_NAME"
        fi
    fi
}

# ============================================================================
# Monster Capture Functions
# ============================================================================

# Attempt to catch the Monster with a Pokeball
catch_monster() {
    local MONSTER_NAME=$1
    local CATCH_PROBABILITY=$2
    local THROW_ATTEMPT=$3  # Now passed from throw_ball

    RANDOM_CATCH=$((RANDOM % 100))
    print_loading "Throwing the Pokeball"

    if [[ $RANDOM_CATCH -lt $CATCH_PROBABILITY ]]; then
        # Ensure MONSTER_STATS is available
        if [[ -z "$MONSTER_STATS" ]]; then
            print_warning "No stats available for $MONSTER_NAME"
            return 1
        fi
        # Pass the stats to add_to_pokedex
        add_to_pokedex "$MONSTER_NAME" "$MONSTER_STATS"
        # Increment successful catches
        ENCOUNTER_STATS["successful_catches"]=$((ENCOUNTER_STATS["successful_catches"] + 1))
        save_progress
        # Add reward money, respecting max money limit
        local REWARD=100
        MONEY=$((MONEY + REWARD))
        if [ $MONEY -gt $MAX_MONEY ]; then
            MONEY=$MAX_MONEY
        fi
        save_progress  # Save after adding money
        return 0  # Return success
    else
        print_warning "The Pokeball failed! Attempt #$THROW_ATTEMPT."
        # Increment failed catches
        ENCOUNTER_STATS["failed_catches"]=$((ENCOUNTER_STATS["failed_catches"] + 1))
        save_progress
        return 1
    fi
}

# ============================================================================
# Pokédex Management
# ============================================================================

# Add a caught Monster to the Pokédex
add_to_pokedex() {
    local MONSTER_NAME=$1
    local MONSTER_STATS=$2
    
    # Check if Monster is already in Pokédex
    if [[ ! " ${CAUGHT_MONSTER[@]} " =~ " ${MONSTER_NAME} " ]]; then
        CAUGHT_MONSTER+=("$MONSTER_NAME")
        # Save stats to a separate array
        if [[ -n "$MONSTER_STATS" ]]; then
            MONSTER_STATS_ARRAY["$MONSTER_NAME"]="$MONSTER_STATS"
            save_pokedex
        else
            print_warning "No stats available for $MONSTER_NAME"
        fi
    fi
}
