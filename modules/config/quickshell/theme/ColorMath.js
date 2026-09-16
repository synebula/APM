.pragma library

function luminanceRgb(red, green, blue) {
    function linear(channel) {
        return channel <= 0.04045 ? channel / 12.92 : Math.pow((channel + 0.055) / 1.055, 2.4);
    }
    return 0.2126 * linear(red) + 0.7152 * linear(green) + 0.0722 * linear(blue);
}

function luminance(color) {
    return luminanceRgb(color.r, color.g, color.b);
}

function contrast(first, second) {
    const a = luminance(first);
    const b = luminance(second);
    return (Math.max(a, b) + 0.05) / (Math.min(a, b) + 0.05);
}

function foreground(red, green, blue) {
    const value = luminanceRgb(red, green, blue);
    const lightContrast = 1.05 / (value + 0.05);
    const darkContrast = (value + 0.05) / 0.05;
    return lightContrast > darkContrast ? "#ffffff" : "#000000";
}
