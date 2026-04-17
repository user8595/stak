local gCol = require "lua.gCol"
local settings = {
    showGrid = true,
    showOutlines = true,
    perspBlocks = true,
    showGhost = true,
    hDropEffect = true,
    coloredHDropEffect = true,
    --TODO: Finish all spin support
    detectAllSpin = false,
    --TODO: Fix broken smooth fall effect
    -- unimplemented now
    smoothFall = false,
    
    fpsTarget = 60,

    bgFilter = 0.5,
    bgCol = {
        gCol.bgB,
        gCol.bg,
    },

    -- accessibility features
    shakeInt = 1, -- preferrably values ranged at 0 - 1.49
    disableColorFlashes = false,
    disableAftrImg = false,
    disablePPSCol = false,
    lineEffect = true,
    lineParticles = true,
    lockEffect = true,
    shakeBoard = true,
    --TODO: Add function to disable locking shake effect
    shakeDrop = true,
    showDanger = true,
    
    -- danger block from hold queue
    showHoldDgr = true,
    showKOverlay = true,
    aKOverPos = true,
    -- small timer text
    altTimerUI = true,
    qRestartTime = 0.4,
    scale = 1,
    --TODO: Implement game UI scale
    uiScale = 1,
    rotSys = "SRS",     -- "ARS", "SRS"
    bagType = "modern", -- "modern", "classicM", "classicRand"

    useIRS = true,
    -- only line particle animation speed
    fastAnim = false,

    -- broken for now
    useVSync = true,

    -- for txt info (debug only)
    freezeTxt = false,
    -- for current piece (debug only)
    showEmpty = false,

    isDebug = true,
}

return settings