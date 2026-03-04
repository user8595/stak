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
        spinT = 0
    },

    -- equivalent to b2b
    strk = 0,
    maxStrk = 0,

    lineClr = 0,
    time = 0,
    timeDisp = 0,
    -- used for pps counter
    stacks = 0,
    maxPPS = 0,
    -- for pause delay
    pTime = 0,
    -- for quick restart
    qrTime = 0,
    lClearUI = {},
    lEffect = {},
    -- for locking effect
    lkEfct = {},
    -- for hard drop effect
    hDEfct = {},
    clearedLinesYPos = {}
}

return stats