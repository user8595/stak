-- high score as of writing: 21850500, lv 110, 1100 lines, 35:33.42 time (no gravity)
-- highest score as of writing: 92637529, lv 222, 2218 lines, 65:08.13 (60hz w/ gravity, srs)
-- fastest 40l as of writing: 00:46.69, 2.88pps

-- i think i like this game

-- highest secret grade as of writing:
-- S8, lv 8, 75 lines, 03:33.64 time (ars)
-- GM, lv 9, 81 lines, 03:17.16 time (srs)

-- ##### a good reminder that this game relies a LOT with 1-based indexing #####
-- and the sky is blue

local mj, mn, rv     = love.getVersion()

local lg, lw, lk, lm = love.graphics, love.window, love.keyboard, love.mouse
local lt, le         = love.timer, love.event
local ls             = love.system

local wWd, wHg       = lg.getWidth(), lg.getHeight()

-- libraries & core functions
local tClear         = require "lua.tClear"
local lerp           = require "lua.lerp"
local gTable         = require "lua.tables"
local kOver          = require "lua.kOver"
local tInfo          = require "lua.textInfo"
local cFlash         = require "lua.colFlash"
local button         = require "lua.button"
local keys           = require "lua.default.keys"
local restartUI      = require "lua.restartUI"
local stats          = require "lua.default.stats"
local gCol           = require "lua.gCol"
local gfx            = require "lua.game.gfx"
local effect         = require "lua.game.effect"
local initvars       = require "lua.game.initvars"
local gStyle         = require "lua.game.gStyle"
local records        = require "lua.default.records"
local save           = require "lua.game.save"

local states         = require "lua.game.states"

local fonts          = {
    ui = lg.newFont("/assets/fonts/monogram-extended.TTF", 32, "mono"),
    smol = lg.newFont("/assets/fonts/monogram-extended.TTF", 24, "mono"),
    beeg = lg.newFont("/assets/fonts/monogram-extended.TTF", 64, "mono"),
    time = lg.newFont("/assets/fonts/monogram-extended.TTF", 48, "mono"),
    othr = lg.newFont("/assets/fonts/Picopixel.ttf", 14, "mono")
}

local uiIcons        = lg.newImageFont("/assets/img/icons.png", "P")

