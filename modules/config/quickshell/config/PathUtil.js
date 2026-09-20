.pragma library

/**
 * 展开以 ~ 或 $HOME 开头的相对用户目录路径
 * @param {string} path 待展开的路径
 * @param {string} homePath 用户家目录绝对路径（如 Quickshell.env("HOME")）
 * @returns {string} 展开后的绝对路径
 */
function expandHome(path, homePath) {
    if (typeof path !== "string" || path.length === 0)
        return "";
    var home = (typeof homePath === "string" && homePath.length > 0) ? homePath.replace(/\/+$/, "") : "";
    if (path === "~")
        return home || path;
    if (path.startsWith("~/"))
        return home ? (home + path.slice(1)) : path;
    if (path === "$HOME")
        return home || path;
    if (path.startsWith("$HOME/"))
        return home ? (home + path.slice(5)) : path;
    return path;
}

/**
 * 校验路径是否非空且格式合法
 */
function isValidPath(path) {
    if (typeof path !== "string" || path.trim().length === 0)
        return false;
    return path.indexOf("\u0000") === -1 && path.indexOf("\n") === -1;
}
