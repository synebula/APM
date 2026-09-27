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
    local config_home="${XDG_CONFIG_HOME:-${HOME}/.config}"
    local kitty_conf="${config_home}/kitty/kitty.conf"
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
            if [[ -f "${config_home}/kitty/themes/nord.conf" ]]; then
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

    if [[ -n "$target_theme" ]] \
        && [[ -f "${config_home}/kitty/themes/${target_theme}" ]] \
        && grep -q "^[[:space:]]*include[[:space:]]\+themes/" "$kitty_conf"; then
        sed -i -E "s|^[[:space:]]*include[[:space:]]+themes/.*$|include themes/${target_theme}|" "$kitty_conf"
        killall -SIGUSR1 kitty 2>/dev/null || true
    fi
}

# 3. 同步 Niri 主题色（外链 include 文件）。
# Niri 没有运行时 keyword API；theme-colors.kdl 由 niri include 字段级合并覆盖
# config.kdl 的颜色默认值，被 niri watcher 监视（改动即自动重载）。
# 此处整文件原子生成，不做行级 sed；文件缺失时主配置优雅回落默认色。
sync_niri() {
    local config_home="${XDG_CONFIG_HOME:-${HOME}/.config}"
    local niri_dir="${config_home}/niri"
    local theme_file="${niri_dir}/theme-colors.kdl"
    [[ -d "$niri_dir" ]] || return 0

    if [[ -n "${NIRI_SOCKET:-}" ]] && command -v niri >/dev/null 2>&1; then
        local active_from="${ACCENT_HEX}"
        local active_to="${SURFACE_HEX}"
        local inactive_from="${OUTLINE_HEX}"
        local inactive_to="${SURFACE_HEX}"
        local value

        for value in "$active_from" "$active_to" "$inactive_from" "$inactive_to"; do
            [[ "$value" =~ ^#[0-9a-fA-F]{6}([0-9a-fA-F]{2})?$ ]] || return 0
        done

        local candidate
        candidate=$(mktemp "${niri_dir}/.quickshell-theme.XXXXXX.kdl") || return 0
        {
            printf '// 由 quickshell ThemeSyncService 自动生成，请勿手改\n'
            printf 'layout {\n'
            printf '    border {\n'
            printf '        active-gradient from="%s" to="%s" angle=45\n' "$active_from" "$active_to"
            printf '        inactive-gradient from="%s" to="%s" angle=45\n' "$inactive_from" "$inactive_to"
            printf '    }\n'
            printf '\n'
            printf '    tab-indicator {\n'
            printf '        active-gradient from="%s" to="%s" angle=45\n' "$active_from" "$active_to"
            printf '    }\n'
            printf '}\n'
            printf '\n'
            printf 'overview {\n'
            # 6 位色补 cc 半透明（与静态默认 #181825cc 观感一致），8 位色原样透传
            local backdrop="${SURFACE_HEX}"
            [[ "$backdrop" =~ ^#[0-9a-fA-F]{6}$ ]] && backdrop="${backdrop}cc"
            printf '    backdrop-color "%s"\n' "$backdrop"
            printf '}\n'
        } >"$candidate" || {
            rm -f -- "$candidate"
            return 0
        }

        # 候选文件与 theme-colors.kdl 同目录，niri validate 会一并解析主配置的
        # 全部 include（字段级合并），提前拦截非法颜色/结构。
        if niri validate -c "$candidate" >/dev/null 2>&1; then
            chmod --reference="$niri_dir/config.kdl" "$candidate" 2>/dev/null || true
            if ! mv -f -- "$candidate" "$theme_file"; then
                rm -f -- "$candidate"
                return 0
            fi
            # 双保险：niri watcher 已监视 include 文件，此处显式请求一次重载
            niri msg action load-config-file >/dev/null 2>&1 || true
        else
            rm -f -- "$candidate"
        fi
    fi
}

# 4. 同步 Hyprland 边框色
sync_hyprland() {
    if [[ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ]] && command -v hyprctl >/dev/null 2>&1; then
        local clean_accent="${ACCENT_HEX#"#"}"
        local clean_outline="${OUTLINE_HEX#"#"}"
        [[ ${#clean_accent} -eq 6 ]] && clean_accent="${clean_accent}ff"
        [[ ${#clean_outline} -eq 6 ]] && clean_outline="${clean_outline}ff"
        hyprctl keyword general:col.active_border "rgba(${clean_accent}) rgba(${clean_outline}) 45deg" 2>/dev/null || true
    fi
}

sync_gtk
sync_kitty
sync_niri
sync_hyprland
