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

test_timeout=${APM_QUICKSHELL_TEST_TIMEOUT:-60}
if [[ ! "$test_timeout" =~ ^[1-9][0-9]*$ ]]; then
    echo "APM_QUICKSHELL_TEST_TIMEOUT must be a positive number of seconds." >&2
    exit 2
fi

set +e
env \
    XDG_STATE_HOME="${test_state_dir}" \
    APM_QUICKSHELL_TEST_MODE=1 \
    timeout --kill-after=5s "${test_timeout}s" qs -p "${shell_dir}/tests.qml" --no-color "$@" 2>&1 | tee "${test_state_dir}/results.log"
process_status=$?
set -e
if (( process_status != 0 )); then
    echo "QuickShell test process failed or timed out (exit ${process_status})." >&2
    exit "$process_status"
fi

# QuickShell can exit successfully even when QtTest reports failed assertions.
# Every registered suite must produce exactly one complete, successful result.
awk '
    /APM_TEST_BEGIN / {
        name = substr($0, index($0, "APM_TEST_BEGIN ") + 15)
        if (name !~ /^[A-Za-z][A-Za-z0-9_]*$/ || name in started) invalid = 1
        started[name] = 1
        next
    }
    /APM_TEST / {
        record = substr($0, index($0, "APM_TEST ") + 9)
        if (record !~ /^\{"name":"[A-Za-z][A-Za-z0-9_]*","passed":[0-9]+,"failed":[0-9]+\}$/) {
            print "Invalid test result: " record
            invalid = 1
            next
        }
        split(record, fields, /[":,{}]+/)
        name = fields[3]
        if (!(name in started) || name in finished) invalid = 1
        finished[name] = 1
        passed += fields[5]
        failed += fields[7]
    }
    END {
        count = 0
        for (name in started) {
            count++
            if (!(name in finished)) {
                print "Test suite did not finish: " name
                invalid = 1
            }
        }
        if (count == 0 || passed + failed == 0) invalid = 1
        printf "Test results: %d suites, %d passed, %d failed\n", count, passed, failed
        if (invalid) print "Test run is incomplete or has invalid results."
        exit (invalid || failed > 0)
    }
' "${test_state_dir}/results.log"
