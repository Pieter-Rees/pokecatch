#!/bin/bash

# Import necessary scripts
source ./pokemon.sh
source ./items.sh
source ./status.sh
source ./shop.sh
source ./style.sh

# Initialize game data
load_progress
load_pokedex

# Function to start the Safari Zone
safari() {
    local POKEMON_ENCOUNTERED=false
    local POKEMON_ANGRY=false
    local POKEMON_EATING=false
    
    while true; do
        if [ "$POKEMON_ENCOUNTERED" = false ]; then
            print_header
            print_menu_option "1" "$SAFARI" "Look for Pokémon"
            print_menu_option "2" "$EXIT" "Go Back"
            read -p "What will you do? " SAFARI_CHOICE
            
            case $SAFARI_CHOICE in
                1)
                    print_loading "Searching for Pokémon"
                    # 30% chance to encounter a Pokémon
                    if [ $((RANDOM % 100)) -lt 30 ]; then
                        POKEMON_ENCOUNTERED=true
                        get_random_pokemon
                    else
                        print_warning "You search the area but find no Pokémon..."
                    fi
                    ;;
                2)
                    print_success "You decide to go back to the main area."
                    return
                    ;;
                *)
                    print_error "Invalid choice. Please choose again."
                    ;;
            esac
        else
            print_divider
            print_menu_option "1" "$POKEBALL" "Throw a Ball"
            print_menu_option "2" "$BERRY" "Throw a Berry"
            print_menu_option "3" "$MUD" "Throw Mud"
            print_menu_option "4" "$EXIT" "Run Away"
            read -p "What will you do? " SAFARI_CHOICE

            case $SAFARI_CHOICE in
                1)
                    throw_ball
                    local BALL_RESULT=$?
                    if [ $BALL_RESULT -eq 0 ]; then
                        POKEMON_ENCOUNTERED=false
                    elif [ $BALL_RESULT -eq 2 ]; then
                        print_warning "You need Pokeballs to catch Pokémon! Visit the shop to buy some."
                        print_menu_option "1" "$SHOP" "Go to Shop"
                        print_menu_option "2" "$EXIT" "Stay Here"
                        read -p "What will you do? " SHOP_CHOICE
                        case $SHOP_CHOICE in
                            1)
                                show_shop
                                ;;
                            2)
                                print_success "You decide to stay and observe the Pokémon."
                                ;;
                            *)
                                print_error "Invalid choice. Staying here."
                                ;;
                        esac
                    fi
                    ;;
                2)
                    throw_berry
                    POKEMON_EATING=true
                    POKEMON_ANGRY=false
                    ;;
                3)
                    throw_mud
                    POKEMON_ANGRY=true
                    POKEMON_EATING=false
                    ;;
                4)
                    print_warning "You ran away from the wild Pokémon."
                    POKEMON_ENCOUNTERED=false
                    MUD_THROWN="false"
                    BERRY_THROWN="false"
                    ;;
                *)
                    print_error "Invalid choice. Please choose again."
                    ;;
            esac
            
            # Check if Pokémon flees (higher chance if angry, lower if eating)
            if [ "$POKEMON_ENCOUNTERED" = true ]; then
                # Don't let Pokemon flee if player has no Pokeballs
                if [[ ${INVENTORY["Pokeball"]} -le 0 ]]; then
                    print_warning "The Pokémon seems to be waiting for you to get some Pokeballs..."
                    continue
                fi

                local FLEE_CHANCE=20
                if [ "$POKEMON_ANGRY" = true ]; then
                    FLEE_CHANCE=40
                elif [ "$POKEMON_EATING" = true ]; then
                    FLEE_CHANCE=10
                fi
                
                if [ $((RANDOM % 100)) -lt $FLEE_CHANCE ]; then
                    print_warning "The wild Pokémon fled!"
                    POKEMON_ENCOUNTERED=false
                    MUD_THROWN="false"
                    BERRY_THROWN="false"
                fi
            fi
        fi
    done
}

# Function to display current items
show_current_items() {
    echo -e "${CYAN}Current Items:${NC}"
    for item in "${!INVENTORY[@]}"; do
        if [ "${INVENTORY[$item]}" -gt 0 ]; then
            print_inventory_item "$item" "${INVENTORY[$item]}"
        fi
    done
    print_divider
}

# Main Game Loop
while true; do
    print_header
    print_money
    print_divider
    show_current_items
    print_menu_option "1" "$SAFARI" "Enter Safari Zone"
    print_menu_option "2" "$POKEDEX" "View Pokédex"
    print_menu_option "3" "$STATUS" "Check Status"
    print_menu_option "4" "$SHOP" "Visit Shop"
    print_menu_option "5" "$EXIT" "Exit Game"
    read -p "What will you do? " CHOICE

    case $CHOICE in
        1)
            safari  # Enter the Safari Zone
            ;;
        2)
            show_pokedex  # View the Pokédex
            ;;
        3)
            show_status  # Check player status
            ;;
        4)
            show_shop  # Visit the shop
            ;;
        5)
            print_success "Exiting the game. Goodbye!"
            save_progress  # Save game progress
            save_pokedex  # Save the Pokédex data
            exit 0
            ;;
        *)
            print_error "Invalid option. Please choose again."
            ;;
    esac
done
