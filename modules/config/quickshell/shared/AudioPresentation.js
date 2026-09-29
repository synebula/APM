.pragma library

function deviceGlyph(node) {
    if (!node) return "󰝟";
    const properties = node.properties || {};
    const description = [properties["device.icon-name"], properties["media.icon-name"], node.description, node.name]
        .join(" ").toLowerCase();
    if (node.isStream) return "󰎈";
    if (description.includes("headphone") || description.includes("headset")) return "󰋋";
    if (description.includes("bluetooth") || description.includes("bluez")) return node.isSink ? "󰋋" : "󰍬";
    if (description.includes("hdmi") || description.includes("displayport")) return "󰽟";
    if (description.includes("speaker")) return "󰓃";
    return node.isSink ? "󰕾" : "󰍬";
}
