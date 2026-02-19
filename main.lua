-- high score as of writing: 21850500, lv 110, 1100 lines, 35:33.42 time
-- highest secret grade as of writing: s8, lv 8, 75 lines, 03:33.64 time (with current version's settings)

local lg, lw, lk, lm = love.graphics, love.window, love.keyboard, love.mouse
local lt, le = love.timer, love.event
local lmth = love.math

local wWd, wHg = lg.getWidth(), lg.getHeight()

local tClear = require "table.clear"
local lerp = require "lua.lerp"
local gTable = require "lua.tables"

local fonts = {
    ui = lg.newFont("/assets/fonts/monogram-extended.TTF", 32),
    smol = lg.newFont("/assets/fonts/monogram-extended.TTF", 24),
    beeg = lg.newFont("/assets/fonts/monogram-extended.TTF", 64),
    time = lg.newFont("/assets/fonts/monogram-extended.TTF", 42),
    othr = lg.newFont("/assets/fonts/Picopixel.ttf", 14)
}

fonts.beeg:setLineHeight(0.8)

for _, f in pairs(fonts) do
    f:setFilter("nearest", "nearest")
end

-- game states
local game = {
    isPaused = false,
    isPauseDelay = false,
    isFail = false,
    useHold = false,
    showFailColors = false,
    isGravityInc = true
}

local settings = {
    showInfo = true,
    showGrid = true,
    showOutlines = true,
    showGhost = true,
    hDropEffect = true,
    coloredHDropEffect = false,
    lineEffect = true,
    lockEffect = true,
    showDanger = true,
    scale = 1,
    -- TODO: Implement rotation system switching
    rotSys = "ARS",
    -- works best with line clear delay
    useIRS = false,
    isDebug = true,
}

if arg[2] == "debug" then
    settings.isDebug = true
else
    settings.isDebug = false
end

local keys = {
    hDrop = "w",
    sDrop = "s",
    left = "a",
    right = "d",
    cw = "l",
    ccw = "k",
    hold = "space",
    pause = "p",
    restart = "return"
}

local gMtrx = {}
local gBoard = {
    x = 0,
    y = 0,
    -- block size
    w = 20,
    h = 20,
    gH = 21,
    -- placeholder value
    visW = 20,
    visH = 20
}

local ply = {
    x = 3,
    y = 0,
    currBlk = lmth.random(1, 7),
    bRot = 1,
    next = {},
    hold = 0,
    isAlreadyHold = false,

    -- in milliseconds
    -- delay before autorepeat
    das = 102 / 1000,
    dasTimer = 0,
    -- auto repeat duration delay
    arr = 9 / 1000,
    arrTimer = 0,
    -- soft drop speed
    sdr = 5 / 1000,
    sdrTimer = 0,

    -- lock delay
    lDTimer = 0,
    lDelay = 1000 / 1000,

    -- line clear delay
    isLnDly = false,
    lnDlyTmr = 0,
    lnDly = 250 / 1000,

    --TODO: Add player entry delay function
    isEnDly = false,
    enDlyTmr = 0,
    enDly = 200 / 1000,

    -- gravity
    gTimer = 0,
    grav = gTable.grav[1],

    isHDrop = false,
    dangerA = 0,

    -- use two separate values for current block & placed blocks
    -- if block > height or active block > placed block = add block to placed blocks
    -- check for each block individually as a table
    -- how to convert milliseconds to seconds for das?
    -- 1 ms = 1/1000th a second, that means 120ms = 0.12s
    -- absolute cinema
}

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
    lClearUI = {},
    lEffect = {},
    -- for locking effect
    lkEfct = {},
    -- for hard drop effect
    hDEfct = {},
    clearedLinesYPos = {}
}

for _ = 1, gBoard.gH, 1 do
    table.insert(gMtrx, { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 })
end

local gCol = {
    bg = { .1, .1, .18 },
    red = { .95, .55, .66 },
    green = { .65, .89, .63 },
    purple = { .80, .55, .66 },
    orange = { .98, .70, .53 },
    blue = { .54, .71, .98 },
    yellow = { .98, .89, .69 },
    lBlue = { .54, .86, .92 },
    white = { .80, .84, .96 },
    gray = { .35, .36, .44 },
    gOutline = { .58, .60, .70 },
    nBox = { .58, .60, .70, .35 }
}
local gColD = {
    red = { gCol.red[1] - .35, gCol.red[2] - .35, gCol.red[3] - .35 },
    green = { gCol.green[1] - .35, gCol.green[2] - .35, gCol.green[3] - .35 },
    purple = { gCol.purple[1] - .35, gCol.purple[2] - .35, gCol.purple[3] - .35 },
    orange = { gCol.orange[1] - .35, gCol.orange[2] - .35, gCol.orange[3] - .35 },
    blue = { gCol.blue[1] - .35, gCol.blue[2] - .35, gCol.blue[3] - .35 },
    yellow = { gCol.yellow[1] - .35, gCol.yellow[2] - .35, gCol.yellow[3] - .35 },
    lBlue = { gCol.lBlue[1] - .35, gCol.lBlue[2] - .35, gCol.lBlue[3] - .35 },
    white = { gCol.white[1] - .35, gCol.white[2] - .35, gCol.white[3] - .35 },
}

-- TODO: Implement modern rotation
local blocks = {
    -- use on currBlk
    {
        -- use on bRot
        {
            { 0,   0,   0,   0 },
            { "I", "I", "I", "I" },
        },
        {
            { 0, 0, "I" },
            { 0, 0, "I" },
            { 0, 0, "I" },
            { 0, 0, "I" }
        },
    },
    {
        {
            { 0,   0,   0 },
            { "Z", "Z", 0, },
            { 0,   "Z", "Z" }
        },
        {
            { 0,   "Z", 0 },
            { "Z", "Z", 0 },
            { "Z", 0,   0 },
        }
    },
    {
        {
            { 0,   0,   0 },
            { 0,   "S", "S" },
            { "S", "S", 0 }
        },
        {
            { "S", 0,   0 },
            { "S", "S", 0 },
            { 0,   "S", 0 },
        }
    },
    {
        {
            { 0,   0,   0 },
            { "L", "L", "L" },
            { "L", 0,   0 }
        },
        {
            { "L", "L", 0 },
            { 0,   "L", 0 },
            { 0,   "L", 0 }
        },
        {
            { 0,   0,   0 },
            { 0,   0,   "L" },
            { "L", "L", "L" }
        },
        {
            { 0, "L", 0 },
            { 0, "L", 0 },
            { 0, "L", "L" }
        },
    },
    {
        {
            { 0,   0,   0 },
            { "J", "J", "J" },
            { 0,   0,   "J" }
        },
        {
            { 0,   "J", 0 },
            { 0,   "J", 0 },
            { "J", "J", 0 }
        },
        {
            { 0,   0,   0 },
            { "J", 0,   0 },
            { "J", "J", "J" }
        },
        {
            { 0, "J", "J" },
            { 0, "J", 0 },
            { 0, "J", 0 }
        }
    },
    {
        {
            { 0, 0,   0 },
            { 0, "O", "O" },
            { 0, "O", "O" },
        }
    },
    {
        {
            { 0,   0,   0 },
            { "T", "T", "T" },
            { 0,   "T", 0 },
        },
        {
            { 0,   "T", 0 },
            { "T", "T", 0 },
            { 0,   "T", 0 }
        },
        {
            { 0,   0,   0 },
            { 0,   "T", 0 },
            { "T", "T", "T" },
        },
        {
            { 0, "T", 0 },
            { 0, "T", "T" },
            { 0, "T", 0 }
        },
    },
}

--TODO: Finish randomizer function
local function bagInit(plyVar)
    if plyVar.currBlk >= #blocks then
        plyVar.currBlk = 1
    else
        plyVar.currBlk = plyVar.currBlk + 1
    end
end

