local lmth     = love.math

local tClear   = require "lua.tClear"
local effect   = require "lua.game.effect"
local game     = require "lua.default.game"
local stg      = require "lua.default.settings"
local gTable   = require "lua.tables"
local initvars = require "lua.game.initvars"
local gCol     = require "lua.gCol"
local lerp     = require "lua.lerp"

local floor    = math.floor

local states   = {}
local bagDef   = { 1, 5, 4, 6, 3, 7, 2 }

-- https://stackoverflow.com/questions/35572435/how-do-you-do-the-fisher-yates-shuffle-in-lua/68486276#68486276
---@param t table
---@return table
local function shuffle(t)
    local s = {}
    for i = 1, #t do s[i] = t[i] end
    for i = #t, 2, -1 do
        local j = lmth.random(i)
        s[i], s[j] = s[j], s[i]
    end
    return s
end

--- concatenates two tables without modifying the original tables
---@param t1 table
---@param t2 table
---@return any
local function concatTab(t1, t2)
    for i = 1, #t2 do
        t1[#t1 + 1] = t2[i]
    end
    return t1
end

--- checks if a value is in a table
--- only works for numbered index tables
---@param tab table
---@param value any
---@return boolean
local function tabContains(tab, value)
    for _, tab in ipairs(tab) do
        if tab == value then
            return true
        end
    end
    return false
end

-- line clear ui effect
local function newLClrUI(lClrTab, str, cBlk, aSpd, aT, yOffSpd)
    -- "cBlk" can be color block, or current block, or a string for color
    if yOffSpd ~= nil then
        table.insert(lClrTab, { str = str, cBlk = cBlk, a = 1, aSpd = aSpd, s = 1, aT = aT, yOff = 0, yOffSpd = yOffSpd })
    else
        table.insert(lClrTab, { str = str, cBlk = cBlk, a = 1, aSpd = aSpd, s = 1, aT = aT, yOff = 0 })
    end
end

-- checks for filled rows
---@param mtrxTab table
---@param xInit number
---@param xEnd number
---@param y number
---@param steps number
---@return boolean
local function solidRows(mtrxTab, xInit, xEnd, y, steps)
    for x = xInit, xEnd do
        if mtrxTab[y][x] == 0 and x % steps == 0 then
            return false
        end
    end
    return true
end

-- returns the lowest y-axis position for the current piece
---@param plyVar table
---@param mtrxTab table
---@param blkTab table
---@param gBoard table
---@return number
function states.lowestCells(plyVar, mtrxTab, blkTab, gBoard)
    local tX, tY = plyVar.x, floor(plyVar.y)
    while states.bMove(plyVar, blkTab, gBoard, tX, tY + 1, plyVar.bRot, mtrxTab) and tY < gBoard.visH do
        tY = tY + 1
    end
    return tY
end

--- returns framestep-like value with dt
---@param fps number
---@param grav number
---@return number
function states.frameStep(fps, grav)
    return fps * (fps * grav) / fps
end

--- returns the furthest horizontal position of the current block, where 'd' is -1 | 1
---@param d -1 | 1
---@param plyVar table
---@param mtrxTab table
---@param blkTab table
---@param gBoard table
---@return number
function states.quickMove(d, plyVar, mtrxTab, blkTab, gBoard)
    local tX, tY = plyVar.x, floor(plyVar.y)
    while states.bMove(plyVar, blkTab, gBoard, tX + d, tY, plyVar.bRot, mtrxTab) do
        tX = tX + d
    end
    return tX
end

--- adjusts current level
---@param num number
---@param ply any
---@param stats any
---@param gBoard any
function states.adjLvl(num, ply, stats, gBoard)
    stats.lv = stats.lv + num

    if game.isGravityInc then
        if stats.lv < #gTable.grav then
            ply.grav = gTable.grav[stats.lv]
        else
            ply.grav = gBoard.visH
        end
    end

    stats.nxtLines = stats.nxtLines + (num * 10)
end

-- line clear function
---@param y number
---@param mtrxTab table
---@param boardVar table
---@param sts table
---@param settings table
function states.clearCells(y, mtrxTab, boardVar, sts, settings)
    sts.line = sts.line + 1
    sts.lineClr = sts.lineClr + 1

    -- trigger line animation function
    if settings.lineEffect then
        -- for offset
        effect.newLineEffect(y - 1, boardVar, sts.lEffect, false, true)
    end

    -- clear lines with empty tiles
    for clrX = 1, boardVar.visW do
        mtrxTab[y][clrX] = 0
    end
end

---@param y number
---@param mtrxTab table
---@param boardVar table
function states.moveCells(y, mtrxTab, boardVar)
    for clrY = y, 2, -1 do
        for clrX = 1, boardVar.visW do
            mtrxTab[clrY][clrX] = mtrxTab[clrY - 1][clrX]
        end
    end

    -- clear the first row to prevent duplicates
    for clrX = 1, boardVar.visW do
        mtrxTab[1][clrX] = 0
    end
end

--- adds lines to board
---@param blk string | number | 0
---@param x number
---@param h number
---@param mtrxTab table
---@param gBoard table
---@param ply table
---@param blkTab table
---@param isShake boolean | nil
function states.addRows(blk, x, h, mtrxTab, gBoard, ply, blkTab, isShake)
    local game = require "lua.default.game"

    if isShake then
        game.isScreenShake = true
        game.sTLen = 0.05
        game.shakeInt = game.prevShake + h
    end

    for i = 1, h do
        mtrxTab[#mtrxTab + 1] = {}
        for xLn = 1, gBoard.visW do
            if xLn ~= x then
                mtrxTab[#mtrxTab][xLn] = blk
            else
                mtrxTab[#mtrxTab][xLn] = 0
            end
        end
        table.remove(mtrxTab, 1)
        if not states.bMove(ply, blkTab, gBoard, ply.x, floor(ply.y), ply.bRot, mtrxTab) and floor(ply.y) > 0 then
            ply.y = floor(ply.y) - 1
        end
    end
end

---@param plyVar table
---@param blkTab any
---@param brdTab any
---@param tX any
---@param tY any
---@param tRot any
---@param mtrxTab any
---@return boolean
function states.bMove(plyVar, blkTab, brdTab, tX, tY, tRot, mtrxTab)
    if blkTab[plyVar.currBlk][tRot] ~= nil then
        for y = 1, #blkTab[plyVar.currBlk][tRot] do
            for x = 1, #blkTab[plyVar.currBlk][tRot][y] do
                local testX, testY = tX + x, math.floor(tY) + y
                if blkTab[plyVar.currBlk][tRot][y][x] ~= 0 then
                    if testX < 1 or testX > brdTab.visW or testY < 1 or testY > brdTab.visH then
                        return false
                    else
                        if mtrxTab[testY][testX] ~= 0 then
                            return false
                        end
                    end
                end
            end
        end
    else
        return false
    end
    return true
end

-- for wall kicks
---@param plyVar any
---@param settings any
---@param tX any
---@param tY any
---@param d any
---@param bRot any
---@param blkTab any
---@param brdTab any
---@param gTable any
---@param mtrxTab any
---@param isFlipSpin boolean
---@return boolean
---@return integer
---@return integer
---@return integer
function states.bRotate(plyVar, settings, tX, tY, d, bRot, blkTab, brdTab, gTable, mtrxTab, isFlipSpin)
    if settings.rotSys == "ARS" then
        if blkTab[plyVar.currBlk] ~= nil then
            local bLen = blkTab[plyVar.currBlk]
            if #bLen > 1 then
                if #bLen[bRot] <= 3 and bLen ~= 1 then -- not an O piece
                    if not states.bMove(plyVar, blkTab, brdTab, tX, tY, bRot, mtrxTab) then
                        -- right kick
                        if states.bMove(plyVar, blkTab, brdTab, tX + 1, tY, bRot, mtrxTab) then
                            return true, tX + 1, tY, 1
                        end
                        -- left kick
                        if states.bMove(plyVar, blkTab, brdTab, tX - 1, tY, bRot, mtrxTab) then
                            return true, tX - 1, tY, 1
                        end
                        return false, tX, tY, 0
                    end
                end
                if not states.bMove(plyVar, blkTab, brdTab, tX, tY, bRot, mtrxTab) then
                    return false, tX, tY, 0
                end
                return true, tX, tY, 1
            end
            return false, tX, tY, 0
        end
        return false, tX, tY, 0
    elseif settings.rotSys == "SRS" then
        local tR

        -- table values
        if not isFlipSpin then
            if plyVar.currBlk ~= 1 and plyVar.currBlk ~= 6 then
                tR = gTable.wKicks[1][d][bRot]
            elseif plyVar.currBlk == 1 then
                tR = gTable.wKicks[2][d][bRot]
            elseif plyVar.currBlk == 6 then
                tR = gTable.wKicks[3][bRot]
            end
        else
            if plyVar.currBlk ~= 1 or plyVar.currBlk ~= 6 then
                tR = gTable.wKicks[4][bRot]
            end
        end

        for t = 1, #tR do
            if states.bMove(plyVar, blkTab, brdTab, tX + tR[t][1], tY - tR[t][2], bRot, mtrxTab) then
                plyVar.lDTimer = 0
                return true, tX + tR[t][1], tY - tR[t][2], t
            end
        end
        return false, tX, tY, 0
    end
    return false, tX, tY, 0
end

-- block placement & line clear logic
function states.bAdd(bX, bY, bL, plyVar, mtrxTab, brdTab, settings, sts)
    local clear = true
    local cAnim = false

    if bL[plyVar.currBlk][plyVar.bRot] ~= nil then
        for y, _ in ipairs(bL[plyVar.currBlk][plyVar.bRot]) do
            for x, blk in ipairs(bL[plyVar.currBlk][plyVar.bRot][y]) do
                if blk ~= 0 then
                    if bY + y <= #mtrxTab then
                        mtrxTab[bY + y][bX + x] = blk
                    end
                end
            end
        end
    else
        newLClrUI(sts.lClearUI "?", plyVar.currBlk, 0.5, 0.65)
        print("!!! this should NOT happen ingame (blocks wont place normally) currBlk: " ..
            plyVar.currBlk .. " bRot: " .. plyVar.bRot .. " x: " .. plyVar.x .. " y: " .. floor(plyVar.y) .. " !!!")
    end

    sts.stacks = sts.stacks + 1

    -- for line clear function
    for y = 1, brdTab.visH do
        clear = true

        for x = 1, brdTab.visW do
            if mtrxTab[y][x] == 0 then
                clear = false
                break
            end
        end

        if clear then
            plyVar.isClear = true
            cAnim = true
            -- store current y positions for cleared lines for use with moveCells() function
            -- same function as the hard drop effect
            table.insert(sts.clearedLinesYPos, y)

            -- line particles
            if settings.lineParticles then
                for x = 1, brdTab.visW do
                    -- boardVar == brdTab
                    effect.newLPart(sts.lPart, brdTab, mtrxTab[y][x], x, y, 0.35)
                end
            end

            print("---------- cAnim: " .. tostring(cAnim) .. " ----------")
            states.clearCells(y, mtrxTab, brdTab, sts, settings)
            clear = false
        end
    end

    plyVar.lineClrTemp = sts.lineClr

    if settings.lockEffect then
        effect.newLockEffect(sts.lkEfct, bL, plyVar, false)
    end
    --TODO: Finish board shake effect

    if stg.shakeDrop then
        plyVar.isShakeY = true
    else
        if plyVar.lineClrTemp > 1 then
            plyVar.isShakeY = true
        end
    end

    plyVar.shakeYTime = 1
    plyVar.sYInv = true

    states.lineReward(cAnim, plyVar, sts, mtrxTab, brdTab, settings)
end

function states.lineReward(cAnim, plyVar, sts, mtrxTab, brdTab, settings)
    if cAnim then
        tClear(sts.textEfct)
        -- start line delay
        plyVar.isLnDly = true

        -- clear line clear ui on new line clear
        tClear(sts.lClearUI)
        tClear(sts.lClearAftrImg)
        tClear(sts.lClearUITxt)

        if #sts.lkEfct > 0 then
            tClear(sts.lkEfct)
        end
    end

    local allClr = 0
    if states.isAllClr(mtrxTab, brdTab) then
        print("+" .. allClr .. " score points from aClear")
        allClr = 16000
        sts.scr = sts.scr + allClr
        sts.clr.ac = sts.clr.ac + 1

        if settings.lineEffect then
            effect.newLineEffect(nil, brdTab, sts.lEffect, true, false)
        end
        newLClrUI(sts.lClearAftrImg, sts.lineClr, "W", 5, 10)
        newLClrUI(sts.lClearUI, "C", "C", 0.5, 0.65, -28)

        tClear(sts.textClr)
        -- main text
        effect.newTextEffect(sts.textClr, "All CLEAR!!", brdTab.w * (brdTab.visW / 2), brdTab.h * (brdTab.visH + .35),
            "center", 1, 0, 1, 1,
            0, gCol.yellow, false, true, 1, 1.3)
        -- backdrop
        effect.newTextEffect(sts.textClr, "All CLEAR!!", brdTab.w * (brdTab.visW / 2), brdTab.h * (brdTab.visH + .35),
            "center", 1, -0.3, 0, 2,
            0, gCol.yellow, false, true, 1, 1.5)
    end

    -- "an unhinged score formula"
    -- line clear spin

    local spinNoClr =
        (plyVar.spinReward == 1) and 100 * sts.lv or
        (plyVar.spinReward == 2) and 400 * sts.lv or 0

    if plyVar.spinReward > 0 and plyVar.isAlrRot then
        if not cAnim then
            tClear(sts.lClearUI)
            newLClrUI(sts.lClearAftrImg, sts.lineClr, plyVar.currBlk, 5, 10)
            newLClrUI(sts.lClearUI, "T", "T", 0.5, 0.65, -28)
        end
        if plyVar.spinReward == 1 then
            newLClrUI(sts.lClearUITxt, "MINI", "W", 5, 10)
            newLClrUI(sts.lClearUITxt, "MINI", plyVar.currBlk, 0.5, 0.65, -28)
        end

        -- base scores, added with line clear formula
        -- mini spin
        sts.scr = sts.scr + spinNoClr

        sts.spinT = sts.spinT + 1
        if not (sts.lineClr > 0) then
            tClear(sts.textEfct)

            effect.newTextEffect(sts.textEfct, "+" .. spinNoClr,
                brdTab.w * (brdTab.visW + 0.85),
                brdTab.h * (brdTab.visH - 0.4), "center", 1, 0, 0.75, 1,
                0, { 1, 1, 1 }, false)
            effect.newTextEffect(sts.textEfct, "+" .. spinNoClr,
                brdTab.w * (brdTab.visW + 0.85),
                brdTab.h * (brdTab.visH - 0.4), "center", 1, 0, 0, 3,
                0, gCol.yellow, false)
            print("-------= spinReward: " .. plyVar.spinReward .. " (no line clr.) =-------")
        end
    end


    -- events after line clears
    --TODO: Rebalance score formula
    if cAnim then
        print("lines: " .. sts.lineClr)
        sts.comb = sts.comb + 1

        -- line clear ui popup
        newLClrUI(sts.lClearAftrImg, sts.lineClr, plyVar.currBlk, 5, 10)
        newLClrUI(sts.lClearUI, sts.lineClr, plyVar.currBlk, 0.5, 0.65, -28)

        -- line clear spin
        local spnReward =
            (plyVar.spinReward == 2) and (((400 * sts.lineClr) * sts.lv) * (sts.strk + 1)) or
            (plyVar.spinReward == 1) and (((100 * sts.lineClr) * sts.lv) * (sts.strk + 1)) or 0

        if plyVar.spinReward > 0 and plyVar.isAlrRot then
            newLClrUI(sts.lClearAftrImg, sts.lineClr, plyVar.currBlk, 5, 10)
            newLClrUI(sts.lClearUI, "T", "T", 0.5, 0.65, -28)

            sts.scr = sts.scr + spnReward
            if sts.lineClr == 1 then
                sts.clr.spinTS = sts.clr.spinTS + 1
            elseif sts.lineClr == 2 then
                sts.clr.spinTD = sts.clr.spinTD + 1
            elseif sts.lineClr == 3 then
                sts.clr.spinTT = sts.clr.spinTT + 1
            end
            sts.strk = sts.strk + 1

            print("-------= spinReward: " ..
                plyVar.spinReward ..
                " scr: " .. spnReward .. " (line clr.) =-------")
        end

        if sts.lineClr == 1 then
            sts.clr.sgl = sts.clr.sgl + 1
            if plyVar.spinReward == 0 then
                sts.strk = 0
            end
        elseif sts.lineClr == 2 then
            sts.clr.dbl = sts.clr.dbl + 1
            if plyVar.spinReward == 0 then
                sts.strk = 0
            end
        elseif sts.lineClr == 3 then
            sts.clr.trp = sts.clr.trp + 1
            if plyVar.spinReward == 0 then
                sts.strk = 0
            end
        elseif sts.lineClr == 4 then
            sts.clr.qd = sts.clr.qd + 1
            sts.strk = sts.strk + 1
        end

        local strkRwd = 0
        local comboRwd = 0
        if sts.strk > 1 then
            strkRwd = (4000 * (sts.strk))
            print("----- strk: x" .. sts.strk - 1 .. " -----")
        else
            strkRwd = 0
        end

        if sts.comb > 1 then
            comboRwd = (50 * sts.comb)
            print("----- combo: x" .. sts.comb - 1 .. " -----")
        else
            comboRwd = 0
        end

        local gReward = (((200 + (200 * sts.lineClr)) + comboRwd + strkRwd) * sts.lv)

        sts.scr = sts.scr + gReward

        effect.newTextEffect(sts.textEfct, "+" .. gReward + spnReward + spinNoClr + allClr,
            brdTab.w * (brdTab.visW + 0.85),
            brdTab.h * (brdTab.visH - 0.4), "center", 1, 0, 0.75, 1,
            0, { 1, 1, 1 }, false)
        effect.newTextEffect(sts.textEfct, "+" .. gReward + spnReward + spinNoClr + allClr,
            brdTab.w * (brdTab.visW + 0.85),
            brdTab.h * (brdTab.visH - 0.4), "center", 1, 0, 0, 3,
            0, gCol.yellow, false)

        if sts.line > sts.nxtLines then
            states.adjLvl(1, plyVar, sts, brdTab)
        end
        
        sts.lineClr = 0
        plyVar.spinReward = 0
        allClr = 0
        cAnim = false
        print("---------- cAnim: " .. tostring(cAnim) .. " ----------")
    else
        -- reset combo counter if no line clears
        sts.comb = 0
    end
end

-- gravity function
function states.gravUpd(ply, gMtrx, blocks, gBoard, settings, stats, dt)
    if not game.isCountdown then
        local lowestY = states.lowestCells(ply, gMtrx, blocks, gBoard)
        local gUpd = states.frameStep(ply.grav, settings.fpsTarget)

        if lowestY - ply.y >= ply.grav and not game.isInstantGrav then
            ply.y = ply.y + dt * gUpd
            ply.isAlrRot = false
        else
            ply.y = lowestY
            if floor(ply.y) ~= lowestY then
                ply.lDTimer = 0
            else
                -- lock piece if player reached move limit
                if ply.moveR > ply.mRLimit or ply.moveRBlk > ply.mRBLimit then
                    if not ply.isHDrop then
                        ply.lDTimer = ply.lDTimer - ply.lDelay
                        states.bAdd(ply.x, floor(ply.y), blocks, ply, gMtrx, gBoard, settings, stats)
                        if not game.isFail then
                            initvars.plyInit(ply)
                            ply.isEnDly = true
                        end
                        ply.moveR = 0
                    end
                else
                    if not ply.isHDrop then
                        if ply.lDTimer < ply.lDelay then
                            ply.lDTimer = ply.lDTimer + dt
                        else
                            states.bAdd(ply.x, floor(ply.y), blocks, ply, gMtrx, gBoard, settings, stats)

                            if not game.isFail then
                                initvars.plyInit(ply)
                                ply.isEnDly = true
                            end
                        end
                    end
                end
            end
        end
    end
end

-- game bag function
function states.bagInit(plyVar, settings)
    if settings.bagType == "modern" then
        local bagShuf = shuffle(bagDef)
        plyVar.next = concatTab(plyVar.next, bagShuf)
    elseif settings.bagType == "classicM" then
        -- might improve this later
        local firstPc = { 1, 5, 4, 7 }
        for _ = 1, plyVar.nDisp do
            if #plyVar.nHist ~= 4 then
                table.insert(plyVar.next, firstPc[lmth.random(1, #firstPc)])
                table.insert(plyVar.next, bagDef[love.math.random(1, #bagDef)])

                -- tInfo.new(textInfo, "initialized next queues", 0, wHg - 50, true, { 1, 1, 1, 1 }, 1, 1)
            else
                local nPiece
                for _ = 1, 4 do
                    nPiece = bagDef[lmth.random(1, #bagDef)]
                    -- tInfo.new(textInfo, "rolled next queues (next piece: " .. nPiece .. ")", 0, wHg - 50, true,
                    --    gCol.yellow,
                    --    1, 1)
                    if not tabContains(plyVar.nHist, nPiece) then
                        --tInfo.new(textInfo, "stopped rolling pieces", 0, wHg - 50, true,
                        --   gCol.green, 1, 1)
                        break
                    end
                end
                table.insert(plyVar.next, nPiece)
            end
        end
    elseif settings.bagType == "classicRand" then
        for _ = 1, #bagDef do
            local nPiece = bagDef[love.math.random(1, #bagDef)]
            if not tabContains(plyVar.nHist, nPiece) then
                nPiece = bagDef[love.math.random(1, #bagDef)]
            end
            table.insert(plyVar.next, nPiece)
        end
    end
end

function states.addHistory(plyVar, settings)
    -- add current piece to history if supported
    if settings.bagType == "classicM" then
        if #plyVar.nHist < 4 then
            table.insert(plyVar.nHist, plyVar.next[1])
        else
            tClear(plyVar.nHist)
            table.insert(plyVar.nHist, plyVar.next[1])
        end
    elseif settings.bagType == "classicRand" then
        if #plyVar.nHist < 1 then
            table.insert(plyVar.nHist, plyVar.next[1])
        else
            tClear(plyVar.nHist)
            table.insert(plyVar.nHist, plyVar.next[1])
        end
    end
end

function states.bagReset(plyVar, settings)
    tClear(plyVar.next)
    tClear(plyVar.nHist)
    states.bagInit(plyVar, settings)
    states.addHistory(plyVar, settings)
end

function states.initBlk(plyVar)
    plyVar.currBlk = plyVar.next[1]
    table.remove(plyVar.next, 1)
end

function states.nextQueue(plyVar, settings)
    if #plyVar.next > plyVar.nDisp + 1 then
        plyVar.currBlk = plyVar.next[1]
        table.remove(plyVar.next, 1)
    else
        -- reshuffle bag on end of next queue
        plyVar.currBlk = plyVar.next[1]
        table.remove(plyVar.next, 1)
        states.bagInit(plyVar, settings)
    end
end

-- hold function
function states.holdFunc(plyVar)
    if plyVar.hold == 0 then
        plyVar.hold = plyVar.currBlk
        plyVar.currBlk = plyVar.next[1]
        table.remove(plyVar.next, 1)
    else
        plyVar.cBlkTemp = plyVar.currBlk
        plyVar.currBlk = plyVar.hold
        plyVar.hold = plyVar.cBlkTemp
    end

    -- reset player position & values
    initvars.plyInit(plyVar)

    plyVar.isAlreadyHold = true
end

-- increment move reset counter
--TODO: Improve move reset function
-- with checking if the last move was from the lowest y axis via a boolean
function states.addMoves(plyVar, game, isBMove)
    if not isBMove then
        if game.useMoveReset then
            plyVar.moveR = plyVar.moveR + 1
        end
    else
        if game.useMoveReset then
            plyVar.moveRBlk = plyVar.moveRBlk + 1
        end
    end
end

-- game fail detection
function states.isGFail(plyVar, blkTab, brdTab, mtrxTab)
    if not states.bMove(plyVar, blkTab, brdTab, plyVar.x, floor(plyVar.y), plyVar.bRot, mtrxTab) then
        return true
    end
end

-- spin detection
function states.isSpin(xOff, yOff, ply, blkTab, gBoard, mtrxTab, t)
    if ply.currBlk ~= 7 then return 0 end

    local cellOff = {
        ---@format disable
        { {1, 1}, {3, 1}, {3, 3}, {1, 3} }, -- 0
        { {3, 1}, {3, 3}, {1, 3}, {1, 1} }, -- R
        { {3, 3}, {1, 3}, {1, 1}, {3, 1} }, -- 2
        { {1, 3}, {1, 1}, {3, 1}, {3, 3} }, -- L
    }
    local blk = blkTab[ply.currBlk][ply.bRot]
    local cOff = cellOff[ply.bRot]

    local function cellCheck(i)
        if xOff + cOff[i][1] > gBoard.visW or yOff + cOff[i][2] > gBoard.visH then
            -- returns a solid block
            return "O"
        else
            return mtrxTab[yOff + cOff[i][2]][xOff + cOff[i][1]]
        end
    end

    if blk ~= nil then
        -- normal spins
        if (cellCheck(1) ~= 0 and cellCheck(2) ~= 0) and
            (cellCheck(3) ~= 0 or cellCheck(4) ~= 0)
            or t == 5 then
            return 2
        end

        -- mini spins
        if (cellCheck(1) ~= 0 or cellCheck(2) ~= 0) and
            (cellCheck(3) ~= 0 and cellCheck(4) ~= 0) then
            return 1
        end
    end
    return 0
end

function states.isAllClr(mtrxTab, brdTab)
    for y = 1, brdTab.visH do
        for x = 1, brdTab.visW do
            if mtrxTab[y][x] ~= 0 then
                return false
            end
        end
    end
    return true
end

-- so strict
function states.sgCheck(mtrxTab, brdTab, sts)
    -- 10x20 cells
    if brdTab.visW == 10 and brdTab.visH >= 20 then
        -- cell x pos.
        for xCl = 1, 20 do
            if xCl == 1 then
                if solidRows(mtrxTab, xCl + 1, brdTab.visW, brdTab.visH, 1)
                    and (mtrxTab[brdTab.visH][xCl] == 0 and mtrxTab[brdTab.visH - xCl][xCl] ~= 0) then
                    sts.scrtG = xCl
                    -- first table value is bottom row
                    sts.sGFill[xCl] = true
                else
                    sts.sGFill[xCl] = false
                end
            elseif xCl > 1 and xCl <= 10 then
                -- 2nd to 10th row
                -- previous rows filled check
                if sts.sGFill[xCl - 1] then
                    if solidRows(mtrxTab, xCl + 1, brdTab.visW, brdTab.visH - (xCl - 1), 1)
                        and (solidRows(mtrxTab, 1, xCl - 1, brdTab.visH - (xCl - 1), 1)
                            and mtrxTab[brdTab.visH - (xCl - 1)][xCl] == 0
                            and mtrxTab[brdTab.visH - xCl][xCl] ~= 0) then
                        sts.scrtG = xCl
                        sts.sGFill[xCl] = true
                    end
                else
                    -- reset values to false
                    sts.sGFill[xCl] = false
                end
            elseif xCl > 10 and xCl <= 19 then
                -- 11th to 19th row
                if sts.sGFill[xCl - 1] then
                    if solidRows(mtrxTab, brdTab.visW - (xCl - 11), brdTab.visW, brdTab.visH - (xCl - 1), 1)
                        and (solidRows(mtrxTab, 1, brdTab.visW - (xCl - 9), brdTab.visH - (xCl - 1), 1)
                            and mtrxTab[brdTab.visH - (xCl - 1)][brdTab.visW - (xCl - 10)] == 0
                            and mtrxTab[brdTab.visH - xCl][brdTab.visW - (xCl - 10)] ~= 0) then
                        sts.scrtG = xCl
                        sts.sGFill[xCl] = true
                    end
                else
                    -- reset values to false
                    sts.sGFill[xCl] = false
                end
            elseif xCl == 20 then
                if sts.sGFill[xCl - 1] then
                    if solidRows(mtrxTab, 3, brdTab.visW, brdTab.visH - (xCl - 1), 1)
                        and (mtrxTab[brdTab.visH - (xCl - 1)][1] ~= 0
                            and mtrxTab[brdTab.visH - (xCl - 1)][2] == 0) then
                        sts.scrtG = xCl
                        -- highest row
                        sts.sGFill[xCl] = true
                    else
                        sts.sGFill[xCl] = false
                    end
                else
                    -- reset values to false
                    sts.sGFill[xCl] = false
                end
            end
        end
    end
end

-- danger zone (near failure) check
function states.dangerCheck(mtrxTab, gBoard)
    local dangerY = 8 -- offset by -2, then 8 == 6 from first row
    for y, _ in ipairs(mtrxTab) do
        for x, _ in ipairs(mtrxTab[y]) do
            if x > math.floor(gBoard.visW / 6) and x < gBoard.visW - (math.floor(gBoard.visW / 6)) then
                -- lv 1
                if y > dangerY - 2 and y < dangerY then
                    if mtrxTab[y][x] ~= 0 then
                        return 1
                    end
                    -- lv 2
                elseif y < dangerY - 2 then
                    if mtrxTab[y][x] ~= 0 then
                        return 2
                    end
                end
            end
        end
    end
    return false
end

return states
