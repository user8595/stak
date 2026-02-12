-- high score as of writing: 302k+, lv 12, ~07:00 time
-- highest secret grade as of writing: s7, lv 11, 04:42.54 time
--TODO: Implement secret grade values
local lg, lw, lk, lm = love.graphics, love.window, love.keyboard, love.mouse
local lt, le = love.timer, love.event

local wWd, wHg = lg.getWidth(), lg.getHeight()

local tClear = require "table.clear"

local fonts = {
    ui = lg.newFont("/assets/fonts/monogram-extended.TTF", 32),
    time = lg.newFont("/assets/fonts/monogram-extended.TTF", 42),
    othr = lg.newFont("/assets/fonts/Picopixel.ttf", 14)
}

local game = {
    isPaused = false
}

local settings = {
    showGrid = true,
    showOutlines = true,
    scale = 1,
    -- TODO: Implement rotation system switching
    rotSys = "ARS",
    isDebug = function()
        if arg[2] == "debug" then
            return true
        else
            return false
        end
    end
}

local keys = {
    hDrop = "w",
    sDrop = "s",
    left = "a",
    right = "d",
    cw = "l",
    ccw = "k",
    hold = "space",
    pause = "p"
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
    currBlk = 1,
    bRot = 1,
    next = {},
    hold = 0,

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

    --TODO: Implement IRS
    -- lock delay
    lDTimer = 0,
    isLDly = false,
    lDelay = 500 / 1000,

    -- line delay
    lnDlyTmr = 0,
    lnDly = 500 / 1000,

    -- gravity
    gTimer = 0,
    grav = 1000 / 1000,

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
    lClearUI = {}
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
    white = { .80, .84, .96 }
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

local blocks = {
    -- TODO: Implement modern rotation (low priority)
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
            { 0,   "T", 0 },
            { "T", "T", "T" },
        },
        {
            { 0, "T", 0 },
            { 0, "T", "T" },
            { 0, "T", 0 }
        },
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
    },
}

local function plyInit(plyVar)
    plyVar.x, plyVar.y, plyVar.bRot = 3, 0, 1
    plyVar.lDTimer, plyVar.gTimer, plyVar.sdrTimer = 0, 0, 0
end

local function gameInit(plyVar, sts)
    plyVar.arrTimer, plyVar.dasTimer, plyVar.gTimer, plyVar.grav = 0, 0, 0, 1000 / 1000
    sts.time = 0
    sts.clr.sgl, sts.clr.dbl, sts.clr.trp, sts.clr.qd, sts.clr.ac = 0, 0, 0, 0, 0
    sts.lv = 1
    sts.line = 0
    sts.strk, sts.comb = 0, 0
    sts.nxtLines = 0
end

local function mtrxClr(mtrxTab)
    for y, _ in ipairs(mtrxTab) do
        for x, _ in ipairs(mtrxTab[y]) do
            mtrxTab[y][x] = 0
        end
    end
end

local function dBlocks(bl, x, y, isGhost)
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
            }
        end
    end
    if bl ~= 0 then
        if isGhost then
            lg.setColor(colors()[bl][1], colors()[bl][2], colors()[bl][3], 0.25)
        else
            lg.setColor(colors()[bl])
        end

        lg.rectangle("fill", gBoard.x + gBoard.w * (x - 1), gBoard.y + gBoard.h * (y - 1), gBoard.w, gBoard.h)
        --outline for ghost
        if isGhost then
            lg.setColor(colors()[bl][1], colors()[bl][2], colors()[bl][3], 0.5)
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

local function dOutline(mtrxTab)
    for y, _ in ipairs(mtrxTab) do
        for x, br in ipairs(mtrxTab[y]) do
            if y ~= 1 then
                if br ~= 0 then
                    lg.setColor(1, 1, 1, 1)
                    lg.rectangle("fill", gBoard.x + gBoard.w * (x - 1) - 2, gBoard.y + gBoard.h * (y - 1) - 2,
                        gBoard.w + 4,
                        gBoard.h + 4)
                end
            end
        end
    end