local function bMove(tX, tY, tRot, mtrxTab)
    if blocks[ply.currBlk][tRot] ~= nil then
        for y = 1, #blocks[ply.currBlk][tRot] do
            for x = 1, #blocks[ply.currBlk][tRot][y] do
                local tX, tY = tX + x, tY + y
                if blocks[ply.currBlk][tRot][y][x] ~= 0 then
                    if tX < 1 or tX > gBoard.visW or tY > gBoard.visH then
                        return false
                    else
                        if mtrxTab[tY][tX] ~= 0 then
                            return false
                        end
                    end
                end
            end
        end
    else
        return false
    end
    return true
end

--TODO: Improve IRS function?
local function checkIRS(plyVar, blkTab)
    if settings.useIRS and not game.isFail and not game.isPauseDelay and not game.isPaused then
        if plyVar.currBlk ~= 6 then
            if lk.isDown(keys.ccw) then
                if plyVar.bRot > 1 then
                    plyVar.bRot = plyVar.bRot - 1
                else
                    plyVar.bRot = #blkTab[plyVar.currBlk]
                end
            end

            if lk.isDown(keys.cw) then
                if plyVar.bRot < #blkTab[plyVar.currBlk] then
                    plyVar.bRot = plyVar.bRot + 1
                else
                    plyVar.bRot = 1
                end
            end
        end
    end
end

local function plyInit(plyVar)
    plyVar.x, plyVar.y = 3, 0
    plyVar.bRot = 1

    if not plyVar.isLnDly then
        checkIRS(ply, blocks)
    end
    plyVar.lDTimer, plyVar.gTimer, plyVar.sdrTimer = 0, 0, 0
end

local function gameInit(plyVar, sts)
    plyVar.arrTimer, plyVar.dasTimer, plyVar.gTimer, plyVar.grav = 0, 0, 0, gTable.grav[1]
    plyVar.isLnDly = false
    plyVar.lnDlyTmr = 0
    plyVar.enDlyTmr = 0
    plyVar.hold = 0
    plyVar.dangerA = 0
    sts.time = 0
    sts.stacks = 0
    sts.clr.sgl, sts.clr.dbl, sts.clr.trp, sts.clr.qd, sts.clr.ac = 0, 0, 0, 0, 0
    sts.lv = 1
    sts.line = 0
    sts.scr = 0
    sts.maxComb, sts.maxPPS, sts.maxStrk = 0, 0, 0
    sts.strk, sts.comb = 0, 0
    sts.nxtLines = 10
    tClear(sts.lClearUI)
end

local function mtrxClr(mtrxTab)
    for y, _ in ipairs(mtrxTab) do
        for x, _ in ipairs(mtrxTab[y]) do
            mtrxTab[y][x] = 0
        end
    end
end

-- hold function
local function holdFunc(plyVar)
    if ply.hold == 0 then
        plyVar.hold = plyVar.currBlk
        bagInit(plyVar)
    else
        --TODO: Tempoary, replace with bag sequence
        --- replace with first next block on queue
        plyVar.currBlk = plyVar.hold
        -- move current block to hold queue
        plyVar.hold = plyVar.currBlk
    end

    -- reset player position
    plyInit(plyVar)

    plyVar.isAlreadyHold = true
end

local function lowestCells(plyVar, mtrxTab, isInverse)
    if not isInverse then
        local tX, tY = plyVar.x, plyVar.y
        while bMove(tX, tY + 1, plyVar.bRot, mtrxTab) do
            tY = tY + 1
        end
        return tY
    else
        for i = plyVar.y, 1, -1 do
            if bMove(plyVar.x, plyVar.y, plyVar.bRot, mtrxTab) then
                return i + 1
            end
        end
        return 1
    end
end

local function dBlocks(bl, x, y, isGhost, isOutline, noColors, lDlyFade, isHDrop, hdAlp, hdHgt)
    local colors = function()
        if settings.rotSys == "ARS" then
            return
            {
                I = gCol.red,
                Z = gCol.green,
                S = gCol.purple,
                L = gCol.orange,
                J = gCol.blue,
                O = gCol.yellow,
                T = gCol.lBlue,
                gO = gCol.gOutline
            }
        else
            return
            {
                I = gCol.lBlue,
                Z = gCol.green,
                S = gCol.purple,
                L = gCol.orange,
                J = gCol.blue,
                O = gCol.yellow,
                T = gCol.purple,
                gO = gCol.gOutline
            }
        end
    end
    if bl ~= 0 then
        if not noColors then
            if not game.isFail then
                if isGhost then
                    lg.setColor(colors()[bl][1], colors()[bl][2], colors()[bl][3], 0.25)
                elseif lDlyFade then
                    if ply.lDTimer > 0 then
                        lg.setColor(colors()[bl][1], colors()[bl][2], colors()[bl][3],
                            ply.lDTimer + 0.1 / ply.lDelay + 0.1)
                    else
                        lg.setColor(colors()[bl])
                    end
                elseif hdAlp ~= nil then
                    lg.setColor(colors()[bl][1], colors()[bl][2], colors()[bl][3], hdAlp)
                else
                    lg.setColor(colors()[bl])
                end
            else
                if not game.showFailColors then
                    if isGhost then
                        lg.setColor(gCol.gray[1], gCol.gray[2], gCol.gray[3], 0.25)
                    else
                        lg.setColor(gCol.gray)
                    end
                else
                    if isGhost then
                        lg.setColor(colors()[bl][1], colors()[bl][2], colors()[bl][3], 0.25)
                    else
                        lg.setColor(colors()[bl])
                    end
                end
            end
        end

        if isHDrop then
            lg.rectangle("fill", gBoard.x + gBoard.w * (x - 1), gBoard.y + gBoard.h * (y - 1), gBoard.w,
                gBoard.h * hdHgt)
        end

        if not isOutline then
            lg.rectangle("fill", gBoard.x + gBoard.w * (x - 1), gBoard.y + gBoard.h * (y - 1), gBoard.w, gBoard.h)
        else
            lg.rectangle("line", gBoard.x + gBoard.w * (x - 1), gBoard.y + gBoard.h * (y - 1), gBoard.w, gBoard.h)
        end
    end
end

local function dGrid(mtrxTab)
    for y, _ in ipairs(mtrxTab) do
        for x, _ in ipairs(mtrxTab[y]) do
            if y ~= 1 then
                lg.setColor(.80 * .3, .84 * .3, .96 * .3)
                lg.rectangle("fill", gBoard.x + gBoard.w * (x - 1), gBoard.y + gBoard.h * (y - 1),
                    gBoard.w - (gBoard.w - 3),
                    gBoard.h - (gBoard.h - 3))
            end
        end
    end
end

local function dOutline(mtrxTab, strokeWd)
    local sCol = function()
        if not game.isFail then
            return { 1, 1, 1, 1 }
        else
            if not game.showFailColors then
                return gCol.gOutline
            else
                return { 1, 1, 1, 1 }
            end
        end
    end
    for y, _ in ipairs(mtrxTab) do
        for x, br in ipairs(mtrxTab[y]) do
            if y ~= 1 then
                if br ~= 0 then
                    -- there must be a better way than this right
                    -- ##### bottom rows
                    if x == 1 and y == #mtrxTab then
                        lg.setColor(sCol())
                        lg.rectangle("fill", gBoard.x + gBoard.w * (x - 1), gBoard.y + gBoard.h * (y - 1) - strokeWd,
                            gBoard.w + strokeWd,
                            gBoard.h + strokeWd)
                    elseif x == #mtrxTab[y] and y == #mtrxTab then
                        lg.setColor(sCol())
                        lg.rectangle("fill", gBoard.x + gBoard.w * (x - 1) - strokeWd,
                            gBoard.y + gBoard.h * (y - 1) - strokeWd,
                            gBoard.w + strokeWd,
                            gBoard.h + strokeWd)
                        -- ##### left % right columns
                    elseif x == 1 then
                        lg.setColor(sCol())
                        lg.rectangle("fill", gBoard.x + gBoard.w * (x - 1),
                            gBoard.y + gBoard.h * (y - 1) - strokeWd,
                            gBoard.w + strokeWd,
                            gBoard.h + (strokeWd * 2))
                    elseif x == #mtrxTab[y] then
                        lg.setColor(sCol())
                        lg.rectangle("fill", gBoard.x + gBoard.w * (x - 1) - strokeWd,
                            gBoard.y + gBoard.h * (y - 1) - strokeWd,
                            gBoard.w + strokeWd,
                            gBoard.h + (strokeWd * 2))
                        -- bottom row (general)
                    elseif y == #mtrxTab then
                        lg.setColor(sCol())
                        lg.rectangle("fill", gBoard.x + gBoard.w * (x - 1) - strokeWd,
                            gBoard.y + gBoard.h * (y - 1) - strokeWd,
                            gBoard.w + (strokeWd * 2),
                            gBoard.h + (strokeWd))
                    else
                        lg.setColor(sCol())
                        lg.rectangle("fill", gBoard.x + gBoard.w * (x - 1) - strokeWd,
                            gBoard.y + gBoard.h * (y - 1) - strokeWd,
                            gBoard.w + (strokeWd * 2),
                            gBoard.h + (strokeWd * 2))
                    end
                end
            end
        end
    end
