#!/bin/bash

# ============================================================================
# Shop Configuration
# ============================================================================

# Shop items and their costs
ITEMS=("Pokeball" "Rock" "Bait")
ITEM_COSTS=(200 50 100)

# ============================================================================
# Shop Display Functions
# ============================================================================

# Display the shop menu and handle purchases
show_shop() {
    print_header
    print_money
    print_divider
    echo -e "${CYAN}Available items for sale:${NC}"
    for i in "${!ITEMS[@]}"; do
        print_menu_option "$((i+1))" "$(get_item_icon "${ITEMS[$i]}")" "${ITEMS[$i]} - \$${ITEM_COSTS[$i]}"
    done
    print_menu_option "0" "$EXIT" "Leave Shop"
    read -p "What would you like to buy? " CHOICE

    case $CHOICE in
        1)
            buy_item "Pokeball" 200
            show_shop  # Show shop menu again after purchase
            ;;
        2)
            buy_item "Rock" 50
            show_shop  # Show shop menu again after purchase
            ;;
        3)
            buy_item "Bait" 100
            show_shop  # Show shop menu again after purchase
            ;;
        0)
            print_success "Leaving the shop..."
            return
            ;;
        *)
            print_error "Invalid option. Try again."
            show_shop  # Show shop menu again after invalid option
            ;;
    esac
}

# Get the icon for a specific item
get_item_icon() {
    local item=$1
    case $item in
        "Pokeball") echo "$POKEBALL" ;;
        "Rock") echo "🪨" ;;
        "Bait") echo "🪱" ;;
        *) echo "•" ;;
    esac
}

# ============================================================================
# Purchase Functions
# ============================================================================

# Buy an item from the shop
buy_item() {
    local ITEM_NAME=$1
    local ITEM_COST=$2
    local CURRENT_COUNT=${INVENTORY["$ITEM_NAME"]:-0}

    if [ $MONEY -ge $ITEM_COST ]; then
        MONEY=$((MONEY - ITEM_COST))
        if [ $MONEY -lt $MIN_MONEY ]; then
            MONEY=$MIN_MONEY
        fi
        INVENTORY["$ITEM_NAME"]=$((CURRENT_COUNT + 1))
        save_progress  # Save progress after buying an item
        print_success "You bought a $ITEM_NAME! You now have ${INVENTORY[$ITEM_NAME]} $ITEM_NAME(s)."
    else
        print_error "You don't have enough $CURRENCY_NAME to buy $ITEM_NAME."
    fi
}
