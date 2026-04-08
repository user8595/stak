local states = require "lua.game.states"
local effect = require "lua.game.effect"
local game = require "lua.default.game"
local initvars = require "lua.game.initvars"
local gTable = require "lua.tables"
local lk = love.keyboard
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

-- game movement function
function ctrl.shiftBlk(ply, blocks, gBoard, gMtrx, settings, keys, dt)
    if not ply.isHDrop then
        if lk.isDown(keys.left) or lk.isDown(keys.right) then
            if ply.dasTimer > ply.das then
                if ply.arrTimer > ply.arr then
                    if lk.isDown(keys.left) then
                        if ply.arr > 0 then
                            if states.bMove(ply, blocks, gBoard, ply.x - 1, ply.y, ply.bRot, gMtrx) then
                                if not game.isCountdown then
                                    ply.x = ply.x - 1

                                    if ply.y == states.lowestCells(ply, gMtrx, blocks, gBoard) then
                                        states.addMoves(ply, game, true)
                                        if settings.rotSys == "SRS" then
                                            ply.lDTimer = 0
                                        end
                                    end
                                end
                                if ply.arrTimer > 0 then
                                    ply.arrTimer = ply.arrTimer - ply.arr
                                end
                            end
                        else
                            ply.x = states.quickMove(-1, ply, gMtrx, blocks, gBoard)
                        end
                    end
                    if lk.isDown(keys.right) then
                        if ply.arr > 0 then
                            if states.bMove(ply, blocks, gBoard, ply.x + 1, ply.y, ply.bRot, gMtrx) then
                                if not game.isCountdown then
                                    ply.x = ply.x + 1
                                    if ply.y == states.lowestCells(ply, gMtrx, blocks, gBoard) then
                                        states.addMoves(ply, game, true)
                                        if settings.rotSys == "SRS" then
                                            ply.lDTimer = 0
                                        end
                                    end
                                end
                                if ply.arrTimer > 0 then
                                    ply.arrTimer = ply.arrTimer - ply.arr
                                end
                            end
                        else
                            ply.x = states.quickMove(1, ply, gMtrx, blocks, gBoard)
                        end
                    end
                else
                    -- dear god
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
end

---soft drop functionality (use on love.keypressed)
---@param ply table
---@param stats table
---@param blocks table
---@param gBoard table
---@param gMtrx table
function ctrl.sDrop(ply, stats, blocks, gBoard, gMtrx)
    stats.finK = stats.finK + 1

    if states.bMove(ply, blocks, gBoard, ply.x, ply.y + 1, ply.bRot, gMtrx) then
        ply.sdrTimer = 0
        if ply.sdr > 0 then
            ply.y = ply.y + 1
        else
            local lowestY = states.lowestCells(ply, gMtrx, blocks, gBoard)
            ply.y = lowestY
        end
    else
        if game.useSonicDrop then
            if ply.lDTimer < ply.lDelay then
                ply.lDTimer = ply.lDelay
            end
        end
    end
end

---soft drop repeat functionality
---@param ply table
---@param stats table
---@param gBoard table
---@param gMtrx table
---@param keys table
---@param blocks table
---@param dt integer
function ctrl.sDropRepeat(ply, stats, game, gBoard, gMtrx, keys, blocks, dt)
    if lk.isDown(keys.sDrop) then
        if ply.sdrTimer > ply.sdr and ply.sdr > 0 then
            if states.bMove(ply, blocks, gBoard, ply.x, ply.y + 1, ply.bRot, gMtrx) then
                if not game.isCountdown then
                    ply.y = ply.y + 1
                    stats.scr = stats.scr + 1
                end
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
            if ply.sdr <= 0 and not game.isCountdown then
                local lowestY = states.lowestCells(ply, gMtrx, blocks, gBoard)
                ply.y = lowestY
            end
            ply.sdrTimer = ply.sdrTimer + dt
        end
    else
        if states.bMove(ply, blocks, gBoard, ply.x, ply.y + 1, ply.bRot, gMtrx) then
            ply.sdrTimer = 0
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
    --TODO: Finish board shake effect
    ply.shakeYTime = 1

    ply.isHDrop = true

    if not game.useSonicDrop then
        ply.arrTimer = 0
        ply.sdrTimer = 0

        ply.gTimer = 0
        ply.lDTimer = 0

        if not ply.isLnDly then
            ply.isEnDly = true
        end
        initvars.plyInit(ply)
    else
        ply.gTimer = 0
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

    local bR, dx, dy, t
    if not isFlip then
        bR, dx, dy, t = states.bRotate(ply, settings, ply.x, ply.y, ply.d, tR, tRPrev, blocks, gBoard, gTable,
            gMtrx, false)
    else
        bR, dx, dy, t = states.bRotate(ply, settings, ply.x, ply.y, ply.d, tR, tRPrev, blocks, gBoard, gTable,
            gMtrx, true)
    end

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

    if ply.y == states.lowestCells(ply, gMtrx, blocks, gBoard) then
        if bR then
            ply.isAlrRot = true
            ply.spinReward = states.isSpin(ply.x, ply.y, ply, blocks, gBoard, gMtrx, t)
        else
            ply.spinReward = 0
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