end

-- next & hold box drawing
-- use 3 next slots
-- TODO: Finish randomizer function
local function dNBox(blkTab, plyTab, isHold)
    -- TODO: Tempoary, replace with bag sequence
    local nBlk = plyTab.currBlk + 1
    local hBlk = plyTab.hold

    if nBlk > #blkTab then
        nBlk = 1
    end

    if not game.isPaused then
        if not isHold then
            for y, _ in ipairs(blkTab[nBlk][1]) do
                for x, blk in ipairs(blkTab[nBlk][1][y]) do
                    dBlocks(blk, x + gBoard.visW + 1, y + 2, false, false, false)
                end
            end
        else
            if plyTab.hold ~= 0 then
                for y, _ in ipairs(blkTab[hBlk][1]) do
                    for x, blk in ipairs(blkTab[hBlk][1][y]) do
                        dBlocks(blk, x + gBoard.x - 5, y + 2, false, false, false)
                    end
                end
                lg.printf("(broken for now)", fonts.othr, -123, gBoard.y + 110, 160, "left")
            end
        end
    end
end

-- next queue outline
local function nxtCol(currBlk, isHold)
    local nBlk = currBlk + 1
    if nBlk > #blocks then
        nBlk = 1
    end
    local cols = function()
        if not game.isFail or game.showFailColors then
            if settings.rotSys == "ARS" then
                return {
                    gray = gCol.gOutline,
                    gCol.red,
                    gCol.green,
                    gCol.purple,
                    gCol.orange,
                    gCol.blue,
                    gCol.yellow,
                    gCol.lBlue,
                }
            else
                return
                {
                    gray = gCol.gOutline,
                    gCol.lBlue,
                    gCol.green,
                    gCol.purple,
                    gCol.orange,
                    gCol.blue,
                    gCol.yellow,
                    gCol.purple,
                }
            end
        else
            if settings.rotSys == "ARS" then
                return {
                    gray = gCol.gOutline,
                    gColD.red,
                    gColD.green,
                    gColD.purple,
                    gColD.orange,
                    gColD.blue,
                    gColD.yellow,
                    gColD.lBlue,
                }
            else
                return
                {
                    gray = gCol.gOutline,
                    gColD.lBlue,
                    gColD.green,
                    gColD.purple,
                    gColD.orange,
                    gColD.blue,
                    gColD.yellow,
                    gColD.purple,
                    gCol.gOutline
                }
            end
        end
    end
    if not game.isPaused then
        if not isHold then
            return cols()[nBlk]
        else
            if currBlk ~= 0 then
                return cols()[currBlk]
            else
                return cols().gray
            end
        end
    else
        return cols().gray
    end
end

-- line clear effect
local function newLineEffect(y, boardVar, lineEffectTab, isBoardFill, isScale)
    if isBoardFill then
        table.insert(lineEffectTab, {
            x = boardVar.x,
            y = boardVar.y + boardVar.h,
            w = boardVar.w * boardVar.visW,
            h = boardVar.h * boardVar.visH - boardVar.h,
            a = 0.15,
            isFill = true,
        })
    elseif isScale then
        table.insert(lineEffectTab, {
            x = boardVar.x,
            y = boardVar.y + (boardVar.h * y),
            w = boardVar.w * boardVar.visW,
            h = boardVar.h,
            a = 1,
            s = 1,
            t = 0,
            isScale = true
        })
    else
        table.insert(lineEffectTab, {
            x = boardVar.x,
            y = boardVar.y + (boardVar.h * y),
            w = boardVar.w * boardVar.visW,
            h = boardVar.h,
            a = 1
        })
    end
end

local function lEUpdate(lineEffectTab, dt)
    for i, ln in ipairs(lineEffectTab) do
        if ln.a > 0 then
            if ln.isFill then
                ln.a = ln.a - dt * 0.65
            else
                ln.a = ln.a - dt * 5
            end
            if ln.isScale then
                ln.t = ln.t + dt
                ln.s = ln.s + (0.5 * lerp.easeOutQuart(0.65, 1, ln.t))
            end
        else
            table.remove(lineEffectTab, i)
        end
    end
end

local function lEDraw(lineEffectTab)
    for _, ln in ipairs(lineEffectTab) do
        lg.setColor(1, 1, 1, ln.a)
        if not ln.isScale then
            lg.rectangle("fill", ln.x, ln.y, ln.w, ln.h)
        else
            lg.rectangle("fill", ln.x - ln.s, ln.y - ln.s, ln.w + (ln.s * 2), ln.h + (ln.s * 2))
        end
    end
end

-- piece locking effect
local function newLockEffect(lockEffectTab, blkTab, plyTab, isHDrop)
    if isHDrop then
        table.insert(lockEffectTab, {
            x = plyTab.x,
            y = plyTab.y,
            h = lowestCells(ply, gMtrx, false),
            invH = lowestCells(ply, gMtrx, true),
            a = 0.15,
            blk = blkTab[plyTab.currBlk][plyTab.bRot],
            HDrop = true
        })
    else
        table.insert(lockEffectTab, {
            x = plyTab.x,
            y = plyTab.y,
            a = 1,
            blk = blkTab[plyTab.currBlk][plyTab.bRot],
        })
    end
end

local function lkUpd(lockEffectTab, dt)
    for i, lk in ipairs(lockEffectTab) do
        if lk.a > 0 then
            if not lk.HDrop then
                lk.a = lk.a - dt * 7
            else
                lk.a = lk.a - dt
            end
        else
            table.remove(lockEffectTab, i)
        end
    end
end

local function lkDrw(lockEffectTab)
    for _, lk in ipairs(lockEffectTab) do
        for y, _ in ipairs(lk.blk) do
            for x, blk in ipairs(lk.blk[y]) do
                lg.setColor(1, 1, 1, lk.a)
                if not lk.HDrop then
                    dBlocks(blk, x + lk.x, y + lk.y, false, false, true)
                end
            end
        end
    end
end

local function hDDrw(lockEffectTab)
    for _, lk in ipairs(lockEffectTab) do
        for y, _ in ipairs(lk.blk) do
            for x, blk in ipairs(lk.blk[y]) do
                if lk.HDrop then
                    if not settings.coloredHDropEffect then
                        lg.setColor(1, 1, 1, lk.a)
                        dBlocks(blk, x + lk.x, lk.y + y, false, false, true, false, true, nil, lk.h - lk.invH)
                    else
                        dBlocks(blk, x + lk.x, lk.y + y, false, false, false, false, true, lk.a, lk.h - lk.invH)
                    end
                end
            end
        end
    end
end

