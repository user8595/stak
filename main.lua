-- high score as of writing: 21850500, lv 110, 1100 lines, 35:33.42 time (no gravity)
-- highest score as of writing: 19876066, lv 106, 1059 lines, 30:31.67 (60hz w/ gravity without resetting board)
-- fastest 40l as of writing: 00:48.79, 2.09pps

-- highest secret grade as of writing:
-- S8, lv 8, 75 lines, 03:33.64 time (ars)
-- GM, lv 9, 81 lines, 03:17.16 time (srs)

-- ##### a good reminder that this game relies a LOT with 1-based indexing #####
-- and the sky is blue

local lg, lw, lk, lm = love.graphics, love.window, love.keyboard, love.mouse
local lt, le = love.timer, love.event
local lmth = love.math
local ls = love.system

local wWd, wHg = lg.getWidth(), lg.getHeight()

-- libraries & core functions
local tClear = require "table.clear"
local lerp = require "lua.lerp"
local gTable = require "lua.tables"
local kOver = require "lua.kOver"
local tInfo = require "lua.textInfo"
local cFlash = require "lua.colFlash"
local button = require "lua.button"
local keys = require "lua.default.keys"
local restartUI = require "lua.restartUI"
local stats = require "lua.default.stats"
local gCol = require "lua.gCol"
local gfx = require "lua.game.gfx"
local effect = require "lua.game.effect"

local states = require "lua.game.states"

local fonts = {
    ui = lg.newFont("/assets/fonts/monogram-extended.TTF", 32),
    smol = lg.newFont("/assets/fonts/monogram-extended.TTF", 24),
    beeg = lg.newFont("/assets/fonts/monogram-extended.TTF", 64),
    time = lg.newFont("/assets/fonts/monogram-extended.TTF", 42),
    othr = lg.newFont("/assets/fonts/Picopixel.ttf", 14),
}

local uiIcons = lg.newImageFont("/assets/img/icons.png", "P")

-- textures
local tex = {
    danger = lg.newImage("/assets/img/danger.png")
}

fonts.beeg:setLineHeight(0.8)

for _, f in pairs(fonts) do
    f:setFilter("nearest", "nearest")
end

uiIcons:setFilter("nearest", "nearest")

for _, t in pairs(tex) do
    t:setFilter("nearest", "nearest")
end

-- for text popups
local textInfo = {}

-- game variables
local game = require("lua.default.game")
local settings = require("lua.default.settings")
local ply = require("lua.ply")

if arg[2] == "debug" then
    settings.isDebug = true
else
    settings.isDebug = false
end

local gMtrx = {}
local gBoard = {
    x = 0,
    y = 0,
    -- block size
    w = 20,
    h = 20,
    gH = 21,
    -- placeholder value
    visW = 10,
    visH = 21
}

for _ = 1, gBoard.gH, 1 do
    table.insert(gMtrx, { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 })
end

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

local blocks = gTable.blocks.ars

local overlays = require("lua.scenes.overlays")

if arg[2] == "debug" then
    table.insert(overlays, kOver.newKey(125, 60, "e", "E", gCol.gOutline, gCol.white))
    table.insert(overlays, kOver.newKey(135, 40, "r", "S", gCol.gOutline, gCol.white))
end

--TODO: Make IRS a buffer, not start from plyInit()
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
    plyVar.moveR = 0

    plyVar.lDTimer, plyVar.gTimer, plyVar.sdrTimer = 0, 0, 0
end

local function gameInit(plyVar, sts, gameVar)
    plyVar.arrTimer, plyVar.dasTimer = 0, 0
    plyVar.gTimer, plyVar.grav = 0, gTable.grav[1]
    -- index table
    plyVar.gMult = 1
    plyVar.isAlreadyHold = false
    plyVar.isAlrRot = false
    plyVar.isLnDly = false
    plyVar.isEnDly = false
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

    sts.qrTime = 0
    gameVar.is40LClr = false
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
    if plyVar.hold == 0 then
        plyVar.hold = plyVar.currBlk
        states.nextQueue(ply, settings)
    else
        -- replace block in hold with current block
        plyVar.currBlk = ply.hold
        -- replace block in hold with first block in next queue
        plyVar.hold = plyVar.next[1]
    end

    -- reset player position & values
    plyInit(plyVar)

    plyVar.isAlreadyHold = true
end

