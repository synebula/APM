pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls as Controls
import QtQuick.Layouts
import Quickshell

import "../../theme"
import "../../ui/containers"
import "../../ui/controls"

PopupPanel {
    id: root
    property QsMenuHandle menuHandle: null
    alignRight: true
    contentWidth: 240 * Theme.controlScale
    contentHeight: (stack.currentItem ? stack.currentItem.implicitHeight : 0) + Theme.components.popup.padding * 2
    onIsOpenChanged: {
        if (!isOpen && stack.depth > 1)
            stack.pop(null, Controls.StackView.Immediate);
    }

    Controls.StackView {
        id: stack
        anchors.fill: parent
        anchors.margins: Theme.components.popup.padding
        initialItem: MenuPage {
            handle: root.menuHandle
            isRoot: true
        }
        Keys.onEscapePressed: {
            if (depth > 1)
                pop();
            else
                root.close();
        }
        pushEnter: Transition {
            NumberAnimation {
                property: "opacity"
                from: 0
                to: 1
                duration: Theme.motion.fastEffects.duration
            }
        }
        pushExit: Transition {
            NumberAnimation {
                property: "opacity"
                from: 1
                to: 0
                duration: Theme.motion.fastEffects.duration
            }
        }
        popEnter: pushEnter
        popExit: pushExit
    }

    Component {
        id: pageFactory
        MenuPage {}
    }

    component MenuPage: ColumnLayout {
        id: page
        property QsMenuHandle handle: null
        property bool isRoot: false
        spacing: Theme.spacing.small
        QsMenuOpener {
            id: opener
            menu: page.handle
        }

        ActionRow {
            visible: !page.isRoot
            text: "返回上一级"
            glyph: ""
            Layout.fillWidth: true
            onClicked: stack.pop()
        }
        Repeater {
            model: opener.children
            delegate: Item {
                id: entry
                required property QsMenuEntry modelData
                Layout.fillWidth: true
                implicitHeight: modelData.isSeparator ? Theme.spacing.medium : action.implicitHeight
                Divider {
                    visible: entry.modelData.isSeparator
                    width: parent.width
                    anchors.verticalCenter: parent.verticalCenter
                }
                ActionRow {
                    id: action
                    visible: !entry.modelData.isSeparator
                    width: parent.width
                    enabled: entry.modelData.enabled
                    text: entry.modelData.text.replace(/&/g, "")
                    icon.source: entry.modelData.icon
                    selected: entry.modelData.checkState === Qt.Checked
                    glyph: entry.modelData.buttonType === QsMenuButtonType.RadioButton ? (selected ? "●" : "○") : (selected ? "✓" : "")
                    trailingText: entry.modelData.hasChildren ? "›" : ""
                    onClicked: {
                        if (entry.modelData.hasChildren)
                            stack.push(pageFactory, {
                                handle: entry.modelData
                            });
                        else {
                            entry.modelData.triggered();
                            root.close();
                        }
                    }
                }
            }
        }
    }
}
