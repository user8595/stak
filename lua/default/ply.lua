local gTable = require "lua.tables"
local gBoard = require "lua.default.gBoard"

local ply = {
    x = math.floor(gBoard.gW / 2) - 2,
    y = 0,
    initX = math.floor(gBoard.gW / 2) - 2,
    initY = 0,
    currBlk = 1,
    bRot = 1,

    d = 1, -- 1: ccw, 2: cw,
    lastKick = 0,

    spinReward = 1, -- 0: no spin, 1: mini spins, 2: normal spins
    next = {},
    nHist = {},
    nDisp = 5,
    hold = 0,
    -- tempoary value for hold func.
    cBlkTemp = 0,
    -- tempoary value for shake effect
    lineClrTemp = 0,

    -- for (some) line clear events
    isClear = false,

    isAlreadyHold = false,
    isAlrRot = false,

    -- in milliseconds (0.1 = 100ms)
    -- delay before autorepeat
    das = 95 / 1000,
    dasTimer = 0,

    --TODO: Add das cut delay
    isCutDly = false,
    cutDly = 0,
    cutDlyTmr = 0,

    -- auto repeat duration delay
    arr = 0 / 1000,
    arrTimer = 0,
    -- soft drop speed
    sdr = 0 / 1000,
    sdrTimer = 0,

    -- lock delay
    lDTimer = 0,
    lDelay = 500 / 1000,

    -- line clear delay
    isLnDly = false,
    lnDlyTmr = 0,
    lnDly = 0 / 1000,

    isEnDly = false,
    enDlyTmr = 0,
    enDly = 0 / 1000,

    -- gravity
    grav = gTable.grav[1],

    moveR = 0,
    mRLimit = 15,
    moveRBlk = 0,
    mRBLimit = 15,

    isIRS = false,

    isHDrop = false,
    dangerA = 0,

    -- board shake tween effect
    isShakeX = false,
    isShakeY = false,
    --TODO: Add tweening on spins
    isShakeRot = false,

    sXInv = false,
    sYInv = false,
    sRInv = false,

    shakeXTime = 0,
    shakeYTime = 0,
    shakeRTime = 0,

    -- for shake length
    sW = gBoard.w,
    sH = gBoard.h

    -- use two separate values for current block & placed blocks
    -- if block > height or active block > placed block = add block to placed blocks
    -- check for each block individually as a table
    -- how to convert milliseconds to seconds for das?
    -- 1 ms = 1/1000th a second, that means 120ms = 0.12s
    -- absolute cinema
}

return ply