-- next queue outline
local function nxtCol(currBlk, isHold)
    local nBlk = ply.next[2]
    local cols = function()
        if not game.isFail or game.showFailColors then
            if settings.rotSys == "ARS" then
                return gTable.colTab.nxtCol.classic(gCol)
            else
                return gTable.colTab.nxtCol.modern(gCol)
            end
        else
            if settings.rotSys == "ARS" then
                return gTable.colTab.nxtCol.clD(gCol, gColD)
            else
                return gTable.colTab.nxtCol.mdD(gCol, gColD)
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

-- increment move reset counter
local function addMoves(plyVar)
    if game.useMoveReset then
        plyVar.moveR = plyVar.moveR + 1
    end
end

local cFStrk = cFlash.new(gCol.yellow, gCol.blue, .05)
local cFCb = cFlash.new(gCol.yellow, gCol.white, .05)
local cFAC = cFlash.new(gColD.yellow, gColD.lBlue, .1)

local cFSpn = cFlash.new(gColD.lBlue, gColD.orange, .1)

local cFFail = cFlash.new(gCol.orange, gCol.red, .05)
local cFFBG = cFlash.new(gColD.orange, gColD.red, .75)

-- game ui fail colors
local function failCol(isPPS, isCol)
    if not isPPS then
        if not game.isFail then
            if not isCol then
                lg.setColor(1, 1, 1, 1)
            else
                lg.setColor(gCol.red)
            end
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

-- pause buttons
local pauseYOff = 70
local pauseBtns = {
    button.new("RESUME", fonts.ui, 0, 70 - pauseYOff, 120, 30,
        function()
            if game.isPaused then
                game.isPaused = false
                game.isPauseDelay = true
            end
        end,
        gCol.bg, { gCol.bg[1] + 0.1, gCol.bg[2] + 0.1, gCol.bg[3] + 0.1 }, gCol.white, gCol.green, true),
    button.new("RESTART", fonts.ui, 0, 110 - pauseYOff, 120, 30,
        function()
            game.isPaused = false
            game.isFail = false
            game.showFailColors = false
            gameInit(ply, stats, game)
            mtrxClr(gMtrx)
            states.bagReset(ply, settings)
            plyInit(ply)
        end,
        gCol.bg, { gCol.bg[1] + 0.1, gCol.bg[2] + 0.1, gCol.bg[3] + 0.1 }, gCol.white, gCol.orange, true),
    button.new("QUIT", fonts.ui, 0, 150 - pauseYOff, 120, 30,
        function()
            le.quit(0)
        end,
        gCol.bg, { gCol.bg[1] + 0.1, gCol.bg[2] + 0.1, gCol.bg[3] + 0.1 }, gCol.white, gCol.red, true)
}

local gameBtns = {
    button.new("P", uiIcons, 20, 20, 35, 35,
        function()
            game.isPaused = true
        end,
        gCol.gray, { gCol.bg[1] + 0.1, gCol.bg[2] + 0.1, gCol.bg[3] + 0.1 }, gCol.yellow, gCol.white)
}

function love.load()
    lg.clear()
    lg.setColor(gCol.bg)
    lg.rectangle("fill", 0, 0, wWd, wHg)
    lg.setColor(1, 1, 1, 1)
    lg.printf("Loading..", fonts.ui, 0, wHg / 2, wWd, "center")
    love.graphics.present()

    if ls.getOS() == "Android" or ls.getOS() == "iOS" then
        lw.setFullscreen(true)
        settings.scale = 0.9
        tInfo.new(textInfo, "no mobile support yet!!", 0, wHg - 50, true, gCol.yellow, 1, 1.5)
    end

    -- initialize next queue
    states.bagInit(ply, settings)
    states.addHistory(ply, settings)

    lg.setBackgroundColor(gCol.bg)
end

