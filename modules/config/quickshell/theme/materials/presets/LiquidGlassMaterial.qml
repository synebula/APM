import QtQuick
import ".."

MaterialSpec {
    surface {
        mode: "liquid"
        fillOpacity: 0.10
        gradientLighten: 1.06
        gradientDarken: 0.94
        fresnelStrength: 0.85
        specularOpacity: 0.60
        textHaloOpacity: 0.20
    }
    border.opacity: 0.90
    elevation {
        shadowEnabled: true
        shadowBlur: 0.90
        shadowVerticalOffset: 8
        shadowOpacity: 0.22
        highlightEnabled: true
        highlightOpacity: 0.65
    }
}