end

local function bMove(tX, tY, mtrxTab)
    if blocks[ply.currBlk][ply.bRot] ~= nil then
        for y = 1, #blocks[ply.currBlk][ply.bRot] do
            for x = 1, #blocks[ply.currBlk][ply.bRot][y] do
                local tX, tY = tX + x, tY + y
                if blocks[ply.currBlk][ply.bRot][y][x] ~= 0 and (
                        tX < 1 or tX > gBoard.visW or tY > gBoard.visH or mtrxTab[tY][tX] ~= 0
                    ) then
                    return false
                end
            end
        end
    else
        return false
    end
    return true
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

local function bRotate(tX, tY, mtrxTab)
    -- TODO: Implement ARS wallkicks
    if settings.rotSys == "ARS" then
        local bLen = blocks[ply.currBlk]
        if #bLen > 1 then

        end
        return true
    end
end

-- block placement & line clear logic
local function bAdd(bX, bY, bL, mtrxTab)
    local clear = true
    local cAnim = false
    for y, _ in ipairs(bL[ply.currBlk][ply.bRot]) do
        for x, blk in ipairs(bL[ply.currBlk][ply.bRot][y]) do
            if blk ~= 0 then
                if bY + y <= #mtrxTab then
                    mtrxTab[bY + y][bX + x] = blk
                end
            end
        end
    end

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
            stats.line = stats.line + 1
            stats.lineClr = stats.lineClr + 1

            -- trigger line animation function (txt for now)
            cAnim = true
            print("---------- cAnim: " .. tostring(cAnim) .. " ----------")
            -- TODO: Implement line clear delay
            -- move top rows from cleared line to bottom
            for clrY = y, 2, -1 do
                for clrX = 1, gBoard.visW do
                    mtrxTab[clrY][clrX] = mtrxTab[clrY - 1][clrX]
                end
            end
            -- clear lines with empty tiles
            for clrX = 1, gBoard.visW do
                mtrxTab[1][clrX] = 0
                clear = false
            end
        end
    end

    if cAnim then tClear(stats.lClearUI) end

    if isAllClr(mtrxTab) then
        print("+16000 score points from aClear")
        stats.scr = stats.scr + 16000
        stats.clr.ac = stats.clr.ac + 1
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
            stats.nxtLines = stats.nxtLines + 10
        end
        stats.lineClr = 0
        cAnim = false
        print("---------- cAnim: " .. tostring(cAnim) .. " ----------")
    else
        stats.comb = 0
    end
end

local function bGhost(mtrxTab)
    local gX, gY = 0 + ply.x, 0 + ply.y
    while bMove(gX, gY + 1, mtrxTab) do
        gY = gY + 1
    end

    for y, _ in ipairs(blocks[ply.currBlk][ply.bRot]) do
        for x, blk in ipairs(blocks[ply.currBlk][ply.bRot][y]) do
            if blk ~= 0 then
                dBlocks(blk, x + gX, y + gY, true)
            end
        end
    end
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
local cFCb = colFlashNew(gCol.yellow, gCol.orange, 0.75)
local cFAC = colFlashNew(gColD.yellow, gColD.lBlue, 0.1)

function love.load()
    lg.setBackgroundColor(gCol.bg)
    lm.setVisible(false)
end

