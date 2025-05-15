#!/bin/bash

# Source required modules
source lib/core/config.sh
source lib/utils/json_utils.sh
source lib/display/ui.sh

# ============================================================================
# Global Variables
# ============================================================================
declare -A inventory
declare -A encounter_stats=(
    ["total_encounters"]=0
    ["successful_catches"]=0
    ["failed_catches"]=0
    ["fled"]=0
)
declare -A monster_stats_array
declare -a caught_monster

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
    mkdir -p "$DATA_DIR"
    
    # Load configuration first
    load_config
    
    if [[ -f "$DATA_DIR/save.json" ]]; then
        # Load money
        money=$(jq -r --arg default "$(get_config 'starting_money' 1000)" '.money // $default' "$DATA_DIR/save.json")
        money=${money:-$(get_config 'starting_money' 1000)}
        money=$((money))
        
        # Load inventory items
        if jq -e '.inventory' "$DATA_DIR/save.json" >/dev/null 2>&1; then
            json_to_array inventory "$(jq -r '.inventory' "$DATA_DIR/save.json")"
        fi
        
        # Load encounter statistics
        if jq -e '.encounter_stats' "$DATA_DIR/save.json" >/dev/null 2>&1; then
            json_to_array encounter_stats "$(jq -r '.encounter_stats' "$DATA_DIR/save.json")"
        fi
    else
        # Initialize new game state
        money=$(get_config 'starting_money' 1000)
        
        # Initialize inventory with starting items from config
        if jq -e '.starting_items' "config/game_config.json" >/dev/null 2>&1; then
            json_to_array inventory "$(jq -r '.starting_items' "config/game_config.json")"
        fi
        
        # Initialize encounter statistics
        encounter_stats["total_encounters"]=0
        encounter_stats["successful_catches"]=0
        encounter_stats["failed_catches"]=0
        encounter_stats["fled"]=0
        
        # Save initial state
        save_progress
    fi
}

# Save progress to save.json
save_progress() {
    # Create data directory if it doesn't exist
    mkdir -p "$DATA_DIR"
    
    # Convert arrays to JSON
    local inventory_json=$(array_to_json inventory)
    local encounter_stats_json=$(array_to_json encounter_stats)
    
    # Create and save the complete JSON
    if ! jq -n \
        --arg money "$money" \
        --argjson inventory "$inventory_json" \
        --argjson encounter_stats "$encounter_stats_json" \
        '{
            "money": ($money|tonumber),
            "inventory": $inventory,
            "encounter_stats": $encounter_stats
        }' > "$DATA_DIR/save.json"; then
        print_error "Failed to save progress"
        return 1
    fi
    return 0
}

# ============================================================================
# Pokédex Management
# ============================================================================

# Load Pokédex from pokedex.json
load_pokedex() {
    # Create data directory if it doesn't exist
    mkdir -p "$DATA_DIR"
    
    # Initialize arrays
    caught_monster=()
    declare -A monster_stats_array
    
    if [[ -f "$DATA_DIR/pokedex.json" ]]; then
        # Read the pokedex array
        mapfile -t caught_monster < <(jq -r '.pokedex[]' "$DATA_DIR/pokedex.json")
        
        # Load monster stats
        if jq -e '.monster_stats' "$DATA_DIR/pokedex.json" >/dev/null 2>&1; then
            json_to_array monster_stats_array "$(jq -r '.monster_stats' "$DATA_DIR/pokedex.json")"
        fi
    fi
}

# Save Pokédex to pokedex.json
save_pokedex() {
    # Create data directory if it doesn't exist
    mkdir -p "$DATA_DIR"
    
    # Convert monster stats to JSON
    local monster_stats_json=$(array_to_json monster_stats_array)
    
    # Save the pokedex array and monster stats
    if ! jq -n \
        --argjson pokedex "$(printf '%s\n' "${caught_monster[@]}" | jq -R . | jq -s .)" \
        --argjson monster_stats "$monster_stats_json" \
        '{
            "pokedex": $pokedex,
            "monster_stats": $monster_stats
        }' > "$DATA_DIR/pokedex.json"; then
        print_error "Failed to save Pokédex"
        return 1
    fi
    return 0
}

# ============================================================================
# Status Display Functions
# ============================================================================

