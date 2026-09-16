#!/usr/bin/env bash
# ==============================================================================
# sync-desktop-theme.sh
# 统一将 Quickshell 主题 (mode, palette, accent) 同步至桌面外部环境 (GTK, Kitty, Hyprland, Niri)
# ==============================================================================
set -euo pipefail

COLOR_MODE="dark"
PALETTE_ID="catppuccin"
ACCENT_HEX="#8839ef"
SURFACE_HEX="#1e1e2e"
OUTLINE_HEX="#313244"

while [[ $# -gt 0 ]]; do
    case "$1" in
        --mode)
            COLOR_MODE="$2"
            shift 2
            ;;
        --palette)
            PALETTE_ID="$2"
            shift 2
            ;;
        --accent)
            ACCENT_HEX="$2"
            shift 2
            ;;
        --surface)
            SURFACE_HEX="$2"
            shift 2
            ;;
        --outline)
            OUTLINE_HEX="$2"
            shift 2
            ;;
        *)
            shift
            ;;
    esac
done

# 1. 同步系统 / GTK 明暗模式
sync_gtk() {
    if command -v gsettings >/dev/null 2>&1; then
        if [[ "$COLOR_MODE" == "dark" ]]; then
            gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark' 2>/dev/null || true
        else
            gsettings set org.gnome.desktop.interface color-scheme 'default' 2>/dev/null || true
        fi
    fi

    if command -v darkman >/dev/null 2>&1; then
        if [[ "$COLOR_MODE" == "dark" ]]; then
            darkman set dark 2>/dev/null || true
        else
            darkman set light 2>/dev/null || true
        fi
    fi
}

# 2. 同步 Kitty 终端配色
sync_kitty() {
    local kitty_conf="${HOME}/.config/kitty/kitty.conf"
    [[ -f "$kitty_conf" ]] || return 0

    local target_theme=""
    case "$PALETTE_ID" in
        catppuccin)
            if [[ "$COLOR_MODE" == "dark" ]]; then
                target_theme="catppuccin-mocha.conf"
            else
                target_theme="catppuccin-latte.conf"
            fi
            ;;
        tokyo-night)
            target_theme="tokyo-night.conf"
            ;;
        everforest)
            target_theme="everforest-dark.conf"
            ;;
        nord)
            if [[ -f "${HOME}/.config/kitty/themes/nord.conf" ]]; then
                target_theme="nord.conf"
            fi
            ;;
        pastel-relief)
            if [[ "$COLOR_MODE" == "dark" ]]; then
                target_theme="catppuccin-mocha.conf"
            else
                target_theme="catppuccin-latte.conf"
            fi
            ;;
    esac

    if [[ -n "$target_theme" ]] && grep -q "^[[:space:]]*include[[:space:]]\+themes/" "$kitty_conf"; then
        sed -i -E "s|^[[:space:]]*include[[:space:]]+themes/.*$|include themes/${target_theme}|" "$kitty_conf"
        killall -SIGUSR1 kitty 2>/dev/null || true
    fi
}

# 3. 同步 Hyprland 边框色
sync_hyprland() {
    if [[ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ]] && command -v hyprctl >/dev/null 2>&1; then
        local clean_accent="${ACCENT_HEX#"#"}"
        local clean_outline="${OUTLINE_HEX#"#"}"
        hyprctl keyword general:col.active_border "rgba(${clean_accent}ff) rgba(${clean_outline}ff) 45deg" 2>/dev/null || true
    fi
}

sync_gtk
sync_kitty
sync_hyprland
