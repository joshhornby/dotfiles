-- Function to resize and position windows
local function resizeAndPosition(appBundleID, xPos, yPos, width, height)
    local app = hs.application.get(appBundleID)
    if app then
        local windows = app:allWindows()
        for _, window in pairs(windows) do
            window:setFrame(hs.geometry.rect(xPos, yPos, width, height))
            window:raise()  -- Bring window to front
        end
    else
        hs.notify.new({title="Hammerspoon", informativeText=appBundleID .. " is not running"}):send()
    end
end

-- Function to open an app if it's not already open
local function openAppIfNeeded(appBundleID)
    local app = hs.application.get(appBundleID)
    if not app then
        hs.application.launchOrFocusByBundleID(appBundleID)
    end
end

-- Function to bring applications to front and arrange them
local function bringAppsToFrontAndArrange()
    -- Open iTerm2 if it's not already open
    openAppIfNeeded("com.googlecode.iterm2")

    -- Wait for a moment to ensure apps are ready
    hs.timer.doAfter(0.1, function()
        local screenFrame = hs.screen.primaryScreen():frame()
        local screenWidth = screenFrame.w
        local screenHeight = screenFrame.h
        local phpstormWidth = screenWidth * 3 / 4
        local itermWidth = screenWidth * 1 / 4
        local itermHeight = screenHeight / 2

        resizeAndPosition("com.jetbrains.PhpStorm", 0, 0, phpstormWidth, screenHeight)
        resizeAndPosition("com.googlecode.iterm2", phpstormWidth, 0, itermWidth, itermHeight)
    end)
end

-- Watcher for application switch events
local function appWatcher(appName, eventType, appObject)
    if (eventType == hs.application.watcher.activated) then
        local appBundleID = appObject:bundleID()
        if (appBundleID == "com.jetbrains.PhpStorm") then
            bringAppsToFrontAndArrange()
        end
    end
end

-- Start the application watcher
appWatcherInstance = hs.application.watcher.new(appWatcher)
appWatcherInstance:start()

-- Notify that Hammerspoon configuration has been loaded
hs.notify.new({title="Hammerspoon", informativeText="Configuration loaded"}):send()
