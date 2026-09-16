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

    name: "CommandQueue"

    CommandQueue {
        id: queue

        onCommandFinished: (command, exitCode) => {
            return root.completedCommands = root.completedCommands.concat([exitCode]);
        }
    }
}