# Show current player status
show_status() {
    print_header
    print_money
    print_divider
    echo -e "${CYAN}Caught Pocket Monsters:${NC} ${#caught_monster[@]}"
    print_divider
    echo -e "${CYAN}Encounter Statistics:${NC}"
    echo -e "  Total Encounters: ${encounter_stats["total_encounters"]}"
    echo -e "  Successful Catches: ${encounter_stats["successful_catches"]}"
    echo -e "  Failed Catches: ${encounter_stats["failed_catches"]}"
    echo -e "  Fled: ${encounter_stats["fled"]}"
    if [ ${encounter_stats["total_encounters"]} -gt 0 ]; then
        local catch_rate=$((encounter_stats["successful_catches"] * 100 / encounter_stats["total_encounters"]))
        echo -e "  Catch Rate: ${catch_rate}%"
    fi
    print_divider
    echo -e "${CYAN}Pokédex:${NC}"
    for pocket_monster in "${caught_monster[@]}"; do
        echo -e "  $pocket_monster"
    done
    print_divider
    echo -e "${CYAN}Inventory:${NC}"
    for item in "${!inventory[@]}"; do
        print_inventory_item "$item" "${inventory[$item]}"
    done
    print_divider
}

# Show Pokédex contents
show_pokedex() {
    while true; do
        print_header
        if [ ${#caught_monster[@]} -eq 0 ]; then
            print_warning "Your Pocket Monster dex is empty. Go catch some Pocket Monsters!"
            return
        fi
        
        echo -e "${PURPLE}╔══════════════════════════════════════════════════════════╗${NC}"
        echo -e "${PURPLE}║${NC}  ${POKEDEX} Your Pokédex ${POKEDEX}  ${PURPLE}║${NC}"
        echo -e "${PURPLE}╚══════════════════════════════════════════════════════════╝${NC}"
        print_divider
        echo -e "${CYAN}Total Pocket Monsters caught:${NC} ${#caught_monster[@]}"
        print_divider
        
        # Display menu options
        print_menu_option "1" "$POKEDEX" "View All Monsters"
        print_menu_option "2" "$SEARCH" "Search Monster"
        print_menu_option "0" "$BACK" "Return to Main Menu"
        
        read -p "Enter your choice: " choice
        
        case $choice in
            1) show_all_monsters ;;
            2) search_monster ;;
            0) return ;;
            *) print_warning "Invalid choice. Please try again." ;;
        esac
    done
}

# Show all caught monsters
show_all_monsters() {
    print_header
    echo -e "${PURPLE}╔══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${PURPLE}║${NC}  ${POKEDEX} All Caught Monsters ${POKEDEX}  ${PURPLE}║${NC}"
    echo -e "${PURPLE}╚══════════════════════════════════════════════════════════╝${NC}"
    print_divider
    
    for monster in "${caught_monster[@]}"; do
        echo -e "${GREEN}$monster${NC}"
        if [[ -n "${monster_stats_array[$monster]}" ]]; then
            print_pokemon_stats "${monster_stats_array[$monster]}"
        fi
        print_divider
    done
    
    read -p "Press Enter to continue..."
}

# Search for a specific monster
search_monster() {
    print_header
    echo -e "${PURPLE}╔══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${PURPLE}║${NC}  ${SEARCH} Search Monster ${SEARCH}  ${PURPLE}║${NC}"
    echo -e "${PURPLE}╚══════════════════════════════════════════════════════════╝${NC}"
    print_divider
    
    read -p "Enter monster name to search: " search_term
    
    local found=false
    for monster in "${caught_monster[@]}"; do
        if [[ "$monster" == *"$search_term"* ]]; then
            found=true
            echo -e "${GREEN}$monster${NC}"
            if [[ -n "${monster_stats_array[$monster]}" ]]; then
                print_pokemon_stats "${monster_stats_array[$monster]}"
            fi
            print_divider
        fi
    done
    
    if [[ "$found" == "false" ]]; then
        print_warning "No monsters found matching '$search_term'"
    fi
    
    read -p "Press Enter to continue..."
}

# Print the current money amount
print_money() {
    echo -e "${GREEN}$money $CURRENCY_NAME${NC}"
}

# Export functions
export -f load_progress
export -f save_progress
export -f load_pokedex
export -f save_pokedex
export -f show_status
export -f show_pokedex
export -f show_all_monsters
export -f search_monster
