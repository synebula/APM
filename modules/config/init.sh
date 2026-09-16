#!/usr/bin/env bash

# Create soft-links for every item in modules/config directory to ~/.config
# Use -f / --force to force recreate existing symlinks/targets

set -euo pipefail

force=false

# Parse command-line options
while [[ $# -gt 0 ]]; do
    case "$1" in
        -f|--force)
            force=true
            shift
            ;;
        -h|--help)
            echo "Usage: $(basename "$0") [-f|--force] [-h|--help]"
            echo "  -f, --force   Force recreate links in ~/.config (replaces existing symlinks)"
            echo "  -h, --help    Show this help message"
            exit 0
            ;;
        *)
            echo "Error: Unknown option '$1'" >&2
            echo "Usage: $(basename "$0") [-f|--force] [-h|--help]" >&2
            exit 1
            ;;
    esac
done

# Get the absolute path to the modules/config directory
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Create ~/.config directory if it doesn't exist
mkdir -p "$HOME/.config"

# Iterate through all items in the modules/config directory
for item in "$script_dir"/*; do
    item_name=$(basename "$item")

    # Skip hidden files/directories
    [[ "$item_name" == .* ]] && continue

    # Skip if the item is the current script itself
    if [[ "$item_name" == "$(basename "${BASH_SOURCE[0]}")" ]]; then
        continue
    fi

    # Skip if no files match the glob pattern
    [[ ! -e "$item" ]] && continue

    # Construct the target path in ~/.config
    target_path="$HOME/.config/$item_name"

    target_exists=false
    if [[ -e "$target_path" || -L "$target_path" ]]; then
        target_exists=true
    fi

    if [[ "$target_exists" == true ]]; then
        if [[ "$force" == true ]]; then
            if [[ -L "$target_path" ]]; then
                rm -f "$target_path"
            else
                backup_path="${target_path}.bak.$(date +%Y%m%d%H%M%S)"
                echo "Warning: $target_path is a real directory/file, backing up to $backup_path"
                mv "$target_path" "$backup_path"
            fi
            ln -s --verbose "$item" "$target_path"
            echo "Recreated soft-link: $item_name -> $target_path"
        else
            echo "Skipping $item_name: target already exists at $target_path (use -f to force)"
        fi
    else
        ln -s --verbose "$item" "$target_path"
        echo "Created soft-link: $item_name -> $target_path"
    fi
done

echo "Soft-link creation complete!"
