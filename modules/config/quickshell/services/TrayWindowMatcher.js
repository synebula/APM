.pragma library

function clean(value) {
    return String(value || "").trim().toLowerCase();
}

function normalizedAppId(value) {
    return clean(value).replace(/\.desktop$/, "");
}

function basename(value) {
    const parts = clean(value).split("/");
    return normalizedAppId(parts[parts.length - 1].replace(/\.(png|svg|ico)$/, ""));
}

function match(windows, trayItem) {
    if (!trayItem || !windows || windows.length === 0)
        return null;

    const identifiers = [
        normalizedAppId(trayItem.id),
        normalizedAppId(trayItem.title),
        basename(trayItem.icon)
    ].filter(value => value.length > 0);
    const tooltip = clean(trayItem.tooltipTitle);
    let bestWindow = null;
    let bestScore = 0;
    let tied = false;

    for (let i = 0; i < windows.length; ++i) {
        const window = windows[i];
        const appId = normalizedAppId(window.appId);
        const title = clean(window.title);
        let score = 0;

        if (identifiers.indexOf(appId) !== -1)
            score = 100;
        else if (tooltip && title === tooltip)
            score = 80;

        if (score === 0)
            continue;

        if (/预览|preview|dialog|open file|save file|首选项|preferences|settings/.test(title))
            score -= 30;

        if (score > bestScore) {
            bestWindow = window;
            bestScore = score;
            tied = false;
        } else if (score === bestScore) {
            tied = true;
        }
    }

    return bestScore >= 80 && !tied ? bestWindow : null;
}
