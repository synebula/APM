import QtQuick

import "../features/session"
import "../services"
import "../theme"

// Application-level eager wiring. Feature views stay focused on presentation;
// long-lived services are instantiated once at the composition root.
QtObject {
    id: root

    readonly property var themeController: ThemeController
    readonly property var themeSyncService: ThemeSyncService
    readonly property var sessionActions: SessionActions
    readonly property var polkitService: PolkitService
}
