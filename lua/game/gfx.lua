local gCol     = require "lua.gCol"
local lerp     = require "lua.lerp"
local gTable   = require "lua.tables"
local settings = require "lua.default.settings"
local initvars = require "lua.game.initvars"
local game     = require "lua.default.game"
local ipairs   = ipairs
local lg       = love.graphics
local gfx      = {}

function gfx.dBlocks(bl, x, y, plyVar, brdVar, settings, game, isGhost, isOutline, noColors, lDlyFade, isHDrop, hdAlp,
                     hdHgt, img)
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
                Z = gCol.red,
                S = gCol.green,
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
                    if plyVar.lDTimer > 0 then
                        lg.setColor(colors()[bl][1], colors()[bl][2], colors()[bl][3],
                            lerp.linear(1, 0.5, plyVar.lDTimer / plyVar.lDelay))
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
    end

    if img == nil then
        if isHDrop then
            lg.rectangle("fill", brdVar.x + brdVar.w * (x - 1), brdVar.y + brdVar.h * (y - 1), brdVar.w,
                brdVar.h * hdHgt)
        end

        if not isOutline then
            lg.rectangle("fill", brdVar.x + brdVar.w * (x - 1), brdVar.y + brdVar.h * (y - 1), brdVar.w, brdVar.h)
        else
            lg.rectangle("line", brdVar.x + brdVar.w * (x - 1), brdVar.y + brdVar.h * (y - 1), brdVar.w, brdVar.h)
        end
    else
        lg.draw(img, brdVar.x + brdVar.w * (x - 1), brdVar.y + brdVar.h * (y - 1), 0, brdVar.w / img:getWidth(),
            brdVar.h / img:getHeight())
    end
end

function gfx.bGhost(isOutline, plyVar, bl, gMtrx, states, gBoard, settings, game)
    local gX, gY = plyVar.x, states.lowestCells(plyVar, gMtrx, bl, gBoard)

    if bl[plyVar.currBlk][plyVar.bRot] ~= nil then
        for y, _ in ipairs(bl[plyVar.currBlk][plyVar.bRot]) do
            for x, blk in ipairs(bl[plyVar.currBlk][plyVar.bRot][y]) do
                if blk ~= 0 then
                    if isOutline then
                        gfx.dBlocks(blk, x + gX, y + gY, plyVar, gBoard, settings, game, true, true)
                    else
                        gfx.dBlocks(blk, x + gX, y + gY, plyVar, gBoard, settings, game, true, false)
                    end
                end
            end
        end
    end
end

function gfx.dGrid(mtrxTab, gBoard)
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

function gfx.dOutline(mtrxTab, game, gBoard, strokeWd)
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
            if br ~= 0 then
                local yOff = 0
                if settings.perspBlocks then
                    yOff = strokeWd + 0.5
                end
                -- there must be a better way than this right
                -- ##### bottom edge rows
                if x == 1 and y == #mtrxTab then
                    lg.setColor(sCol())
                    lg.rectangle("fill", gBoard.x + gBoard.w * (x - 1),
                        (gBoard.y + gBoard.h * (y - 1) - strokeWd) - yOff,
                        (gBoard.w + strokeWd),
                        (gBoard.h + strokeWd) + yOff)
                elseif x == #mtrxTab[y] and y == #mtrxTab then
                    lg.setColor(sCol())
                    lg.rectangle("fill", gBoard.x + gBoard.w * (x - 1) - strokeWd,
                        (gBoard.y + gBoard.h * (y - 1) - strokeWd) - yOff,
                        gBoard.w + strokeWd,
                        (gBoard.h + strokeWd) + yOff)
                    -- ##### left & right columns
                elseif x == 1 then
                    lg.setColor(sCol())
                    lg.rectangle("fill", gBoard.x + gBoard.w * (x - 1),
                        (gBoard.y + gBoard.h * (y - 1) - strokeWd) - yOff,
                        gBoard.w + strokeWd,
                        (gBoard.h + (strokeWd * 2) + yOff))
                elseif x == #mtrxTab[y] then
                    lg.setColor(sCol())
                    lg.rectangle("fill", gBoard.x + gBoard.w * (x - 1) - strokeWd,
                        (gBoard.y + gBoard.h * (y - 1) - strokeWd) - yOff,
                        gBoard.w + strokeWd,
                        (gBoard.h + (strokeWd * 2)) + yOff)
                    -- bottom row (general)
                elseif y == #mtrxTab then
                    lg.setColor(sCol())
                    lg.rectangle("fill", gBoard.x + gBoard.w * (x - 1) - strokeWd,
                        (gBoard.y + gBoard.h * (y - 1) - strokeWd) - yOff,
                        gBoard.w + (strokeWd * 2),
                        (gBoard.h + (strokeWd)) + yOff)
                else
                    lg.setColor(sCol())
                    lg.rectangle("fill", (gBoard.x + gBoard.w * (x - 1) - strokeWd),
                        (gBoard.y + gBoard.h * (y - 1) - strokeWd) - yOff,
                        (gBoard.w + (strokeWd * 2)),
                        (gBoard.h + (strokeWd * 2)) + yOff)
                end
            end
        end
    end
