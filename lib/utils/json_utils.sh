#!/bin/bash

# JSON utilities module

# Convert associative array to JSON object
array_to_json() {
    local -n arr=$1
    local json="{}"
    
    for key in "${!arr[@]}"; do
        if [[ -n "$key" && -n "${arr[$key]}" ]]; then
            json=$(echo "$json" | jq --arg k "$key" --arg v "${arr[$key]}" '. + {($k): ($v|tonumber)}')
        fi
    done
    
    echo "$json"
}

# Convert JSON object to associative array
json_to_array() {
    local -n arr=$1
    local json=$2
    
    while IFS="=" read -r key value; do
        if [[ -n "$key" && -n "$value" ]]; then
            arr["$key"]=$value
        fi
    done < <(echo "$json" | jq -r 'to_entries | .[] | "\(.key)=\(.value)"')
}

# Save JSON to file with error handling
save_json() {
    local json=$1
    local file=$2
    
    # Create directory if it doesn't exist
    mkdir -p "$(dirname "$file")"
    
    # Save with error handling
    if ! echo "$json" > "$file"; then
        print_error "Failed to save JSON to $file"
        return 1
    fi
    return 0
}

# Load JSON from file with error handling
load_json() {
    local file=$1
    
    if [[ ! -f "$file" ]]; then
        print_warning "File not found: $file"
        return 1
    fi
    
    if ! jq empty "$file" 2>/dev/null; then
        print_error "Invalid JSON in file: $file"
        return 1
    fi
    
    cat "$file"
    return 0
}

# Export functions
export -f array_to_json
export -f json_to_array
export -f save_json
export -f load_json 