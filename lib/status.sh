#!/bin/bash

# ============================================================================
# Global Variables
# ============================================================================
declare -A INVENTORY
declare -A ENCOUNTER_STATS=(
    ["total_encounters"]=0
    ["successful_catches"]=0
    ["failed_catches"]=0
    ["fled"]=0
)

# ============================================================================
# Configuration Loading
# ============================================================================

# Load game configuration
load_config() {
    if [[ -f "config/game_config.json" ]]; then
        STARTING_MONEY=$(jq -r '.starting_money' config/game_config.json)
        CURRENCY_NAME=$(jq -r '.currency_name' config/game_config.json)
        MIN_MONEY=$(jq -r '.min_money' config/game_config.json)
        MAX_MONEY=$(jq -r '.max_money' config/game_config.json)
    else
        # Default values if config file is missing
        STARTING_MONEY=1000
        CURRENCY_NAME="PokéDollars"
        MIN_MONEY=0
        MAX_MONEY=999999
    fi
}

# ============================================================================
# Save/Load Functions
# ============================================================================

# Load progress from save.json
load_progress() {
    # Create data directory if it doesn't exist
    mkdir -p data

    # Load configuration first
    load_config

    if [[ -f "data/save.json" ]]; then
        # Load money
        MONEY=$(jq -r --arg default "$STARTING_MONEY" '.money // $default' data/save.json)
        MONEY=${MONEY:-$STARTING_MONEY}  # Ensure MONEY is set
        MONEY=$((MONEY))  # Convert to number
        
        # Load inventory items
        if jq -e '.inventory' data/save.json >/dev/null 2>&1; then
            while IFS="=" read -r key value; do
                if [[ -n "$key" && -n "$value" ]]; then
                    INVENTORY["$key"]=$value
                fi
            done < <(jq -r '.inventory | to_entries | .[] | "\(.key)=\(.value)"' data/save.json)
        fi

        # Load encounter statistics
        if jq -e '.encounter_stats' data/save.json >/dev/null 2>&1; then
            while IFS="=" read -r key value; do
                if [[ -n "$key" && -n "$value" ]]; then
                    ENCOUNTER_STATS["$key"]=$value
                fi
            done < <(jq -r '.encounter_stats | to_entries | .[] | "\(.key)=\(.value)"' data/save.json)
        fi
    else
        MONEY=$STARTING_MONEY
    fi
}

# Save progress to save.json
save_progress() {
    # Create data directory if it doesn't exist
    mkdir -p data

    # Create inventory JSON object
    local inventory_json="{}"
    for item in "${!INVENTORY[@]}"; do
        if [[ -n "$item" && -n "${INVENTORY[$item]}" ]]; then
            inventory_json=$(echo "$inventory_json" | jq --arg key "$item" --arg value "${INVENTORY[$item]}" '. + {($key): ($value|tonumber)}')
        fi
    done

    # Create encounter stats JSON object
    local encounter_stats_json="{}"
    for stat in "${!ENCOUNTER_STATS[@]}"; do
        if [[ -n "$stat" && -n "${ENCOUNTER_STATS[$stat]}" ]]; then
            encounter_stats_json=$(echo "$encounter_stats_json" | jq --arg key "$stat" --arg value "${ENCOUNTER_STATS[$stat]}" '. + {($key): ($value|tonumber)}')
        fi
    done

    # Create and save the complete JSON
    jq -n \
        --arg money "$MONEY" \
        --argjson inventory "$inventory_json" \
        --argjson encounter_stats "$encounter_stats_json" \
        '{
            "money": ($money|tonumber),
            "inventory": $inventory,
            "encounter_stats": $encounter_stats
        }' > data/save.json
}

# ============================================================================
# Pokédex Management
# ============================================================================

