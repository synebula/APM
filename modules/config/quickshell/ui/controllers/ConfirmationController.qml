pragma Singleton
import Quickshell

Singleton {
    id: root

    property bool isOpen: false
    property var request: ({})
    property var callback: null

    function ask(options) {
        root.request = {
            "title": options.title || "确认操作",
            "message": options.message || "确定要继续吗？",
            "glyph": options.glyph || "",
            "confirmText": options.confirmText || "确定",
            "cancelText": options.cancelText || "取消",
            "destructive": !!options.destructive
        };
        root.callback = options.onConfirmed || null;
        root.isOpen = true;
    }

    function confirm() {
        if (!root.isOpen)
            return;

        const action = root.callback;
        root.cancel();
        if (action)
            action();
    }

    function cancel() {
        root.isOpen = false;
        root.callback = null;
    }
}