function love.keypressed(k)
    if k == "escape" then
        if game.isPaused then
            le.quit(0)
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
        if not game.isPaused then
            game.isPaused = true
        else
            game.isPaused = false
        end
    end

    if not game.isPaused then
        if k == keys.left then
            if bMove(ply.x - 1, ply.y, gMtrx) then
                ply.x = ply.x - 1
                ply.dasTimer = 0
                ply.arrTimer = 0
            end
        end

        if k == keys.right then
            if bMove(ply.x + 1, ply.y, gMtrx) then
                ply.x = ply.x + 1
                ply.dasTimer = 0
                ply.arrTimer = 0
            end
        end

        -- TODO: Implement hard drop animation (trails of current obj)
        if k == keys.hDrop then
            while bMove(ply.x, ply.y + 1, gMtrx) do
                ply.y = ply.y + 1
                ply.sdrTimer = 0
                ply.arrTimer = 0
                ply.gTimer = ply.grav
                ply.lDTimer = ply.lDelay
                ply.gTimer = ply.grav
            end
            if ply.lDTimer < ply.lDelay then
                bAdd(ply.x, ply.y, blocks, gMtrx)
                ply.x, ply.y = 3, 0
                ply.bRot = 1
            end
        end

        if k == keys.ccw then
            if bRotate(ply.x, ply.y, gMtrx) then
                if ply.bRot > 1 then
                    ply.bRot = ply.bRot - 1
                else
                    ply.bRot = #blocks[ply.currBlk]
                end
            end
        end

        if k == keys.cw then
            if bRotate(ply.x, ply.y, gMtrx) then
                if ply.bRot < #blocks[ply.currBlk] then
                    ply.bRot = ply.bRot + 1
                else
                    ply.bRot = 1
                end
            end
        end

        if k == keys.sDrop then
            if bMove(ply.x, ply.y + 1, gMtrx) then
                ply.sdrTimer = 0
                ply.y = ply.y + 1
            else
                ply.gTimer = ply.grav
            end
        end
    end

    -- ### below is for debug only ###
    if k == "r" then
        plyInit(ply)
        settings.scale = 1
    end

    if k == "o" then
        if ply.currBlk < #blocks then
            ply.currBlk = ply.currBlk + 1
        else
            ply.currBlk = 1
        end
    end

    if k == "e" then
        plyInit(ply)
        mtrxClr(gMtrx)
        settings.scale = 1
    end

    if k == "f4" then
        if not settings.isDebug then
            settings.isDebug = true
        else
            settings.isDebug = false
        end
    end
end

function love.resize(w, h)
    wWd, wHg = w, h
end

function love.update(dt)
    -- time milliseconds
    local _, tMs = math.modf(stats.time)

    if not game.isPaused then
        stats.time = stats.time + dt
        stats.timeDisp = string.format("%02d", math.floor(stats.time / 60)) ..
            ":" .. string.format("%02d", stats.time % 60) .. "." .. string.format("%.2f", tMs):sub(3, -1)

        -- das & arr implemented
        if lk.isDown(keys.left) or lk.isDown(keys.right) then
            if ply.dasTimer > ply.das then
                if ply.arrTimer > ply.arr then
                    if lk.isDown(keys.left) then
                        if bMove(ply.x - 1, ply.y, gMtrx) then
                            ply.x = ply.x - 1
                        end
                    end
                    if lk.isDown(keys.right) then
                        if bMove(ply.x + 1, ply.y, gMtrx) then
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

        if lk.isDown(keys.sDrop) then
            if ply.sdrTimer < ply.sdr then
                ply.sdrTimer = ply.sdrTimer + dt
            else
                if bMove(ply.x, ply.y + 1, gMtrx) then
                    ply.y = ply.y + 1
                    ply.sdrTimer = 0
                else
                    if settings.rotSys == "ARS" then
                        if ply.gTimer < ply.grav then
                            ply.gTimer = ply.grav
                        end
                    end
                end
            end
        else
            if bMove(ply.x, ply.y + 1, gMtrx) then
                ply.sdrTimer = 0
            end
        end

        if ply.gTimer <= ply.grav then
            ply.gTimer = ply.gTimer + dt
        else
            if bMove(ply.x, ply.y + 1, gMtrx) then
                ply.y = ply.y + 1
                ply.lDTimer = 0
                ply.gTimer = 0
            else
                if ply.lDTimer < ply.lDelay then
                    -- sDrop button held == stuck on this line
                    -- TODO: Fix soft drop issue
                    ply.lDTimer = ply.lDTimer + dt
                else
                    bAdd(ply.x, ply.y, blocks, gMtrx)
                    plyInit(ply)
                    --TODO: Add entry delay
                end
            end
        end

        if not bMove(ply.x, ply.y, gMtrx) and not bRotate(ply.x, ply.y, gMtrx) then
            plyInit(ply)
            gameInit(ply, stats)
            mtrxClr(gMtrx)
        end

        for _, blk in ipairs(gMtrx) do
            gBoard.visW = #blk
        end

        gBoard.visH = #gMtrx

        if stats.maxComb < stats.comb then
            stats.maxComb = stats.comb
        end

        if stats.maxStrk < stats.strk then
            stats.maxStrk = stats.strk - 1
        end

        -- workaround for test
        if ply.bRot > #blocks[ply.currBlk] then
            ply.bRot = 1
        end

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

    if lk.isDown("-") then
        settings.scale = settings.scale - dt
    end

    if lk.isDown("=") then
        settings.scale = settings.scale + dt
    end
