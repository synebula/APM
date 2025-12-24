#!/usr/bin/env bash
# 作用：解析 `keybindings.conf` 并用 rofi 展示 Hyprland 快捷键列表；支持 `--print` 仅打印到 stdout 便于调试。
set -euo pipefail

HYPR_DIR="${HYPR_DIR:-$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)}"
KEYBINDS_FILE="${KEYBINDS_FILE:-"$HYPR_DIR/keybindings.conf"}"
KEYBINDS_DEFAULT_ICON_NAME="${KEYBINDS_DEFAULT_ICON_NAME:-input-keyboard}"
KEYBINDS_GAP_SPACES="${KEYBINDS_GAP_SPACES:-3}"
KEYBINDS_COMBO_COL_MAX="${KEYBINDS_COMBO_COL_MAX:-18}"

usage() {
  cat <<'EOF'
用法：
  keybinds.sh            # 用 rofi 展示 Hyprland 快捷键（同普通启动器样式）
  keybinds.sh --print    # 仅打印解析结果到 stdout（便于调试）
EOF
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

render_keybinds() {
  awk -v default_icon="$KEYBINDS_DEFAULT_ICON_NAME" '
  function trim(s) { gsub(/^[ \t]+|[ \t]+$/, "", s); return s }
  function expand(s, k) { for (k in vars) gsub("\\$" k, vars[k], s); return s }
  function mods_to_combo(mods, key) {
    mods = trim(mods)
    key = trim(key)
    mods = expand(mods)
    key = expand(key)
    gsub(/[[:space:]]+/, "+", mods)
    if (mods == "") return key
    if (key == "") return mods
    return mods "+" key
  }
  function icon_from_exec(args_lc) {
    if (args_lc ~ /(^|[[:space:]])(pkill[[:space:]]+rofi|rofi)([[:space:]]|$)/) return "system-run"
    if (args_lc ~ /(^|[[:space:]])kitty([[:space:]]|$)/) return "utilities-terminal"
    if (args_lc ~ /(^|[[:space:]])nautilus([[:space:]]|$)/) return "system-file-manager"
    if (args_lc ~ /(hyprshot|grim|slurp)/) return "applets-screenshooter"
    if (args_lc ~ /(^|[[:space:]])wpctl([[:space:]]|$)/) return "audio-volume-high"
    if (args_lc ~ /(^|[[:space:]])playerctl([[:space:]]|$)/) return "multimedia-player"
    if (args_lc ~ /(^|[[:space:]])hyprpicker([[:space:]]|$)/) return "applications-graphics"
    if (args_lc ~ /(gamemode\.sh|gamemode)/) return "applications-games"
    if (args_lc ~ /(^|[[:space:]])obsidian([[:space:]]|$)/) return "applications-office"
    if (args_lc ~ /(antigravity|visual[[:space:]]*studio[[:space:]]*code|vscode|(^|[[:space:]])code([[:space:]]|$))/) return "applications-development"
    return default_icon
  }
  BEGIN { OFS = "\t" }
  {
    raw = $0

    # 解析注释（用于展示说明）
    comment = ""
    hash_pos = index(raw, "#")
    if (hash_pos > 0) {
      comment = trim(substr(raw, hash_pos + 1))
      raw = substr(raw, 1, hash_pos - 1)
    }

    raw = trim(raw)
    if (raw == "") next

    # 变量定义：$mod = SUPER
    if (match(raw, /^\$[A-Za-z_][A-Za-z0-9_]*[[:space:]]*=/)) {
      eq = index(raw, "=")
      key = trim(substr(raw, 2, eq - 2))
      val = trim(substr(raw, eq + 1))
      vars[key] = val
      next
    }

    # 绑定定义：bind / binde / bindm ...
    if (!match(raw, /^bind[a-z]*[[:space:]]*=/)) next
    eq = index(raw, "=")
    kind = trim(substr(raw, 1, eq - 1))
    rhs = trim(substr(raw, eq + 1))

    n = split(rhs, parts, ",")
    for (i = 1; i <= n; i++) parts[i] = trim(parts[i])

    mods = (n >= 1 ? parts[1] : "")
    key  = (n >= 2 ? parts[2] : "")
    action = (n >= 3 ? parts[3] : "")

    args = ""
    for (i = 4; i <= n; i++) {
      if (parts[i] == "") continue
      if (args == "") args = parts[i]
      else args = args ", " parts[i]
    }

    combo = mods_to_combo(mods, key)
    if (combo == "") next

    desc = comment
    if (desc == "") {
      action = expand(action)
      args = expand(args)
      desc = action
      if (args != "") desc = desc " " args
    }
    if (desc == "") desc = "-"

    if (kind != "bind") desc = "(" kind ") " desc

    icon = default_icon
    action_lc = tolower(action)
    args_lc = tolower(args)

    if (kind == "bindm") {
      icon = "input-mouse"
    } else if (action_lc == "killactive") {
      icon = "window-close"
    } else if (action_lc == "togglefloating") {
      icon = "preferences-system-windows"
    } else if (action_lc == "fullscreen") {
      icon = "view-fullscreen"
    } else if (action_lc == "exit") {
      icon = "system-log-out"
    } else if (action_lc == "movefocus") {
      if (args_lc == "l") icon = "go-previous"
      else if (args_lc == "r") icon = "go-next"
      else if (args_lc == "u") icon = "go-up"
      else if (args_lc == "d") icon = "go-down"
    } else if (action_lc == "movewindow") {
      icon = "transform-move"
    } else if (action_lc == "resizeactive") {
      icon = "transform-scale"
    } else if (action_lc ~ /^(workspace|movetoworkspace|movetoworkspacesilent|togglespecialworkspace)$/) {
      icon = "preferences-desktop-workspaces"
    } else if (action_lc == "exec") {
      icon = icon_from_exec(args_lc)
    }

    print combo, desc, icon
  }' "$KEYBINDS_FILE"
}

format_for_print() {
  local -a combos=()
  local -a descs=()
  local max_combo_len=0

  while IFS=$'\t' read -r combo desc _icon; do
    [[ -z "${combo:-}" ]] && continue
    combos+=("$combo")
    descs+=("${desc:-}")
    if (( ${#combo} > max_combo_len )); then
      max_combo_len=${#combo}
    fi
  done

  if [[ "$KEYBINDS_COMBO_COL_MAX" =~ ^[0-9]+$ ]] && (( max_combo_len > KEYBINDS_COMBO_COL_MAX )); then
    max_combo_len=$KEYBINDS_COMBO_COL_MAX
  fi

  local i
  for (( i = 0; i < ${#combos[@]}; i++ )); do
    printf '%-*s%*s%s\n' \
      "$max_combo_len" "${combos[$i]}" \
      "$KEYBINDS_GAP_SPACES" "" \
      "${descs[$i]}"
  done
}

format_for_rofi() {
  local -a combos=()
  local -a descs=()
  local -a icons=()
  local max_combo_len=0

  while IFS=$'\t' read -r combo desc icon; do
    [[ -z "${combo:-}" ]] && continue
    combos+=("$combo")
    descs+=("${desc:-}")
    icons+=("${icon:-$KEYBINDS_DEFAULT_ICON_NAME}")
    if (( ${#combo} > max_combo_len )); then
      max_combo_len=${#combo}
    fi
  done

  if [[ "$KEYBINDS_COMBO_COL_MAX" =~ ^[0-9]+$ ]] && (( max_combo_len > KEYBINDS_COMBO_COL_MAX )); then
    max_combo_len=$KEYBINDS_COMBO_COL_MAX
  fi

  pango_escape() {
    local s=${1-}
    s=${s//&/&amp;}
    s=${s//</&lt;}
    s=${s//>/&gt;}
    printf '%s' "$s"
  }

  truncate_combo() {
    local s=${1-}
    local max=${2-0}
    if (( max <= 0 )); then
      printf '%s' "$s"
      return 0
    fi
    if (( ${#s} <= max )); then
      printf '%s' "$s"
      return 0
    fi
    if (( max == 1 )); then
      printf '…'
      return 0
    fi
    printf '%s…' "${s:0:max-1}"
  }

  local i
  for (( i = 0; i < ${#combos[@]}; i++ )); do
    local combo_truncated padded_combo gap escaped_combo escaped_desc
    combo_truncated="$(truncate_combo "${combos[$i]}" "$max_combo_len")"
    printf -v padded_combo '%-*s' "$max_combo_len" "$combo_truncated"
    printf -v gap '%*s' "$KEYBINDS_GAP_SPACES" ""
    escaped_combo="$(pango_escape "$padded_combo")"
    escaped_desc="$(pango_escape "${descs[$i]}")"

    printf '<span font_family="monospace">%s%s</span>%s\0icon\x1f%s\n' \
      "$escaped_combo" \
      "$gap" \
      "$escaped_desc" \
      "${icons[$i]}"
  done
}

if [[ ! -f "$KEYBINDS_FILE" ]]; then
  echo "找不到快捷键文件：$KEYBINDS_FILE" >&2
  exit 1
fi

if [[ "${1:-}" == "--print" ]]; then
  render_keybinds | format_for_print
  exit 0
fi

# 与普通启动器一致：再次触发则关闭 rofi
if pgrep -x rofi >/dev/null 2>&1; then
  pkill rofi
  exit 0
fi

if ! command -v rofi >/dev/null 2>&1; then
  echo "未找到 rofi，改为打印解析结果：" >&2
  render_keybinds | format_for_print
  exit 1
fi

KEYBINDS_TSV="$(render_keybinds)"
if [[ -z "$KEYBINDS_TSV" ]]; then
  rofi -e "No keybinds found."
  exit 1
fi

printf '%s\n' "$KEYBINDS_TSV" | format_for_rofi | rofi -dmenu -i -show-icons -markup-rows -mesg "Hyprland 快捷键（只读）"
