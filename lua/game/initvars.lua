local initvars = {}
local lk = love.keyboard
local gTable = require "lua.tables"
local tClear = require "lua.tClear"

function initvars.checkIRS(plyVar, blkTab, settings, game, keys)
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

function initvars.plyInit(plyVar)
    plyVar.x, plyVar.y = plyVar.initX, plyVar.initY
    plyVar.bRot = 1
    plyVar.moveR = 0
    plyVar.moveRBlk = 0

    plyVar.lDTimer, plyVar.gTimer, plyVar.sdrTimer = 0, 0, 0
end

function initvars.gameInit(plyVar, sts, gameVar)
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
    plyVar.spinReward = 0
    plyVar.dangerA = 0
    sts.time = 0
    sts.stacks = 0
    sts.clr.sgl, sts.clr.dbl, sts.clr.trp, sts.clr.qd, sts.clr.ac = 0, 0, 0, 0, 0
    sts.spinT, sts.clr.spinTS, sts.clr.spinTD, sts.clr.spinTT = 0, 0, 0, 0
    sts.lv = 1
    sts.line = 0
    sts.scr = 0
    sts.maxComb, sts.maxPPS, sts.maxStrk = 0, 0, 0
    sts.finesse, sts.finK = 0, 0
    sts.strk, sts.comb = 0, 0
    sts.nxtLines = 10
    sts.scrtG = 1
    sts.qrTime = 0

    gameVar.is40LClr = false
    gameVar.isHScore = false
    gameVar.statsIndex = 0
    tClear(sts.lClearUI)
    tClear(sts.lClearAftrImg)
    tClear(sts.lClearUITxt)
end

function initvars.mtrxClr(mtrxTab)
    for y, _ in ipairs(mtrxTab) do
        for x, _ in ipairs(mtrxTab[y]) do
            mtrxTab[y][x] = 0
        end
    end
end

-- time rendering
function initvars.dTime(time)
    local _, tMs = math.modf(time)
    return string.format("%02d", math.floor(time / 60)) .. ":" ..
        string.format("%02d", time % 60) ..
        "." .. string.sub(string.format("%.2f", tMs), 3, -1)
end

return initvars
