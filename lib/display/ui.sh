#!/bin/bash

# UI display module

# Display functions
print_header() {
    clear
    echo -e "${PURPLE}╔══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${PURPLE}║${NC}  ${POKEBALL} ${YELLOW}PokéCatch${NC} ${POKEBALL}  ${PURPLE}║${NC}"
    echo -e "${PURPLE}╚══════════════════════════════════════════════════════════╝${NC}"
}

print_divider() {
    echo -e "${PURPLE}════════════════════════════════════════════════════════════${NC}"
}

print_menu_option() {
    local number=$1
    local icon=$2
    local text=$3
    echo -e "${CYAN}║${NC}  ${GREEN}$number${NC} ${YELLOW}$icon${NC} $text  ${CYAN}║${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_loading() {
    echo -e "${CYAN}⏳ $1...${NC}"
}

print_money() {
    local currency_name=$(get_config "currency_name" "PokéDollars")
    echo -e "${CYAN}Money:${NC} ${GREEN}$MONEY${NC} $currency_name"
}

print_inventory_item() {
    local item=$1
    local quantity=$2
    echo -e "  ${YELLOW}$item${NC}: ${GREEN}$quantity${NC}"
}

print_pocket_monster_encounter() {
    local name=$1
    echo -e "${YELLOW}A wild ${GREEN}$name${NC} ${YELLOW}appeared!${NC}"
}

# Display Pokemon stats with visual bars
print_pokemon_stats() {
    local stats=$1
    
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${NC}  ${YELLOW}Base Stats${NC}  ${CYAN}║${NC}"
    echo -e "${CYAN}╠══════════════════════════════════════════════════════════╣${NC}"
    
    echo "$stats" | tr '|' '\n' | while IFS=':' read -r stat_name stat_value; do
        stat_name=$(echo "$stat_name" | sed 's/^./\U&/')
        local bar_length=$((stat_value / 10))
        local bar=""
        for ((i=0; i<bar_length; i++)); do
            bar+="█"
        done
        printf "${CYAN}║${NC}  ${GREEN}%-10s${NC}: ${YELLOW}%3d${NC} ${bar}${NC}  ${CYAN}║${NC}\n" "$stat_name" "$stat_value"
    done
    
    echo -e "${CYAN}╚══════════════════════════════════════════════════════════╝${NC}"
}

# Export functions
export -f print_header
export -f print_divider
export -f print_menu_option
export -f print_warning
export -f print_error
export -f print_success
export -f print_loading
export -f print_money
export -f print_inventory_item
export -f print_pocket_monster_encounter
export -f print_pokemon_stats 