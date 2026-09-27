import "../services"
import QtQuick

TestSuite {
    id: root

    property var completedCommands: []

    function test_latestBatchDoesNotCancelCurrentCommand() {
        root.completedCommands = [];
        queue.replacePending([["sh", "-c", "sleep 0.1; exit 3"], ["sh", "-c", "exit 4"]]);
        tryVerify(() => {
            return queue.running;
        });
        queue.replacePending([["sh", "-c", "exit 7"], ["sh", "-c", "exit 0"]]);
        tryCompare(root, "completedCommands", [3, 7, 0]);
        compare(queue.pendingCommands.length, 0);
        verify(!queue.running);
    }

    function test_timeoutSettlesCommandExactlyOnce() {
        root.completedCommands = [];
        queue.timeoutMs = 40;
        queue.replacePending([[
                    "sh", "-c", "sleep 0.2"
                ], [
                    "sh", "-c", "exit 0"
        ]]);
        tryVerify(() => root.completedCommands.length === 2);
        compare(root.completedCommands[0], -1);
        compare(root.completedCommands[1], 0);
        compare(queue.pendingCommands.length, 0);
        verify(!queue.running);
        // A timed-out process may emit a delayed exit after the next command;
        // it must not produce a third completion.
        wait(260);
        compare(root.completedCommands.length, 2);
        compare(root.completedCommands[0], -1);
        compare(root.completedCommands[1], 0);
        queue.timeoutMs = 10000;
    }

    name: "CommandQueue"

    CommandQueue {
        id: queue

        onCommandFinished: (command, exitCode) => {
            return root.completedCommands = root.completedCommands.concat([exitCode]);
        }
    }
}