function love.mousereleased(x, y, b, isTouch)
    -- freedom!!!!!!!!!!!!!!
    if game.isPaused then
        button.mUpd(x, y, b, pauseBtns)
    else
        if ls.getOS() == "Android" or ls.getOS() == "iOS" then
            if not game.isPauseDelay then
                button.mUpd(x, y, b, gameBtns)
            end
        end
    end
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
        tClear(textInfo)
    end

    if k == "f6" then
        tClear(textInfo)
        if not settings.useVSync then
            settings.useVSync = true
            tInfo.new(textInfo, { gCol.green, "VSync enabled" }, 0, wHg - 50, true, nil, 2, 1)
        else
            settings.useVSync = false
            tInfo.new(textInfo, { gCol.red, "VSync disabled" }, 0, wHg - 50, true, nil, 2, 1)
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

    if not game.isPaused and not game.isPauseDelay and not game.isFail and not game.isCountdown and not ply.isLnDly and not ply.isEnDly then
        if k == keys.left then
            if states.bMove(ply, blocks, gBoard, ply.x - 1, ply.y, ply.bRot, gMtrx) then
                ply.x = ply.x - 1
                ply.dasTimer = 0
                ply.arrTimer = 0

                if ply.y == states.lowestCells(ply, gMtrx, blocks, gBoard, false) then
                    if settings.rotSys == "SRS" then
                        ply.lDTimer = 0
                    end
                end
            end
        end

        if k == keys.right then
            if states.bMove(ply, blocks, gBoard, ply.x + 1, ply.y, ply.bRot, gMtrx) then
                ply.x = ply.x + 1
                ply.dasTimer = 0
                ply.arrTimer = 0

                if ply.y == states.lowestCells(ply, gMtrx, blocks, gBoard, false) then
                    if settings.rotSys == "SRS" then
                        ply.lDTimer = 0
                    end
                end
            end
        end

        if k == keys.hDrop then
            local hY = states.lowestCells(ply, gMtrx, blocks, gBoard, false)
            -- so many edge cases
            if settings.hDropEffect and states.bMove(ply, blocks, gBoard, ply.x, ply.y + 1, ply.bRot, gMtrx) then
                effect.newLockEffect(stats.hDEfct, blocks, ply, gMtrx, gBoard, states, true)
            end

            ply.y = hY
            stats.scr = stats.scr + (2 * hY)

            -- ignore locking piece on sonic lock
            if not game.useSonicDrop then
                states.bAdd(ply.x, ply.y, blocks, ply, gMtrx, gBoard, settings, stats)
            end

            ply.isHDrop = true

            if not game.useSonicDrop then
                if not ply.isLnDly then
                    ply.isEnDly = true
                end
                plyInit(ply)
                stats.stacks = stats.stacks + 1

                ply.gTimer = 0
                ply.lDTimer = 0

                ply.arrTimer = 0
                ply.sdrTimer = 0
            else
                ply.gTimer = 0
            end
        end

        if k == keys.ccw then
            local tR = ply.bRot - 1
            local tRPrev = ply.bRot

            ply.d = 1

            if tR < 1 then
                tR = #blocks[ply.currBlk]
            end

            local bR, dx, dy = states.bRotate(ply, settings, ply.x, ply.y, ply.d, tR, tRPrev, blocks, gBoard, gTable,
                gMtrx)
            if settings.rotSys ~= "SRS" then
                if bR and states.bMove(ply, blocks, gBoard, ply.x, ply.y, tR, gMtrx) then
                    ply.bRot = tR
                end
            else
                if bR then
                    ply.x, ply.y = dx, dy
                    ply.bRot = tR
                end
            end

            if not states.bMove(ply, blocks, gBoard, ply.x, ply.y + 1, tR, gMtrx) then
                ply.isAlrRot = true
            end

            if ply.y == states.lowestCells(ply, gMtrx, blocks, gBoard, false) then
                addMoves(ply)
            end
        end

        if k == keys.cw then
            local tR = ply.bRot + 1
            local tRPrev = ply.bRot

            ply.d = 2

            if tR > #blocks[ply.currBlk] then
                tR = 1
            end

            local bR, dx, dy = states.bRotate(ply, settings, ply.x, ply.y, ply.d, tR, tRPrev, blocks, gBoard, gTable,
                gMtrx)
            if settings.rotSys ~= "SRS" then
                if bR and states.bMove(ply, blocks, gBoard, ply.x, ply.y, tR, gMtrx) then
                    ply.bRot = tR
                end
            else
                if bR then
                    ply.x, ply.y = dx, dy
                    ply.bRot = tR
                end
            end

            if not states.bMove(ply, blocks, gBoard, ply.x, ply.y + 1, tR, gMtrx) then
                ply.isAlrRot = true
            end

            if ply.y == states.lowestCells(ply, gMtrx, blocks, gBoard, false) then
                addMoves(ply)
            end
        end

        if k == keys.flip then
            --TODO: Implement 180 spins
        end

        if k == keys.sDrop then
            if states.bMove(ply, blocks, gBoard, ply.x, ply.y + 1, ply.bRot, gMtrx) then
                ply.sdrTimer = 0
                ply.y = ply.y + 1
            else
                if game.useSonicDrop then
                    if ply.lDTimer < ply.lDelay then
                        ply.lDTimer = ply.lDelay
                    end
                end
            end
        end

        -- hold key function
        if k == keys.hold and game.useHold then
            if not ply.isAlreadyHold and not ply.isLnDly and not ply.isEnDly then
                holdFunc(ply)
            end
        end

        if k == "o" then
            if not settings.altTimerUI then
                settings.altTimerUI = true
            else
                settings.altTimerUI = false
            end
        end

        if k == "f7" then
            if not settings.showKOverlay then
                settings.showKOverlay = true
            else
                settings.showKOverlay = false
            end
        end
    end

    if game.isFail then
        if k == keys.restart then
            game.isFail = false
            game.showFailColors = false
            gameInit(ply, stats, game)
            mtrxClr(gMtrx)
            states.bagReset(ply, settings)
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
    if not game.isFail and not game.isPaused and not game.isPauseDelay and arg[2] == "debug" then
        if k == "r" then
            plyInit(ply)
        end

        if k == "e" then
            states.bagReset(ply, settings)
            plyInit(ply)
            mtrxClr(gMtrx)
        end
        if k == "9" then
            if not settings.freezeTxt then
                settings.freezeTxt = true
            else
                settings.freezeTxt = false
            end
        end
        if k == "8" then
            if not settings.showEmpty then
                settings.showEmpty = true
            else
                settings.showEmpty = false
            end
        end
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

    --TODO: Fix timings?
    if settings.useVSync then
        lw.setVSync(1)
    else
        lw.setVSync(0)
    end

    if game.isPauseDelay then
        if stats.pTime >= 1 then
            stats.pTime = 0
            game.isPauseDelay = false
        else
            stats.pTime = stats.pTime + dt
        end
    end

    if settings.rotSys == "SRS" then
        blocks = gTable.blocks.srs
    else
        blocks = gTable.blocks.ars
    end

    -- scale text info font size based on settings
    if not settings.freezeTxt then
        tInfo.update(textInfo, dt, settings.scale)
    end

    -- game buttons update
    if game.isPaused then
        button.update(pauseBtns, dt)
        lm.setVisible(true)
    else
        if ls.getOS() == "Android" or ls.getOS() == "iOS" then
            if not game.isPauseDelay then
                button.update(gameBtns, dt)
            end
        else
            lm.setVisible(false)
        end
    end

    -- duct tape
    if ply.y > gBoard.visH then
        ply.y = gBoard.visH - states.lowestCells(ply, gMtrx, gMtrx, blocks, true)
    end

    if game.isFail then
        if stats.qrTime > 0 then
            stats.qrTime = stats.qrTime - dt * (8 * settings.qRestartTime)
        else
            stats.qrTime = 0
        end
    end

    if stats.line >= 40 and not game.is40LClr then
        tInfo.new(textInfo,
            "40 lines clear! (" ..
            stats.timeDisp .. ", " .. string.format("%.2f", stats.stacks / stats.time) .. " pps)", 0, wHg - 30, true,
            gCol.yellow, 1, 4)
        game.is40LClr = true
    end

    if not game.isPaused and not game.isPauseDelay and not game.isFail and not game.isCountdown then
        stats.time = stats.time + dt
        stats.timeDisp = string.format("%02d", math.floor(stats.time / 60)) ..
            ":" .. string.format("%02d", stats.time % 60) .. "." .. string.format("%.2f", tMs):sub(3, -1)

        kOver.updKey(overlays)

        if restartUI.update(dt) then
            game.isFail = false
            game.showFailColors = false
            gameInit(ply, stats, game)
            mtrxClr(gMtrx)
            states.bagReset(ply, settings)
            plyInit(ply)
            stats.qrTime = 0
        end

        -- line delay function
        if ply.isLnDly then
            -- the ultimate performance boost /j
            local ipair = ipairs
            if ply.lnDly > 0 then
                if ply.lnDlyTmr < ply.lnDly then
                    ply.lnDlyTmr = ply.lnDlyTmr + dt
                else
                    print("shifted lines by -1 (lnDly: " .. ply.lnDly .. ")")

                    for _, yPos in ipair(stats.clearedLinesYPos) do
                        states.moveCells(yPos, gMtrx, gBoard)
                    end

                    ply.isEnDly = true

                    ply.isLnDly = false
                    ply.lnDlyTmr = 0
                    if #stats.clearedLinesYPos > 0 then
                        tClear(stats.clearedLinesYPos)
                    end
                end
            else
                print("shifted lines by -1 (lnDly: " .. ply.lnDly .. ")")
                for _, yPos in ipair(stats.clearedLinesYPos) do
                    states.moveCells(yPos, gMtrx, gBoard)
                end

                ply.isEnDly = true

                ply.isLnDly = false
                ply.lnDlyTmr = 0
                if #stats.clearedLinesYPos > 0 then
                    tClear(stats.clearedLinesYPos)
                end
            end
        else
            ply.lnDlyTmr = 0
        end

        -- entry delay (are)
        if ply.isEnDly then
            if ply.enDlyTmr < ply.enDly then
                ply.enDlyTmr = ply.enDlyTmr + dt
            else
                -- for hold & rotate function reserving
                ply.isAlreadyHold = false
                ply.isAlrRot = false

                -- only advance next queue bag after line & entry delay
                states.addHistory(ply, settings)
                states.nextQueue(ply, settings)

                if settings.useIRS and ply.isIRS then
                    checkIRS(ply, blocks)
                end

                ply.enDlyTmr = 0
                ply.isEnDly = false
            end
        else
            ply.enDlyTmr = 0
        end

        -- line effect
        effect.lEUpdate(stats.lEffect, dt)
        effect.lkUpd(stats.lkEfct, dt)
        effect.lkUpd(stats.hDEfct, dt)

        -- danger zone detection
        if states.dangerCheck(gMtrx, gBoard) == 1 then
            -- TODO: This is safe right?
            if ply.dangerA < 0.15 then
                ply.dangerA = tonumber(string.format("%.2f", ply.dangerA + dt))
            elseif ply.dangerA > 0.15 then
                ply.dangerA = tonumber(string.format("%.2f", ply.dangerA - dt))
            end
        elseif states.dangerCheck(gMtrx, gBoard) == 2 then
            if ply.dangerA < 0.25 then
                ply.dangerA = ply.dangerA + dt
            end
        else
            if ply.dangerA > 0 then
                ply.dangerA = ply.dangerA - dt * 0.5
            end
        end

        -- game movement function
        if not ply.isLnDly and not ply.isEnDly then
            if not ply.isHDrop then
                if lk.isDown(keys.left) or lk.isDown(keys.right) then
                    if ply.dasTimer > ply.das then
                        if ply.arrTimer > ply.arr then
                            if lk.isDown(keys.left) then
                                if states.bMove(ply, blocks, gBoard, ply.x - 1, ply.y, ply.bRot, gMtrx) then
                                    ply.x = ply.x - 1
                                    if ply.y == states.lowestCells(ply, gMtrx, blocks, gBoard, false) then
                                        if settings.rotSys == "SRS" then
                                            ply.lDTimer = 0
                                        end
                                    end
                                end
                            end
                            if lk.isDown(keys.right) then
                                if states.bMove(ply, blocks, gBoard, ply.x + 1, ply.y, ply.bRot, gMtrx) then
                                    ply.x = ply.x + 1
                                    if ply.y == states.lowestCells(ply, gMtrx, blocks, gBoard, false) then
                                        if settings.rotSys == "SRS" then
                                            ply.lDTimer = 0
                                        end
                                    end
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

            -- soft drop
            if lk.isDown(keys.sDrop) then
                if ply.sdrTimer < ply.sdr then
                    ply.sdrTimer = ply.sdrTimer + dt
                else
                    if states.bMove(ply, blocks, gBoard, ply.x, ply.y + 1, ply.bRot, gMtrx) then
                        ply.y = ply.y + 1
                        stats.scr = stats.scr + 1
                        if ply.sdrTimer > ply.sdr then
                            ply.sdrTimer = 0
                        end
                    else
                        if not game.useSonicDrop then
                            if ply.gTimer < ply.grav then
                                ply.gTimer = ply.grav
                            end
                        else
                            if ply.lDTimer < ply.lDelay then
                                ply.lDTimer = ply.lDelay
                            end
                        end
                    end
                end
            else
                if states.bMove(ply, blocks, gBoard, ply.x, ply.y + 1, ply.bRot, gMtrx) then
                    ply.sdrTimer = 0
                end
            end

            -- gravity function
            if ply.gTimer < ply.grav and
                states.bMove(ply, blocks, gBoard, ply.x, ply.y + (1 + gTable.gravMult[ply.gMult]), ply.bRot, gMtrx) then
                if not ply.isHDrop then
                    ply.gTimer = ply.gTimer + dt
                    ply.lDTimer = 0
                end
                ply.isAlrRot = false
            else
                if not ply.isHDrop then
                    ply.gTimer = 0
                end
                if states.bMove(ply, blocks, gBoard, ply.x, ply.y + (1 + gTable.gravMult[ply.gMult]), ply.bRot, gMtrx) then
                    ply.y = ply.y + (1 + gTable.gravMult[ply.gMult])
                    ply.lDTimer = 0
                else
                    -- hopefully this works as intended
                    ply.y = states.lowestCells(ply, gMtrx, blocks, gBoard, false)
                    -- lock piece if player reached move limit
                    if ply.moveR > ply.mRLimit and not ply.isHDrop then
                        ply.lDTimer = 0
                        stats.stacks = stats.stacks + 1
                        states.bAdd(ply.x, ply.y, blocks, ply, gMtrx, gBoard, settings, stats)
                        if not game.isFail then
                            plyInit(ply)
                            ply.isEnDly = true
                        end
                        ply.moveR = 0
                    else
                        if ply.lDTimer < ply.lDelay then
                            ply.lDTimer = ply.lDTimer + dt
                        else
                            if not ply.isHDrop then
                                stats.stacks = stats.stacks + 1
                                states.bAdd(ply.x, ply.y, blocks, ply, gMtrx, gBoard, settings, stats)
                            end

                            if not game.isFail then
                                plyInit(ply)
                                ply.isEnDly = true
                            end
                        end
                    end
                end
            end

            if lk.isDown(keys.cw) or lk.isDown(keys.ccw) then
                ply.isIRS = true
            else
                ply.isIRS = false
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

        -- line clear ui function update
        for i, lnui in ipairs(stats.lClearUI) do
            if lnui.a > 0 then
                lnui.a = lnui.a - dt * lnui.aSpd
                if lnui.a < 0.65 then
                    lnui.s = lnui.s + dt * ((lnui.aSpd / 2.5))
                    lnui.yOff = lnui.yOff - dt * 30
                end
            else
                table.remove(stats.lClearUI, i)
            end
        end

        -- color flash update
        cFlash.upd(cFStrk, dt)
        cFlash.upd(cFCb, dt)
        cFlash.upd(cFAC, dt)
        cFlash.upd(cFSpn, dt)
    end

    if not game.isPaused and not game.isPauseDelay then
        -- game fail function
        if states.isGFail(ply, blocks, gBoard, gMtrx) and not ply.isLnDly and not ply.isEnDly then
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

        -- game fail function
        if game.isFail then
            plyInit(ply)
        end

        -- for fail text
        cFlash.upd(cFFail, dt)
    end

    if lk.isDown("-") then
        settings.scale = settings.scale - dt
    end

    if lk.isDown("=") then
        settings.scale = settings.scale + dt
    end
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
        if not game.isFail and not game.isPaused then
            lg.setColor(1, 0.15, 0.15, ply.dangerA)
            lg.rectangle("fill", gBoard.x, gBoard.y + gBoard.w, gBoard.w * gBoard.visW, gBoard.h * (gBoard.visH - 1))
        end
    end

    if settings.showGrid then
        gfx.dGrid(gMtrx, gBoard)
    end

    if not game.isPaused then
        -- hard drop effect
        effect.hDDrw(stats.hDEfct, ply, gBoard, settings, game)

        if settings.showOutlines then
            gfx.dOutline(gMtrx, game, gBoard, 2)
        end

        gfx.dBPersp(gMtrx, 0, 0, settings, ply, gBoard, game)

        for y, _ in ipairs(gMtrx) do
            for x, br in ipairs(gMtrx[y]) do
                gfx.dBlocks(br, x, y, ply, gBoard, settings, game)
            end
        end

        if not ply.isLnDly and not ply.isEnDly then
            gfx.dBPersp(blocks[ply.currBlk][ply.bRot], ply.x, ply.y, settings, ply, gBoard, game, true, ply.lDTimer)
            for y, _ in ipairs(blocks[ply.currBlk][ply.bRot]) do
                for x, blk in ipairs(blocks[ply.currBlk][ply.bRot][y]) do
                    if blk ~= 0 then
                        gfx.dBlocks(blk, x + ply.x, y + ply.y, ply, gBoard, settings, game, false, false, false, true)
                    else
                        if settings.showEmpty then
                            gfx.dBlocks(blk, x + ply.x, y + ply.y, ply, gBoard, settings, game, false, false, false, true,
                                false, nil, nil, tex
                                .danger)
                        end
                    end
                end
            end
        end

        effect.lEDraw(stats.lEffect)
        effect.lkDrw(stats.lkEfct, ply, gBoard, settings, game)

        gfx.dDangerBlk(blocks, gMtrx, ply, game, states, tex, gBoard, settings)
    end

    -- game ui
    failCol(false, true)
    lg.printf("LV.", fonts.othr, -60, gBoard.h * (gBoard.visH - 5.55), 40, "right")
    failCol(false, false)
    lg.printf(stats.lv, fonts.ui, -1200, gBoard.h * (gBoard.visH - 5.05), 1200 - 20, "right")

    failCol(false, true)
    lg.printf("LINES", fonts.othr, -60, gBoard.h * (gBoard.visH - 3.25), 40, "right")
    failCol(false, false)
    lg.printf(stats.line, fonts.ui, -1200, gBoard.h * (gBoard.visH - 2.75), 1200 - 20, "right")

    if not settings.altTimerUI then
        failCol(false, true)
        lg.printf("SCORE", fonts.othr, gBoard.w * (gBoard.visW + 0.85), gBoard.h * (gBoard.visH - 2.32), 1200, "left")
        failCol(false, false)
        lg.printf(stats.scr, fonts.ui, gBoard.w * (gBoard.visW + 0.85), gBoard.h * (gBoard.visH - 1.8), 1200, "left")
    else
        failCol(false, true)
        lg.printf("SCORE", fonts.othr, gBoard.w * (gBoard.visW + 0.85), gBoard.h * (gBoard.visH - 3.15), 1200, "left")
        failCol(false, false)
        lg.printf(stats.scr, fonts.ui, gBoard.w * (gBoard.visW + 0.85), gBoard.h * (gBoard.visH - 2.65), 1200, "left")
    end

    failCol(true)
    lg.printf(string.format("%.2f p/s", stats.stacks / stats.time), fonts.othr, -1200, gBoard.h * (gBoard.visH - 1.135),
        1200 - 20,
        "right")

    failCol(false)
    if not settings.altTimerUI then
        lg.printf(stats.timeDisp, fonts.time, gBoard.x,
            gBoard.h * (gBoard.visH + 0.35), gBoard.w * gBoard.visW, "center")
    else
        lg.printf(stats.timeDisp, fonts.othr, gBoard.w * (gBoard.visW + 0.85), gBoard.h * (gBoard.visH - 1.135), 1200,
            "left")
    end

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
    lg.push()
    lg.scale(.9, .9)
    lg.translate(30, 10)
    gfx.dNBox(blocks, ply, game, settings, gBoard, false)
    lg.pop()

    lg.push()
    lg.scale(.9, .9)
    lg.translate(-5, 10)
    if game.useHold then
        gfx.dNBox(blocks, ply, game, settings, gBoard, true)
    end
    lg.pop()

    failCol(false)
    lg.printf("NEXT", fonts.othr, gBoard.w * (gBoard.visW + 1.5), gBoard.y + 26, 40, "left")
    if game.useHold then
        lg.printf("HOLD", fonts.othr, -60 - 8, gBoard.y + 26, 40, "right")
    end

    -- line clear ui effects
    gfx.lClearDrw(fonts, stats, gTable, gBoard, game, settings, gColD, cFAC, cFSpn)

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
        gfx.bGhost(false, ply, blocks, gMtrx, states, gBoard, settings, game)
        gfx.bGhost(true, ply, blocks, gMtrx, states, gBoard, settings, game)
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
        gfx.dPStats(2, 2, wWd, wHg, stats, fonts)
        lg.setColor(1, 1, 1, 1)
        gfx.dPStats(0, 0, wWd, wHg, stats, fonts)
    else
        -- key overlay
        if settings.showKOverlay then
            kOver.drwKey(overlays)
        end
    end

    if ls.getOS() == "Android" or ls.getOS() == "iOS" then
        button.draw(gameBtns)
    end

    -- game quick restart toggle ui
    restartUI.draw()

    -- pause menu
    if game.isPaused then
        lg.setColor(gCol.bg)
        lg.setColor(0, 0, 0, 0.45)
        lg.rectangle("fill", 0, 0, wWd, wHg)
        lg.setColor(1, 1, 1, 1)
        lg.printf("- PAUSED -", fonts.ui, 0, wHg / 2 - pauseYOff, wWd, "center")
        lg.printf({ gCol.orange, "<" .. keys.pause:gsub("^%l", string.upper) .. "> ", gCol.gOutline, "to continue" },
            fonts.othr, 0, wHg / 2 + 30 - pauseYOff, wWd, "center")
        lg.setColor(gCol.bg)
        lg.rectangle("fill", 0, wHg - 50, wWd, 50)
        lg.setColor(1, 1, 1, 1)
        gfx.dPStats(0, 0, wWd, wHg, stats, fonts)
        button.draw(pauseBtns)
    else
    end

    lg.setColor(1, 1, 1, 1)
    tInfo.draw(textInfo)

    -- debug
    if settings.isDebug then
        lg.setColor(1, 1, 1, 1)
        if arg[2] == "debug" then
            lg.print(
                lt.getFPS() ..
                " FPS\n" ..
                wWd ..
                "x" ..
                wHg ..
                "\n" ..
                lg.getStats().drawcalls ..
                " draws / " ..
                string.format("%.3f", lg.getStats().texturememory / 1024 / 1024) ..
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
                states.lowestCells(ply, gMtrx, blocks, gBoard, false) ..
                " / " ..
                states.lowestCells(ply, gMtrx, blocks, gBoard, true) ..
                "\nnext: " ..
                table.concat(ply.next, " ,") ..
                "\nnHist: " .. table.concat(ply.nHist, ", ") .. "\nqrTime: " .. stats.qrTime ..
                "\nclearedLinesYPos: " .. table.concat(stats.clearedLinesYPos, " ,") ..
                "\nuseVSync: " .. tostring(settings.useVSync),
                fonts.othr, 10, 10)
            lg.printf(
                "x: " ..
                ply.x ..
                "\ny: " ..
                ply.y ..
                "\nvisW: " .. gBoard.visW .. "\nvisH: " .. gBoard.visH ..
                "\nbRot: " ..
                ply.bRot .. " / " .. #blocks[ply.currBlk] .. "\nd: " .. ply.d ..
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
                "\ngMult: " .. gTable.gravMult[ply.gMult] ..
                "\nlDTimer: " ..
                ply.lDTimer .. " / " .. ply.lDelay .. "\nlnDlyTmr: " .. ply.lnDlyTmr .. " / " .. ply.lnDly ..
                "\nisLnDly: " .. tostring(ply.isLnDly) .. "\nisEnDly: " .. tostring(ply.isEnDly) ..
                "\nenDlyTmr: " .. ply.enDlyTmr .. " / " .. ply.enDly ..
                "\nisHDrop: " ..
                tostring(ply.isHDrop) ..
                "\nisAlrRot: " ..
                tostring(ply.isAlrRot) ..
                "\nisAlreadyHold: " .. tostring(ply.isAlreadyHold) .. "\nisIRS: " .. tostring(ply.isIRS) ..
                "\nisPaused: " .. tostring(game.isPaused) .. "\nisPauseDelay: " .. tostring(game.isPauseDelay) ..
                "\nrotSys: " ..
                settings.rotSys ..
                "\nbagType: " ..
                settings.bagType ..
                "\nmoveR: " .. ply.moveR .. "\nstacks: " .. stats.stacks .. "\nisFail: " .. tostring(game.isFail) ..
                "\nsg: " ..
                stats.clr.sgl ..
                "\ndb: " ..
                stats.clr.dbl .. "\ntp: " .. stats.clr.trp .. "\nqd: " .. stats.clr.qd .. "\n ac: " .. stats.clr.ac
                .. "\ncomb: " .. stats.comb .. "\nstrk: " .. stats.strk,
                fonts.othr, 0, 10, wWd - 10, "right")
        else
            lg.print(
                lt.getFPS() ..
                " FPS\n" ..
                wWd ..
                "x" ..
                wHg,
                fonts.othr, 10, 10)
        end
    end

    if arg[2] == "debug" then
        lg.setColor(gCol.gray[1], gCol.gray[2], gCol.gray[3], 0.5)
        if not game.isPaused then
            lg.rectangle("line", 5, 5, wWd - 10, wHg - 10)
        end
        -- the label of shame
        lg.printf("- DEBUG MODE -", fonts.smol, 0, wHg - 30, wWd, "center")
    end
end
