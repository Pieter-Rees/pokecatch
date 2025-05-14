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
declare -A MONSTER_STATS_ARRAY
declare -a CAUGHT_MONSTER

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
        MONEY=$(jq -r --arg default "$STARTING_MONEY" '.money // $default' "$DATA_DIR/save.json")
        MONEY=${MONEY:-$STARTING_MONEY}  # Ensure MONEY is set
        MONEY=$((MONEY))  # Convert to number
        
        # Load inventory items
        if jq -e '.inventory' "$DATA_DIR/save.json" >/dev/null 2>&1; then
            while IFS="=" read -r key value; do
                if [[ -n "$key" && -n "$value" ]]; then
                    INVENTORY["$key"]=$value
                fi
            done < <(jq -r '.inventory | to_entries | .[] | "\(.key)=\(.value)"' "$DATA_DIR/save.json")
        fi

        # Load encounter statistics
        if jq -e '.encounter_stats' "$DATA_DIR/save.json" >/dev/null 2>&1; then
            while IFS="=" read -r key value; do
                if [[ -n "$key" && -n "$value" ]]; then
                    ENCOUNTER_STATS["$key"]=$value
                fi
            done < <(jq -r '.encounter_stats | to_entries | .[] | "\(.key)=\(.value)"' "$DATA_DIR/save.json")
        fi
    else
        MONEY=$STARTING_MONEY
    fi
}

# Save progress to save.json
save_progress() {
    # Create data directory if it doesn't exist
    mkdir -p "$DATA_DIR"

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
        }' > "$DATA_DIR/save.json"
}

# ============================================================================
# Pokédex Management
# ============================================================================

# Load Pokédex from pokedex.json
load_pokedex() {
    # Create data directory if it doesn't exist
    mkdir -p "$DATA_DIR"

    # Initialize arrays
    CAUGHT_MONSTER=()
    declare -A MONSTER_STATS_ARRAY

    if [[ -f "$DATA_DIR/pokedex.json" ]]; then
        # Read the pokedex array
        mapfile -t CAUGHT_MONSTER < <(jq -r '.pokedex[]' "$DATA_DIR/pokedex.json")
        
        # Load monster stats
        while IFS="=" read -r monster stats_json; do
            if [[ -n "$monster" && -n "$stats_json" ]]; then
                # Convert JSON stats back to pipe-separated format
                local stats=""
                while IFS="=" read -r stat_name stat_value; do
                    if [[ -n "$stat_name" && -n "$stat_value" ]]; then
                        if [[ -n "$stats" ]]; then
                            stats+="|"
                        fi
                        stats+="${stat_name}:${stat_value}"
                    fi
                done < <(echo "$stats_json" | jq -r 'to_entries | .[] | "\(.key)=\(.value)"')
                MONSTER_STATS_ARRAY["$monster"]="$stats"
            fi
        done < <(jq -r '.monster_stats | to_entries | .[] | "\(.key)=\(.value)"' "$DATA_DIR/pokedex.json")
    fi
}

# Save Pokédex to pokedex.json
save_pokedex() {
    # Create data directory if it doesn't exist
    mkdir -p "$DATA_DIR"

    # Create monster stats JSON object
    local monster_stats_json="{}"
    for monster in "${!MONSTER_STATS_ARRAY[@]}"; do
        if [[ -n "$monster" && -n "${MONSTER_STATS_ARRAY[$monster]}" ]]; then
            # Convert pipe-separated stats to JSON format
            local stats="${MONSTER_STATS_ARRAY[$monster]}"
            local stats_json="{}"
            while IFS='|' read -ra stat_array; do
                for stat in "${stat_array[@]}"; do
                    if [[ -n "$stat" ]]; then
                        IFS=':' read -r stat_name stat_value <<< "$stat"
                        stats_json=$(echo "$stats_json" | jq --arg name "$stat_name" --arg value "$stat_value" '. + {($name): $value}')
                    fi
                done
            done <<< "$stats"
            monster_stats_json=$(echo "$monster_stats_json" | jq --arg key "$monster" --argjson value "$stats_json" '. + {($key): $value}')
        fi
    done

    # Save the pokedex array and monster stats into pokedex.json
    jq -n \
        --argjson pokedex "$(printf '%s\n' "${CAUGHT_MONSTER[@]}" | jq -R . | jq -s .)" \
        --argjson monster_stats "$monster_stats_json" \
        '{
            "pokedex": $pokedex,
            "monster_stats": $monster_stats
        }' > "$DATA_DIR/pokedex.json"
}