local function isAllClr(mtrxTab)
    local allClear = true
    for y = 1, gBoard.visH do
        for x = 1, gBoard.visW do
            if mtrxTab[y][x] ~= 0 then
                allClear = false
            end
        end
    end
    return allClear
end

-- game fail detection
local function isGFail(mtrxTab)
    -- local fail = false
    -- local iX, iY = 3, 0
    -- if blkTab[ply.currBlk][ply.bRot] ~= nil then
    --     for y = 1, #blkTab[ply.currBlk][ply.bRot] do
    --         for x = 1, #blkTab[ply.currBlk][ply.bRot][y] do
    --             if blkTab[ply.currBlk][ply.bRot][y][x] ~= 0 and mtrxTab[iY + y][iX + x] ~= 0 then
    --                 fail = true
    --                 break
    --             end
    --         end
    --     end
    -- end
    -- return fail
    if not bMove(ply.x, ply.y, ply.bRot, gMtrx) then
        return true
    end
end

-- for wall kicks
local function bRotate(tX, tY, bRot, mtrxTab)
    -- TODO: Fix wrong wallkicks
    if settings.rotSys == "ARS" then
        if blocks[ply.currBlk] ~= nil then
            local bLen = blocks[ply.currBlk]
            if #bLen > 1 then
                if #bLen[bRot] <= 3 and bLen ~= 1 then -- not an O piece
                    if ply.currBlk ~= 1 then           -- not an I piece
                        if not bMove(tX - 1, tY, bRot, mtrxTab) then
                            ply.x = ply.x + 1
                        end
                        if not bMove(tX + 1, tY, bRot, mtrxTab) then
                            ply.x = ply.x - 1
                        end
                    else
                        if not bMove(tX, tY, bRot, mtrxTab) then
                            return false
                        end
                    end
                end
            end
            return true
        else
            return false
        end
        --TODO: Finish modern rotation system
    elseif settings.rotSys == "SRS" then
        local rotate = true
        if blocks[ply.currBlk] ~= nil and gTable.wKicks[ply.currBlk] ~= nil then
            rotate = true
            for _, kick in ipairs(gTable.wKicks[ply.currBlk]) do
                if bMove(tX + kick[1], tY + kick[2], bRot, mtrxTab) then
                    ply.x = ply.x + kick[1]
                    ply.y = ply.y + kick[2]
                else
                    rotate = false
                    break
                end
            end
        else
            rotate = false
        end
        return rotate
    end
end

-- line clear function
local function clearCells(y, mtrxTab, boardVar)
    stats.line = stats.line + 1
    stats.lineClr = stats.lineClr + 1

    -- trigger line animation function
    if settings.lineEffect then
        -- for offset
        newLineEffect(y - 1, gBoard, stats.lEffect, false, true)
    end

    -- TODO: Implement line clear delay
    -- clear lines with empty tiles
    for clrX = 1, gBoard.visW do
        mtrxTab[y][clrX] = 0
    end
end

local function moveCells(y, mtrxTab, boardVar)
    for clrY = y, 2, -1 do
        for clrX = 1, boardVar.visW do
            mtrxTab[clrY][clrX] = mtrxTab[clrY - 1][clrX]
        end
    end
end

-- block placement & line clear logic
local function bAdd(bX, bY, bL, mtrxTab)
    local clear = true
    local cAnim = false

    if bL[ply.currBlk][ply.bRot] ~= nil then
        for y, _ in ipairs(bL[ply.currBlk][ply.bRot]) do
            for x, blk in ipairs(bL[ply.currBlk][ply.bRot][y]) do
                if blk ~= 0 then
                    if bY + y <= #mtrxTab then
                        mtrxTab[bY + y][bX + x] = blk
                    end
                end
            end
        end
    else
        table.insert(stats.lClearUI, { str = "?", cBlk = ply.currBlk, a = 1, aSpd = 0.5 })
        print("!!! this should NOT happen ingame (blocks wont place normally) currBlk: " ..
            ply.currBlk .. " bRot: " .. ply.bRot .. " x: " .. ply.x .. " y: " .. ply.y .. " !!!")
    end

    -- for hold function reserving
    ply.isAlreadyHold = false

    -- for line clear function
    for y = 1, gBoard.visH do
        clear = true

        for x = 1, gBoard.visW do
            if mtrxTab[y][x] == 0 then
                clear = false
                break
            end
        end

        if clear then
            cAnim = true
            -- store current y positions for cleared lines for use with moveCells() function
            -- same function as the hard drop effect
            table.insert(stats.clearedLinesYPos, y)
            print("---------- cAnim: " .. tostring(cAnim) .. " ----------")
            clearCells(y, gMtrx, gBoard)
            clear = false
        end
    end

    if settings.lockEffect then
        newLockEffect(stats.lkEfct, blocks, ply, false)
    end

    if cAnim then
        -- start line delay
        ply.isLnDly = true

        -- clear line clear ui on new line clear
        tClear(stats.lClearUI)
        if #stats.lkEfct > 0 then
            tClear(stats.lkEfct)
        end
    end

    if isAllClr(mtrxTab) then
        print("+16000 score points from aClear")
        stats.scr = stats.scr + 16000
        stats.clr.ac = stats.clr.ac + 1

        if settings.lineEffect then
            newLineEffect(nil, gBoard, stats.lEffect, true, false)
        end

        table.insert(stats.lClearUI, { str = "C", cBlk = "C", a = 1, aSpd = 0.5 })
    end

    -- events after line clears
    if cAnim then
        print("lines: " .. stats.lineClr)
        stats.comb = stats.comb + 1
        stats.scr = stats.scr + (stats.lv * ((200 + (200 * stats.lineClr)) + (50 * stats.comb)))
        print(stats.scr + (stats.lv * ((200 + (200 * stats.lineClr)) + (200 * stats.comb))) ..
            " (+" .. (stats.lv * ((200 + (200 * stats.lineClr)) + (200 * stats.comb))) .. ")" ..
            " prev. curr score: " .. stats.scr .. " clear: " .. tostring(clear))

        -- "cBlk" can be color block, or current block, or a string for color (?)
        table.insert(stats.lClearUI, { str = stats.lineClr, cBlk = ply.currBlk, a = 1, aSpd = 0.5 })
        if stats.lineClr == 1 then
            stats.clr.sgl = stats.clr.sgl + 1
            stats.strk = 0
        elseif stats.lineClr == 2 then
            stats.clr.dbl = stats.clr.dbl + 1
            stats.strk = 0
        elseif stats.lineClr == 3 then
            stats.clr.trp = stats.clr.trp + 1
            stats.strk = 0
        elseif stats.lineClr == 4 then
            stats.clr.qd = stats.clr.qd + 1
            stats.strk = stats.strk + 1
        end
        if stats.line > stats.nxtLines then
            stats.lv = stats.lv + 1

            -- gravity increase function
            if game.isGravityInc then
                if stats.lv < #gTable.grav then
                    ply.grav = gTable.grav[stats.lv]
                    print("increased gravity (grav: " .. ply.grav .. ")")
                else
                    ply.grav = 0
                    print("stopped increasing gravity (grav: " .. ply.grav .. ")")
                end
            end

            stats.nxtLines = stats.nxtLines + 10
        end
        stats.lineClr = 0
        cAnim = false
        print("---------- cAnim: " .. tostring(cAnim) .. " ----------")
    else
        -- reset combo counter if no line clears
        stats.comb = 0
    end
end

local function bGhost(isOutline)
    local gX, gY = ply.x, lowestCells(ply, gMtrx)

    if blocks[ply.currBlk][ply.bRot] ~= nil then
        for y, _ in ipairs(blocks[ply.currBlk][ply.bRot]) do
            for x, blk in ipairs(blocks[ply.currBlk][ply.bRot][y]) do
                if blk ~= 0 then
                    if isOutline then
                        dBlocks(blk, x + gX, y + gY, true, true)
                    else
                        dBlocks(blk, x + gX, y + gY, true, false)
                    end
                end
            end
        end
    end
end

