"use strict";

var previousWindow = null;
var previousGeometry = null;

function copyGeometry(geometry) {
    return {
        x: geometry.x,
        y: geometry.y,
        width: geometry.width,
        height: geometry.height
    };
}

function activeMovableWindow() {
    var window = workspace.activeWindow;
    if (!window || !window.normalWindow || !window.moveable) {
        print("desktop-config-window-actions: no movable active window");
        return null;
    }
    return window;
}

function remember(window) {
    previousWindow = window;
    previousGeometry = copyGeometry(window.frameGeometry);
}

function setGeometry(window, geometry) {
    window.setMaximize(false, false);
    window.frameGeometry = geometry;
}

function withHistory(callback) {
    var window = activeMovableWindow();
    if (!window) {
        return;
    }

    remember(window);
    callback(window);
}

function clientArea(window) {
    return workspace.clientArea(KWin.MaximizeArea, window);
}

function placeFraction(x, y, width, height) {
    withHistory(function (window) {
        var area = clientArea(window);
        setGeometry(window, {
            x: Math.round(area.x + area.width * x),
            y: Math.round(area.y + area.height * y),
            width: Math.round(area.width * width),
            height: Math.round(area.height * height)
        });
    });
}

function outputCenter(output) {
    var geometry = output.geometry;
    return {
        x: geometry.x + geometry.width / 2,
        y: geometry.y + geometry.height / 2
    };
}

function outputMatches(left, right) {
    return left && right && left.name === right.name;
}

function directionalOutput(currentOutput, direction) {
    var screens = workspace.screens;
    var currentCenter = outputCenter(currentOutput);
    var bestOutput = null;
    var bestScore = Number.POSITIVE_INFINITY;

    for (var index = 0; index < screens.length; index += 1) {
        var candidate = screens[index];
        if (outputMatches(candidate, currentOutput)) {
            continue;
        }

        var candidateCenter = outputCenter(candidate);
        var deltaX = candidateCenter.x - currentCenter.x;
        var deltaY = candidateCenter.y - currentCenter.y;
        var primaryDistance;
        var perpendicularDistance;

        if (direction === "left") {
            primaryDistance = -deltaX;
            perpendicularDistance = Math.abs(deltaY);
        } else if (direction === "right") {
            primaryDistance = deltaX;
            perpendicularDistance = Math.abs(deltaY);
        } else if (direction === "up") {
            primaryDistance = -deltaY;
            perpendicularDistance = Math.abs(deltaX);
        } else if (direction === "down") {
            primaryDistance = deltaY;
            perpendicularDistance = Math.abs(deltaX);
        } else {
            print("desktop-config-window-actions: unknown direction " + direction);
            return null;
        }

        if (primaryDistance <= 0) {
            continue;
        }

        // Prefer the closest output in the requested direction, while strongly
        // penalizing diagonally offset outputs when a better aligned one exists.
        var score = primaryDistance + perpendicularDistance * 2;
        if (score < bestScore) {
            bestScore = score;
            bestOutput = candidate;
        }
    }

    return bestOutput;
}

function moveToDirectionalScreenAndMaximize(direction) {
    var window = activeMovableWindow();
    if (!window) {
        return;
    }

    var targetOutput = directionalOutput(window.output, direction);
    if (!targetOutput) {
        print(
            "desktop-config-window-actions: no output in direction " + direction
        );
        return;
    }

    remember(window);

    var completed = false;
    function maximizeAfterMove() {
        if (completed || !outputMatches(window.output, targetOutput)) {
            return;
        }

        completed = true;
        window.outputChanged.disconnect(maximizeAfterMove);
        workspace.activeWindow = window;
        window.setMaximize(true, true);
        print(
            "desktop-config-window-actions: moved to " +
            targetOutput.name +
            " and maximized"
        );
    }

    window.outputChanged.connect(maximizeAfterMove);
    workspace.sendClientToScreen(window, targetOutput);

    // sendClientToScreen can complete synchronously depending on the backend.
    maximizeAfterMove();
}

function moveToNextScreen() {
    withHistory(function () {
        workspace.slotWindowToNextScreen();
    });
}

function maximizeWindow() {
    withHistory(function (window) {
        window.setMaximize(true, true);
    });
}

