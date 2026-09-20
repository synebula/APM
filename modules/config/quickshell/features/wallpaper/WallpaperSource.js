.pragma library

function localPath(source) {
    var path = String(source || "").trim();
    if (!path.startsWith("file://"))
        return path;
    path = path.slice(7);
    if (path.startsWith("localhost/"))
        path = path.slice(9);
    if (!path.startsWith("/"))
        return "";
    try {
        return decodeURIComponent(path);
    } catch (error) {
        return "";
    }
}

function kind(source) {
    if (typeof source !== "string" || source === "")
        return "empty";
    if (/^#[0-9a-fA-F]{6}([0-9a-fA-F]{2})?$/.test(source))
        return "solid";
    var path = localPath(source);
    if (path.indexOf("\u0000") >= 0 || path.indexOf("\n") >= 0 || path.startsWith("#")
            || /^[a-zA-Z][a-zA-Z0-9+.-]*:/.test(path))
        return "invalid";
    return /\.(jpg|jpeg|png|webp|bmp|gif)$/i.test(path) ? "image" : "invalid";
}

function isImage(source) {
    return kind(source) === "image";
}

function isSolid(source) {
    return kind(source) === "solid";
}
