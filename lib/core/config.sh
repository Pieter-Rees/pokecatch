#!/bin/bash

# Configuration management module
declare -A GAME_CONFIG

load_config() {
    local config_file="config/game_config.json"
    
    if [[ ! -f "$config_file" ]]; then
        print_warning "Configuration file not found. Using default values."
        GAME_CONFIG=(
            ["starting_money"]=1000
            ["currency_name"]="PokéDollars"
            ["min_money"]=0
            ["max_money"]=999999
        )
        return
    }

    # Load configuration using jq
    while IFS="=" read -r key value; do
        if [[ -n "$key" && -n "$value" ]]; then
            GAME_CONFIG["$key"]="$value"
        fi
    done < <(jq -r 'to_entries | .[] | "\(.key)=\(.value)"' "$config_file")
}

get_config() {
    local key=$1
    local default=$2
    echo "${GAME_CONFIG[$key]:-$default}"
}

# Export functions
export -f load_config
export -f get_config 