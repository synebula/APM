#!/usr/bin/env bash
set -euo pipefail
test_dir=$(mktemp -d /tmp/apm-qs-runner-test.XXXXXX)
trap 'rm -rf -- "$test_dir"' EXIT
source_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
mkdir -p "$test_dir/bin" "$test_dir/scripts" "$test_dir/state"
cp "$source_dir/scripts/run-tests.sh" "$test_dir/scripts/run-tests.sh"
cat > "$test_dir/bin/qs" <<'EOF'
#!/usr/bin/env bash
printf '%s\n' "$XDG_STATE_HOME" > "$RUNNER_STATE_PATH"
case "$RUNNER_CASE" in
    success)
        echo 'DEBUG qml: APM_TEST_BEGIN Example'
        echo 'DEBUG qml: APM_TEST {"name":"Example","passed":2,"failed":0}' ;;
    failure)
        echo 'DEBUG qml: APM_TEST_BEGIN Example'
        echo 'DEBUG qml: APM_TEST {"name":"Example","passed":1,"failed":1}' ;;
    incomplete)
        echo 'DEBUG qml: APM_TEST_BEGIN Example'
        echo 'DEBUG qml: APM_TEST_BEGIN Missing'
        echo 'DEBUG qml: APM_TEST {"name":"Example","passed":2,"failed":0}' ;;
    duplicate)
        echo 'DEBUG qml: APM_TEST_BEGIN Example'
        for i in 1 2; do echo 'DEBUG qml: APM_TEST {"name":"Example","passed":2,"failed":0}'; done ;;
    malformed)
        echo 'DEBUG qml: APM_TEST_BEGIN Example'
        echo 'DEBUG qml: APM_TEST {"name":"Example","passed":2}' ;;
    empty) ;;
    crash) exit 9 ;;
    timeout) sleep 5 ;;
esac
EOF
chmod +x "$test_dir/bin/qs"
for scenario in success failure incomplete duplicate malformed empty crash timeout; do
    result=0
    env PATH="$test_dir/bin:$PATH" RUNNER_CASE="$scenario" RUNNER_STATE_PATH="$test_dir/state/path" \
        APM_QUICKSHELL_TEST_TIMEOUT=1 bash "$test_dir/scripts/run-tests.sh" > "$test_dir/result.log" 2>&1 || result=$?
    if [[ "$scenario" == success && "$result" != 0 ]] || [[ "$scenario" != success && "$result" == 0 ]]; then
        cat "$test_dir/result.log"
        echo "Runner failed scenario: $scenario (exit $result)" >&2
        exit 1
    fi
    if [[ -e "$(cat "$test_dir/state/path")" ]]; then
        echo "Runner left its temporary state behind: $scenario" >&2
        exit 1
    fi
done
echo 'Runner: 8 scenarios passed.'