end

-- okay this is crazy
function gfx.dBPersp(mtrxTab, xOff, yOff, settings, ply, gBoard, game, isLDlyFade, a)
    if settings.perspBlocks then
        for y, _ in ipairs(mtrxTab) do
            for x, blk in ipairs(mtrxTab[y]) do
                if blk ~= 0 then
                    lg.push()
                    lg.translate(0, -2.5)
                    local colors = function()
                        local cOff = .1
                        if settings.rotSys == "ARS" then
                            return
                            {
                                I = { gCol.red[1] - cOff, gCol.red[2] - cOff, gCol.red[3] - cOff },
                                Z = { gCol.green[1] - cOff, gCol.green[2] - cOff, gCol.green[3] - cOff },
                                S = { gCol.purple[1] - cOff, gCol.purple[2] - cOff, gCol.purple[3] - cOff },
                                L = { gCol.orange[1] - cOff, gCol.orange[2] - cOff, gCol.orange[3] - cOff },
                                J = { gCol.blue[1] - cOff, gCol.blue[2] - cOff, gCol.blue[3] - cOff },
                                O = { gCol.yellow[1] - cOff, gCol.yellow[2] - cOff, gCol.yellow[3] - cOff },
                                T = { gCol.lBlue[1] - cOff, gCol.lBlue[2] - cOff, gCol.lBlue[3] - cOff },
                                g = { gCol.gray[1] - .05, gCol.gray[2] - .05, gCol.gray[3] - .05 }
                            }
                        else
                            return
                            {
                                I = { gCol.lBlue[1] - cOff, gCol.lBlue[2] - cOff, gCol.lBlue[3] - cOff },
                                Z = { gCol.red[1] - cOff, gCol.red[2] - cOff, gCol.red[3] - cOff },
                                S = { gCol.green[1] - cOff, gCol.green[2] - cOff, gCol.green[3] - cOff },
                                L = { gCol.orange[1] - cOff, gCol.orange[2] - cOff, gCol.orange[3] - cOff },
                                J = { gCol.blue[1] - cOff, gCol.blue[2] - cOff, gCol.blue[3] - cOff },
                                O = { gCol.yellow[1] - cOff, gCol.yellow[2] - cOff, gCol.yellow[3] - cOff },
                                T = { gCol.purple[1] - cOff, gCol.purple[2] - cOff, gCol.purple[3] - cOff },
                                g = { gCol.gray[1] - .05, gCol.gray[2] - .05, gCol.gray[3] - .05 }
                            }
                        end
                    end
                    if isLDlyFade then
                        if not game.isFail then
                            lg.setColor(colors()[blk][1], colors()[blk][2], colors()[blk][3], lerp.linear(1, 0, a))
                        else
                            if game.showFailColors then
                                lg.setColor(colors()[blk][1], colors()[blk][2], colors()[blk][3], lerp.linear(1, 0, a))
                            else
                                lg.setColor(colors().g)
                            end
                        end
                    else
                        if not game.isFail then
                            lg.setColor(colors()[blk][1], colors()[blk][2], colors()[blk][3], 1)
                        else
                            if game.showFailColors then
                                lg.setColor(colors()[blk][1], colors()[blk][2], colors()[blk][3], 1)
                            else
                                lg.setColor(colors().g)
                            end
                        end
                    end
                    gfx.dBlocks(blk, x + xOff, y + yOff, ply, gBoard, settings, game, false, false, true, false, true, 1,
                        0.15)
                    lg.pop()
                end
            end
        end
    end
