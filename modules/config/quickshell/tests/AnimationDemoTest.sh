#!/usr/bin/env bash
set -euo pipefail

shell_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
test_dir=$(mktemp -d /tmp/apm-animation-demo-test.XXXXXX)
trap 'rm -rf -- "$test_dir"' EXIT

# Launch the actual entry point: importing it from another QML root would hide
# errors in Quickshell's configuration-root-relative import resolution.
result=0
env XDG_STATE_HOME="$test_dir/state" APM_QUICKSHELL_TEST_MODE=1 \
    QT_QPA_PLATFORM=offscreen QT_QUICK_BACKEND=software \
    timeout --kill-after=2s 4s qs -p "$shell_dir/animations.qml" --no-color \
    > "$test_dir/launch.log" 2>&1 || result=$?

if [[ "$result" != 124 ]] \
    || ! rg -q 'INFO: Configuration Loaded' "$test_dir/launch.log" \
    || rg -q 'ERROR|ReferenceError|TypeError|is not a type|is not defined|Unable to assign' "$test_dir/launch.log"; then
    cat "$test_dir/launch.log"
    echo "Animation demo failed to load or stay running (exit $result)." >&2
    exit 1
fi

echo 'Animation demo: standalone entry loaded successfully.'
