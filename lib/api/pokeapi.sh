#!/bin/bash

# PokeAPI interaction module

# Constants
POKEAPI_BASE_URL="https://pokeapi.co/api/v2"
MAX_POKEMON=898
MAX_RETRIES=3

# Fetch Pokemon data from PokeAPI
fetch_pokemon() {
    local pokemon_id=$1
    local retry_count=0
    
    while [ $retry_count -lt $MAX_RETRIES ]; do
        local response
        local http_code
        
        # Fetch data with timeout
        response=$(curl -s -w "\n%{http_code}" --max-time 10 "${POKEAPI_BASE_URL}/pokemon/${pokemon_id}")
        http_code=$(echo "$response" | tail -n1)
        response_body=$(echo "$response" | sed '$d')
        
        if [ "$http_code" -eq 200 ] && echo "$response_body" | jq empty 2>/dev/null; then
            echo "$response_body"
            return 0
        fi
        
        retry_count=$((retry_count + 1))
        if [ $retry_count -lt $MAX_RETRIES ]; then
            sleep 1
        fi
    done
    
    return 1
}

# Get random Pokemon ID
get_random_pokemon_id() {
    shuf -i 1-$MAX_POKEMON -n 1
}

# Extract Pokemon data from API response
extract_pokemon_data() {
    local response=$1
    local -n name=$2
    local -n image_url=$3
    local -n stats=$4
    
    name=$(echo "$response" | jq -r '.name // empty')
    image_url=$(echo "$response" | jq -r '.sprites.front_default // empty')
    stats=$(echo "$response" | jq -r '.stats[] | "\(.stat.name): \(.base_stat)"' | tr '\n' '|')
    
    [[ -n "$name" && -n "$image_url" && -n "$stats" ]]
}

# Download Pokemon image
download_pokemon_image() {
    local image_url=$1
    local output_path=$2
    
    mkdir -p "$(dirname "$output_path")"
    curl -s -o "$output_path" "$image_url"
}

# Export functions
export -f fetch_pokemon
export -f get_random_pokemon_id
export -f extract_pokemon_data
export -f download_pokemon_image 