end

-- next & hold box drawing
--TODO: Simplify function
function gfx.dNBox(blkTab, plyTab, game, settings, gBoard, isHold)
    local hBlk = plyTab.hold

    if not game.isPaused then
        if not isHold then
            for i = 1, plyTab.nDisp, 1 do
                for y, _ in ipairs(blkTab[plyTab.next[2 + (i - 1)]][1]) do
                    for x, blk in ipairs(blkTab[plyTab.next[2 + (i - 1)]][1][y]) do
                        if blk ~= 0 then
                            if settings.rotSys == "ARS" then
                                lg.push()
                                if plyTab.next[2 + (i - 1)] ~= 1 and
                                    plyTab.next[2 + (i - 1)] ~= 6
                                then
                                    lg.translate(10, 0)
                                elseif plyTab.next[2 + (i - 1)] == 1 then
                                    lg.translate(0, 10)
                                end
                                gfx.dBlocks(blk, x + gBoard.visW + 1, y + 2 + (3 * (i - 1)), plyTab, gBoard, settings,
                                    game, false, false, false)
                                lg.pop()
                            else
                                lg.push()
                                if plyTab.next[2 + (i - 1)] ~= 1 and
                                    plyTab.next[2 + (i - 1)] ~= 6
                                then
                                    lg.translate(10, 0)
                                elseif plyTab.next[2 + (i - 1)] == 1 then
                                    lg.translate(0, -10)
                                end
                                gfx.dBlocks(blk, x + gBoard.visW + 1, y + 3 + (3 * (i - 1)), plyTab, gBoard, settings,
                                    game, false, false, false)
                                lg.pop()
                            end
                        end
                    end
                end
            end
        else
            if plyTab.hold ~= 0 then
                for y, _ in ipairs(blkTab[hBlk][1]) do
                    for x, blk in ipairs(blkTab[hBlk][1][y]) do
                        if blk ~= 0 then
                            if plyTab.isAlreadyHold then
                                lg.setColor(gCol.gOutline)
                                if settings.rotSys == "ARS" then
                                    lg.push()
                                    if hBlk ~= 1 and
                                        hBlk ~= 6
                                    then
                                        lg.translate(10, 0)
                                    elseif hBlk == 1 then
                                        lg.translate(0, 10)
                                    end
                                    gfx.dBlocks(blk, x + gBoard.x - 5, y + 2, plyTab, gBoard, settings, game, false,
                                        false, true)
                                    lg.pop()
                                else
                                    lg.push()
                                    if hBlk ~= 1 and
                                        hBlk ~= 6
                                    then
                                        lg.translate(10, 0)
                                    elseif hBlk == 1 then
                                        lg.translate(0, -10)
                                    end
                                    gfx.dBlocks(blk, x + gBoard.x - 5, y + 3, plyTab, gBoard, settings, game, false,
                                        false, true)
                                    lg.pop()
                                end
                            else
                                if settings.rotSys == "ARS" then
                                    lg.push()
                                    if hBlk ~= 1 and
                                        hBlk ~= 6
                                    then
                                        lg.translate(10, 0)
                                    elseif hBlk == 1 then
                                        lg.translate(0, 10)
                                    end
                                    gfx.dBlocks(blk, x + gBoard.x - 5, y + 2, plyTab, gBoard, settings, game, false,
                                        false, false)
                                    lg.pop()
                                else
                                    lg.push()
                                    if hBlk ~= 1 and
                                        hBlk ~= 6
                                    then
                                        lg.translate(10, 0)
                                    elseif hBlk == 1 then
                                        lg.translate(0, -10)
                                    end
                                    gfx.dBlocks(blk, x + gBoard.x - 5, y + 3, plyTab, gBoard, settings, game, false,
                                        false, false)
                                    lg.pop()
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end

