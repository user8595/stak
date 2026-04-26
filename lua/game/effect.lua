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
    for _, lp in ipairs(lPartTab) do
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

-- did i just rewrite textInfo.lua
-- might remove that in the future soon, prob
-- so complex

---creates new text effect, which adds to a object handler via table.insert()
---@param textTable table
---@param str string
---@param x number
---@param y number
---@param align love.AlignMode
---@param a number
---@param aOvr number
---@param fadeTime number
---@param fadeSpd number
---@param limit number | nil
---@param colTxt table
---@param isStack boolean | nil
---@param isScale boolean | nil
---@param scaleInit number | nil
---@param scaleSpd number | nil
---@param useBg boolean | nil
---@param bgCol table | nil
---@param bgAOvr number | nil
---@param bgPadding number | nil
function effect.newTextEffect(textTable, str, x, y, align, a, aOvr, fadeTime, fadeSpd, limit, colTxt, isStack, isScale,
                              scaleInit, scaleSpd, useBg, bgCol, bgAOvr, bgPadding)
    table.insert(textTable, {
        str = str,
        x = x,
        y = y,
        align = align,
        t = 0,
        a = a,
        aOvr = aOvr,
        fadeTime = fadeTime,
        fadeSpd = fadeSpd,
        limit = (type(limit) ~= nil) and limit or 0,
        colTxt = colTxt,
        isStack = (type(isStack) ~= "nil") and isStack or false,
        isScale = (type(isScale) ~= "nil") and isScale or false,
        scaleInit = (type(scaleInit) ~= "nil") and scaleInit or 1,
        scaleSpd = (type(scaleSpd) ~= "nil") and scaleSpd or 0,
        useBg = (type(useBg) ~= "nil") and useBg or false,
        bgCol = (type(bgCol) ~= "nil") and bgCol or { 0, 0, 0 },
        bgAOvr = (type(bgAOvr) ~= "nil") and bgAOvr or 0,
        bgPadding = (type(bgPadding) ~= "nil") and bgPadding or 0,
    })
end

---updates text effect obj. in object handler from table
---@param textTable table
---@param dt number | integer
function effect.updTextEffect(textTable, dt)
    for i, txt in ipairs(textTable) do
        if txt.t < txt.fadeTime then
            txt.t = txt.t + dt
        else
            if txt.a + txt.aOvr > 0 then
                txt.a = txt.a - dt * txt.fadeSpd
            else
                table.remove(textTable, i)
            end
        end
    end
end

---draws text from object handler table
---@param textTable table
---@param font love.Font
---@param brightMult number
function effect.drwTextEffect(textTable, font, game, brightMult)
    for i, txt in ipairs(textTable) do
        -- current lines - (current lines - prev. lines)?
        -- multi line aligning
        local _, lines = font:getWrap(txt.str, font:getWidth(txt.str))
        local wd = (txt.limit ~= 0) and txt.limit or font:getWidth(txt.str)

        local x, y =
            (txt.isScale) and -(font:getWidth(txt.str) + txt.limit) / 2 or txt.x,
            (txt.isScale) and -((font:getHeight()) * #lines) / 2 or txt.y

        local yStk = (txt.isStack) and ((font:getHeight()) + txt.bgPadding) * (i - 1) or 0

        lg.push()
        if txt.isScale then
            lg.translate(txt.x + (((font:getWidth(txt.str) + txt.limit) / 2) - (font:getWidth(txt.str) / 2)), txt.y + ((font:getHeight() * #lines) / 2))
            lg.scale(lerp.linear(txt.scaleSpd, txt.scaleInit, txt.a), lerp.linear(txt.scaleSpd, txt.scaleInit, txt.a))
        end

        if txt.useBg then
            -- txt.aOvr, txt.bgAOvr = alpha override
            if not game.isFail then
                lg.setColor(txt.bgCol[1] + brightMult, txt.bgCol[2] + brightMult, txt.bgCol[3] + brightMult,
                    txt.a + txt.bgAOvr)
            else
                lg.setColor(gCol.gOutline[1] + brightMult, gCol.gOutline[2] + brightMult, gCol.gOutline[3] + brightMult)
            end
            lg.rectangle("fill", x - txt.bgPadding, y - txt.bgPadding + yStk,
                wd + txt.bgPadding,
                (font:getHeight() * #lines) + txt.bgPadding)
        end

        local tPad = (txt.bgPadding > 0) and txt.bgPadding / 2 or txt.bgPadding
        if not game.isFail then
            lg.setColor(txt.colTxt[1] + brightMult, txt.colTxt[2] + brightMult, txt.colTxt[3] + brightMult,
                txt.a + txt.aOvr)
        else
            lg.setColor(gCol.gOutline[1] + brightMult, gCol.gOutline[2] + brightMult, gCol.gOutline[3] + brightMult)
        end
        lg.printf(txt.str, font, x - tPad, y - tPad + yStk, wd, txt.align)
        lg.pop()
    end
end

--TODO: Implement board shake on x axis
---board shake effect function
---@param plyVar table
---@param settings table
---@param gBoard table
---@param dt number
function effect.updShake(plyVar, settings, gBoard, dt)
    local hMult = {
        (gBoard.visH / 2) * settings.shakeInt,
        (gBoard.visH / 4) + ((plyVar.isHDrop) and 50 or 25 * settings.shakeInt),
        (gBoard.visH / 4) + ((plyVar.isHDrop) and 75 or 50 * settings.shakeInt),
        (gBoard.visH / 4) + ((plyVar.isHDrop) and 125 or 85 * settings.shakeInt),
        (gBoard.visH / 4) + ((plyVar.isHDrop) and 180 or 125 * settings.shakeInt),
    }

    if plyVar.isShakeY then
        if hMult[plyVar.lineClrTemp + 1] ~= nil then
            plyVar.sH = hMult[plyVar.lineClrTemp + 1]
        else
            plyVar.sH = hMult[1]
        end

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

function effect.updScreenShake(game, dt)
    if game.isScreenShake then
        if game.sTimer < game.sTLen then
            game.sTimer = game.sTimer + dt
        else
            game.sTimer = 0
            game.isScreenShake = false
        end
    end
end

return effect
