import QtQuick

QtObject {
    // Shared family; an empty family lets the user's setting supply the font.
    property string family: ""
    // Bind subproperties so derived presets can override one without replacing the font.
    property font small
    small { family: ""; pixelSize: 10 }
    property font caption
    caption { family: ""; pixelSize: 11 }
    property font body
    body { family: ""; pixelSize: 12; weight: Font.Normal }
    property font title
    title { family: ""; pixelSize: 15; weight: Font.Bold }
    property font heading
    heading { family: ""; pixelSize: 20 }
}
