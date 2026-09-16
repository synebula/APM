.pragma library

function empty() {
    return { windows: [], workspaces: [] };
}

function apply(state, event) {
    if (event.WorkspacesChanged)
        return { windows: state.windows, workspaces: event.WorkspacesChanged.workspaces };
    if (event.WindowsChanged)
        return { windows: event.WindowsChanged.windows, workspaces: state.workspaces };
    if (event.WorkspaceActivated) {
        const activation = event.WorkspaceActivated;
        const target = state.workspaces.find(workspace => workspace.id === activation.id);
        if (!target) return state;
        return { windows: state.windows, workspaces: state.workspaces.map(workspace => Object.assign({}, workspace, {
            is_active: workspace.output === target.output ? workspace.id === target.id : workspace.is_active,
            is_focused: activation.focused ? workspace.id === target.id : workspace.is_focused
        })) };
    }
    if (event.WorkspaceUrgencyChanged) {
        const change = event.WorkspaceUrgencyChanged;
        return { windows: state.windows, workspaces: state.workspaces.map(workspace => workspace.id === change.id
            ? Object.assign({}, workspace, { is_urgent: change.urgent }) : workspace) };
    }
    if (event.WindowOpenedOrChanged) {
        const changed = event.WindowOpenedOrChanged.window;
        const exists = state.windows.some(window => window.id === changed.id);
        const windows = state.windows.map(window => window.id === changed.id ? changed :
            (changed.is_focused ? Object.assign({}, window, { is_focused: false }) : window));
        if (!exists) windows.push(changed);
        return { windows: windows, workspaces: state.workspaces };
    }
    if (event.WindowClosed)
        return { windows: state.windows.filter(window => window.id !== event.WindowClosed.id), workspaces: state.workspaces };
    if (event.WindowFocusChanged)
        return { windows: state.windows.map(window => Object.assign({}, window, {
            is_focused: window.id === event.WindowFocusChanged.id
        })), workspaces: state.workspaces };
    if (event.WindowUrgencyChanged) {
        const change = event.WindowUrgencyChanged;
        return { windows: state.windows.map(window => window.id === change.id
            ? Object.assign({}, window, { is_urgent: change.urgent }) : window), workspaces: state.workspaces };
    }
    return state;
}

function snapshot(state) {
    const workspaces = state.workspaces.map(workspace => ({
        workspaceId: String(workspace.id),
        name: workspace.name || String(workspace.idx),
        isNamed: !!workspace.name,
        index: workspace.idx,
        outputName: workspace.output || "",
        active: !!workspace.is_active,
        focused: !!workspace.is_focused,
        urgent: !!workspace.is_urgent
    }));
    const windows = state.windows.map(window => {
        const workspace = workspaces.find(item => item.workspaceId === String(window.workspace_id));
        return {
            windowId: String(window.id),
            appId: window.app_id || "",
            title: window.title || "",
            workspaceId: workspace ? workspace.workspaceId : "",
            outputName: workspace ? workspace.outputName : "",
            focused: !!window.is_focused,
            urgent: !!window.is_urgent
        };
    });
    return { windows: windows, workspaces: workspaces };
}

function workspaceReference(state, name) {
    const named = state.workspaces.find(workspace => workspace.name === name);
    if (named) return { Name: named.name };
    const indexed = state.workspaces.find(workspace => !workspace.name && String(workspace.idx) === name);
    return indexed ? { Index: indexed.idx } : { Name: name };
}