-- danger block draw function
function gfx.dDangerBlk(blkTab, mtrxTab, plyVar, game, states, tex, gBoard, settings)
    local nBlk = plyVar.next[2]
    local hBlk = plyVar.hold

    if not game.isFail then
        if states.dangerCheck(mtrxTab, gBoard) == 2 then
            for y, _ in ipairs(blkTab[nBlk][1]) do
                for x, blk in ipairs(blkTab[nBlk][1][y]) do
                    if blk ~= 0 then
                        lg.setColor(1, 1, 1, 1)
                        gfx.dBlocks(blk, x + plyVar.initX, y + plyVar.initY, plyVar, gBoard, settings, game, false, false,
                            true, false, false,
                            nil, nil, tex.danger)
                    end
                end
            end
            if settings.showHoldDgr and hBlk ~= 0 then
                for y, _ in ipairs(blkTab[hBlk][1]) do
                    for x, blk in ipairs(blkTab[hBlk][1][y]) do
                        if blk ~= 0 then
                            gfx.dBlocks(blk, x + plyVar.initX, y + plyVar.initY, plyVar, gBoard, settings, game, false,
                                false, false, false,
                                true,
                                0.5, nil, tex.danger)
                        end
                    end
                end
            end
        end
    end
end

-- line clear ui effect
function gfx.lClearDrw(lClearTab, fonts, gTable, gBoard, game, settings, gColD, cFAC, cFSpn, isAftrImg)
    for i, lnui in ipairs(lClearTab) do
        local clr = function()
            if not game.isFail then
                if settings.rotSys == "ARS" then
                    return gTable.colTab.lClearUI.classic(gColD, cFAC, cFSpn, lnui.a)
                else
                    return gTable.colTab.lClearUI.modern(gColD, cFAC, cFSpn, lnui.a)
                end
            else
                local tCol = 0.35
                return { gCol.gray[1] + tCol, gCol.gray[2] + tCol, gCol.gray[3] + tCol, lnui.a }
            end
        end

        local clrB = function()
            if not game.isFail then
                if not isAftrImg then
                    if settings.rotSys == "ARS" then
                        return gTable.colTab.lClearUI.classicD(gCol, cFAC, cFSpn)
                    else
                        return gTable.colTab.lClearUI.modernD(gCol, cFAC, cFSpn)
                    end
                end
            else
                local tCol = 0.35
                return { gCol.gray[1] + tCol, gCol.gray[2] + tCol, gCol.gray[3] + tCol, lnui.a }
            end
        end

        -- text background
        lg.push()
        if not isAftrImg then
            lg.scale(lnui.s, lnui.s)
            -- lnui.s starts from 1
            lg.translate((lnui.s * 10) - 10, -lnui.yOff)
        end
        local x, y = -52 - (35 * (i - 1)), gBoard.h * (gBoard.visH - 12) - 10

        if type(lnui.str) ~= "number" then
            if not game.isFail then
                if not isAftrImg then
                    lg.setColor(clr()[lnui.cBlk][1] + 0.2, clr()[lnui.cBlk][2] + 0.2, clr()[lnui.cBlk][3] + 0.2, lnui.a)
                else
                    lg.setColor(clr()[lnui.cBlk])
                end
            else
                lg.setColor(clr())
            end
            lg.polygon("fill",
                x,
                y - 10,

                x + 30,
                y - 10,

                x,
                (y + 30) - 10)
        end

        if not game.isFail then
            if not isAftrImg then
                lg.setColor(clr()[lnui.cBlk][1], clr()[lnui.cBlk][2], clr()[lnui.cBlk][3], lnui.a)
            else
                if type(lnui.str) ~= "number" then
                    lg.setColor(clr()[lnui.cBlk][1] + .5, clr()[lnui.cBlk][2] + .5, clr()[lnui.cBlk][3] + .5,
                        lerp.linear(0, 0.85, lnui.a))
                else
                    lg.setColor(clr()[lnui.cBlk][1] + .5, clr()[lnui.cBlk][2] + .5, clr()[lnui.cBlk][3] + .5,
                        lerp.linear(0, 0.5, lnui.a))
                end
            end
        else
            lg.setColor(clr())
        end

        if not isAftrImg then
            lg.rectangle("fill", x, y - 10, 30,
                30)
        else
            lg.rectangle("fill", x + lnui.yOff, (y - 10) + lnui.yOff, 30 - (lnui.yOff * 2),
                30 - (lnui.yOff * 2))
        end

        -- backdrop text
        if not isAftrImg then
            if not game.isFail then
                lg.setColor(clrB()[lnui.cBlk][1], clrB()[lnui.cBlk][2], clrB()[lnui.cBlk][3], lnui.a)
            else
                lg.setColor(clr()[1], clr()[2], clr()[3], lnui.a)
            end

            lg.printf(lnui.str, fonts.ui, x + 2, (y + 2) - 10, 30,
                "center")

            -- front text
            lg.setColor(1, 1, 1, lnui.a)
            lg.printf(lnui.str, fonts.ui, x, y - 10, 30, "center")
        end
        lg.pop()
    end
