local gTable = require("lua.tables")

local ply = {
    x = 3,
    y = 0,
    currBlk = 1,
    bRot = 1,
    next = {},
    nHist = {},
    nDisp = 5,
    hold = 0,
    isAlreadyHold = false,
    isAlrRot = false,

    -- in milliseconds
    -- delay before autorepeat
    das = 102 / 1000,
    dasTimer = 0,
    -- auto repeat duration delay
    arr = 1 / 1000,
    arrTimer = 0,
    -- soft drop speed
    sdr = 0.1 / 1000,
    sdrTimer = 0,

    -- lock delay
    lDTimer = 0,
    lDelay = 1000 / 1000,

    -- line clear delay
    isLnDly = false,
    lnDlyTmr = 0,
    lnDly = 100 / 1000,

    isEnDly = false,
    enDlyTmr = 0,
    enDly = 50 / 1000,

    -- gravity
    gTimer = 0,
    grav = gTable.grav[1],
    gMult = 1,

    --TODO: Implement move reset limit
    moveR = 0, -- max. 15 steps

    isIRS = false,

    isHDrop = false,
    dangerA = 0,

    -- use two separate values for current block & placed blocks
    -- if block > height or active block > placed block = add block to placed blocks
    -- check for each block individually as a table
    -- how to convert milliseconds to seconds for das?
    -- 1 ms = 1/1000th a second, that means 120ms = 0.12s
    -- absolute cinema
}

return ply