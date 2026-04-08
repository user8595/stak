local lg, lmth = love.graphics, love.math
local lerp = require "lua.lerp"
local gTable = require "lua.tables"
local gfx = require "lua.game.gfx"
local gCol = require "lua.gCol"
local ipairs = ipairs
local effect = {}

-- line clear effect
--TODO: Refactor insert function
function effect.newLineEffect(y, boardVar, lineEffectTab, isBoardFill, isScale, col, a, aSpd)
    if isBoardFill then
        if not isScale then
            table.insert(lineEffectTab, {
                x = boardVar.x,
                y = boardVar.y + boardVar.h,
                w = boardVar.w * boardVar.visW,
                h = boardVar.h * boardVar.visH - boardVar.h,
                a = 0.15,
                isFill = true,
            })
        else
            table.insert(lineEffectTab, {
                x = boardVar.x,
                y = boardVar.y + boardVar.h,
                w = boardVar.w * boardVar.visW,
                h = boardVar.h * boardVar.visH - boardVar.h,
                a = a,
                aSpd = aSpd,
                col = col,
                s = 1,
                isScale = true,
                isFill = true,
            })
        end
    elseif isScale and not isBoardFill then
        table.insert(lineEffectTab, {
            x = boardVar.x,
            y = boardVar.y + (boardVar.h * y),
            w = boardVar.w * boardVar.visW,
            h = boardVar.h,
            a = 1,
            s = 1,
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

function effect.newLPart(lPartTab, boardVar, bl, x, y, a)
    table.insert(lPartTab, {
        bl = bl,
        x = boardVar.x + (boardVar.w * (x - 1)),
        y = boardVar.y + (boardVar.h * (y - 1)),
        w = boardVar.w,
        h = boardVar.h,
        a = a,
        t = 0,
        vx = lmth.random(20, 50),
        isMin = lmth.random(0, 1)
    })
end

function effect.lPUpdate(lPartTab, settings, dt)
    for i, lp in ipairs(lPartTab) do
        if lp.a > 0 then
            if lp.isMin == 0 then
                lp.x = lp.x + dt * lp.vx
            else
                lp.x = lp.x - dt * lp.vx
            end

            if lp.t < 2 then
                lp.t = lp.t + dt * 7
            end

            if not settings.fastAnim then
                lp.a = lp.a - dt * 0.875
                lp.y = lp.y + dt * lerp.easeOutCubic(-10, 50, lp.t)
            else
                lp.a = lp.a - dt * 1.1
                lp.y = lp.y + dt * lerp.easeOutCubic(-5, 120, lp.t)
            end
        else
            table.remove(lPartTab, i)
        end
    end
end

function effect.lPDrw(lPartTab, settings)
    for i, lp in ipairs(lPartTab) do
        local col, blnd = gTable.colTab.blk, .45
        if settings.rotSys ~= "ARS" then
            lg.setColor(
                lerp.linear(col.modern(gCol)[lp.bl][1], gCol.white[1], blnd),
                lerp.linear(col.modern(gCol)[lp.bl][2], gCol.white[2], blnd),
                lerp.linear(col.modern(gCol)[lp.bl][3], gCol.white[3], blnd),
                lp.a)
        else
            lg.setColor(
                lerp.linear(col.classic(gCol)[lp.bl][1], gCol.white[1], blnd),
                lerp.linear(col.classic(gCol)[lp.bl][2], gCol.white[2], blnd),
                lerp.linear(col.classic(gCol)[lp.bl][3], gCol.white[3], blnd),
                lp.a)
        end
        lg.rectangle("fill", lp.x, lp.y, lp.w, lp.h)
    end
end

--- line effect update
---@param lineEffectTab table
---@param settings table
---@param dt number
function effect.lEUpdate(lineEffectTab, settings, dt)
    for i, ln in ipairs(lineEffectTab) do
        if ln.a > 0 then
            if ln.isFill and not ln.isScale then
                ln.a = ln.a - dt * 0.65
            elseif ln.isFill and ln.isScale then
                ln.a = ln.a - dt * ln.aSpd
            else
                if not settings.fastAnim then
                    ln.a = ln.a - dt * 5
                else
                    ln.a = ln.a - dt * 5
                end
            end

            if ln.isScale then
                ln.s = ln.s + dt * lerp.easeOutQuart(50, 0, ln.a)
            end
        else
            table.remove(lineEffectTab, i)
        end
    end
end

--- line effect drawing
---@param lineEffectTab table
function effect.lEDraw(lineEffectTab)
    for _, ln in ipairs(lineEffectTab) do
        if ln.col == nil then
            lg.setColor(1, 1, 1, ln.a)
        else
            lg.setColor(ln.col[1], ln.col[2], ln.col[3], ln.a)
        end
        if not ln.isScale then
            lg.rectangle("fill", ln.x, ln.y, ln.w, ln.h)
        else
            lg.rectangle("fill", ln.x - ln.s, ln.y - ln.s, ln.w + (ln.s * 2), ln.h + (ln.s * 2))
        end
    end
end

-- piece locking effect
function effect.newLockEffect(lockEffectTab, blkTab, plyTab, mtrxTab, brdTab, states, isHDrop)
    if isHDrop then
        table.insert(lockEffectTab, {
            x = plyTab.x,
            y = plyTab.y,
            -- had to pass it as a arg. because of a loop error
            h = (states.lowestCells(plyTab, mtrxTab, blkTab, brdTab) -
                plyTab.y),
            a = 0.175,
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

--- lock effect update
---@param lockEffectTab table
---@param dt number
function effect.lkUpd(lockEffectTab, dt)
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

--- lock effect drawing
---@param lockEffectTab table
---@param plyVar table
---@param brdVar table
---@param settings table
---@param game table
function effect.lkDrw(lockEffectTab, plyVar, brdVar, settings, game)
    for _, lk in ipairs(lockEffectTab) do
        for y, _ in ipairs(lk.blk) do
            for x, blk in ipairs(lk.blk[y]) do
                if blk ~= 0 then
                    lg.setColor(1, 1, 1, lk.a)
                    if not lk.HDrop then
                        ---@diagnostic disable: missing-parameter
                        gfx.dBlocks(blk, x + lk.x, y + lk.y, plyVar, brdVar, settings, game, false, false, true)
                    end
                end
            end
        end
    end
end

--- hard drop drawing
---@param lockEffectTab table
---@param plyVar table
---@param brdVar table
---@param settings table
---@param game table
function effect.hDDrw(lockEffectTab, plyVar, brdVar, settings, game)
    for _, lk in ipairs(lockEffectTab) do
        for y, _ in ipairs(lk.blk) do
            for x, blk in ipairs(lk.blk[y]) do
                if lk.HDrop then
                    if blk ~= 0 then
                        if not settings.coloredHDropEffect then
                            lg.setColor(1, 1, 1, lk.a)
                            gfx.dBlocks(blk, x + lk.x, lk.y + y, plyVar, brdVar, settings, game, false, false, true,
                                false,
                                true, nil, lk.h)
                        else
                            gfx.dBlocks(blk, x + lk.x, lk.y + y, plyVar, brdVar, settings, game, false, false, false,
                                false,
                                true, lk.a, lk.h)
                        end
                    end
                end
            end
        end
    end
end

--TODO: Implement board shake on x axis
---board shake effect function
---@param plyVar table
---@param dt number
function effect.updShake(plyVar, settings, gBoard, dt)
    local hMult = {
        gBoard.h * settings.shakeInt,
        gBoard.h + ((plyVar.isHDrop) and 50 or 25 * settings.shakeInt),
        gBoard.h + ((plyVar.isHDrop) and 75 or 50 * settings.shakeInt),
        gBoard.h + ((plyVar.isHDrop) and 125 or 85 * settings.shakeInt),
        gBoard.h + ((plyVar.isHDrop) and 180 or 125 * settings.shakeInt),
    }

    if plyVar.isShakeY then
        plyVar.sH = hMult[plyVar.lineClrTemp + 1]
        if not plyVar.sYInv then
            if plyVar.shakeYTime < 1 then
                plyVar.shakeYTime = plyVar.shakeYTime + dt * lmth.random(10, 11)
            else
                plyVar.sYInv = true
            end
        else
            if plyVar.shakeYTime > 0 then
                plyVar.shakeYTime = plyVar.shakeYTime - dt * lmth.random(4, 8)
            else
                plyVar.shakeYTime = 0
                plyVar.sYInv = false
                plyVar.isShakeY = false
            end
        end
    end
end

return effect