end

-- line clear ui function update
function gfx.lClearUpd(lClearTab, dt)
    for i, lnui in ipairs(lClearTab) do
        if lnui.a > 0 then
            lnui.a = lnui.a - dt * lnui.aSpd
            if lnui.a < lnui.aT then
                lnui.s = lnui.s + dt * ((lnui.aSpd / 2.5))
                if lnui.yOffSpd ~= nil then
                    lnui.yOff = lnui.yOff - dt * lnui.yOffSpd
                else
                    lnui.yOff = lnui.yOff - dt * 30
                end
            end
        else
            table.remove(lClearTab, i)
        end
    end
end

-- secret grade indicator
function gfx.dScrtG(x, y, stats, fonts, gBoard, txt, backdrop)
    lg.push()
    lg.translate(x, y)
    if txt then
        if not backdrop then
            lg.setColor(1, 1, 1, 1)
        else
            lg.setColor(gCol.gray[1] - .1, gCol.gray[2] - .1, gCol.gray[3] - .1)
        end
        lg.printf("SECRET GRADE", fonts.othr, gBoard.x,
            gBoard.h * (gBoard.visH + 0.35) - 108, gBoard.w * gBoard.visW, "center")
    end
    if not txt then
        lg.push()
        if not backdrop then
            lg.setColor(gCol.gray[1] + .525, gCol.gray[2] + .525, gCol.gray[3] + .525)
        else
            lg.setColor(gCol.gray[1] - .1, gCol.gray[2] - .1, gCol.gray[3] - .1)
        end

        if string.len(tostring(gTable.sGrade[stats.scrtG])) > 1 then
            lg.translate(-fonts.time:getWidth(gTable.sGrade[stats.scrtG]) * 0.2, 0)
        end

        lg.printf(string.sub(gTable.sGrade[stats.scrtG], 1, 1), fonts.time, gBoard.x,
            gBoard.h * (gBoard.visH + 0.35) - 100, gBoard.w * gBoard.visW, "center")
        if string.len(gTable.sGrade[stats.scrtG]) > 1 then
            lg.printf(string.sub(gTable.sGrade[stats.scrtG], 2, 2), fonts.time, gBoard.x + 18,
                (gBoard.h * (gBoard.visH + 0.35) + 8) - 100, gBoard.w * gBoard.visW, "center", 0)
        end
        if string.len(gTable.sGrade[stats.scrtG]) > 2 then
            lg.printf(string.sub(gTable.sGrade[stats.scrtG], 3, 3), fonts.time, gBoard.x + 46,
                gBoard.h * (gBoard.visH + 0.35) - 100, gBoard.w * gBoard.visW, "center", 0, .85, .85)
        end
        lg.pop()
    end
    lg.pop()
