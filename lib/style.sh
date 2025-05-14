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
BERRY="🍓"
MUD="💩"
SHOP="🏪"
SAFARI="🌴"
POKEDEX="📱"
STATUS="📊"
EXIT="🚪"

# ============================================================================
# UI Components
# ============================================================================

# Print the game header
print_header() {
    echo -e "${BLUE}╔══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${NC}  ${MONSTER} ${YELLOW}Pokemon Safari Zone${NC} ${MONSTER}  ${BLUE}║${NC}"
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
    echo -e "${CYAN}[${number}]${NC} ${icon} ${text}"
}

# Print an inventory item with its count
print_inventory_item() {
    local item=$1
    local count=$2
    local icon=""
    
    case $item in
        "Pokeball") icon=$POKEBALL ;;
        "Berry") icon=$BERRY ;;
        "Mud") icon=$MUD ;;
        *) icon="•" ;;
    esac
    
    echo -e "${CYAN}$icon $item:${NC} $count"
}

# Print the current money amount
print_money() {
    echo -e "${GREEN}$MONEY Money: $MONEY${NC}"
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

# Print a Pokemon encounter message
print_pokemon_encounter() {
    echo -e "${PURPLE}╔══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${PURPLE}║${NC}  ${MONSTER} A wild $1 appeared! ${MONSTER}  ${PURPLE}║${NC}"
    echo -e "${PURPLE}╚══════════════════════════════════════════════════════════╝${NC}"
}

# Print a loading animation
print_loading() {
    local text=$1
    echo -ne "${CYAN}$text${NC} ["
    for i in {1..3}; do
        echo -ne "${YELLOW}${POKEBALL}${NC}"
        sleep 0.3
        echo -ne "\b"
    done
    echo -e "]"
} 