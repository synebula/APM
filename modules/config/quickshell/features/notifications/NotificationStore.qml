pragma ComponentBehavior: Bound
import QtQuick
import Quickshell

import "../../config"

Scope {
    id: root

    property bool doNotDisturb: false
    property bool centerOpen: false
    property list<NotificationRecord> records: []
    readonly property var toasts: root.records.filter(record => record.toast.visible)
    readonly property int unreadCount: root.records.filter(record => record.unread).length
    signal changed

    onDoNotDisturbChanged: {
        if (root.doNotDisturb) {
            for (const record of root.records)
                record.toast.hide();
        }
    }
    onCenterOpenChanged: {
        if (root.centerOpen)
            root.markAllRead();
    }

    function receive(notificationId, source, metadata, restored) {
        const existing = root.records.find(record => record.notificationId === notificationId);
        if (existing) {
            root.present(existing);
            return existing;
        }
        const record = recordFactory.createObject(root, {
            notificationId: notificationId,
            source: source,
            receivedAt: metadata ? metadata.receivedAt : Date.now(),
            unread: restored ? !!(metadata && metadata.unread) : !root.centerOpen
        });
        root.records = [record].concat(root.records);
        while (root.records.length > ShellSettings.notificationHistoryLimit)
            root.dismiss(root.records[root.records.length - 1].notificationId);
        if (!restored)
            root.present(record);
        root.changed();
        return record;
    }

    function present(record) {
        record.receivedAt = Date.now();
        record.unread = !root.centerOpen;
        if (!root.doNotDisturb && !root.centerOpen) {
            const seconds = record.source.expireTimeout;
            const duration = seconds === 0 || record.urgency === 2 ? 0 : (seconds > 0 ? Math.round(seconds * 1000) : ShellSettings.notificationTimeout);
            record.toast.show(duration);
        }
        root.changed();
    }

    function remove(notificationId) {
        const record = root.records.find(item => item.notificationId === notificationId);
        if (!record)
            return;
        record.toast.hide();
        root.records = root.records.filter(item => item !== record);
        record.destroy();
        root.changed();
    }

    function dismiss(notificationId) {
        const record = root.records.find(item => item.notificationId === notificationId);
        if (!record)
            return;
        const source = record.source;
        root.remove(notificationId);
        if (source)
            source.dismiss();
    }

    function finishInteraction(record) {
        if (!record || !root.records.includes(record))
            return;
        record.unread = false;
        if (record.resident)
            record.toast.hide();
        else
            root.dismiss(record.notificationId);
        root.changed();
    }

    function clearAll() {
        const ids = root.records.map(record => record.notificationId);
        for (const id of ids)
            root.dismiss(id);
    }

    function markAllRead() {
        for (const record of root.records) {
            record.unread = false;
            record.toast.hide();
        }
        root.changed();
    }

    Component {
        id: recordFactory
        NotificationRecord {
            id: record
            onUpdated: root.present(record)
            onClosed: root.remove(record.notificationId)
            onExpired: root.dismiss(record.notificationId)
        }
    }
}