end

function love.draw()
    -- board matrix
    lg.push()
    lg.scale(settings.scale, settings.scale)
    lg.translate((wWd - (gBoard.w * gBoard.visW)) / 2, (wHg - (gBoard.h * gBoard.visH)) / 2)
    lg.setColor(.06, .06, .12, 1)
    lg.rectangle("fill", gBoard.x, gBoard.y + gBoard.h, gBoard.w * 10, gBoard.h * gBoard.gH - gBoard.h)

    if settings.showGrid then
        dGrid(gMtrx)
    end
    if not game.isPaused then
        if settings.showOutlines then
            dOutline(gMtrx)
        end

        for y, _ in ipairs(gMtrx) do
            for x, br in ipairs(gMtrx[y]) do
                if y ~= 1 then
                    dBlocks(br, x, y)
                end
            end
        end

        for y, _ in ipairs(blocks[ply.currBlk][ply.bRot]) do
            for x, blk in ipairs(blocks[ply.currBlk][ply.bRot][y]) do
                if y == 1 then
                    if blk ~= 0 then
                        dBlocks(blk, x + ply.x, y + ply.y)
                    end
                else
                    if blk ~= 0 then
                        dBlocks(blk, x + ply.x, y + ply.y)
                    end
                end
            end
        end
    end

    lg.setColor(1, 1, 1, 1)
    lg.printf("SCORE\n", fonts.othr, -60, gBoard.h * (gBoard.visH - 2.35), 40, "right")
    lg.printf(stats.scr, fonts.ui, -1200, gBoard.h * (gBoard.visH - 1.85), 1200 - 20, "right")

    lg.printf("LV.\n", fonts.othr, gBoard.w * (gBoard.visW + 0.85), gBoard.h * (gBoard.visH - 5), 40, "left")
    lg.printf(stats.lv, fonts.ui, gBoard.w * (gBoard.visW + 0.85), gBoard.h * (gBoard.visH - 4.5), 1200, "left")

    lg.printf("LINES\n", fonts.othr, gBoard.w * (gBoard.visW + 0.85), gBoard.h * (gBoard.visH - 2.5), 40, "left")
    lg.printf(stats.line, fonts.ui, gBoard.w * (gBoard.visW + 0.85), gBoard.h * (gBoard.visH - 2), 1200, "left")

    lg.printf(stats.timeDisp, fonts.time, gBoard.x,
        gBoard.h * (gBoard.visH + 0.35), gBoard.w * gBoard.visW, "center")

    for i, lnui in ipairs(stats.lClearUI) do
        local clr = function()
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
        end
        lg.setColor(clr()[lnui.cBlk][1], clr()[lnui.cBlk][2], clr()[lnui.cBlk][3], lnui.a)
        lg.rectangle("fill", -52 - (35 * (i - 1)), gBoard.h * (gBoard.visH - 12), 30, 30)
        lg.setColor(1, 1, 1, lnui.a)
        lg.printf(lnui.str, fonts.ui, -1210 - (35 * (i - 1)), gBoard.h * (gBoard.visH - 12), 1200 - 20, "right")
    end

    if stats.strk > 1 then
        lg.setColor(cFStrk.col[cFStrk.index][1], cFStrk.col[cFStrk.index][2], cFStrk.col[cFStrk.index][3])
        lg.printf("STK. x" .. stats.strk - 1, fonts.othr, -1200, gBoard.h * (gBoard.visH - 9), 1200 - 20, "right")
    end

    if stats.comb > 1 then
        lg.setColor(cFCb.col[cFStrk.index][1], cFCb.col[cFStrk.index][2], cFCb.col[cFStrk.index][3])
        lg.printf("COMBO x" .. stats.comb, fonts.othr, -1200, gBoard.h * (gBoard.visH - 9.75), 1200 - 20, "right")
    end

    lg.setColor(0.7, 0.7, 0.7, 1)
    lg.rectangle("line", gBoard.x, gBoard.y + gBoard.h, gBoard.w * 10, gBoard.h * gBoard.gH - gBoard.gH)
    if not game.isPaused then
        bGhost(gMtrx)
    end
    lg.pop()

    if game.isPaused then
        lg.setColor(gCol.bg)
        lg.setColor(0, 0, 0, 0.45)
        lg.rectangle("fill", 0, 0, wWd, wHg)
        lg.setColor(1, 1, 1, 1)
        lg.printf("- PAUSED -", fonts.ui, 0, wHg / 2, wWd, "center")
        lg.printf("<" .. keys.pause .. "> to continue", fonts.othr, 0, wHg / 2 + 30, wWd, "center")
        lg.printf(
            { gCol.green, "sg: ", gCol.white, stats.clr.sgl, gCol.purple, " dbl: ", gCol.white, stats.clr.dbl, gCol
                .yellow,
                " trp: ", gCol.white, stats.clr.trp, gCol.lBlue, " qd: ", gCol.white, stats.clr.qd, gCol.white, "   |  ",
                gCol
                    .orange, " all clears: ", gCol.white, stats.clr.ac, gCol.red, " max comb. ", gCol.yellow, "&", gCol
                .purple, " strk: ", gCol.white, "x" ..
            stats.maxComb .. " | x" .. stats.maxStrk }, fonts.othr, 0, wHg - 30, wWd, "center")
    end

    lg.setColor(1, 1, 1, 1)
    if settings.isDebug then
        lg.print(
            lt.getFPS() ..
            " FPS\n" ..
            wWd ..
            "x" ..
            wHg .. "\n" .. lg.getStats().drawcalls .. " draws / " .. lg.getStats().texturememory / 1024 / 1024 .. " MB",
            fonts.othr, 10, 10)
        lg.printf(
            "x: " ..
            ply.x ..
            "\ny: " ..
            ply.y ..
            "\nvisW: " .. gBoard.visW .. "\nvisH: " .. gBoard.visH ..
            "\nbRot: " ..
            ply.bRot ..
            "\ncurrBlk: " ..
            ply.currBlk ..
            "\ndasTimer: " ..
            ply.dasTimer ..
            "\narrTimer: " ..
            ply.arrTimer ..
            "\nsdrTimer: " ..
            ply.sdrTimer ..
            "\ngTimer: " ..
            ply.gTimer ..
            "\nlDTimer: " ..
            ply.lDTimer .. "\nrotSys: " .. settings.rotSys ..
            "\nsg: " ..
            stats.clr.sgl ..
            "\ndb: " ..
            stats.clr.dbl .. "\ntp: " .. stats.clr.trp .. "\nqd: " .. stats.clr.qd .. "\n ac: " .. stats.clr.ac
            .. "\ncomb: " .. stats.comb .. "\nstrk: " .. stats.strk,
            fonts.othr, 0, 10, wWd - 10, "right")
    end
end