-- danger zone (near failure) check
local function dangerCheck(mtrxTab)
    local dangerY = 8 -- offset by -2, then 8 == 6 from first row
    for y, _ in ipairs(mtrxTab) do
        for x, _ in ipairs(mtrxTab[y]) do
            if x > math.floor(gBoard.visW / 6) and x < gBoard.visW - (math.floor(gBoard.visW / 6)) then
                if y > dangerY - 2 and y < dangerY then
                    if mtrxTab[y][x] ~= 0 then
                        return 1
                    end
                elseif y < dangerY - 2 then
                    if mtrxTab[y][x] ~= 0 then
                        return 2
                    end
                end
            end
        end
    end
    return false
end

-- color flash effect
local function colFlashNew(col1, col2, time)
    return {
        index = 1,
        cTime = 0,
        time = time,
        col = {
            col1,
            col2
        }
    }
end

local function colFlashUpd(colVar, dt)
    colVar.cTime = colVar.cTime + dt
    if colVar.cTime > colVar.time then
        if colVar.index < #colVar.col then
            colVar.index = colVar.index + 1
        else
            colVar.index = 1
        end
        colVar.cTime = 0
    end
end

local cFStrk = colFlashNew(gCol.yellow, gCol.blue, 0.05)
local cFCb = colFlashNew(gCol.yellow, gCol.white, 0.05)
local cFAC = colFlashNew(gColD.yellow, gColD.lBlue, 0.1)

local cFFail = colFlashNew(gCol.orange, gCol.red, .05)
local cFFBG = colFlashNew(gColD.orange, gColD.red, .75)

-- game ui fail colors
local function failCol(isPPS)
    if not isPPS then
        if not game.isFail then
            lg.setColor(1, 1, 1, 1)
        else
            local tCol = 0.35
            lg.setColor(gCol.gray[1] + tCol, gCol.gray[2] + tCol, gCol.gray[3] + tCol)
        end
    else
        if not game.isFail then
            -- p/s colors
            if stats.stacks / stats.time > 1.55 and stats.stacks / stats.time < 2.65 then
                lg.setColor(gCol.yellow)
            end
            if stats.stacks / stats.time > 2.65 and stats.stacks / stats.time < 3 then
                lg.setColor(gCol.lBlue[1] + .1, gCol.lBlue[2] + .2, 1)
            end
            if stats.stacks / stats.time > 3 and stats.stacks / stats.time < 4 then
                lg.setColor(gCol.red[1] + .3, gCol.red[2], gCol.red[3])
            end
            if stats.stacks / stats.time > 4 then
                lg.setColor(gCol.purple[1] + .4, gCol.purple[2] - .1, gCol.purple[3] + 0.1)
            end
            if stats.stacks / stats.time < 1.55 then
                lg.setColor(1, 1, 1, 1)
            end
        else
            local tCol = 0.35
            lg.setColor(gCol.gray[1] + tCol, gCol.gray[2] + tCol, gCol.gray[3] + tCol)
        end
    end
end

function love.load()
    lg.clear()
    lg.setColor(gCol.bg)
    lg.rectangle("fill", 0, 0, wWd, wHg)
    lg.setColor(1, 1, 1, 1)
    lg.printf("Loading..", fonts.ui, 0, wHg / 2, wWd, "center")
    love.graphics.present()
    lg.setBackgroundColor(gCol.bg)
    lm.setVisible(false)
end

function love.keypressed(k)
    if k == "escape" then
        if not game.isPaused and not game.isPauseDelay and not game.isFail then
            game.isPaused = true
        else
            if not game.isPauseDelay then
                le.quit(0)
            end
        end
    end

    if k == "f11" then
        if not lw.getFullscreen() then
            lw.setFullscreen(true)
        else
            lw.setFullscreen(false)
        end
    end

    if k == keys.pause then
        if not game.isPaused and not game.isPauseDelay and not game.isFail then
            game.isPaused = true
        elseif not game.isFail then
            game.isPaused = false
            game.isPauseDelay = true
        end
    end

    if not game.isPaused and not game.isPauseDelay and not game.isFail and not ply.isLnDly then
        if k == keys.left then
            if bMove(ply.x - 1, ply.y, ply.bRot, gMtrx) then
                ply.x = ply.x - 1
                ply.dasTimer = 0
                ply.arrTimer = 0
            end
        end

        if k == keys.right then
            if bMove(ply.x + 1, ply.y, ply.bRot, gMtrx) then
                ply.x = ply.x + 1
                ply.dasTimer = 0
                ply.arrTimer = 0
            end
        end

        if k == keys.hDrop then
            -- so many edge cases
            if settings.hDropEffect and bMove(ply.x, ply.y + 1, ply.bRot, gMtrx) then
                newLockEffect(stats.hDEfct, blocks, ply, true)
            end

            while bMove(ply.x, ply.y + 1, ply.bRot, gMtrx) do
                ply.y = ply.y + 1
            end

            bAdd(ply.x, ply.y, blocks, gMtrx)

            ply.isHDrop = true

            if not ply.isLnDly then
                bagInit(ply)
            end
            plyInit(ply)

            stats.stacks = stats.stacks + 1

            ply.gTimer = 0
            ply.lDTimer = 0

            ply.arrTimer = 0
            ply.sdrTimer = 0
        end

        if k == keys.ccw then
            local tR = ply.bRot - 1
            if tR < 1 then
                tR = #blocks[ply.currBlk]
            end
            if bRotate(ply.x, ply.y, tR, gMtrx) and bMove(ply.x, ply.y, tR, gMtrx) then
                ply.bRot = tR
            end
        end

        if k == keys.cw then
            local tR = ply.bRot + 1
            if tR > #blocks[ply.currBlk] then
                tR = 1
            end
            if bRotate(ply.x, ply.y, tR, gMtrx) and bMove(ply.x, ply.y, tR, gMtrx) then
                ply.bRot = tR
            end
        end

        if k == keys.sDrop then
            if bMove(ply.x, ply.y + 1, ply.bRot, gMtrx) then
                ply.sdrTimer = 0
                ply.y = ply.y + 1
            else
                if ply.gTimer < ply.grav then
                    ply.gTimer = ply.grav
                end
            end
        end

        -- hold key function
        if k == keys.hold and game.useHold then
            if not ply.isAlreadyHold and not ply.lnDly and not ply.isEnDly then
                holdFunc(ply)
            end
        end
    end

    if game.isFail then
        if k == keys.restart then
            game.isFail = false
            game.showFailColors = false
            gameInit(ply, stats)
            mtrxClr(gMtrx)
            bagInit(ply)
            plyInit(ply)
        end
        if k == "i" then
            if not game.showFailColors then
                game.showFailColors = true
            else
                game.showFailColors = false
            end
        end
    end

    -- ### below is for debug only ###
    if not game.isFail and not game.isPaused and not game.isPauseDelay then
        if k == "r" then
            plyInit(ply)
        end

        if k == "e" then
            bagInit(ply)
            plyInit(ply)
            mtrxClr(gMtrx)
        end

        if k == "i" then
            if not game.useHold then
                game.useHold = true
            else
                game.useHold = false
            end
        end

        -- if k == "o" then
        --     ply.currBlk = 1
        -- end
    end

    if k == "0" then
        settings.scale = 1
    end

    if k == "f4" then
        if not settings.isDebug then
            settings.isDebug = true
        else
            settings.isDebug = false
        end
    end

    if k == "f5" then
        if not settings.showInfo then
            settings.showInfo = true
        else
            settings.showInfo = false
        end
    end
end

function love.resize(w, h)
    wWd, wHg = w, h
end

function love.focus(f)
    if not game.isFail and not game.isPauseDelay then
        if f then
            if not game.isPaused then
                game.isPaused = false
            end
        else
            game.isPaused = true
        end
    end
end