# ============================================================================
# Status Display Functions
# ============================================================================

# Show current player status (Money, Caught Pocket Monsters, Inventory)
show_status() {
    print_header
    print_money
    print_divider
    echo -e "${CYAN}Caught Pocket Monsters:${NC} ${#CAUGHT_MONSTER[@]}"
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
    for pocket_monster in "${CAUGHT_MONSTER[@]}"; do
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
    while true; do
        print_header
        if [ ${#CAUGHT_MONSTER[@]} -eq 0 ]; then
            print_warning "Your Pocket Monster dex is empty. Go catch some Pocket Monsters!"
            return
        fi

        echo -e "${PURPLE}╔══════════════════════════════════════════════════════════╗${NC}"
        echo -e "${PURPLE}║${NC}  ${POKEDEX} Your Pokédex ${POKEDEX}  ${PURPLE}║${NC}"
        echo -e "${PURPLE}╚══════════════════════════════════════════════════════════╝${NC}"
        print_divider
        echo -e "${CYAN}Total Pocket Monsters caught:${NC} ${#CAUGHT_MONSTER[@]}"
        print_divider
        
        # Display menu options
        print_menu_option "1" "$POKEDEX" "View All Monsters"
        print_menu_option "2" "$SEARCH" "Search Monster"
        print_menu_option "0" "$BACK" "Return to Main Menu"
        read -p "What would you like to do? " POKEDEX_CHOICE

        case $POKEDEX_CHOICE in
            1)
                show_all_monsters
                ;;
            2)
                search_monster
                ;;
            0)
                return
                ;;
            *)
                print_error "Invalid option. Please try again."
                ;;
        esac
    done
}

# Show all monsters in the Pokédex
show_all_monsters() {
    while true; do
        print_header
        echo -e "${PURPLE}╔══════════════════════════════════════════════════════════╗${NC}"
        echo -e "${PURPLE}║${NC}  ${POKEDEX} All Monsters ${POKEDEX}  ${PURPLE}║${NC}"
        echo -e "${PURPLE}╚══════════════════════════════════════════════════════════╝${NC}"
        print_divider

        # Sort the caught monsters alphabetically
        IFS=$'\n' sorted_monsters=($(sort <<<"${CAUGHT_MONSTER[*]}"))
        unset IFS

        # Display numbered list of monsters
        for i in "${!sorted_monsters[@]}"; do
            monster="${sorted_monsters[$i]}"
            monster_name=$(echo "$monster" | sed 's/^./\U&/')
            print_menu_option "$((i+1))" "$MONSTER" "$monster_name"
        done
        print_divider
        print_menu_option "0" "$BACK" "Return to Pokédex Menu"
        
        read -p "Select a monster number to view details (0 to return): " SELECTION
        
        # Check if selection is valid
        if [[ "$SELECTION" == "0" ]]; then
            return
        elif [[ "$SELECTION" =~ ^[0-9]+$ ]] && [ "$SELECTION" -le "${#sorted_monsters[@]}" ] && [ "$SELECTION" -gt 0 ]; then
            # Get the selected monster
            selected_monster="${sorted_monsters[$((SELECTION-1))]}"
            view_monster_details "$selected_monster"
        else
            print_error "Invalid selection. Please try again."
            sleep 1
        fi
    done
}

