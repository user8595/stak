local gCol = require "lua.gCol"
local lerp = require "lua.lerp"
local lg = love.graphics
local gfx = {}

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
    else
        lg.setColor(1, 1, 1, 0)
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
        lg.setColor(1, 1, 1, 1)
        lg.draw(img, brdVar.x + brdVar.w * (x - 1), brdVar.y + brdVar.h * (y - 1), 0, brdVar.w / img:getWidth(),
            brdVar.h / img:getHeight())
    end
end

function gfx.bGhost(isOutline, plyVar, bl, gMtrx, states, gBoard, settings, game)
    local gX, gY = plyVar.x, states.lowestCells(plyVar, gMtrx, bl, gBoard, false)

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
        for x, blk in ipairs(mtrxTab[y]) do
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
            if y ~= 1 then
                if br ~= 0 then
                    -- there must be a better way than this right
                    -- ##### bottom rows
                    if x == 1 and y == #mtrxTab then
                        lg.setColor(sCol())
                        lg.rectangle("fill", gBoard.x + gBoard.w * (x - 1), gBoard.y + gBoard.h * (y - 1) - strokeWd,
                            gBoard.w + strokeWd,
                            gBoard.h + strokeWd)
                    elseif x == #mtrxTab[y] and y == #mtrxTab then
                        lg.setColor(sCol())
                        lg.rectangle("fill", gBoard.x + gBoard.w * (x - 1) - strokeWd,
                            gBoard.y + gBoard.h * (y - 1) - strokeWd,
                            gBoard.w + strokeWd,
                            gBoard.h + strokeWd)
                        -- ##### left & right columns
                    elseif x == 1 then
                        lg.setColor(sCol())
                        lg.rectangle("fill", gBoard.x + gBoard.w * (x - 1),
                            gBoard.y + gBoard.h * (y - 1) - strokeWd,
                            gBoard.w + strokeWd,
                            gBoard.h + (strokeWd * 2))
                    elseif x == #mtrxTab[y] then
                        lg.setColor(sCol())
                        lg.rectangle("fill", gBoard.x + gBoard.w * (x - 1) - strokeWd,
                            gBoard.y + gBoard.h * (y - 1) - strokeWd,
                            gBoard.w + strokeWd,
                            gBoard.h + (strokeWd * 2))
                        -- bottom row (general)
                    elseif y == #mtrxTab then
                        lg.setColor(sCol())
                        lg.rectangle("fill", gBoard.x + gBoard.w * (x - 1) - strokeWd,
                            gBoard.y + gBoard.h * (y - 1) - strokeWd,
                            gBoard.w + (strokeWd * 2),
                            gBoard.h + (strokeWd))
                    else
                        lg.setColor(sCol())
                        lg.rectangle("fill", gBoard.x + gBoard.w * (x - 1) - strokeWd,
                            gBoard.y + gBoard.h * (y - 1) - strokeWd,
                            gBoard.w + (strokeWd * 2),
                            gBoard.h + (strokeWd * 2))
                    end
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
                        local cOff = .175
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
                                g = { gCol.gray[1] - .1, gCol.gray[2] - .1, gCol.gray[3] - .1 }
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
                                g = { gCol.gray[1] - .1, gCol.gray[2] - .1, gCol.gray[3] - .1 }
                            }
                        end
                    end
                    if isLDlyFade then
                        if not game.isFail then
                            lg.setColor(colors()[blk][1], colors()[blk][2], colors()[blk][3], lerp.linear(1, 0, a))
                        else
                            lg.setColor(colors().g)
                        end
                    else
                        if not game.isFail then
                            lg.setColor(colors()[blk][1], colors()[blk][2], colors()[blk][3], 1)
                        else
                            lg.setColor(colors().g)
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
    if not game.isFail then
        if states.dangerCheck(mtrxTab, gBoard) == 2 then
            for y, _ in ipairs(blkTab[nBlk][1]) do
                for x, blk in ipairs(blkTab[nBlk][1][y]) do
                    if blk ~= 0 then
                        gfx.dBlocks(blk, x + 3, y + 0, plyVar, gBoard, settings, game, false, false, true, false, false,
                            nil, nil, tex.danger)
                    end
                end
            end
        end
    end
