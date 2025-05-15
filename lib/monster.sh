#!/bin/bash

# Source required modules
source lib/core/config.sh
source lib/utils/json_utils.sh
source lib/api/pokeapi.sh
source lib/display/ui.sh

# ============================================================================
# Monster Encounter Functions
# ============================================================================

# Get and display a random Monster
get_random_monster() {
    local monster_id
    local response
    local monster_name
    local monster_image_url
    local monster_stats
    
    monster_id=$(get_random_pokemon_id)
    response=$(fetch_pokemon "$monster_id")
    
    if [[ $? -eq 0 ]] && extract_pokemon_data "$response" monster_name monster_image_url monster_stats; then
        # Increment total encounters
        encounter_stats["total_encounters"]=$((encounter_stats["total_encounters"] + 1))
        if ! save_progress; then
            print_error "Failed to save encounter progress"
            return 1
        fi
        
        # Export stats for child processes
        export monster_stats="$monster_stats"
        display_monster "$monster_name" "$monster_image_url" "$monster_stats"
        return 0
    fi
    
    print_error "Failed to fetch Pokemon data"
    return 1
}

# Display the Monster image and encounter message
display_monster() {
    local monster_name=$1
    local monster_image_url=$2
    local monster_stats=$3
    
    # Create temporary directory for images
    local temp_dir="/tmp/monster_images"
    local temp_image="${temp_dir}/${monster_name}.png"
    
    # Download and display image
    if download_pokemon_image "$monster_image_url" "$temp_image"; then
        if command -v catimg >/dev/null 2>&1; then
            clear
            print_header
            print_divider
            
            # Encounter animation
            for msg in "Wild grass rustles..." "Something is moving..." "A shadow appears..." "It's getting closer..." "..."; do
                echo -e "${YELLOW}$msg${NC}"
                sleep 0.3
            done
            sleep 0.5
            
            # Display image
            echo
            echo -e "${PURPLE}╔══════════════════════════════════════════════════════════╗${NC}"
            echo -e "${PURPLE}║${NC}"
            catimg -w 100 "$temp_image" | sed 's/^/    /'
            echo -e "${PURPLE}║${NC}"
            echo -e "${PURPLE}╚══════════════════════════════════════════════════════════╝${NC}"
            echo
            print_divider
            
            # Display encounter message and stats
            monster_name=$(echo "$monster_name" | sed 's/^./\U&/')
            print_pocket_monster_encounter "$monster_name"
            print_pokemon_stats "$monster_stats"
            print_divider
        else
            print_warning "Note: Install 'catimg' to see Monster sprites"
            print_pocket_monster_encounter "$monster_name"
        fi
    else
        print_error "Failed to download monster image"
        print_pocket_monster_encounter "$monster_name"
    fi
}

# ============================================================================
# Monster Capture Functions
# ============================================================================

# Attempt to catch the Monster
catch_monster() {
    local monster_name=$1
    local catch_probability=$2
    local throw_attempt=$3
    
    local random_catch=$((RANDOM % 100))
    print_loading "Throwing the Ball"
    
    if [[ $random_catch -lt $catch_probability ]]; then
        if [[ -z "$monster_stats" ]]; then
            print_warning "No stats available for $monster_name"
            return 1
        fi
        
        # Catch animation
        clear
        print_header
        print_divider
        echo
        for msg in "The Ball wobbles..." "... wobbles again..." "... and one more time..."; do
            echo -e "${YELLOW}$msg${NC}"
            sleep 0.5
        done
        echo
        echo -e "${GREEN}╔══════════════════════════════════════════════════════════╗${NC}"
        echo -e "${GREEN}║${NC}  ${POKEBALL} ${YELLOW}Gotcha! ${monster_name} was caught!${NC} ${POKEBALL}  ${GREEN}║${NC}"
        echo -e "${GREEN}╚══════════════════════════════════════════════════════════╝${NC}"
        echo
        print_divider
        
        # Update game state
        if ! add_to_pokedex "$monster_name" "$monster_stats"; then
            print_error "Failed to add monster to Pokédex"
            return 1
        fi
        
        encounter_stats["successful_catches"]=$((encounter_stats["successful_catches"] + 1))
        
        # Add reward money
        local reward=100
        money=$((money + reward))
        if [ $money -gt $(get_config "max_money" 999999) ]; then
            money=$(get_config "max_money" 999999)
        fi
        
        if ! save_progress; then
            print_error "Failed to save progress after catch"
            return 1
        fi
        
        return 0
    else
        print_warning "The Pokeball failed! Attempt #$throw_attempt."
        encounter_stats["failed_catches"]=$((encounter_stats["failed_catches"] + 1))
        if ! save_progress; then
            print_error "Failed to save failed catch progress"
            return 1
        fi
        return 1
    fi
}

# ============================================================================
# Pokédex Management
# ============================================================================

# Add a caught Monster to the Pokédex
add_to_pokedex() {
    local monster_name=$1
    local monster_stats=$2
    
    if [[ ! " ${caught_monster[@]} " =~ " ${monster_name} " ]]; then
        caught_monster+=("$monster_name")
        if [[ -n "$monster_stats" ]]; then
            monster_stats_array["$monster_name"]="$monster_stats"
            if ! save_pokedex; then
                print_error "Failed to save Pokédex"
                return 1
            fi
        else
            print_warning "No stats available for $monster_name"
            return 1
        fi
    fi
    return 0
}

# Export functions
export -f get_random_monster
export -f display_monster
export -f catch_monster
export -f add_to_pokedex
