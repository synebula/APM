pragma Singleton
import "../../services"
import "../../ui/controllers"
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property var actions: [
        {
            "actionId": "lock",
            "label": "锁定",
            "glyph": "",
            "destructive": false
        },
        {
            "actionId": "logout",
            "label": "注销",
            "glyph": "",
            "destructive": false,
            "title": "注销会话",
            "message": "确定要注销当前桌面会话吗？未保存的工作可能会丢失。"
        },
        {
            "actionId": "suspend",
            "label": "睡眠",
            "glyph": "",
            "destructive": false,
            "title": "睡眠系统",
            "message": "确定将计算机睡眠吗？当前会话保存到内存，可快速恢复。"
        },
        {
            "actionId": "reboot",
            "label": "重启",
            "glyph": "",
            "destructive": true,
            "title": "重启系统",
            "message": "确定要重启计算机吗？请先保存正在进行的工作。"
        },
        {
            "actionId": "poweroff",
            "label": "关机",
            "glyph": "",
            "destructive": true,
            "title": "关闭计算机",
            "message": "确定要关闭计算机电源吗？"
        }
    ]

    function request(actionId: string) {
        const action = root.actions.find(item => {
            return item.actionId === actionId;
        });
        if (!action)
            return;

        if (actionId === "lock") {
            root.execute(actionId);
            return;
        }
        ConfirmationController.ask({
            "title": action.title,
            "message": action.message,
            "glyph": action.glyph,
            "confirmText": action.label,
            "destructive": action.destructive,
            "onConfirmed": () => {
                return root.execute(actionId);
            }
        });
    }

    function execute(actionId) {
        if (actionId === "lock") {
            Quickshell.execDetached(["hyprlock"]);
        } else if (actionId === "logout") {
            if (!WindowManagerService.exitSession())
                Quickshell.execDetached(["loginctl", "terminate-session", "self"]);
        } else if (actionId === "reboot" || actionId === "poweroff" || actionId === "suspend") {
            Quickshell.execDetached(["systemctl", actionId]);
        }
    }

    IpcHandler {
        function logout() {
            root.request("logout");
        }

        function reboot() {
            root.request("reboot");
        }

        function suspend() {
            root.request("suspend");
        }

        function poweroff() {
            root.request("poweroff");
        }

        function cancel() {
            ConfirmationController.cancel();
        }

        function confirm() {
            ConfirmationController.confirm();
        }

        target: "confirm"
    }
}
