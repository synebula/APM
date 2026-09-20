import "../features/notifications"
import QtQuick

TestSuite {
    id: root

    function cleanup() {
        notifications.clearAll();
        notifications.doNotDisturb = false;
        notifications.centerOpen = false;
        lifetime.hide();
        lifetime.setPaused(leftScreen, false);
        lifetime.setPaused(rightScreen, false);
    }

    function test_hoverPausesAcrossScreensAndReplacementResetsTime() {
        lifetime.show(100);
        wait(30);
        lifetime.setPaused(leftScreen, true);
        lifetime.setPaused(rightScreen, true);
        const remaining = lifetime.remaining;
        wait(140);
        verify(lifetime.visible);
        compare(lifetime.remaining, remaining);
        lifetime.setPaused(leftScreen, false);
        verify(lifetime.paused);
        lifetime.show(120);
        compare(lifetime.remaining, 120);
        lifetime.setPaused(rightScreen, false);
        tryVerify(() => {
            return !lifetime.visible;
        }, 500);
    }

    function test_zeroTimeoutRemainsVisible() {
        lifetime.show(0);
        wait(120);
        verify(lifetime.visible);
        compare(lifetime.progress, 1);
    }

    function test_nativePropertyUpdateRefreshesOneRecord() {
        const source = createTemporaryObject(sourceFactory, root);
        const record = notifications.receive(7, source, null, false);
        compare(notifications.records.length, 1);
        compare(notifications.unreadCount, 1);
        notifications.markAllRead();
        verify(!record.toast.visible);
        source.summary = "Updated version";
        tryVerify(() => {
            return record.toast.visible;
        });
        compare(record.summary, "Updated version");
        compare(notifications.records.length, 1);
        compare(notifications.unreadCount, 1);
        source.closed();
        compare(notifications.records.length, 0);
        compare(notifications.unreadCount, 0);
    }

    function test_dndAndReloadDoNotReplayToasts() {
        notifications.doNotDisturb = true;
        const source = createTemporaryObject(sourceFactory, root);
        const first = notifications.receive(1, source, null, false);
        verify(!first.toast.visible);
        compare(notifications.unreadCount, 1);
        const restored = notifications.receive(2, createTemporaryObject(sourceFactory, root), {
            "receivedAt": 123,
            "unread": false
        }, true);
        verify(!restored.toast.visible);
        compare(restored.receivedAt, 123);
        notifications.centerOpen = true;
        compare(notifications.unreadCount, 0);
    }

    function test_residentActionKeepsHistory() {
        const source = createTemporaryObject(sourceFactory, root, {
            "resident": true
        });
        const record = notifications.receive(5, source, null, false);
        notifications.finishInteraction(record);
        compare(notifications.records.length, 1);
        verify(!record.toast.visible);
        compare(notifications.unreadCount, 0);
    }

    name: "Notifications"

    NotificationStore {
        id: notifications
    }

    ToastLifetime {
        id: lifetime
    }

    QtObject {
        id: leftScreen
    }

    QtObject {
        id: rightScreen
    }

    Component {
        id: sourceFactory

        QtObject {
            property string appName: "Test"
            property string appIcon: ""
            property string summary: "First version"
            property string body: "Body"
            property string desktopEntry: "test"
            property string image: ""
            property bool resident: false
            property int urgency: 1
            property real expireTimeout: 150
            property var actions: []

            signal closed

            function dismiss() {
                closed();
            }
        }
    }
}