end

-- pause stats
function gfx.dPStats(xOff, yOff, wWd, wHg, stats, records, fonts, isRecords)
    local yBestOff = 45
    if not isRecords then
        if game.isFail then
            lg.printf(
                { gCol.green, "sg: ", gCol.white, stats.clr.sgl, gCol.purple, " dbl: ", gCol.white, stats.clr.dbl, gCol
                    .yellow,
                    " trp: ", gCol.white, stats.clr.trp, gCol.lBlue, " qd: ", gCol.white, stats.clr.qd, gCol.white,
                    "   |  ", gCol.orange, " all clear: ", gCol.white, stats.clr.ac, gCol.purple, " t-spin: ", gCol
                    .white,
                    stats
                    .spinT .. ", " .. stats.clr.spinTS .. ", " .. stats.clr.spinTD .. ", " .. stats.clr.spinTT, gCol.red,
                    " comb. ",
                    gCol.orange,
                    "&", gCol.purple, " strk: ", gCol.white, "x" ..
                stats.maxComb .. ", x" .. stats.maxStrk .. "  |  ", gCol.yellow, "p/s.: ", gCol.white,
                    string.format("%.2f", stats.maxPPS) .. " p/s, " .. stats.finesse .. "F" }, fonts.othr, 0 + xOff,
                wHg - 30 + yOff, wWd, "center")
        else
            lg.printf(
                { gCol.green, "sg: ", gCol.white, stats.clr.sgl, gCol.purple, " dbl: ", gCol.white, stats.clr.dbl, gCol
                    .yellow,
                    " trp: ", gCol.white, stats.clr.trp, gCol.lBlue, " qd: ", gCol.white, stats.clr.qd, gCol.white,
                    "   |  ", gCol.orange, " all clear: ", gCol.white, stats.clr.ac, gCol.purple, " t-spin: ", gCol
                    .white,
                    stats
                    .spinT .. ", " .. stats.clr.spinTS .. ", " .. stats.clr.spinTD .. ", " .. stats.clr.spinTT, gCol.red,
                    " comb. ",
                    gCol.orange,
                    "&", gCol.purple, " strk: ", gCol.white, "x" ..
                stats.maxComb .. ", x" .. stats.maxStrk .. " | " .. string.format("%.2f", stats.maxPPS) .. " p/s, " .. stats.finesse .. "F" }, fonts.othr, 0 + xOff,
                wHg - 30 + yOff, wWd, "center")
        end
    else
        lg.printf(
            { gCol.yellow, "best spr.: ", { 1, 1, 1, 1 }, initvars.dTime(records.bestSpr.time) .. ", ",
                string.format("%.2f", records.bestSpr.maxpps) .. " p/s, " .. records.bestSpr.finesse .. "F" },
            fonts.othr, 0 + xOff, (wHg - yBestOff) + yOff, wWd, "center")

        lg.printf({ gCol.purple, " best scr.: ", { 1, 1, 1, 1 },
                records
                .bestScore.scr ..
                ", lv. " .. records.bestScore.lv .. ", "
                .. records.bestScore.line .. " ln., " .. initvars.dTime(records.bestScore.time) .. ", "
                .. string.format("%.2f", records.bestScore.maxpps) .. " p/s, " .. records.bestScore.finesse .. "F" },
            fonts.othr, 0 + xOff,
            (wHg - yBestOff + 15) + yOff,
            wWd,
            "center")
    end
end

return gfx
