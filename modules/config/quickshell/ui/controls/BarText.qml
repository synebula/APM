import QtQuick
import "../../theme"

TextLabel {
    font: Theme.typography.withOverrides(Theme.typography.body, { weight: Theme.typography.title.weight })
}