function centerWindow() {
    withHistory(function (window) {
        var area = clientArea(window);
        var geometry = window.frameGeometry;
        var width = Math.min(geometry.width, area.width);
        var height = Math.min(geometry.height, area.height);

        setGeometry(window, {
            x: Math.round(area.x + (area.width - width) / 2),
            y: Math.round(area.y + (area.height - height) / 2),
            width: Math.round(width),
            height: Math.round(height)
        });
    });
}

function undoWindowOperation() {
    if (!previousWindow || !previousGeometry) {
        print("desktop-config-window-actions: no window geometry to restore");
        return;
    }

    var window = previousWindow;
    var currentGeometry = copyGeometry(window.frameGeometry);
    setGeometry(window, previousGeometry);
    previousGeometry = currentGeometry;
    workspace.activeWindow = window;
}

function registerBinding(actionId, title, keySequence, callback) {
    var registered = registerShortcut(
        "desktop-config-" + actionId,
        "Desktop Config: " + title,
        keySequence,
        callback
    );

    if (!registered) {
        print(
            "desktop-config-window-actions: failed to register " +
            actionId +
            " (" +
            keySequence +
            ")"
        );
    }
}

// @binding action=half_left context=global key=alt+shift+h
registerBinding("half_left", "Half Left", "Alt+Shift+H", function () {
    placeFraction(0, 0, 0.5, 1);
});

// @binding action=half_bottom context=global key=alt+shift+j
registerBinding("half_bottom", "Half Bottom", "Alt+Shift+J", function () {
    placeFraction(0, 0.5, 1, 0.5);
});

// @binding action=half_top context=global key=alt+shift+k
registerBinding("half_top", "Half Top", "Alt+Shift+K", function () {
    placeFraction(0, 0, 1, 0.5);
});

// @binding action=half_right context=global key=alt+shift+l
registerBinding("half_right", "Half Right", "Alt+Shift+L", function () {
    placeFraction(0.5, 0, 0.5, 1);
});

// @binding action=monitor_left_maximize context=global key=alt+ctrl+h
registerBinding("monitor_left_maximize", "Move Left and Maximize", "Alt+Ctrl+H", function () {
    moveToDirectionalScreenAndMaximize("left");
});

// @binding action=monitor_down_maximize context=global key=alt+ctrl+j
registerBinding("monitor_down_maximize", "Move Down and Maximize", "Alt+Ctrl+J", function () {
    moveToDirectionalScreenAndMaximize("down");
});

// @binding action=monitor_up_maximize context=global key=alt+ctrl+k
registerBinding("monitor_up_maximize", "Move Up and Maximize", "Alt+Ctrl+K", function () {
    moveToDirectionalScreenAndMaximize("up");
});

// @binding action=monitor_right_maximize context=global key=alt+ctrl+l
registerBinding("monitor_right_maximize", "Move Right and Maximize", "Alt+Ctrl+L", function () {
    moveToDirectionalScreenAndMaximize("right");
});

// @binding action=corner_nw context=global key=meta+alt+y
registerBinding("corner_nw", "North West Quarter", "Meta+Alt+Y", function () {
    placeFraction(0, 0, 0.5, 0.5);
});

// @binding action=corner_ne context=global key=meta+alt+o
registerBinding("corner_ne", "North East Quarter", "Meta+Alt+O", function () {
    placeFraction(0.5, 0, 0.5, 0.5);
});

// @binding action=corner_sw context=global key=meta+alt+u
registerBinding("corner_sw", "South West Quarter", "Meta+Alt+U", function () {
    placeFraction(0, 0.5, 0.5, 0.5);
});

// @binding action=corner_se context=global key=meta+alt+i
registerBinding("corner_se", "South East Quarter", "Meta+Alt+I", function () {
    placeFraction(0.5, 0.5, 0.5, 0.5);
});

// @binding action=maximize context=global key=meta+alt+f
registerBinding("maximize", "Maximize", "Meta+Alt+F", maximizeWindow);

// @binding action=center context=global key=meta+alt+c
registerBinding("center", "Center", "Meta+Alt+C", centerWindow);

// @binding action=monitor_next context=global key=meta+alt+space
registerBinding("monitor_next", "Move to Next Monitor", "Meta+Alt+Space", moveToNextScreen);

// @binding action=undo_window_operation context=global key=meta+alt+[
registerBinding("undo_window_operation", "Undo Window Operation", "Meta+Alt+[", undoWindowOperation);