# View detailed information about a specific monster
view_monster_details() {
    local monster=$1
    local monster_name=$(echo "$monster" | sed 's/^./\U&/')
    
    while true; do
        print_header
        echo -e "${PURPLE}╔══════════════════════════════════════════════════════════╗${NC}"
        echo -e "${PURPLE}║${NC}  ${MONSTER} $monster_name ${MONSTER}  ${PURPLE}║${NC}"
        echo -e "${PURPLE}╚══════════════════════════════════════════════════════════╝${NC}"
        print_divider
        
        # Display monster stats if available
        if [[ -n "${MONSTER_STATS_ARRAY[$monster]}" ]]; then
            echo -e "${CYAN}Base Stats:${NC}"
            echo "${MONSTER_STATS_ARRAY[$monster]}" | tr '|' '\n' | while IFS=':' read -r stat_name stat_value; do
                # Capitalize and format stat name
                stat_name=$(echo "$stat_name" | sed 's/^./\U&/')
                # Create a visual stat bar
                local bar_length=$((stat_value / 10))
                local bar=""
                for ((i=0; i<bar_length; i++)); do
                    bar+="█"
                done
                echo -e "  ${GREEN}$stat_name${NC}: $stat_value"
                echo -e "  ${YELLOW}$bar${NC}"
            done
        else
            print_warning "No stats available for this monster"
        fi
        print_divider
        
        print_menu_option "0" "$BACK" "Return to Monster List"
        read -p "Press 0 to return to the monster list... " CHOICE
        if [[ "$CHOICE" == "0" ]]; then
            return
        fi
    done
}

# Search for a specific monster in the Pokédex
search_monster() {
    while true; do
        print_header
        echo -e "${PURPLE}╔══════════════════════════════════════════════════════════╗${NC}"
        echo -e "${PURPLE}║${NC}  ${SEARCH} Search Pokédex ${SEARCH}  ${PURPLE}║${NC}"
        echo -e "${PURPLE}╚══════════════════════════════════════════════════════════╝${NC}"
        print_divider
        
        print_menu_option "0" "$BACK" "Return to Pokédex Menu"
        read -p "Enter monster name to search (0 to return): " SEARCH_TERM
        
        if [[ "$SEARCH_TERM" == "0" ]]; then
            return
        fi
        
        # Convert search term to lowercase for case-insensitive search
        SEARCH_TERM=$(echo "$SEARCH_TERM" | tr '[:upper:]' '[:lower:]')
        
        # Search through caught monsters
        local found=false
        for monster in "${CAUGHT_MONSTER[@]}"; do
            if [[ "$monster" == *"$SEARCH_TERM"* ]]; then
                found=true
                # Capitalize first letter of monster name
                monster_name=$(echo "$monster" | sed 's/^./\U&/')
                echo -e "${YELLOW}$monster_name${NC}"
                
                # Display monster stats if available
                if [[ -n "${MONSTER_STATS_ARRAY[$monster]}" ]]; then
                    echo -e "${CYAN}Stats:${NC}"
                    echo "${MONSTER_STATS_ARRAY[$monster]}" | tr '|' '\n' | while IFS=':' read -r stat_name stat_value; do
                        # Capitalize and format stat name
                        stat_name=$(echo "$stat_name" | sed 's/^./\U&/')
                        echo -e "  ${GREEN}$stat_name${NC}: $stat_value"
                    done
                fi
                print_divider
            fi
        done
        
        if [ "$found" = false ]; then
            print_warning "No monsters found matching '$SEARCH_TERM'"
        fi
        
        read -p "Press Enter to continue searching (0 to return)... " CHOICE
        if [[ "$CHOICE" == "0" ]]; then
            return
        fi
    done
}

# Print the current money amount
print_money() {
    echo -e "${GREEN}$MONEY $CURRENCY_NAME${NC}"
}