end

-- line clear ui effect
function gfx.lClearDrw(fonts, stats, gTable, gBoard, game, settings, gColD, cFAC, cFSpn)
    for i, lnui in ipairs(stats.lClearUI) do
        local clr = function()
            if not game.isFail then
                if settings.rotSys == "ARS" then
                    return gTable.colTab.lClearUI.classic(gColD, cFAC, cFSpn)
                else
                    return gTable.colTab.lClearUI.modern(gColD, cFAC, cFSpn)
                end
            else
                local tCol = 0.35
                return { gCol.gray[1] + tCol, gCol.gray[2] + tCol, gCol.gray[3] + tCol }
            end
        end

        local clrB = function()
            if not game.isFail then
                if settings.rotSys == "ARS" then
                    return gTable.colTab.lClearUI.classicD(gCol, cFAC, cFSpn)
                else
                    return gTable.colTab.lClearUI.modernD(gCol, cFAC, cFSpn)
                end
            else
                local tCol = 0.35
                return { gCol.gray[1] + tCol, gCol.gray[2] + tCol, gCol.gray[3] + tCol }
            end
        end

        -- text background
        lg.push()
        lg.scale(lnui.s, lnui.s)
        lg.translate(-lnui.yOff / 6.5, lnui.yOff)
        if type(lnui.str) ~= "number" then
            if not game.isFail then
                lg.setColor(clr()[lnui.cBlk][1] + 0.2, clr()[lnui.cBlk][2] + 0.2, clr()[lnui.cBlk][3] + 0.2, lnui.a)
            else
                lg.setColor(clr()[1], clr()[2], clr()[3], lnui.a)
            end
            lg.polygon("fill",
                (-52 - (35 * (i - 1))),
                (gBoard.h * (gBoard.visH - 12)) - 10,

                (-52 - (35 * (i - 1))) + 30,
                (gBoard.h * (gBoard.visH - 12)) - 10,

                (-52 - (35 * (i - 1))),
                ((gBoard.h * (gBoard.visH - 12)) - 10) + 30)
        end

        if not game.isFail then
            lg.setColor(clr()[lnui.cBlk][1], clr()[lnui.cBlk][2], clr()[lnui.cBlk][3], lnui.a)
        else
            lg.setColor(clr()[1], clr()[2], clr()[3], lnui.a)
        end


        lg.rectangle("fill", (-52 - (35 * (i - 1))), (gBoard.h * (gBoard.visH - 12)) - 10, 30,
            30)

        -- backdrop text
        if not game.isFail then
            lg.setColor(clrB()[lnui.cBlk][1], clrB()[lnui.cBlk][2], clrB()[lnui.cBlk][3], lnui.a)
            lg.printf(lnui.str, fonts.ui, -52 - (35 * (i - 1)) + 2, gBoard.h * (gBoard.visH - 12) + 2 - 10, 30,
                "center")
        end

        -- front text
        lg.setColor(1, 1, 1, lnui.a)
        lg.printf(lnui.str, fonts.ui, -52 - (35 * (i - 1)), gBoard.h * (gBoard.visH - 12) - 10, 30, "center")
        lg.pop()
    end
end

-- pause stats
function gfx.dPStats(xOff, yOff, wWd, wHg, stats, fonts)
    lg.printf(
        { gCol.green, "sg: ", gCol.white, stats.clr.sgl, gCol.purple, " dbl: ", gCol.white, stats.clr.dbl, gCol
            .yellow,
            " trp: ", gCol.white, stats.clr.trp, gCol.lBlue, " qd: ", gCol.white, stats.clr.qd, gCol.white, "   |  ",
            gCol
                .orange, " all clears: ", gCol.white, stats.clr.ac, gCol.purple, " t-spins: ", gCol.white, stats.clr
            .spinT, gCol.red, " max comb. ", gCol.orange, "&", gCol
            .purple, " strk: ", gCol.white, "x" ..
        stats.maxComb .. ", x" .. stats.maxStrk .. "  |  ", gCol.yellow, "max spd.: ", gCol.white,
            string.format("%.2f", stats.maxPPS) .. " p/s" }, fonts.othr, 0 + xOff, wHg - 30 + yOff, wWd, "center")
end

return gfx
