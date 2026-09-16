pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Notifications

import "../../services"

Singleton {
    id: root

    signal toggleCenterRequested()

    property alias doNotDisturb: persistent.doNotDisturb
    property alias centerOpen: store.centerOpen
    readonly property list<NotificationRecord> records: store.records
    readonly property var toasts: store.toasts
    readonly property int unreadCount: store.unreadCount
    property var restoredMetadata: null

    function toggleDoNotDisturb() {
        root.doNotDisturb = !root.doNotDisturb;
    }
    function toggleCenter() {
        root.toggleCenterRequested();
    }
    function clearAll() {
        store.clearAll();
    }

    IpcHandler {
        target: "notifications"
        function toggle() {
            root.toggleCenter();
        }
        function clearAll() {
            root.clearAll();
        }
    }
    function dismiss(notificationId) {
        store.dismiss(notificationId);
    }
    function markAllRead() {
        store.markAllRead();
    }

    function activate(notificationId) {
        const record = store.records.find(item => item.notificationId === notificationId);
        if (!record)
            return;
        const appId = record.desktopEntry || record.appName;
        record.invokeAction("default");
        if (appId)
            WindowManagerService.focusApplication(appId);
        store.finishInteraction(record);
    }

    function invokeAction(notificationId, actionId) {
        const record = store.records.find(item => item.notificationId === notificationId);
        if (!record)
            return;
        record.invokeAction(actionId);
        store.finishInteraction(record);
    }

    PersistentProperties {
        id: persistent
        reloadableId: "notification-state"
        property bool doNotDisturb: false
        property var metadata: ({})
    }

    NotificationStore {
        id: store
        doNotDisturb: root.doNotDisturb
        onChanged: {
            const metadata = {};
            for (const record of store.records)
                metadata[record.notificationId] = {
                    receivedAt: record.receivedAt,
                    unread: record.unread
                };
            persistent.metadata = metadata;
        }
    }

    NotificationServer {
        keepOnReload: true
        actionsSupported: true
        bodyMarkupSupported: true
        bodySupported: true
        imageSupported: true
        persistenceSupported: true
        onNotification: notification => {
            if (root.restoredMetadata === null)
                root.restoredMetadata = Object.assign({}, persistent.metadata);
            notification.tracked = true;
            store.receive(notification.id, notification, notification.lastGeneration ? root.restoredMetadata[notification.id] : null, notification.lastGeneration);
        }
    }
}
