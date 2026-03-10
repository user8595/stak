local gTable = require "lua.tables"

local stats = {
    scr = 0,
    lv = 1,
    line = 0,
    nxtLines = 10,
    comb = 0,
    maxComb = 0,

    clr = {
        sgl = 0,
        dbl = 0,
        trp = 0,
        qd = 0,
        ac = 0,
        --TODO: Implement t-spin detection
        spinTS = 0,
        spinTD = 0,
        spinTT = 0
    },

    -- equivalent to b2b
    strk = 0,
    maxStrk = 0,

    lineClr = 0,
    time = 0,
    timeDisp = "00:00.00",
    -- used for pps counter
    stacks = 0,
    currPPS = 0,
    maxPPS = 0,
    -- for pause delay
    pTime = 0,
    -- for quick restart
    qrTime = 0,
    scrtG = 1, -- index value
    resetPosDbg = 0,
    clrDbg = 0,
    sGFill = {},
    lClearUI = {},
    lClearAftrImg = {},
    lEffect = {},
    -- for locking effect
    lkEfct = {},
    -- for hard drop effect
    hDEfct = {},
    clearedLinesYPos = {}
}

for _ = 1, 20 do
    table.insert(stats.sGFill, false)
end

return stats
