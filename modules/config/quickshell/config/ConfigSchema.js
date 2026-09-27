.pragma library

function isObject(value) {
    return value !== null && typeof value === "object" && !Array.isArray(value);
}

function clone(value) {
    if (Array.isArray(value))
        return value.map(item => clone(item));
    if (!isObject(value))
        return value;

    const result = {};
    for (const key of Object.keys(value))
        result[key] = clone(value[key]);
    return result;
}

function mergeDeep(base, override) {
    const result = clone(isObject(base) ? base : {});
    if (!isObject(override))
        return result;

    for (const key of Object.keys(override)) {
        const value = override[key];
        if (isObject(value) && isObject(result[key]))
            result[key] = mergeDeep(result[key], value);
        else if (isObject(value))
            result[key] = mergeDeep({}, value);
        else
            result[key] = clone(value);
    }
    return result;
}

function valueOf(section, key) {
    return isObject(section) ? section[key] : undefined;
}

function isValidString(value) {
    return typeof value === "string" && value.trim().length > 0
        && value.indexOf("\u0000") === -1 && value.indexOf("\n") === -1 && value.indexOf("\r") === -1;
}

function booleanValue(value, fallback) {
    return typeof value === "boolean" ? value : fallback;
}

function stringValue(value, fallback, allowEmpty) {
    if (typeof value !== "string")
        return fallback;
    if (value.length === 0)
        return allowEmpty ? "" : fallback;
    if (!isValidString(value))
        return fallback;
    return value;
}

function integerValue(value, fallback, minimum, maximum) {
    if (typeof value !== "number" || !Number.isFinite(value) || Math.floor(value) !== value)
        return fallback;
    if (value < minimum || value > maximum)
        return fallback;
    return value;
}

function realValue(value, fallback, minimum, maximum) {
    if (typeof value !== "number" || !Number.isFinite(value))
        return fallback;
    if (value < minimum || value > maximum)
        return fallback;
    return value;
}

function stringArrayValue(value, fallback, minimumLength) {
    if (!Array.isArray(value))
        return clone(fallback);

    const result = value.filter(item => typeof item === "string" && item.length > 0);
    return result.length >= minimumLength ? result : clone(fallback);
}

function regexArrayValue(value, fallback) {
    if (!Array.isArray(value))
        return clone(fallback);

    const result = [];
    for (const item of value) {
        if (typeof item !== "string")
            continue;
        try {
            new RegExp(item, "i");
            result.push(item);
        } catch (error) {
            // Ignore one malformed pattern instead of breaking all taskbar matching.
        }
    }
    return result;
}

function outputMapValue(value, fallback) {
    if (!isObject(value))
        return clone(fallback);

    const result = {};
    for (const output of Object.keys(value)) {
        const workspaces = stringArrayValue(value[output], [], 1);
        if (workspaces.length > 0)
            result[output] = workspaces;
    }
    return result;
}

