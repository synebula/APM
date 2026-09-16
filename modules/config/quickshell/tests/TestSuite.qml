import QtTest

TestCase {
    function verify(condition, message) {
        if (!condition) {
            console.error("APM_ASSERT " + name + "/" + qtest_results.functionName + ": " + (message || "condition failed"));
            fail(message || "condition failed");
        }
    }

    function compare(actual, expected, message) {
        if (actual !== expected) {
            const detail = (message || "values differ") + ": " + actual + " != " + expected;
            console.error("APM_ASSERT " + name + "/" + qtest_results.functionName + ": " + detail);
            fail(detail);
        }
    }

    // Quickshell embeds the Qt plugins; QtTest's runner executable cannot load them.
    // Report its counters explicitly because Quickshell owns the process exit code.
    onCompletedChanged: {
        if (completed)
            console.log("APM_TEST " + JSON.stringify({
                "name": name,
                "passed": qtest_results.passCount,
                "failed": qtest_results.failCount
            }));
    }
}
