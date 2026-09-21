pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Polkit

Singleton {
    id: root

    signal errorTriggered
    signal authenticationCompleted(bool successful)

    IpcHandler {
        target: "polkit"

        function test(message: string, actionId: string) {
            root.simulateRequest({
                "message": message || "测试认证：QuickShell 原生毛玻璃认证弹窗",
                "actionId": actionId || "org.quickshell.test.auth"
            });
        }

        function cancel() {
            root.cancel();
        }
    }

    property bool isSubmitting: false
    property var simulatedFlow: null

    property var agentFlow: null
    readonly property bool hasSimulation: root.simulatedFlow !== null
    readonly property var activeFlow: root.simulatedFlow !== null ? root.simulatedFlow : root.agentFlow

    readonly property bool isOpen: {
        if (root.simulatedFlow !== null)
            return !!root.simulatedFlow.isOpen;
        const f = root.agentFlow;
        return polkitAgent.isActive && f !== null && !f.isCompleted;
    }

    readonly property string message: {
        if (!root.activeFlow)
            return "";
        if (root.activeFlow.message)
            return root.activeFlow.message;
        if (root.activeFlow.request && root.activeFlow.request.message)
            return root.activeFlow.request.message;
        return "请求特权操作，需要进行身份验证。";
    }

    readonly property string actionId: {
        if (!root.activeFlow)
            return "";
        if (root.activeFlow.actionId)
            return root.activeFlow.actionId;
        if (root.activeFlow.request && root.activeFlow.request.actionId)
            return root.activeFlow.request.actionId;
        return "";
    }

    readonly property string iconName: {
        if (!root.activeFlow)
            return "";
        if (root.activeFlow.iconName)
            return root.activeFlow.iconName;
        if (root.activeFlow.request && root.activeFlow.request.iconName)
            return root.activeFlow.request.iconName;
        return "";
    }

    readonly property var identities: {
        if (!root.activeFlow)
            return [];
        if (root.activeFlow.identities && root.activeFlow.identities.length > 0)
            return root.activeFlow.identities;
        if (root.activeFlow.request && root.activeFlow.request.identities)
            return root.activeFlow.request.identities;
        return [];
    }

    readonly property var selectedIdentity: {
        if (!root.activeFlow)
            return null;
        if (root.activeFlow.selectedIdentity)
            return root.activeFlow.selectedIdentity;
        if (root.activeFlow.request && root.activeFlow.request.selectedIdentity)
            return root.activeFlow.request.selectedIdentity;
        return null;
    }

    readonly property bool isResponseRequired: {
        if (!root.activeFlow)
            return false;
        if (root.activeFlow.isResponseRequired !== undefined)
            return !!root.activeFlow.isResponseRequired;
        return true;
    }

    readonly property string inputPrompt: {
        if (!root.activeFlow)
            return "密码：";
        return root.activeFlow.inputPrompt || "密码：";
    }

    readonly property bool responseVisible: {
        if (!root.activeFlow)
            return false;
        return !!root.activeFlow.responseVisible;
    }

    readonly property string supplementaryMessage: {
        if (!root.activeFlow)
            return "";
        return root.activeFlow.supplementaryMessage || "";
    }

    readonly property bool supplementaryIsError: {
        if (!root.activeFlow)
            return false;
        return !!root.activeFlow.supplementaryIsError;
    }

    readonly property bool failed: {
        if (!root.activeFlow)
            return false;
        return !!root.activeFlow.failed;
    }

    readonly property bool isRegistered: polkitAgent.isRegistered
    readonly property bool isAgentActive: polkitAgent.isActive

    function submit(value) {
        if (!root.isOpen || root.isSubmitting)
            return;

        root.isSubmitting = true;
        if (root.simulatedFlow !== null) {
            if (typeof root.simulatedFlow.onSubmit === "function") {
                root.simulatedFlow.onSubmit(value);
            }
            return;
        }

        const f = root.agentFlow;
        if (f) {
            f.submit(value);
        }
    }

    function cancel() {
        if (!root.isOpen)
            return;

        root.isSubmitting = false;
        if (root.simulatedFlow !== null) {
            if (typeof root.simulatedFlow.onCancel === "function") {
                root.simulatedFlow.onCancel();
            }
            root.simulatedFlow = Object.assign({}, root.simulatedFlow, { "isOpen": false });
            return;
        }

        const f = root.agentFlow;
        if (f) {
            f.cancelAuthenticationRequest();
        }
    }

    function selectIdentity(identity) {
        if (!root.isOpen)
            return;

        if (root.simulatedFlow !== null) {
            root.simulatedFlow = Object.assign({}, root.simulatedFlow, { "selectedIdentity": identity });
            return;
        }

        const f = root.agentFlow;
        if (f) {
            f.selectedIdentity = identity;
        }
    }
    function simulateRequest(options) {
        const currentUser = Quickshell.env("USER") || "current-user";
        const idList = options.identities || [{
            "displayName": options.user || currentUser,
            "string": "unix-user:" + (options.user || currentUser),
            "isGroup": false
        }];

        root.isSubmitting = false;
        root.simulatedFlow = {
            "isOpen": true,
            "message": options.message || "测试提权操作：运行系统管理员命令",
            "actionId": options.actionId || "org.freedesktop.policykit.exec",
            "iconName": options.iconName || "dialog-password",
            "identities": idList,
            "selectedIdentity": idList[0] || null,
            "isResponseRequired": options.isResponseRequired !== undefined ? options.isResponseRequired : true,
            "inputPrompt": options.inputPrompt || "密码：",
            "responseVisible": !!options.responseVisible,
            "supplementaryMessage": options.supplementaryMessage || "",
            "supplementaryIsError": !!options.supplementaryIsError,
            "failed": false,
            "onSubmit": options.onSubmit || null,
            "onCancel": options.onCancel || null
        };
    }

    function updateSimulation(updates) {
        if (!root.simulatedFlow)
            return;

        const updated = Object.assign({}, root.simulatedFlow, updates);
        root.simulatedFlow = updated;
        if (updated.supplementaryIsError) {
            root.isSubmitting = false;
            root.errorTriggered();
        }
    }

    function resetSimulation() {
        root.isSubmitting = false;
        root.simulatedFlow = null;
    }

    PolkitAgent {
        id: polkitAgent
        path: "/org/quickshell/PolkitAgent"

        onFlowChanged: {
            // qmllint disable unresolved-type
            root.agentFlow = polkitAgent["flow"];
            // qmllint enable unresolved-type
        }

        Component.onCompleted: {
            // qmllint disable unresolved-type
            root.agentFlow = polkitAgent["flow"];
            // qmllint enable unresolved-type
        }

        onAuthenticationRequestStarted: {
            root.isSubmitting = false;
        }
    }

    Connections {
        target: root.agentFlow
        ignoreUnknownSignals: true

        function onAuthenticationSucceeded() {
            root.isSubmitting = false;
            root.authenticationCompleted(true);
        }

        function onAuthenticationFailed() {
            root.isSubmitting = false;
            root.errorTriggered();
            root.authenticationCompleted(false);
        }

        function onAuthenticationRequestCancelled() {
            root.isSubmitting = false;
        }

        function onIsResponseRequiredChanged() {
            const f = root.agentFlow;
            if (f && f.isResponseRequired) {
                root.isSubmitting = false;
            }
        }

        function onSupplementaryMessageChanged() {
            const f = root.agentFlow;
            if (f && f.supplementaryIsError) {
                root.isSubmitting = false;
                root.errorTriggered();
            }
        }
    }
}
