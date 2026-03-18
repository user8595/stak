local states = require "lua.game.states"
local effect = require "lua.game.effect"
local game = require "lua.default.game"
local initvars = require "lua.game.initvars"
local gTable = require "lua.tables"
local ctrl = {}

-- for "d" parameter: -1: ccw, 1: cw
---@param d number
---@param ply table
---@param stats table
---@param settings table
---@param blocks table
---@param gBoard table
---@param gMtrx table
function ctrl.move(d, ply, stats, settings, blocks, gBoard, gMtrx)
    if states.bMove(ply, blocks, gBoard, ply.x + d, ply.y, ply.bRot, gMtrx) then
        ply.x = ply.x + d
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

---@param ply table
---@param stats table
---@param blocks table
---@param gMtrx table
---@param gBoard table
---@param settings table
function ctrl.hDrop(ply, stats, blocks, gMtrx, gBoard, settings)
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

---@param ply table
---@param stats table
---@param blocks table
---@param gBoard table
---@param gMtrx table
function ctrl.sDrop(ply, stats, blocks, gBoard, gMtrx)
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

---@param d number
---@param ply table
---@param stats table
---@param blocks table
---@param settings table
---@param gBoard table
---@param gMtrx table
---@param isFlip boolean
function ctrl.rot(d, ply, stats, blocks, settings, gBoard, gMtrx, isFlip)
    stats.finK = stats.finK + 1

    -- next rot.
    local tR = ply.bRot + d
    -- prev rot.
    local tRPrev = ply.bRot

    if not isFlip then
        -- flip state
        if d == -1 then
            ply.d = 1
        else
            ply.d = 2
        end

        if d == -1 then
            if tR < 1 then
                tR = #blocks[ply.currBlk]
            end
        else
            if tR > #blocks[ply.currBlk] then
                tR = 1
            end
        end
    else
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
        states.addMoves(ply, game, false)
    end
end

---@param ply table
---@param stats table
---@param settings table
function ctrl.hold(ply, stats, settings)
    if not ply.isAlreadyHold and not ply.isLnDly and not ply.isEnDly then
        stats.finK = 0
        states.holdFunc(ply, settings)
    end
end

return ctrl
