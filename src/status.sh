#!/bin/bash

# Load progress from save.json
load_progress() {
    # Create data directory if it doesn't exist
    mkdir -p data

    if [[ -f "data/save.json" ]]; then
        MONEY=$(jq -r '.money' data/save.json)
        declare -A INVENTORY
        INVENTORY_JSON=$(jq -r '.inventory' data/save.json)
        
        # Parse inventory JSON into an associative array
        for item in $(echo "$INVENTORY_JSON" | jq -r 'keys | .[]'); do
            INVENTORY["$item"]=$(echo "$INVENTORY_JSON" | jq -r ".[\"$item\"]")
        done
    else
        MONEY=1000
        declare -A INVENTORY
    fi
}

# Save progress to save.json
save_progress() {
    # Create data directory if it doesn't exist
    mkdir -p data

    # Create JSON data to save
    INVENTORY_JSON=$(jq -n '{'"$(for item in "${!INVENTORY[@]}"; do echo "\"$item\": ${INVENTORY[$item]},"; done | sed 's/,$//')"'}')
    
    echo "{
        \"money\": $MONEY,
        \"inventory\": $INVENTORY_JSON
    }" > data/save.json
}

# Load Pokédex from pokedex.json
load_pokedex() {
    # Create data directory if it doesn't exist
    mkdir -p data

    if [[ -f "data/pokedex.json" ]]; then
        CAUGHT_POKEMON=$(jq -r '.pokedex' data/pokedex.json)
    else
        CAUGHT_POKEMON=()
    fi
}

# Save Pokédex to pokedex.json
save_pokedex() {
    # Create data directory if it doesn't exist
    mkdir -p data

    # Save the pokedex array into pokedex.json
    echo "{\"pokedex\": ${CAUGHT_POKEMON[@]}}" > data/pokedex.json
}

# Show current player status (Money, Caught Pokémon, Inventory)
show_status() {
    echo "💰 Money: \$${MONEY}"
    echo "Caught Pokémon: ${#CAUGHT_POKEMON[@]}"
    echo "Pokédex: ${CAUGHT_POKEMON[@]}"
    echo "Inventory: "
    for item in "${!INVENTORY[@]}"; do
        echo "$item: ${INVENTORY[$item]}"
    done
}

# Show Pokédex contents
show_pokedex() {
    if [ ${#CAUGHT_POKEMON[@]} -eq 0 ]; then
        echo "Your Pokédex is empty. Go catch some Pokémon!"
        return
    fi

    echo "=== Your Pokédex ==="
    echo "Total Pokémon caught: ${#CAUGHT_POKEMON[@]}"
    echo "-------------------"
    for pokemon in "${CAUGHT_POKEMON[@]}"; do
        echo "• $pokemon"
    done
    echo "-------------------"
}
