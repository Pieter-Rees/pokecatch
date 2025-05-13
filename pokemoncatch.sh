#!/bin/bash

set -e

POKEDEX_FILE="$HOME/.pokedex_caught.txt"

# Function to print in 256-color
color_text() {
    local color="$1"
    shift
    echo -e "\033[38;5;${color}m$*\033[0m"
}

# Function to fetch and display Pokémon sprite
display_pokemon_image() {
    local name="$1"
    local info=$(curl -s "https://pokeapi.co/api/v2/pokemon/$name")
    local image_url=$(echo "$info" | jq -r '.sprites.front_default')
    [[ "$image_url" == "null" ]] && return
    local temp_img=$(mktemp /tmp/pokemon_img.XXXXXX.png)
    curl -s -o "$temp_img" "$image_url"
    catimg -w 30 "$temp_img"
    rm "$temp_img"
}

# Function to show Pokédex
show_pokedex() {
    if [[ ! -f "$POKEDEX_FILE" || ! -s "$POKEDEX_FILE" ]]; then
        color_text 240 "Your Pokédex is empty."
        return
    fi

    color_text 39 "📖 Your Pokédex:"
    sort "$POKEDEX_FILE" | uniq | nl
    echo ""
    echo "Type a Pokémon name to view its sprite or press Enter to return:"
    read -r query
    [[ -z "$query" ]] && return
    display_pokemon_image "$query"
    echo ""
}

# Safari Zone main function
start_safari() {
    POKEMON_ID=$(shuf -i 1-898 -n 1)
    RESPONSE=$(curl -s https://pokeapi.co/api/v2/pokemon/$POKEMON_ID)

    if [[ -z "$RESPONSE" || "$RESPONSE" == "null" ]]; then
        echo "Failed to fetch data for Pokémon ID $POKEMON_ID."
        return
    fi

    POKEMON_NAME=$(echo "$RESPONSE" | jq -r '.name')
    POKEMON_IMAGE_URL=$(echo "$RESPONSE" | jq -r '.sprites.front_default')

    TEMP_IMAGE=$(mktemp /tmp/pokemon_image.XXXXXX.png)
    curl -s -o "$TEMP_IMAGE" "$POKEMON_IMAGE_URL"
    catimg -w 40 "$TEMP_IMAGE"
    rm "$TEMP_IMAGE"

    color_text 11 "A wild $POKEMON_NAME appeared! 🌿"

    BASE_CATCH_RATE=$(curl -s https://pokeapi.co/api/v2/pokemon-species/$POKEMON_ID | jq -r '.capture_rate')
    BASE_SPEED=$(echo "$RESPONSE" | jq -r '.stats[] | select(.stat.name == "speed") | .base_stat')

    if [[ -z "$BASE_CATCH_RATE" || "$BASE_CATCH_RATE" == "null" ]]; then
        BASE_CATCH_RATE=$(( (BASE_SPEED + 10) / 2 ))
    fi
    (( BASE_CATCH_RATE > 255 )) && BASE_CATCH_RATE=255

    CATCH_PROBABILITY=$(( BASE_CATCH_RATE * 100 / 255 ))
    FLEE_RATE=$(( 100 - CATCH_PROBABILITY ))

    BAIT_TURNS=0
    MUD_TURNS=0

    adjust_rates() {
        MODIFIED_CATCH=$CATCH_PROBABILITY
        MODIFIED_FLEE=$FLEE_RATE

        if (( BAIT_TURNS > 0 )); then
            MODIFIED_CATCH=$(( CATCH_PROBABILITY - 15 ))
            MODIFIED_FLEE=$(( FLEE_RATE - 25 ))
            (( BAIT_TURNS-- ))
        elif (( MUD_TURNS > 0 )); then
            MODIFIED_CATCH=$(( CATCH_PROBABILITY + 15 ))
            MODIFIED_FLEE=$(( FLEE_RATE + 25 ))
            (( MUD_TURNS-- ))
        fi

        (( MODIFIED_CATCH < 1 )) && MODIFIED_CATCH=1
        (( MODIFIED_CATCH > 100 )) && MODIFIED_CATCH=100
        (( MODIFIED_FLEE < 0 )) && MODIFIED_FLEE=0
        (( MODIFIED_FLEE > 100 )) && MODIFIED_FLEE=100

        CURRENT_CATCH=$MODIFIED_CATCH
        CURRENT_FLEE=$MODIFIED_FLEE
    }

    while true; do
        echo ""
        color_text 45 "What will you do?"
        echo "1) Throw Safari Ball"
        echo "2) Throw Bait"
        echo "3) Throw Mud"
        echo "4) Run Away"
        echo -n "> "
        read -r choice

        adjust_rates

        case $choice in
            1)
                color_text 220 "You threw a Safari Ball! 🎯"
                catch_roll=$(( RANDOM % 100 ))
                if (( catch_roll < CURRENT_CATCH )); then
                    color_text 82 "You caught $POKEMON_NAME! 🎉"
                    echo "$POKEMON_NAME" >> "$POKEDEX_FILE"
                    break
                else
                    color_text 160 "$POKEMON_NAME broke free!"
                fi
                ;;
            2)
                color_text 10 "You threw bait! 🪙"
                BAIT_TURNS=5
                MUD_TURNS=0
                ;;
            3)
                color_text 130 "You threw mud! 💩"
                MUD_TURNS=5
                BAIT_TURNS=0
                ;;
            4)
                color_text 8 "You ran away..."
                return
                ;;
            *)
                echo "Invalid choice."
                continue
                ;;
        esac

        flee_roll=$(( RANDOM % 100 ))
        if (( flee_roll < CURRENT_FLEE )); then
            color_text 196 "The wild $POKEMON_NAME fled! 💨"
            return
        fi
    done
}

# Main menu
while true; do
    echo ""
    color_text 45 "🌿 Welcome to the Safari Zone 🌿"
    echo "1) Start Encounter"
    echo "2) View Pokédex"
    echo "3) Exit"
    echo -n "> "
    read -r option

    case $option in
        1) start_safari ;;
        2) show_pokedex ;;
        3) echo "Goodbye, Trainer! 👋"; exit 0 ;;
        *) echo "Invalid option." ;;
    esac
done
