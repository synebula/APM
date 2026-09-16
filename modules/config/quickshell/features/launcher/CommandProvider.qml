import "./LauncherSearch.js" as LauncherSearch
import Quickshell
import Quickshell.Io

Scope {
    id: root

    readonly property string mode: "commands"
    readonly property string placeholder: "运行命令"
    readonly property string glyph: ""
    property var commands: []

    function result(command) {
        return {
            "key": command,
            "label": command,
            "description": "",
            "icon": "utilities-terminal",
            "searchTerms": [command]
        };
    }

    function search(query, history) {
        const commands = Array.from(new Set(Object.keys(history || {}).concat(root.commands)));
        const matches = LauncherSearch.rank(commands.map(command => {
            return root.result(command);
        }), query, history);
        const typed = query.trim();
        // Keep arguments and shell expressions intact instead of selecting a fuzzy executable match.
        if (typed && !matches.some(entry => {
            return entry.key === typed;
        })) {
            if (/\s|[|;&<>]/.test(typed) || matches.length === 0)
                matches.unshift(root.result(typed));
            else
                matches.push(root.result(typed));
        }
        return matches.slice(0, 100);
    }

    function launch(result, inTerminal) {
        const command = ["sh", "-c", result.key];
        Quickshell.execDetached(inTerminal ? ["kitty", "-e"].concat(command) : command);
    }

    Process {
        command: ["bash", "-c", "compgen -c | sort -u"]
        running: true

        stdout: StdioCollector {
            onStreamFinished: root.commands = text.split("\n").filter(command => {
                return command.length > 0;
            })
        }
    }
}