function love.update(dt)
    -- time milliseconds
    local _, tMs = math.modf(stats.time)

    if game.isPauseDelay then
        if stats.pTime >= 1 then
            stats.pTime = 0
            game.isPauseDelay = false
        else
            stats.pTime = stats.pTime + dt
        end
    end

    if not game.isPaused and not game.isPauseDelay and not game.isFail then
        stats.time = stats.time + dt
        stats.timeDisp = string.format("%02d", math.floor(stats.time / 60)) ..
            ":" .. string.format("%02d", stats.time % 60) .. "." .. string.format("%.2f", tMs):sub(3, -1)

        -- line delay function
        if ply.isLnDly and not game.isFail then
            -- the ultimate performance boost /j
            local ipair = ipairs
            if ply.lnDly > 0 then
                if ply.lnDlyTmr < ply.lnDly then
                    ply.lnDlyTmr = ply.lnDlyTmr + dt
                else
                    print("shifted lines by -1 (lnDly: " .. ply.lnDly .. ")")

                    for _, yPos in ipair(stats.clearedLinesYPos) do
                        moveCells(yPos, gMtrx, gBoard)
                    end

                    ply.isLnDly = false
                    ply.lnDlyTmr = 0
                    if #stats.clearedLinesYPos > 0 then
                        tClear(stats.clearedLinesYPos)
                    end

                    -- only shuffle bag after line delay
                    if not game.isFail then
                        bagInit(ply)
                    end
                end
            else
                print("shifted lines by -1 (lnDly: " .. ply.lnDly .. ")")
                for _, yPos in ipair(stats.clearedLinesYPos) do
                    moveCells(yPos, gMtrx, gBoard)
                end

                ply.isLnDly = false
                ply.lnDlyTmr = 0
                if #stats.clearedLinesYPos > 0 then
                    tClear(stats.clearedLinesYPos)
                end

                -- only shuffle bag after line delay
                if not game.isFail then
                    bagInit(ply)
                end
                if settings.useIRS then
                    checkIRS(ply, blocks)
                end
            end
        else
            ply.lnDlyTmr = 0
        end

        -- line effect
        lEUpdate(stats.lEffect, dt)
        lkUpd(stats.lkEfct, dt)
        lkUpd(stats.hDEfct, dt)

        -- danger zone detection
        if dangerCheck(gMtrx) == 1 then
            -- TODO: This is safe right?
            if ply.dangerA < 0.15 then
                ply.dangerA = tonumber(string.format("%.2f", ply.dangerA + dt))
            elseif ply.dangerA > 0.15 then
                ply.dangerA = tonumber(string.format("%.2f", ply.dangerA - dt))
            end
        elseif dangerCheck(gMtrx) == 2 then
            if ply.dangerA < 0.25 then
                ply.dangerA = ply.dangerA + dt
            end
        else
            if ply.dangerA > 0 then
                ply.dangerA = ply.dangerA - dt * 0.5
            end
        end

        -- game movement function
        if not ply.isLnDly then
            if not ply.isHDrop then
                if lk.isDown(keys.left) or lk.isDown(keys.right) then
                    if ply.dasTimer > ply.das then
                        if ply.arrTimer > ply.arr then
                            if lk.isDown(keys.left) then
                                if bMove(ply.x - 1, ply.y, ply.bRot, gMtrx) then
                                    ply.x = ply.x - 1
                                end
                            end
                            if lk.isDown(keys.right) then
                                if bMove(ply.x + 1, ply.y, ply.bRot, gMtrx) then
                                    ply.x = ply.x + 1
                                end
                            end
                        else
                            ply.arrTimer = ply.arrTimer + dt
                        end
                    else
                        ply.dasTimer = ply.dasTimer + dt
                    end
                else
                    ply.dasTimer = 0
                    ply.arrTimer = 0
                end
            end

            if lk.isDown(keys.sDrop) then
                if ply.sdrTimer < ply.sdr then
                    ply.sdrTimer = ply.sdrTimer + dt
                else
                    if bMove(ply.x, ply.y + 1, ply.bRot, gMtrx) then
                        ply.y = ply.y + 1
                        if ply.sdrTimer > ply.sdr then
                            ply.sdrTimer = 0
                        end
                    else
                        if settings.rotSys == "ARS" then
                            if ply.gTimer < ply.grav then
                                ply.gTimer = ply.grav
                            end
                        end
                    end
                end
            else
                if bMove(ply.x, ply.y + 1, ply.bRot, gMtrx) then
                    ply.sdrTimer = 0
                end
            end

            if ply.gTimer <= ply.grav and bMove(ply.x, ply.y + 1, ply.bRot, gMtrx) then
                if not ply.isHDrop then
                    ply.gTimer = ply.gTimer + dt
                    ply.lDTimer = 0
                end
            else
                if not ply.isHDrop then
                    ply.gTimer = 0
                end
                if bMove(ply.x, ply.y + 1, ply.bRot, gMtrx) then
                    ply.y = ply.y + 1
                    ply.lDTimer = 0
                else
                    if ply.lDTimer < ply.lDelay then
                        ply.lDTimer = ply.lDTimer + dt
                    else
                        if not ply.isHDrop then
                            stats.stacks = stats.stacks + 1
                            bAdd(ply.x, ply.y, blocks, gMtrx)
                        end

                        if not game.isFail then
                            if not ply.isLnDly then
                                bagInit(ply)
                            end
                            plyInit(ply)
                        end
                    end
                end
            end
        end

        if ply.isHDrop then
            ply.isHDrop = false
        end

        for _, blk in ipairs(gMtrx) do
            gBoard.visW = #blk
        end

        gBoard.visH = #gMtrx

        -- max stats values
        if stats.maxComb < stats.comb then
            stats.maxComb = stats.comb - 1
        end

        if stats.maxStrk < stats.strk then
            stats.maxStrk = stats.strk - 1
        end

        -- TODO: Is this delay reasonable?
        if stats.maxPPS < stats.stacks / stats.time and stats.time > 0.25 then
            stats.maxPPS = stats.stacks / stats.time
        end

        -- workaround for rotation
        if blocks[ply.currBlk] ~= nil then
            if ply.bRot > #blocks[ply.currBlk] then
                ply.bRot = 1
            end
        end

        -- line clear ui function
        for i, lnui in ipairs(stats.lClearUI) do
            if lnui.a > 0 then
                lnui.a = lnui.a - dt * lnui.aSpd
            else
                table.remove(stats.lClearUI, i)
            end
        end

        -- color flash update
        colFlashUpd(cFStrk, dt)
        colFlashUpd(cFCb, dt)
        colFlashUpd(cFAC, dt)
    end


    if not game.isPaused and not game.isPauseDelay then
        -- game fail function
        if isGFail(gMtrx) then
            game.isFail = true
            if #stats.lEffect > 0 then
                tClear(stats.lEffect)
            end
            if #stats.lkEfct > 0 then
                tClear(stats.lkEfct)
            end
            if #stats.clearedLinesYPos > 0 then
                tClear(stats.clearedLinesYPos)
            end
            if #stats.hDEfct > 0 then
                tClear(stats.hDEfct)
            end
            if ply.isHDrop then
                ply.isHDrop = false
            end
        end

        -- increase width for hard drop effect in separate variable
        -- store width & current position values to table
        -- after storing values to table, reset current unstored value for width to 0
        -- stored variable is used for width of current object & current players position of block
        -- rinse and repeat

        -- game fail function
        if game.isFail then
            plyInit(ply)
        end

        -- for fail text
        colFlashUpd(cFFail, dt)
    end

    if lk.isDown("-") then
        settings.scale = settings.scale - dt
    end

    if lk.isDown("=") then
        settings.scale = settings.scale + dt
    end
end

