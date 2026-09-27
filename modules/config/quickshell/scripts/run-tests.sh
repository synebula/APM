#!/usr/bin/env bash
set -euo pipefail

script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
shell_dir=$(cd -- "${script_dir}/.." && pwd)
test_state_dir=$(mktemp -d /tmp/apm-quickshell-tests.XXXXXX)

cleanup() {
    rm -rf -- "${test_state_dir}"
}
trap cleanup EXIT

base64 -d > "${test_state_dir}/test_wallpaper.gif" <<'EOF'
R0lGODlhAgACAIEAAP8AAAAAAAAAAAAAACH/C05FVFNDQVBFMi4wAwEAAAAh+QQACgAAACwAAAAAAgACAAAIBgABCAQQEAAh+QQBCgABACwAAAAAAgACAIEA/wAAAAAAAAAAAAAIBgABCAQQEAA7
EOF

exec env \
    XDG_STATE_HOME="${test_state_dir}" \
    APM_QUICKSHELL_TEST_MODE=1 \
    qs -p "${shell_dir}/tests.qml" "$@"
