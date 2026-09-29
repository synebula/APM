import QtQuick
import "../geometry/runtime"

QtObject {
    id: root

    required property SpacingTokens spacing

    readonly property int separatorHeight: root.spacing.medium
}
