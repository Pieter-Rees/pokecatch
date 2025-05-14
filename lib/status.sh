#!/bin/bash

# ============================================================================
# Global Variables
# ============================================================================
declare -A INVENTORY

# ============================================================================
# Save/Load Functions
# ============================================================================

# Load progress from save.json
load_progress() {
    # Create data directory if it doesn't exist
    mkdir -p data

    if [[ -f "data/save.json" ]]; then
        # Load money
        MONEY=$(jq -r '.money // 1000' data/save.json)
        
        # Load inventory items
        if jq -e '.inventory' data/save.json >/dev/null 2>&1; then
            while IFS="=" read -r key value; do
                if [[ -n "$key" && -n "$value" ]]; then
                    INVENTORY["$key"]=$value
                fi
            done < <(jq -r '.inventory | to_entries | .[] | "\(.key)=\(.value)"' data/save.json)
        fi
    else
        MONEY=1000
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

    # Create and save the complete JSON
    jq -n \
        --arg money "$MONEY" \
        --argjson inventory "$inventory_json" \
        '{
            "money": ($money|tonumber),
            "inventory": $inventory
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
        CAUGHT_pocket_monster=$(jq -r '.pokedex' data/pokedex.json)
    else
        CAUGHT_pocket_monster=()
    fi
}

# Save Pokédex to pokedex.json
save_pokedex() {
    # Create data directory if it doesn't exist
    mkdir -p data

    # Save the pokedex array into pokedex.json
    echo "{\"pokedex\": ${CAUGHT_pocket_monster[@]}}" > data/pokedex.json
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