function normalize(raw, defaults) {
    const source = isObject(raw) ? raw : {};
    const base = defaults || {};
    const workspaces = source.workspaces;
    const bar = source.bar;
    const wallpaper = source.wallpaper;
    const notifications = source.notifications;
    const clock = source.clock;
    const metrics = source.metrics;
    const osd = source.osd;
    const audio = source.audio;
    const apps = source.apps;
    const commands = source.commands;

    return {
        "workspaces": {
            "byOutput": outputMapValue(valueOf(workspaces, "byOutput"), valueOf(base.workspaces, "byOutput") || {}),
            "default": stringArrayValue(valueOf(workspaces, "default"), valueOf(base.workspaces, "default") || [], 1),
            "autoDistribute": booleanValue(valueOf(workspaces, "autoDistribute"), valueOf(base.workspaces, "autoDistribute"))
        },
        "bar": {
            "showWorkspaces": booleanValue(valueOf(bar, "showWorkspaces"), valueOf(base.bar, "showWorkspaces")),
            "showWindowTitle": booleanValue(valueOf(bar, "showWindowTitle"), valueOf(base.bar, "showWindowTitle")),
            "showMedia": booleanValue(valueOf(bar, "showMedia"), valueOf(base.bar, "showMedia")),
            "showClock": booleanValue(valueOf(bar, "showClock"), valueOf(base.bar, "showClock")),
            "showNotifications": booleanValue(valueOf(bar, "showNotifications"), valueOf(base.bar, "showNotifications")),
            "showTray": booleanValue(valueOf(bar, "showTray"), valueOf(base.bar, "showTray")),
            "showMetrics": booleanValue(valueOf(bar, "showMetrics"), valueOf(base.bar, "showMetrics")),
            "showIndicators": booleanValue(valueOf(bar, "showIndicators"), valueOf(base.bar, "showIndicators")),
            "showTaskbar": booleanValue(valueOf(bar, "showTaskbar"), valueOf(base.bar, "showTaskbar"))
        },
        "wallpaper": {
            "directory": stringValue(valueOf(wallpaper, "directory"), valueOf(base.wallpaper, "directory"), false),
            "defaultPath": stringValue(valueOf(wallpaper, "defaultPath"), valueOf(base.wallpaper, "defaultPath"), true),
            "transitionDurationMs": integerValue(valueOf(wallpaper, "transitionDurationMs"), valueOf(base.wallpaper, "transitionDurationMs"), 0, 60000),
            "carouselEnabled": booleanValue(valueOf(wallpaper, "carouselEnabled"), valueOf(base.wallpaper, "carouselEnabled")),
            "carouselIntervalMinutes": integerValue(valueOf(wallpaper, "carouselIntervalMinutes"), valueOf(base.wallpaper, "carouselIntervalMinutes"), 1, 10080),
            "carouselRandom": booleanValue(valueOf(wallpaper, "carouselRandom"), valueOf(base.wallpaper, "carouselRandom")),
            "overviewEnabled": booleanValue(valueOf(wallpaper, "overviewEnabled"), valueOf(base.wallpaper, "overviewEnabled")),
            "overviewBlurRadius": integerValue(valueOf(wallpaper, "overviewBlurRadius"), valueOf(base.wallpaper, "overviewBlurRadius"), 0, 256),
            "overviewDim": realValue(valueOf(wallpaper, "overviewDim"), valueOf(base.wallpaper, "overviewDim"), 0, 1),
            "overviewSaturation": realValue(valueOf(wallpaper, "overviewSaturation"), valueOf(base.wallpaper, "overviewSaturation"), 0, 1),
            "overviewContrast": realValue(valueOf(wallpaper, "overviewContrast"), valueOf(base.wallpaper, "overviewContrast"), 0, 1)
        },
        "notifications": {
            "timeoutMs": integerValue(valueOf(notifications, "timeoutMs"), valueOf(base.notifications, "timeoutMs"), 1, 3600000),
            "historyLimit": integerValue(valueOf(notifications, "historyLimit"), valueOf(base.notifications, "historyLimit"), 1, 10000),
            "toastLimit": integerValue(valueOf(notifications, "toastLimit"), valueOf(base.notifications, "toastLimit"), 1, 4),
            "toastsOnFocusedScreenOnly": booleanValue(valueOf(notifications, "toastsOnFocusedScreenOnly"), valueOf(base.notifications, "toastsOnFocusedScreenOnly"))
        },
        "clock": {
            "format": stringValue(valueOf(clock, "format"), valueOf(base.clock, "format"), false),
            "detailedFormat": stringValue(valueOf(clock, "detailedFormat"), valueOf(base.clock, "detailedFormat"), false),
            "locale": stringValue(valueOf(clock, "locale"), valueOf(base.clock, "locale"), false)
        },
        "metrics": {
            "cpuPollIntervalMs": integerValue(valueOf(metrics, "cpuPollIntervalMs"), valueOf(base.metrics, "cpuPollIntervalMs"), 1, 3600000),
            "memoryPollIntervalMs": integerValue(valueOf(metrics, "memoryPollIntervalMs"), valueOf(base.metrics, "memoryPollIntervalMs"), 1, 3600000)
        },
        "osd": {
            "timeoutMs": integerValue(valueOf(osd, "timeoutMs"), valueOf(base.osd, "timeoutMs"), 1, 60000)
        },
        "audio": {
            "volumeStep": realValue(valueOf(audio, "volumeStep"), valueOf(base.audio, "volumeStep"), 0.001, 1)
        },
        "apps": {
            "taskbarExcludedAppPatterns": regexArrayValue(valueOf(apps, "taskbarExcludedAppPatterns"), valueOf(base.apps, "taskbarExcludedAppPatterns") || [])
        },
        "commands": {
            "terminal": stringValue(valueOf(commands, "terminal"), valueOf(base.commands, "terminal"), false),
            "lock": stringValue(valueOf(commands, "lock"), valueOf(base.commands, "lock"), false)
        }
    };
}
