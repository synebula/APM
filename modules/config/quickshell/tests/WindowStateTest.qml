import "../services"
import "../services/windowmanager"
import "../services/windowmanager/NiriState.js" as NiriState
import "../services/TrayWindowMatcher.js" as TrayWindowMatcher
import QtQuick

TestSuite {
    id: root

    function state() {
        return {
            "workspaces": [
                {
                    "id": 101,
                    "idx": 1,
                    "name": "11",
                    "output": "left",
                    "is_active": true,
                    "is_focused": true
                },
                {
                    "id": 102,
                    "idx": 2,
                    "name": null,
                    "output": "left",
                    "is_active": false
                },
                {
                    "id": 103,
                    "idx": 1,
                    "name": "6",
                    "output": "right",
                    "is_active": true
                }
            ],
            "windows": [
                {
                    "id": 7,
                    "app_id": "editor",
                    "title": "before",
                    "workspace_id": 101,
                    "is_focused": true
                }
            ]
        };
    }

    function cleanup() {
        backend.publish({
            "windows": [],
            "workspaces": []
        });
    }

    function test_titleChangeKeepsIdentityAndRefreshesActiveWindow() {
        const initial = root.state();
        backend.publish(NiriState.snapshot(initial));
        const original = backend.activeWindow;
        const next = NiriState.apply(initial, {
            "WindowOpenedOrChanged": {
                "window": Object.assign({}, initial.windows[0], {
                    "title": "after"
                })
            }
        });
        backend.publish(NiriState.snapshot(next));
        compare(backend.activeWindow, original);
        compare(original.title, "after");
        compare(original.appId, "editor");
        compare(original.outputName, "left");
        compare(backend.windows.length, 1);
    }

    function test_workspaceActivationPreservesOtherOutput() {
        const next = NiriState.apply(root.state(), {
            "WorkspaceActivated": {
                "id": 102,
                "focused": true
            }
        });
        backend.publish(NiriState.snapshot(next));
        compare(backend.focusedWorkspace.workspaceId, "102");
        verify(!backend.workspaces[0].active);
        verify(backend.workspaces[1].active);
        verify(backend.workspaces[2].active);
    }

    function test_numericNameIsNotPhysicalIndex() {
        compare(NiriState.workspaceReference(root.state(), "11").Name, "11");
        compare(NiriState.workspaceReference(root.state(), "2").Index, 2);
    }

    function test_focusUrgencyAndRemoval() {
        let next = NiriState.apply(root.state(), {
            "WindowUrgencyChanged": {
                "id": 7,
                "urgent": true
            }
        });
        next = NiriState.apply(next, {
            "WindowFocusChanged": {
                "id": null
            }
        });
        backend.publish(NiriState.snapshot(next));
        compare(backend.activeWindow, null);
        verify(backend.windows[0].urgent);
        next = NiriState.apply(next, {
            "WindowClosed": {
                "id": 7
            }
        });
        backend.publish(NiriState.snapshot(next));
        compare(backend.windows.length, 0);
    }

    function test_findWindowForTray() {
        const windows = [
            { windowId: "preview", appId: "wechat", title: "预览" },
            { windowId: "main", appId: "wechat", title: "微信" }
        ];
        const trayItem = {
            id: "wechat",
            title: "wechat",
            tooltipTitle: "微信",
            icon: "wechat"
        };
        const found = TrayWindowMatcher.match(windows, trayItem);
        verify(found !== null);
        compare(found.windowId, "main");
    }

    function test_trayMatcherRejectsWeakAndAmbiguousMatches() {
        compare(TrayWindowMatcher.match([
            { windowId: "editor", appId: "editor", title: "微信文档" }
        ], { id: "wechat", title: "wechat", tooltipTitle: "微信" }), null);
        compare(TrayWindowMatcher.match([
            { windowId: "one", appId: "wechat", title: "微信" },
            { windowId: "two", appId: "wechat", title: "微信" }
        ], { id: "wechat", title: "wechat", tooltipTitle: "微信" }), null);
    }

    function test_workspaceLookupPrioritizesExplicitNameAndScreenScope() {
        const rawState = {
            "workspaces": [
                { "id": 22, "idx": 9, "name": null, "output": "HDMI-A-1", "is_active": false },
                { "id": 12, "idx": 4, "name": "9", "output": "HDMI-A-2", "is_active": false }
            ],
            "windows": [
                { "id": 163, "app_id": "kitty", "title": "term", "workspace_id": 12 }
            ]
        };
        const snap = NiriState.snapshot(rawState);
        compare(snap.workspaces[0].isNamed, false);
        compare(snap.workspaces[1].isNamed, true);
        backend.publish(snap);

        const scoped = backend.workspaces.find(w => w.name === "9" && w.outputName === "HDMI-A-2");
        verify(scoped !== null);
        compare(scoped.workspaceId, "12");

        const resolved = backend.workspaces.find(w => w.name === "9" && w.isNamed)
            || backend.workspaces.find(w => w.name === "9");
        verify(resolved !== null);
        compare(resolved.workspaceId, "12");
    }

    function test_windowsAreSortedByGeometricScrollingLayout() {
        const rawState = {
            "workspaces": [
                { "id": 1, "idx": 1, "name": "1", "output": "HDMI-A-1", "is_active": true }
            ],
            "windows": [
                { "id": 103, "app_id": "c", "title": "col3", "workspace_id": 1, "layout": { "pos_in_scrolling_layout": [3, 1] } },
                { "id": 101, "app_id": "a", "title": "col1", "workspace_id": 1, "layout": { "pos_in_scrolling_layout": [1, 1] } },
                { "id": 104, "app_id": "floating", "title": "float", "workspace_id": 1, "is_floating": true },
                { "id": 102, "app_id": "b", "title": "col2-row2", "workspace_id": 1, "layout": { "pos_in_scrolling_layout": [2, 2] } },
                { "id": 105, "app_id": "b1", "title": "col2-row1", "workspace_id": 1, "layout": { "pos_in_scrolling_layout": [2, 1] } }
            ]
        };
        const snap = NiriState.snapshot(rawState);
        compare(snap.windows.length, 5);
        compare(snap.windows[0].windowId, "101");
        compare(snap.windows[1].windowId, "105");
        compare(snap.windows[2].windowId, "102");
        compare(snap.windows[3].windowId, "103");
        compare(snap.windows[4].windowId, "104");

        const updated = NiriState.apply(rawState, {
            "WindowLayoutsChanged": {
                "changes": [
                    [103, { "pos_in_scrolling_layout": [1, 1] }],
                    [101, { "pos_in_scrolling_layout": [3, 1] }]
                ]
            }
        });
        const nextSnap = NiriState.snapshot(updated);
        compare(nextSnap.windows[0].windowId, "103");
        compare(nextSnap.windows[3].windowId, "101");
    }

    name: "WindowState"

    WindowManagerBackend {
        id: backend
    }
}
