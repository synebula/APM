import QtQuick
import Quickshell

Scope {
    id: root

    required property int notificationId
    required property var source
    property real receivedAt: Date.now()
    property bool unread: true
    readonly property string appName: root.source ? root.source.appName || "系统" : "系统"
    readonly property string appIcon: root.source ? root.source.appIcon : ""
    readonly property string summary: root.source ? root.source.summary : ""
    readonly property string body: root.source ? root.source.body : ""
    readonly property string image: root.source ? root.source.image : ""
    readonly property string desktopEntry: root.source ? root.source.desktopEntry : ""
    readonly property bool resident: root.source ? root.source.resident : false
    readonly property bool isTransient: root.source ? !!root.source.transient : false
    readonly property int urgency: root.source ? root.source.urgency : 1
    readonly property var actions: root.source ? root.source.actions.filter(action => {
        return action.identifier !== "default";
    }) : []
    readonly property ToastLifetime toast: ToastLifetime {
        onExpired: {
            if (root.isTransient)
                root.expired();
        }
    }

    signal updated
    signal closed
    signal expired

    function invokeAction(actionId) {
        if (!root.source)
            return false;

        const action = root.source.actions.find(item => {
            return item.identifier === actionId;
        });
        if (!action)
            return false;

        action.invoke();
        return true;
    }

    // A replacement updates this same native object without a new server notification signal.
    Timer {
        id: updateTimer

        interval: 0
        onTriggered: root.updated()
    }

    Connections {
        function onClosed() {
            root.closed();
        }

        function onSummaryChanged() {
            updateTimer.restart();
        }

        function onBodyChanged() {
            updateTimer.restart();
        }

        function onActionsChanged() {
            updateTimer.restart();
        }

        function onExpireTimeoutChanged() {
            updateTimer.restart();
        }

        function onUrgencyChanged() {
            updateTimer.restart();
        }

        function onImageChanged() {
            updateTimer.restart();
        }

        target: root.source
    }
}
