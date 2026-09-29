import QtQuick
import ".."

MaterialSpec {
    surface {
        mode: "acrylic"
        fillOpacity: 0.42
        gradientLighten: 1.02
        gradientDarken: 1.01
    }
    border.opacity: 0.45
    elevation {
        shadowEnabled: true
        shadowBlur: 0.82
        shadowVerticalOffset: 6
        shadowOpacity: 0.18
        highlightEnabled: true
        highlightOpacity: 0.45
    }
}