-- pause stats
local function dPStats(xOff, yOff)
    lg.printf(
        { gCol.green, "sg: ", gCol.white, stats.clr.sgl, gCol.purple, " dbl: ", gCol.white, stats.clr.dbl, gCol
            .yellow,
            " trp: ", gCol.white, stats.clr.trp, gCol.lBlue, " qd: ", gCol.white, stats.clr.qd, gCol.white, "   |  ",
            gCol
                .orange, " all clears: ", gCol.white, stats.clr.ac, gCol.red, " max comb. ", gCol.orange, "&", gCol
            .purple, " strk: ", gCol.white, "x" ..
        stats.maxComb .. ", x" .. stats.maxStrk .. "  |  ", gCol.yellow, "max spd.: ", gCol.white,
            string.format("%.2f", stats.maxPPS) .. " p/s" }, fonts.othr, 0 + xOff, wHg - 30 + yOff, wWd, "center")
end

function love.draw()
    -- game board
    lg.push()
    lg.scale(settings.scale, settings.scale)
    lg.translate(
        (wWd / (2 * settings.scale)) - ((gBoard.w * gBoard.visW) / 2),
        (wHg / (2 * settings.scale)) - ((gBoard.h * gBoard.visH) / 2)
    )
    lg.setColor(.06, .06, .12, 1)
    lg.rectangle("fill", gBoard.x, gBoard.y + gBoard.h, gBoard.w * 10, gBoard.h * gBoard.gH - gBoard.h)

    -- danger zone overlay
    if settings.showDanger then
        lg.setColor(1, 0.15, 0.15, ply.dangerA)
        if not game.isFail then
            lg.rectangle("fill", gBoard.x, gBoard.y + gBoard.w, gBoard.w * gBoard.visW, gBoard.h * (gBoard.visH - 1))
        end
    end

    if settings.showGrid then
        dGrid(gMtrx)
    end

    if not game.isPaused then
        -- hard drop effect
        hDDrw(stats.hDEfct)

        if settings.showOutlines then
            dOutline(gMtrx, 2)
        end

        for y, _ in ipairs(gMtrx) do
            for x, br in ipairs(gMtrx[y]) do
                if y ~= 1 then
                    dBlocks(br, x, y)
                end
            end
        end

        if not ply.isLnDly and not ply.isEnDly then
            for y, _ in ipairs(blocks[ply.currBlk][ply.bRot]) do
                for x, blk in ipairs(blocks[ply.currBlk][ply.bRot][y]) do
                    if y == 1 then
                        if blk ~= 0 then
                            dBlocks(blk, x + ply.x, y + ply.y, false, false, false, true)
                        end
                    else
                        if blk ~= 0 then
                            dBlocks(blk, x + ply.x, y + ply.y, false, false, false, true)
                        end
                    end
                end
            end
        end

        lEDraw(stats.lEffect)
        lkDrw(stats.lkEfct)
    end


    -- game ui
    failCol(false)
    lg.printf("SCORE", fonts.othr, -60, gBoard.h * (gBoard.visH - 2.35), 40, "right")
    lg.printf(stats.scr, fonts.ui, -1200, gBoard.h * (gBoard.visH - 1.85), 1200 - 20, "right")

    lg.printf("LV.", fonts.othr, gBoard.w * (gBoard.visW + 0.85), gBoard.h * (gBoard.visH - 6.15), 40, "left")
    lg.printf(stats.lv, fonts.ui, gBoard.w * (gBoard.visW + 0.85), gBoard.h * (gBoard.visH - 5.65), 1200, "left")

    lg.printf("LINES", fonts.othr, gBoard.w * (gBoard.visW + 0.85), gBoard.h * (gBoard.visH - 3.65), 40, "left")
    lg.printf(stats.line, fonts.ui, gBoard.w * (gBoard.visW + 0.85), gBoard.h * (gBoard.visH - 3.15), 1200, "left")

    failCol(true)
    lg.printf(string.format("%.2f", stats.stacks / stats.time) .. " p/s", fonts.othr, gBoard.w * (gBoard.visW + 0.85),
        gBoard.h * (gBoard.visH - 1.35), 1200, "left")

    failCol(false)
    lg.printf(stats.timeDisp, fonts.time, gBoard.x,
        gBoard.h * (gBoard.visH + 0.35), gBoard.w * gBoard.visW, "center")

    -- next frame text
    lg.setColor(gCol.nBox)
    lg.rectangle("fill", gBoard.w * (gBoard.visW + 1), gBoard.y + 20, 80, 23)

    lg.setColor(nxtCol(ply.currBlk, false))
    lg.rectangle("fill", gBoard.w * (gBoard.visW + 1), gBoard.y + 20, 3, 23)

    -- hold frame text
    if game.useHold then
        lg.setColor(gCol.nBox)
        lg.rectangle("fill", -60 - (80 / 2), gBoard.y + 20, 80, 23)
    end

    if game.useHold then
        lg.setColor(nxtCol(ply.hold, true))
        lg.rectangle("fill", -23, gBoard.y + 20, 3, 23)
    end

    -- hold & next boxes
    dNBox(blocks, ply, false)
    if game.useHold then
        dNBox(blocks, ply, true)
    end

    failCol(false)
    lg.printf("NEXT", fonts.othr, gBoard.w * (gBoard.visW + 1.5), gBoard.y + 26, 40, "left")
    if game.useHold then
        lg.printf("HOLD", fonts.othr, -60 - 8, gBoard.y + 26, 40, "right")
    end

    -- line clear ui effects
    for i, lnui in ipairs(stats.lClearUI) do
        local clr = function()
            if not game.isFail then
                if settings.rotSys == "ARS" then
                    return {
                        gColD.red,
                        gColD.green,
                        gColD.purple,
                        gColD.orange,
                        gColD.blue,
                        gColD.yellow,
                        gColD.lBlue,
                        C = cFAC.col[cFAC.index]
                    }
                end
            else
                local tCol = 0.35
                return { gCol.gray[1] + tCol, gCol.gray[2] + tCol, gCol.gray[3] + tCol }
            end
        end

        local clrB = function()
            if not game.isFail then
                if settings.rotSys == "ARS" then
                    return {
                        -- duct tape
                        { gCol.red[1] - .2,    gCol.red[2] - .2,    gCol.red[3] - .2 },
                        { gCol.green[1] - .2,  gCol.green[2] - .2,  gCol.green[3] - .2 },
                        { gCol.purple[1] - .2, gCol.purple[2] - .2, gCol.purple[3] - .2 },
                        { gCol.orange[1] - .2, gCol.orange[2] - .2, gCol.orange[3] - .2 },
                        { gCol.blue[1] - .2,   gCol.blue[2] - .2,   gCol.blue[3] - .2 },
                        { gCol.yellow[1] - .2, gCol.yellow[2] - .2, gCol.yellow[3] - .2 },
                        { gCol.lBlue[1] - .2,  gCol.lBlue[2] - .2,  gCol.lBlue[3] - .2 },
                        C = cFAC.col[cFAC.index]
                    }
                end
            else
                local tCol = 0.35
                return { gCol.gray[1] + tCol, gCol.gray[2] + tCol, gCol.gray[3] + tCol }
            end
        end

        -- text background
        if not game.isFail then
            lg.setColor(clr()[lnui.cBlk][1], clr()[lnui.cBlk][2], clr()[lnui.cBlk][3], lnui.a)
        else
            lg.setColor(clr()[1], clr()[2], clr()[3], lnui.a)
        end

        lg.rectangle("fill", -52 - (35 * (i - 1)), gBoard.h * (gBoard.visH - 12), 30, 30)

        -- backdrop text
        if not game.isFail then
            lg.setColor(clrB()[lnui.cBlk][1], clrB()[lnui.cBlk][2], clrB()[lnui.cBlk][3], lnui.a)
            lg.printf(lnui.str, fonts.ui, -1210 - (35 * (i - 1)) + 2, gBoard.h * (gBoard.visH - 12) + 2, 1200 - 20,
                "right")
        end

        -- front text
        lg.setColor(1, 1, 1, lnui.a)
        lg.printf(lnui.str, fonts.ui, -1210 - (35 * (i - 1)), gBoard.h * (gBoard.visH - 12), 1200 - 20, "right")
    end

    -- combo & streak ui
    if stats.strk > 1 then
        if not game.isFail then
            lg.setColor(cFStrk.col[cFStrk.index][1], cFStrk.col[cFStrk.index][2], cFStrk.col[cFStrk.index][3])
        end
        lg.printf("STK. x" .. stats.strk - 1, fonts.othr, -1200, gBoard.h * (gBoard.visH - 9), 1200 - 20, "right")
    end

    if stats.comb > 1 then
        if not game.isFail then
            lg.setColor(cFCb.col[cFCb.index][1], cFCb.col[cFCb.index][2], cFCb.col[cFCb.index][3])
        end
        lg.printf("COMBO x" .. stats.comb - 1, fonts.othr, -1200, gBoard.h * (gBoard.visH - 9.75), 1200 - 20, "right")
    end

    -- board frame
    lg.setColor(0.7, 0.7, 0.7, 1)
    lg.rectangle("line", gBoard.x, gBoard.y + gBoard.h, gBoard.w * 10, gBoard.h * gBoard.gH - gBoard.gH)

    -- ghost piece
    if not game.isPaused and not ply.isLnDly and not ply.isEnDly and settings.showGhost then
        bGhost(false)
        bGhost(true)
    end

    -- pause delay screen
    if game.isPauseDelay then
        local pbCol = function(isAlpha, isInner)
            if isAlpha then
                return { gCol.white[1] + 0.25, gCol.white[2] + 0.25, gCol.white[3] + 0.25,
                    lerp.easeOutCubic(0, 1, stats.pTime) }
            elseif isInner then
                return gCol.gray
            else
                return { gCol.gOutline[1] - 0.4, gCol.gOutline[2] - 0.4, gCol.gOutline[3] - 0.4 }
            end
        end
        lg.setColor(pbCol(false, false))
        lg.rectangle("fill", gBoard.x + 10 - 2, (gBoard.y + gBoard.h * gBoard.visH) / 2 - 2,
            (gBoard.w * gBoard.visW) - 20 + 4, 20 + 4)
        lg.setColor(pbCol(false, true))
        lg.rectangle("fill", gBoard.x + 10, (gBoard.y + gBoard.h * gBoard.visH) / 2,
            (gBoard.w * gBoard.visW) - 20, 20)

        lg.setColor(pbCol(true, false))
        lg.rectangle("fill", gBoard.x + 10, (gBoard.y + gBoard.h * gBoard.visH) / 2,
            (gBoard.w * gBoard.visW) * lerp.easeOutCubic(0, 1, stats.pTime) - 20, 20)
    end

    -- fail screen
    if game.isFail then
        lg.setColor(cFFBG.col[cFFail.index])
        lg.printf("GAME\nOVER", fonts.beeg, gBoard.x + 2, (gBoard.y + (gBoard.h * gBoard.visH)) / 2.63 + 2,
            gBoard.w * gBoard.visW,
            "center")
        lg.setColor(cFFail.col[cFFail.index])
        lg.printf("GAME\nOVER", fonts.beeg, gBoard.x, (gBoard.y + (gBoard.h * gBoard.visH)) / 2.63,
            gBoard.w * gBoard.visW,
            "center")
        lg.setColor(gCol.bg[1], gCol.bg[2], gCol.bg[3], 0.9)
        lg.printf("<Enter> restart\n<I> show/hide colors", fonts.othr, gBoard.x + 1,
            (gBoard.y + (gBoard.h * gBoard.visH)) / 1.65 + 1, gBoard.w * gBoard.visW, "center")
        lg.setColor(1, 1, 1, 1)
        lg.printf({ gCol.yellow, "<Enter>", gCol.white, " restart\n", gCol.red, "<I>", gCol.white, " show/hide colors" },
            fonts.othr, gBoard.x,
            (gBoard.y + (gBoard.h * gBoard.visH)) / 1.65,
            gBoard.w * gBoard.visW,
            "center")
    end
    lg.pop()

    -- stats in fail screen
    if game.isFail then
        lg.setColor(gCol.bg)
        dPStats(2, 2)
        lg.setColor(1, 1, 1, 1)
        dPStats(0, 0)
    end

    -- pause menu
    if game.isPaused then
        lg.setColor(gCol.bg)
        lg.setColor(0, 0, 0, 0.45)
        lg.rectangle("fill", 0, 0, wWd, wHg)
        lg.setColor(1, 1, 1, 1)
        lg.printf("- PAUSED -", fonts.ui, 0, wHg / 2, wWd, "center")
        lg.printf({ gCol.orange, "<" .. keys.pause:gsub("^%l", string.upper) .. "> ", gCol.gOutline, "to continue" },
            fonts.othr, 0, wHg / 2 + 30, wWd, "center")
        lg.setColor(gCol.bg)
        lg.rectangle("fill", 0, wHg - 50, wWd, 50)
        lg.setColor(1, 1, 1, 1)
        dPStats(0, 0)
    else
        -- info txt
        if settings.showInfo and not game.isFail then
            lg.setColor(gCol.gray)
            lg.printf("very unstable!!\nexpect some crashes", fonts.othr, 0, wHg - 40, wWd - 20, "right")
        end
    end

    -- debug
    lg.setColor(1, 1, 1, 1)
    if settings.isDebug then
        lg.print(
            lt.getFPS() ..
            " FPS\n" ..
            wWd ..
            "x" ..
            wHg ..
            "\n" ..
            lg.getStats().drawcalls ..
            " draws / " ..
            lg.getStats().texturememory / 1024 / 1024 ..
            " MB" ..
            "\nsc: " ..
            settings.scale ..
            "\nlEffect: " ..
            #stats.lEffect ..
            "\nlkEfct: " ..
            #stats.lkEfct ..
            "\nuseHold: " ..
            tostring(game.useHold) ..
            "\nlowestCells: " ..
            lowestCells(ply, gMtrx, false) ..
            " / " ..
            lowestCells(ply, gMtrx, true) .. "\nclearedLinesYPos: " .. table.concat(stats.clearedLinesYPos, " ,"),
            fonts.othr, 10, 10)
        lg.printf(
            "x: " ..
            ply.x ..
            "\ny: " ..
            ply.y ..
            "\nvisW: " .. gBoard.visW .. "\nvisH: " .. gBoard.visH ..
            "\nbRot: " ..
            ply.bRot .. " / " .. #blocks[ply.currBlk] ..
            "\ncurrBlk: " ..
            ply.currBlk .. " / " .. #blocks ..
            "\ndasTimer: " ..
            ply.dasTimer .. " / " .. ply.das ..
            "\narrTimer: " ..
            ply.arrTimer .. " / " .. ply.arr ..
            "\nsdrTimer: " ..
            ply.sdrTimer .. " / " .. ply.sdr ..
            "\ngTimer: " ..
            ply.gTimer .. " / " .. ply.grav ..
            "\nlDTimer: " ..
            ply.lDTimer .. " / " .. ply.lDelay .. "\nlnDlyTmr: " .. ply.lnDlyTmr .. " / " .. ply.lnDly ..
            "\nisLnDly: " .. tostring(ply.isLnDly) .. "\nisHDrop: " ..
            tostring(ply.isHDrop) .. "\nisAlreadyHold: " .. tostring(ply.isAlreadyHold) ..
            "\nisPaused: " .. tostring(game.isPaused) .. "\nisPauseDelay: " .. tostring(game.isPauseDelay) ..
            "\nrotSys: " .. settings.rotSys .. "\nstacks: " .. stats.stacks .. "\nisFail: " .. tostring(game.isFail) ..
            "\nsg: " ..
            stats.clr.sgl ..
            "\ndb: " ..
            stats.clr.dbl .. "\ntp: " .. stats.clr.trp .. "\nqd: " .. stats.clr.qd .. "\n ac: " .. stats.clr.ac
            .. "\ncomb: " .. stats.comb .. "\nstrk: " .. stats.strk,
            fonts.othr, 0, 10, wWd - 10, "right")
    end
end
