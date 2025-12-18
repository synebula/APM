#!/usr/bin/env bash

# Create soft-links for every item in modules/hyprland directory to ~/.config
# Only creates links if the target doesn't already exist

# Get the absolute path to the modules/hyprland directory
# This script is located in modules/hyprland, so we can use its location
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Create ~/.config directory if it doesn't exist
mkdir -p "$HOME/.config"

# Iterate through all items in the modules/hyprland directory
for item in "$script_dir"/*; do
    # Get just the basename of the item
    item_name=$(basename "$item")
    
    # Skip if the item is the current script itself
    if [[ "$item_name" == "$(basename "$0")" ]]; then
        continue
    fi
    
    # Skip if no files match the glob pattern
    [[ ! -e "$item" ]] && continue
    
    # Construct the target path in ~/.config
    target_path="$HOME/.config/$item_name"
    
    # Silently test if the target path already exists
    if [[ ! -e "$target_path" ]]; then
        # Create the soft-link with absolute path and verbose output
        ln -s --verbose "$item" "$target_path"
        echo "Created soft-link: $item_name -> $target_path"
    else
        echo "Skipping $item_name: target already exists at $target_path"
    fi
done

echo "Soft-link creation complete!"