# Load Pokédex from pokedex.json
load_pokedex() {
    # Create data directory if it doesn't exist
    mkdir -p data

    if [[ -f "data/pokedex.json" ]]; then
        CAUGHT_MONSTER=($(jq -r '.pokedex[]' data/pokedex.json))
        # Load monster stats
        while IFS="=" read -r key value; do
            if [[ -n "$key" && -n "$value" ]]; then
                MONSTER_STATS_ARRAY["$key"]="$value"
            fi
        done < <(jq -r '.monster_stats | to_entries | .[] | "\(.key)=\(.value)"' data/pokedex.json)
    else
        CAUGHT_MONSTER=()
        declare -A MONSTER_STATS_ARRAY
    fi
}

# Save Pokédex to pokedex.json
save_pokedex() {
    # Create data directory if it doesn't exist
    mkdir -p data

    # Create monster stats JSON object
    local monster_stats_json="{}"
    for monster in "${!MONSTER_STATS_ARRAY[@]}"; do
        if [[ -n "$monster" && -n "${MONSTER_STATS_ARRAY[$monster]}" ]]; then
            monster_stats_json=$(echo "$monster_stats_json" | jq --arg key "$monster" --arg value "${MONSTER_STATS_ARRAY[$monster]}" '. + {($key): $value}')
        fi
    done

    # Save the pokedex array and monster stats into pokedex.json
    jq -n \
        --argjson pokedex "$(printf '%s\n' "${CAUGHT_MONSTER[@]}" | jq -R . | jq -s .)" \
        --argjson monster_stats "$monster_stats_json" \
        '{
            "pokedex": $pokedex,
            "monster_stats": $monster_stats
        }' > data/pokedex.json
}

# ============================================================================
# Status Display Functions
# ============================================================================

# Show current player status (Money, Caught Pocket Monsters, Inventory)
show_status() {
    print_header
    print_money
    print_divider
    echo -e "${CYAN}Caught Pocket Monsters:${NC} ${#CAUGHT_pocket_monster[@]}"
    print_divider
    echo -e "${CYAN}Encounter Statistics:${NC}"
    echo -e "  Total Encounters: ${ENCOUNTER_STATS["total_encounters"]}"
    echo -e "  Successful Catches: ${ENCOUNTER_STATS["successful_catches"]}"
    echo -e "  Failed Catches: ${ENCOUNTER_STATS["failed_catches"]}"
    echo -e "  Fled: ${ENCOUNTER_STATS["fled"]}"
    if [ ${ENCOUNTER_STATS["total_encounters"]} -gt 0 ]; then
        local catch_rate=$((ENCOUNTER_STATS["successful_catches"] * 100 / ENCOUNTER_STATS["total_encounters"]))
        echo -e "  Catch Rate: ${catch_rate}%"
    fi
    print_divider
    echo -e "${CYAN}Pokédex:${NC}"
    for pocket_monster in "${CAUGHT_pocket_monster[@]}"; do
        echo -e "  $pocket_monster"
    done
    print_divider
    echo -e "${CYAN}Inventory:${NC}"
    for item in "${!INVENTORY[@]}"; do
        print_inventory_item "$item" "${INVENTORY[$item]}"
    done
    print_divider
}

# Show Pokédex contents
show_pokedex() {
    print_header
    if [ ${#CAUGHT_pocket_monster[@]} -eq 0 ]; then
        print_warning "Your Pocket Monster dex is empty. Go catch some Pocket Monsters!"
        return
    fi

    echo -e "${PURPLE}╔══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${PURPLE}║${NC}  ${pocket_monster_DEX} Your Pokédex ${pocket_monster_DEX}  ${PURPLE}║${NC}"
    echo -e "${PURPLE}╚══════════════════════════════════════════════════════════╝${NC}"
    print_divider
    echo -e "${CYAN}Total Pocket Monsters caught:${NC} ${#CAUGHT_pocket_monster[@]}"
    print_divider
    for pocket_monster in "${CAUGHT_pocket_monster[@]}"; do
        echo -e "  $pocket_monster"
    done
    print_divider
}

# Print the current money amount
print_money() {
    echo -e "${GREEN}$MONEY $CURRENCY_NAME${NC}"
}
