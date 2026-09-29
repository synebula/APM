import QtQuick
import ".."

MaterialSpec {
    surface {
        mode: "gradient"
        gradientLighten: 1.018
        gradientDarken: 1.018
    }
    border {
        width: 0
        colorPolicy: "transparent"
    }
    elevation {
        shadowEnabled: true
        shadowBlur: 0.65
        shadowHorizontalOffset: 2
        shadowVerticalOffset: 3
        shadowOpacity: 0.20
        shadowColorPolicy: "foreground"
        highlightEnabled: true
        highlightOpacity: 0.20
    }
}
