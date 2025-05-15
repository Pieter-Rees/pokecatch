#!/bin/bash

# ============================================================================
# Color Constants
# ============================================================================
RED='\033[0;31m'
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# ============================================================================
# Game Icons
# ============================================================================
POKEBALL="⚪"
MONSTER="🐾"
MONEY="💰"
ROCK="🪨"
BAIT="🪱"
SHOP="🏪"
SAFARI="🌴"
POKEDEX="📱"
STATUS="📊"
EXIT="🚪"
SEARCH="🔍"
BACK="⬅️"

# ============================================================================
# UI Components
# ============================================================================

# Print the game header
print_header() {
    echo -e "${BLUE}╔══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${NC}  ${MONSTER} ${YELLOW}Pokémon${NC} ${GREEN}Safari Zone${NC} ${MONSTER}  ${BLUE}║${NC}"
    echo -e "${BLUE}║${NC}  ${CYAN}Gotta catch 'em all!${NC}  ${BLUE}║${NC}"
    echo -e "${BLUE}╚══════════════════════════════════════════════════════════╝${NC}"
}

# Print a horizontal divider
print_divider() {
    echo -e "${BLUE}──────────────────────────────────────────────────────────${NC}"
}

# ============================================================================
# Menu and Option Display
# ============================================================================

# Print a menu option with icon and number
print_menu_option() {
    local number=$1
    local icon=$2
    local text=$3
    echo -e "${CYAN}[${number}]${NC} ${icon}  ${text}"
}

# Print an inventory item with its count
print_inventory_item() {
    local item=$1
    local count=$2
    local icon=""
    local width=1
    
    case $item in
        "Pokeball") 
            icon=$POKEBALL
            width=2  # Pokeball emoji is wider
            ;;
        "Rock") 
            icon=$ROCK
            width=1
            ;;
        "Bait") 
            icon=$BAIT
            width=1
            ;;
        *) 
            icon="•"
            width=1
            ;;
    esac
    
    printf "${CYAN}%-${width}s %s${NC}: %d\n" "$icon" "$item" "$count"
}

# Print the current money amount
print_money() {
    echo -e "${GREEN}${MONEY} ${CURRENCY_NAME}${NC}"
}

# ============================================================================
# Status Messages
# ============================================================================

# Print a success message
print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

# Print an error message
print_error() {
    echo -e "${RED}✗ $1${NC}"
}

# Print a warning message
print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

# Print a Pocket Monster encounter message
print_pocket_monster_encounter() {
    echo -e "${PURPLE}╔══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${PURPLE}║${NC}  ${MONSTER} A wild $1 appeared! ${MONSTER}  ${PURPLE}║${NC}"
    echo -e "${PURPLE}╚══════════════════════════════════════════════════════════╝${NC}"
}

# Print a loading animation
print_loading() {
    local text=$1
    echo -ne "${CYAN}$text${NC} ["
    for i in {1..3}; do
        echo -ne " "
        sleep 0.3
        echo -ne "\b"
    done
    echo -e "]"
} 