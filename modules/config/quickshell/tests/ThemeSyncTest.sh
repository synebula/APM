#!/usr/bin/env bash
set -euo pipefail
shell_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
test_dir=$(mktemp -d /tmp/apm-qs-sync-test.XXXXXX)
trap 'rm -rf -- "$test_dir"' EXIT
mkdir -p "$test_dir/bin" "$test_dir/state" "$test_dir/config/niri"
ln -s "$shell_dir" "$test_dir/project"

# Intercept only the service's script invocation; no desktop settings are changed.
cat > "$test_dir/bin/bash" <<'SH'
#!/usr/bin/bash
if [[ "${1##*/}" != sync-desktop-theme.sh ]]; then
    exec /usr/bin/bash "$@"
fi
shift
palette=
while (( $# )); do
    if [[ "$1" == --palette ]]; then palette=$2; fi
    shift 2
done
printf '%s\n' "$palette" >> "$SYNC_TEST_DIR/commands"
case "$palette" in
    catppuccin) sleep 0.2; exit 7 ;;
    everforest) exit 0 ;;
    *) exit 9 ;;
esac
SH
chmod +x "$test_dir/bin/bash"
cat > "$test_dir/test.qml" <<'QML'
import QtQuick
import Quickshell
import "project/config"
import "project/services"
import "project/theme/appearance"

ShellRoot {
    id: root
    property int completions: 0
    property bool failed: false
    readonly property var service: ThemeSyncService
    Component.onCompleted: service.enabled = false
    function check(condition, message) {
        if (!condition) {
            failed = true;
            console.error("SYNC_TEST_FAIL", message);
        }
    }
    Timer {
        interval: 50
        running: AppearanceSettings.ready
        onTriggered: {
            root.check(!ThemeSyncService.syncNow(), "disabled service accepted a request");
            ThemeController.setColorMode("light");
            ThemeController.setPalette("catppuccin");
            ThemeSyncService.enabled = true;
            root.check(ThemeSyncService.syncNow(), "first request rejected");
            root.check(ThemeSyncService.syncing, "missing running state");
            ThemeController.setPalette("nord");
            ThemeSyncService.syncNow();
            ThemeController.setPalette("everforest");
            ThemeSyncService.syncNow();
        }
    }
    Connections {
        target: ThemeSyncService
        function onSyncFinished(exitCode) {
            root.check(exitCode === (root.completions === 0 ? 7 : 0), "unexpected exit code");
            root.check(ThemeSyncService.lastExitCode === exitCode, "missing completion status");
            root.completions++;
        }
    }
    Timer {
        interval: 50
        repeat: true
        running: true
        onTriggered: {
            if (root.completions < 2 || ThemeSyncService.syncing)
                return;
            ThemeSyncService.enabled = false;
            if (!root.failed && root.completions === 2)
                console.log("SYNC_TEST_PASS");
            Qt.quit();
        }
    }
}
QML
env -u WAYLAND_DISPLAY -u NIRI_SOCKET -u HYPRLAND_INSTANCE_SIGNATURE \
    PATH="$test_dir/bin:$PATH" SYNC_TEST_DIR="$test_dir" \
    QT_QPA_PLATFORM=offscreen APM_QUICKSHELL_TEST_MODE=0 \
    XDG_STATE_HOME="$test_dir/state" XDG_CONFIG_HOME="$test_dir/config" \
    timeout --kill-after=2s 10s qs -p "$test_dir/test.qml" --no-color > "$test_dir/service.log" 2>&1 || {
        cat "$test_dir/service.log"; exit 1;
    }
if ! grep -q 'SYNC_TEST_PASS' "$test_dir/service.log" || grep -q 'SYNC_TEST_FAIL' "$test_dir/service.log"; then
    cat "$test_dir/service.log"
    exit 1
fi
printf 'catppuccin\neverforest\n' > "$test_dir/expected"
diff -u "$test_dir/expected" "$test_dir/commands"

# Exercise the real sync script with fake desktop commands, including partial failure.
cat > "$test_dir/bin/desktop-command" <<'SH'
#!/usr/bin/bash
name=${0##*/}
printf '%s\n' "$name" >> "$SYNC_TEST_DIR/targets"
case "$name" in
    gsettings|darkman) [[ "$SYNC_TEST_FAILURE" != gtk ]] ;;
    niri) [[ "$SYNC_TEST_FAILURE" != niri ]] ;;
    hyprctl) [[ "$SYNC_TEST_FAILURE" != hyprland ]] ;;
esac
SH
chmod +x "$test_dir/bin/desktop-command"
for command in gsettings darkman niri hyprctl; do
    ln -s desktop-command "$test_dir/bin/$command"
done
touch "$test_dir/config/niri/config.kdl"
for scenario in none gtk niri hyprland; do
    : > "$test_dir/targets"
    result=0
    env PATH="$test_dir/bin:$PATH" SYNC_TEST_DIR="$test_dir" SYNC_TEST_FAILURE="$scenario" \
        XDG_CONFIG_HOME="$test_dir/config" NIRI_SOCKET=test HYPRLAND_INSTANCE_SIGNATURE=test \
        /usr/bin/bash "$shell_dir/scripts/sync-desktop-theme.sh" \
        > "$test_dir/script.log" 2>&1 || result=$?
    if [[ "$scenario" == none ]]; then
        test "$result" = 0
        test -s "$test_dir/config/niri/theme-colors.kdl"
    else
        test "$result" = 1
        grep -q "Theme sync failed: $scenario" "$test_dir/script.log"
    fi
    # One failed target must not prevent the remaining targets from being attempted.
    for command in gsettings darkman niri hyprctl; do
        grep -qx "$command" "$test_dir/targets"
    done
done
echo 'Theme sync: coalescing, completion status and 4 script scenarios passed.'
