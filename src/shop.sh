#!/bin/bash

# Shop items and their costs
ITEMS=("Pokeball" "Berry" "Mud")
ITEM_COSTS=(200 100 50)

# Function to display the shop menu
show_shop() {
    echo -e "Welcome to the Safari Zone Shop!\n"
    echo "Available items for sale:"
    for i in "${!ITEMS[@]}"; do
        echo "[$((i+1))] ${ITEMS[$i]} - \$${ITEM_COSTS[$i]}"
    done
    echo "[0] Leave Shop"
    read -p "What would you like to buy? " CHOICE

    case $CHOICE in
        1)
            buy_item "Pokeball" 200
            ;;
        2)
            buy_item "Berry" 100
            ;;
        3)
            buy_item "Mud" 50
            ;;
        0)
            echo "Leaving the shop..."
            return
            ;;
        *)
            echo "Invalid option. Try again."
            show_shop
            ;;
    esac
}

# Function to buy an item
buy_item() {
    local ITEM_NAME=$1
    local ITEM_COST=$2
    local CURRENT_COUNT=${INVENTORY["$ITEM_NAME"]:-0}

    if [ $MONEY -ge $ITEM_COST ]; then
        MONEY=$((MONEY - ITEM_COST))
        INVENTORY["$ITEM_NAME"]=$((CURRENT_COUNT + 1))
        save_progress  # Save progress after buying an item
        echo "You bought a $ITEM_NAME! You now have ${INVENTORY[$ITEM_NAME]} $ITEM_NAME(s)."
    else
        echo "You don't have enough money to buy $ITEM_NAME."
    fi
}
