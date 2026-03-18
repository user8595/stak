local lg = love.graphics
local lerp = require "lua.lerp"
local gfx = require "lua.game.gfx"
local ipairs = ipairs
local effect = {}

-- line clear effect
function effect.newLineEffect(y, boardVar, lineEffectTab, isBoardFill, isScale)
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

--- line effect update
---@param lineEffectTab table
---@param dt number
function effect.lEUpdate(lineEffectTab, dt)
    for i, ln in ipairs(lineEffectTab) do
        if ln.a > 0 then
            if ln.isFill then
                ln.a = ln.a - dt * 0.65
            else
                ln.a = ln.a - dt * 5
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
        lg.setColor(1, 1, 1, ln.a)
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
            h = states.lowestCells(plyTab, mtrxTab, blkTab, brdTab) -
                plyTab.y,
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

return effect