-- textures
local tex            = {
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
local ply = require("lua.default.ply")

if arg[2] == "debug" then
    settings.isDebug = true
else
    settings.isDebug = false
end

local gMtrx = {}
local gBoard = require "lua.default.gBoard"

for y = 1, gBoard.gH do
    table.insert(gMtrx, {})
    for _ = 1, gBoard.gW do
        table.insert(gMtrx[y], 0)
    end
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

local cFStrk = cFlash.new(gCol.yellow, gCol.blue, .05)
local cFCb = cFlash.new(gCol.yellow, gCol.white, .05)
local cFAC = cFlash.new(gColD.yellow, gColD.lBlue, .1)

-- change in love.update()
local cfSpnCol = gColD.lBlue
local cFSpn = cFlash.new(cfSpnCol, gColD.orange, .1)

local cFFail = cFlash.new(gCol.orange, gCol.red, .05)
local cFFBG = cFlash.new(gColD.orange, gColD.red, .75)

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
            initvars.gameInit(ply, stats, game)
            initvars.mtrxClr(gMtrx)
            states.bagReset(ply, settings)
            initvars.plyInit(ply)
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

    if mj <= 11 and mn <= 4 then
        if rv ~= 0 then
            tInfo.new(textInfo, "(current ver.: " .. mj .. "." .. mn .. "." .. rv .. ")", 0, wHg - 50, true, gCol.green,
                1, 1.5)
        else
            tInfo.new(textInfo, "(current ver.: " .. mj .. "." .. mn .. ")", 0, wHg - 50, true, gCol.green, 1, 1.5)
        end
        tInfo.new(textInfo, "game might not work as expected in version than 11.5", 0, wHg - 50, true, gCol.yellow, 1,
            1.5)
    end

    -- initialize next queue
    states.bagInit(ply, settings)
    states.addHistory(ply, settings)

    -- load scores table & value compariasion
    local saveF = save.readScores(records)
    local pair = pairs
    for k, _ in pair(records) do
        for l, v in pair(records[k]) do
            if v ~= saveF[k][l] and type(saveF[k][l]) == "nil" then
                saveF[k][l] = 0
            end
        end
    end

    -- set score values
    records = saveF

    lg.setBackgroundColor(gCol.bg)
end

function love.quit()
    if game.isFail then
        if game.isHScore then
            print("--## saving on game exit ##--")
            save.writeScores(records)
        end
    end
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

        if mj <= 11 and mn <= 4 then
            -- workaround since ui won't update on old versions
            if ls.getOS() ~= "Android" or ls.getOS() ~= "iOS" then
                settings.scale = lg.getHeight() / 600
            end
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

                stats.finK = stats.finK + 1

                if ply.y == states.lowestCells(ply, gMtrx, blocks, gBoard) then
                    states.addMoves(ply, game, true)
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

                stats.finK = stats.finK + 1

                if ply.y == states.lowestCells(ply, gMtrx, blocks, gBoard) then
                    states.addMoves(ply, game, true)
                    if settings.rotSys == "SRS" then
                        ply.lDTimer = 0
                    end
                end
            end
        end

        if k == keys.hDrop then
            stats.finK = 0

            local hY = states.lowestCells(ply, gMtrx, blocks, gBoard)
            -- so many edge cases
            if settings.hDropEffect and states.bMove(ply, blocks, gBoard, ply.x, ply.y + 1, ply.bRot, gMtrx) then
                effect.newLockEffect(stats.hDEfct, blocks, ply, gMtrx, gBoard, states, true)
            end

            stats.scr = stats.scr + (2 * (hY - ply.y))
            ply.y = hY

            -- ignore locking piece on sonic lock
            if not game.useSonicDrop then
                states.bAdd(ply.x, ply.y, blocks, ply, gMtrx, gBoard, settings, stats)
            end

            ply.isHDrop = true

            if not game.useSonicDrop then
                if not ply.isLnDly then
                    ply.isEnDly = true
                end
                initvars.plyInit(ply)

                ply.gTimer = 0
                ply.lDTimer = 0

                ply.arrTimer = 0
                ply.sdrTimer = 0
            else
                ply.gTimer = 0
            end
        end

        if k == keys.ccw then
            stats.finK = stats.finK + 1

            local tR = ply.bRot - 1
            local tRPrev = ply.bRot

            ply.d = 1

            if tR < 1 then
                tR = #blocks[ply.currBlk]
            end

            local bR, dx, dy, t = states.bRotate(ply, settings, ply.x, ply.y, ply.d, tR, tRPrev, blocks, gBoard, gTable,
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

            ply.spinReward = states.isSpin(ply.x, ply.y, ply, settings, gMtrx, t)

            if ply.y == states.lowestCells(ply, gMtrx, blocks, gBoard) then
                if bR then
                    ply.isAlrRot = true
                end
                states.addMoves(ply, game, stats)
            end
        end

        if k == keys.cw then
            stats.finK = stats.finK + 1

            local tR = ply.bRot + 1
            local tRPrev = ply.bRot

            ply.d = 2

            if tR > #blocks[ply.currBlk] then
                tR = 1
            end

            local bR, dx, dy, t = states.bRotate(ply, settings, ply.x, ply.y, ply.d, tR, tRPrev, blocks, gBoard, gTable,
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

            ply.spinReward = states.isSpin(ply.x, ply.y, ply, settings, gMtrx, t)

            if ply.y == states.lowestCells(ply, gMtrx, blocks, gBoard) then
                if bR then
                    ply.isAlrRot = true
                end
                states.addMoves(ply, game, stats)
            end
        end

        if k == keys.flip then
            stats.finK = stats.finK + 1

            local tR = ply.bRot
            local tRPrev = ply.bRot

            --TODO: Add 180 kicks
            ply.d = 2

            if settings.rotSys == "SRS" then
                if tRPrev == 1 then
                    tR = 3
                end
                if tRPrev == 2 then
                    tR = 4
                end
                if tRPrev == 3 then
                    tR = 1
                end
                if tRPrev == 4 then
                    tR = 2
                end
            else
                if ply.currBlk ~= 1 or ply.currBlk ~= 6 then
                    if tRPrev == 1 then
                        tR = 3
                    end
                    if tRPrev == 2 then
                        tR = 4
                    end
                    if tRPrev == 3 then
                        tR = 1
                    end
                    if tRPrev == 4 then
                        tR = 2
                    end
                end
            end

            local bR, dx, dy, t = states.bRotate(ply, settings, ply.x, ply.y, ply.d, tR, tRPrev, blocks, gBoard, gTable,
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

            ply.spinReward = states.isSpin(ply.x, ply.y, ply, settings, gMtrx, t)

            if ply.y == states.lowestCells(ply, gMtrx, blocks, gBoard) then
                if bR then
                    ply.isAlrRot = true
                end
                states.addMoves(ply, game, stats)
            end
        end

        if k == keys.sDrop then
            stats.finK = stats.finK + 1

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
                stats.finK = 0
                states.holdFunc(ply, settings)
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
            if game.isHScore then
                save.writeScores(records)
            end
            game.isFail = false
            game.showFailColors = false
            initvars.gameInit(ply, stats, game)
            initvars.mtrxClr(gMtrx)
            states.bagReset(ply, settings)
            initvars.plyInit(ply)
        end
        if k == "i" then
            if not game.showFailColors then
                game.showFailColors = true
            else
                game.showFailColors = false
            end
        end
        if k == "space" then
            if game.statsIndex < 2 then
                game.statsIndex = game.statsIndex + 1
            else
                game.statsIndex = 0
            end
        end
    end

    -- ### below is for debug only ###
    if not game.isFail and not game.isPaused and not game.isPauseDelay and arg[2] == "debug" then
        if k == "r" then
            initvars.plyInit(ply)
            stats.resetPosDbg = stats.resetPosDbg + 1
        end

        if k == "e" then
            states.bagReset(ply, settings)
            initvars.plyInit(ply)
            initvars.mtrxClr(gMtrx)
            stats.clrDbg = stats.clrDbg + 1
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
        settings.scale = wHg / 600
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
    -- update game scale from window height
    if ls.getOS() ~= "Android" or ls.getOS() ~= "iOS" then
        settings.scale = wHg / 600
    end
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
    -- workaround since ui won't update on old versions
    if mj <= 11 and mn <= 4 then
        wWd, wHg = lg.getWidth(), lg.getHeight()
    end

    --TODO: Fix timings?
    if settings.useVSync then
        lw.setVSync(1)
    else
        lw.setVSync(0)
    end

    if stats.time > 0 then
        stats.timeDisp = initvars.dTime(stats.time)
    else
        stats.timeDisp = "00:00.00"
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
        -- spin popup
        cfSpnCol = gColD.purple
        blocks = gTable.blocks.srs
    else
        cfSpnCol = gColD.lBlue
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
        ply.y = gBoard.visH - ply.y
    end

    if stats.line >= 40 and not game.is40LClr then
        tInfo.new(textInfo,
            "40 lines clear! (" ..
            stats.timeDisp .. ", " .. string.format("%.2f", stats.stacks / stats.time) .. " pps)", 0, wHg - 30, true,
            gCol.yellow, 1, 4)
        if records.bestSpr.time <= 0 then
            records.bestSpr.time = stats.time
            records.bestSpr.maxpps = stats.maxPPS
            records.bestSpr.finesse = stats.finesse
            game.isHScore = true
            tInfo.new(textInfo, "first sprint pb!", 0, wHg - 30, true, gCol.green, 1, 4)
        elseif stats.time < records.bestSpr.time then
            records.bestSpr.time = stats.time
            records.bestSpr.maxpps = stats.maxPPS
            records.bestSpr.finesse = stats.finesse
            game.isHScore = true
            tInfo.new(textInfo, "new sprint pb!", 0, wHg - 30, true, gCol.green, 1, 4)
        end
        game.is40LClr = true
    end

    if game.isFail then
        if stats.qrTime > 0 then
            stats.qrTime = stats.qrTime - dt * (8 * settings.qRestartTime)
        else
            if stats.qrTime > 0 then
                stats.qrTime = 0
            end
        end
    end

    if not game.isPaused and not game.isPauseDelay and not game.isFail and not game.isCountdown then
        stats.time = stats.time + dt
        stats.currPPS = stats.stacks / stats.time

        -- flip update
        states.flipStateUpd(ply)

        kOver.updKey(overlays)

        if stats.finK > 2 then
            stats.finesse = stats.finesse + 1
            stats.finK = 0
        end

        -- best score
        if stats.scr > records.bestScore.scr then
            records.bestScore.scr = stats.scr
            records.bestScore.line = stats.line
            records.bestScore.lv = stats.lv
            records.bestScore.time = stats.time
            records.bestScore.maxpps = stats.maxPPS
            records.bestScore.finesse = stats.finesse
            game.isHScore = true
        end

        if restartUI.update(dt) then
            game.isFail = false
            game.showFailColors = false
            initvars.gameInit(ply, stats, game)
            initvars.mtrxClr(gMtrx)
            states.bagReset(ply, settings)
            initvars.plyInit(ply)
            stats.qrTime = 0
        end

        -- line delay function
        if ply.isLnDly then
            -- the ultimate performance boost /j
            local ipair = ipairs
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
                    initvars.checkIRS(ply, blocks, settings, game, keys)
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

        -- ingame function
        if not ply.isLnDly and not ply.isEnDly then
            -- game movement function
            if not ply.isHDrop then
                if lk.isDown(keys.left) or lk.isDown(keys.right) then
                    if ply.dasTimer > ply.das then
                        if ply.arrTimer > ply.arr then
                            if lk.isDown(keys.left) then
                                if states.bMove(ply, blocks, gBoard, ply.x - 1, ply.y, ply.bRot, gMtrx) then
                                    ply.x = ply.x - 1
                                    if ply.arrTimer > 0 then
                                        ply.arrTimer = ply.arrTimer - ply.arr
                                    end
                                    if ply.y == states.lowestCells(ply, gMtrx, blocks, gBoard) then
                                        states.addMoves(ply, game, true)
                                        if settings.rotSys == "SRS" then
                                            ply.lDTimer = 0
                                        end
                                    end
                                end
                            end
                            if lk.isDown(keys.right) then
                                if states.bMove(ply, blocks, gBoard, ply.x + 1, ply.y, ply.bRot, gMtrx) then
                                    ply.x = ply.x + 1
                                    if ply.arrTimer > 0 then
                                        ply.arrTimer = ply.arrTimer - ply.arr
                                    end
                                    if ply.y == states.lowestCells(ply, gMtrx, blocks, gBoard) then
                                        states.addMoves(ply, game, true)
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
                if ply.sdrTimer > ply.sdr then
                    if states.bMove(ply, blocks, gBoard, ply.x, ply.y + 1, ply.bRot, gMtrx) then
                        ply.y = ply.y + 1
                        stats.scr = stats.scr + 1
                        if ply.sdrTimer > ply.sdr and ply.sdrTimer > 0 then
                            ply.sdrTimer = ply.sdrTimer - ply.sdr
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
                else
                    ply.sdrTimer = ply.sdrTimer + dt
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
                    ply.y = states.lowestCells(ply, gMtrx, blocks, gBoard)
                    -- lock piece if player reached move limit
                    if ply.moveR > ply.mRLimit and not ply.isHDrop or ply.moveRBlk > ply.mRBLimit and not ply.isHDrop then
                        ply.lDTimer = 0
                        states.bAdd(ply.x, ply.y, blocks, ply, gMtrx, gBoard, settings, stats)
                        if not game.isFail then
                            initvars.plyInit(ply)
                            ply.isEnDly = true
                        end
                        ply.moveR = 0
                    else
                        if not ply.isHDrop then
                            if ply.lDTimer < ply.lDelay then
                                ply.lDTimer = ply.lDTimer + dt
                            else
                                states.bAdd(ply.x, ply.y, blocks, ply, gMtrx, gBoard, settings, stats)

                                if not game.isFail then
                                    initvars.plyInit(ply)
                                    ply.isEnDly = true
                                end
                            end
                        end
                    end
                end
            end

            -- secret grade check
            states.sgCheck(gMtrx, gBoard, stats)

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
        if stats.maxPPS < stats.currPPS and stats.time > 0.25 then
            stats.maxPPS = stats.currPPS
        end

        -- workaround for rotation
        if blocks[ply.currBlk] ~= nil then
            if ply.bRot > #blocks[ply.currBlk] then
                ply.bRot = 1
            end
        end

        gfx.lClearUpd(stats.lClearUI, dt)
        gfx.lClearUpd(stats.lClearAftrImg, dt)

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
            if #textInfo > 0 then
                tClear(textInfo)
            end
            if ply.isHDrop then
                ply.isHDrop = false
            end
        end

        -- game fail function
        if game.isFail then
            initvars.plyInit(ply)
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
        (wHg / (2 * settings.scale)) - ((gBoard.h * (gBoard.visH + 1)) / 2)
    )
    lg.setLineWidth(1)

    lg.setColor(gCol.bgB)
    lg.rectangle("fill", gBoard.x, gBoard.y + gBoard.h, gBoard.w * gBoard.visW, gBoard.h * gBoard.gH - gBoard.h)

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

    -- upper border frame
    lg.setColor(0.5, 0.5, 0.5, 1)
    lg.line(gBoard.x, gBoard.y + gBoard.h, gBoard.x + (gBoard.h * gBoard.visW), gBoard.y + gBoard.h)

    if not game.isPaused then
        -- hard drop effect
        effect.hDDrw(stats.hDEfct, ply, gBoard, settings, game)

        if settings.showOutlines then
            gfx.dOutline(gMtrx, game, gBoard, 2)
        end

        gfx.dBPersp(gMtrx, 0, 0, settings, ply, gBoard, game)

        for y, _ in ipairs(gMtrx) do
            for x, br in ipairs(gMtrx[y]) do
                if br ~= 0 then
                    gfx.dBlocks(br, x, y, ply, gBoard, settings, game)
                end
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
    gStyle.failCol(game, stats, gCol, false, true)
    lg.printf("LV.", fonts.othr, -60, gBoard.h * (gBoard.visH - 5.55), 40, "right")
    gStyle.failCol(game, stats, gCol, false, false)
    lg.printf(stats.lv, fonts.ui, -1200, gBoard.h * (gBoard.visH - 5.05), 1200 - 20, "right")

    gStyle.failCol(game, stats, gCol, false, true)
    lg.printf("LINES", fonts.othr, -60, gBoard.h * (gBoard.visH - 3.25), 40, "right")
    gStyle.failCol(game, stats, gCol, false, false)
    lg.printf(stats.line, fonts.ui, -1200, gBoard.h * (gBoard.visH - 2.75), 1200 - 20, "right")

    if not settings.altTimerUI then
        gStyle.failCol(game, stats, gCol, false, true)
        lg.printf("SCORE", fonts.othr, gBoard.w * (gBoard.visW + 0.85), gBoard.h * (gBoard.visH - 2.32), 1200, "left")
        gStyle.failCol(game, stats, gCol, false, false)
        lg.printf(stats.scr, fonts.ui, gBoard.w * (gBoard.visW + 0.85), gBoard.h * (gBoard.visH - 1.8), 1200, "left")
    else
        gStyle.failCol(game, stats, gCol, false, true)
        lg.printf("SCORE", fonts.othr, gBoard.w * (gBoard.visW + 0.85), gBoard.h * (gBoard.visH - 3.15), 1200, "left")
        gStyle.failCol(game, stats, gCol, false, false)
        lg.printf(stats.scr, fonts.ui, gBoard.w * (gBoard.visW + 0.85), gBoard.h * (gBoard.visH - 2.65), 1200, "left")
    end

    gStyle.failCol(game, stats, gCol, true, false)
    lg.printf(string.format("%.2f p/s", stats.currPPS), fonts.othr, -1200, gBoard.h * (gBoard.visH - 1.135),
        1200 - 20,
        "right")

    gStyle.failCol(game, stats, gCol, false, false)
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
    lg.setColor(gStyle.nxtCol(ply, settings, game, ply.currBlk, gCol, gColD, false))
    lg.rectangle("fill", gBoard.w * (gBoard.visW + 1), gBoard.y + 20, 3, 23)

    -- next box
    lg.push()
    lg.scale(.9, .9)
    lg.translate(30, 10)
    gfx.dNBox(blocks, ply, game, settings, gBoard, false)
    lg.pop()

    -- hold frame text
    if game.useHold then
        lg.setColor(gCol.nBox)
        lg.rectangle("fill", -60 - (80 / 2), gBoard.y + 20, 80, 23)
        lg.setColor(gStyle.nxtCol(ply, settings, game, ply.hold, gCol, gColD, true))
        lg.rectangle("fill", -23, gBoard.y + 20, 3, 23)

        lg.push()
        lg.scale(.9, .9)
        lg.translate(-5, 10)
        -- hold box
        gfx.dNBox(blocks, ply, game, settings, gBoard, true)
        lg.pop()
    end

    gStyle.failCol(game, stats, gCol, false, false)
    lg.printf("NEXT", fonts.othr, gBoard.w * (gBoard.visW + 1.5), gBoard.y + 26, 40, "left")
    if game.useHold then
        lg.printf("HOLD", fonts.othr, -60 - 8, gBoard.y + 26, 40, "right")
    end

    -- line clear ui effects
    gfx.lClearDrw(stats.lClearUI, fonts, gTable, gBoard, game, settings, gColD, cFAC, cFSpn)
    gfx.lClearDrw(stats.lClearAftrImg, fonts, gTable, gBoard, game, settings, gColD, cFAC, cFSpn, true)

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
    lg.line(gBoard.x, gBoard.y + gBoard.h, gBoard.x, gBoard.y + (gBoard.h * gBoard.visH))

    lg.line(gBoard.x, gBoard.y + (gBoard.h * gBoard.visH), gBoard.x + (gBoard.w * gBoard.visW),
        gBoard.y + (gBoard.h * gBoard.visH))
    lg.line(gBoard.x + (gBoard.w * gBoard.visW), gBoard.y + gBoard.h, gBoard.x + (gBoard.w * gBoard.visW),
        gBoard.y + (gBoard.h * gBoard.visH))

    -- ghost piece
    if not game.isPaused and not game.isFail and not ply.isLnDly and not ply.isEnDly and settings.showGhost then
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

        if stats.scrtG > 4 then
            if game.showFailColors then
                lg.setColor(gCol.bg[1], gCol.bg[2], gCol.bg[3], 0.65)
                lg.rectangle("fill", gBoard.x + 0.55, gBoard.y + (gBoard.h * (gBoard.visH - 5.5)),
                    gBoard.w * gBoard.visW - 0.85, 60)
            end

            gfx.dScrtG(2, 2, stats, fonts, gBoard, true, true)
            gfx.dScrtG(0, 0, stats, fonts, gBoard, true, false)
            gfx.dScrtG(2, 2, stats, fonts, gBoard, false, true)
            gfx.dScrtG(0, 0, stats, fonts, gBoard, false, false)
        end
    end
    lg.pop()

    -- stats in fail screen
    if game.isFail then
        if game.statsIndex ~= 0 then
            if game.statsIndex == 1 then
                lg.printf({ gCol.gray, "< " .. game.statsIndex .. " >" }, fonts.othr, 0, wHg - 45, wWd, "center")
                lg.setColor(gCol.bg)
                gfx.dPStats(2, 2, wWd, wHg, stats, records, fonts, false)
                lg.setColor(1, 1, 1, 1)
                gfx.dPStats(0, 0, wWd, wHg, stats, records, fonts, false)
            else
                lg.printf({ gCol.gray, "< " .. game.statsIndex .. " >" }, fonts.othr, 0, wHg - 60, wWd, "center")
                lg.setColor(gCol.bg)
                gfx.dPStats(2, 2, wWd, wHg, stats, records, fonts, true)
                lg.setColor(1, 1, 1, 1)
                gfx.dPStats(0, 0, wWd, wHg, stats, records, fonts, true)
            end
        else
            lg.setColor(gCol.bg)
            lg.printf("<Space> show stats", fonts.othr, 2, wHg - 30 + 2, wWd, "center")
            lg.setColor(gCol.gOutline)
            lg.printf("<Space> show stats", fonts.othr, 0, wHg - 30, wWd, "center")
        end
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
        gfx.dPStats(0, 0, wWd, wHg, stats, records, fonts, false)
        button.draw(pauseBtns)
    end

    lg.setColor(1, 1, 1, 1)
    tInfo.draw(textInfo)

    -- debug
    if settings.isDebug then
        lg.setColor(1, 1, 1, 1)
        if arg[2] == "debug" then
            -- lg.print("secret grade", fonts.othr, 10, (wHg - 380) - fonts.othr:getHeight())
            -- for i = 1, #stats.sGFill do
            --     lg.print(tostring(stats.sGFill[i]) .. " row: " .. 20 - (i - 1), fonts.othr, 10,
            --         (wHg - 380) + (fonts.othr:getHeight() * (i - 1)))
            -- end
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
                tostring(game.useHold) .. "\nisHScore: " .. tostring(game.isHScore) ..
                "\nlowestCells: " ..
                states.lowestCells(ply, gMtrx, blocks, gBoard) ..
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
                ply.bRot .. " / " .. #blocks[ply.currBlk] .. "\nd: " .. ply.d .. " / " .. ply.flipD ..
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
                "\nspinReward: " .. ply.spinReward ..
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
                "\nmoveR: " ..
                ply.moveR ..
                " / " .. ply.moveRBlk .. "\nstacks: " .. stats.stacks .. "\nisFail: " .. tostring(game.isFail) ..
                "\nfinesse: " .. stats.finK .. " / " .. stats.finesse ..
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

        local xOff = 165
        local yOff = 0
        if not game.isFail then
            xOff = 165
            yOff = 0
        else
            xOff = 10
            yOff = 10
        end
        if not game.isPaused then
            lg.setColor(1, 1, 1, 1)
            lg.printf(stats.clrDbg .. ", " .. stats.resetPosDbg, fonts.othr, xOff, wHg - 30 + yOff, wWd - 10, "left")
        end
    end
end
