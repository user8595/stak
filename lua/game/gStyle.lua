local gStyle = {}
local lg = love.graphics
local gTable = require "lua.tables"

-- next queue outline
function gStyle.nxtCol(plyVar, settings, game, currBlk, gCol, gColD, isHold)
    local nBlk = plyVar.next[2]
    local cols = function()
        if not game.isFail or game.showFailColors then
            if settings.rotSys == "ARS" then
                return gTable.colTab.nxtCol.classic(gCol)
            else
                return gTable.colTab.nxtCol.modern(gCol)
            end
        else
            if settings.rotSys == "ARS" then
                return gTable.colTab.nxtCol.clD(gCol, gColD)
            else
                return gTable.colTab.nxtCol.mdD(gCol, gColD)
            end
        end
    end
    if not game.isPaused then
        if not isHold then
            return cols()[nBlk]
        else
            if currBlk ~= 0 then
                return cols()[currBlk]
            else
                return cols().gray
            end
        end
    else
        return cols().gray
    end
end

-- game ui fail colors
function gStyle.failCol(game, stats, gCol, isPPS, isCol)
    if not isPPS then
        if not game.isFail then
            if not isCol then
                lg.setColor(1, 1, 1, 1)
            else
                lg.setColor(gCol.red)
            end
        else
            local tCol = 0.35
            lg.setColor(gCol.gray[1] + tCol, gCol.gray[2] + tCol, gCol.gray[3] + tCol)
        end
    else
        if not game.isFail then
            -- p/s colors
            if stats.currPPS > 1.55 and stats.currPPS < 2.65 then
                lg.setColor(gCol.yellow)
            end
            if stats.currPPS > 2.65 and stats.currPPS < 3 then
                lg.setColor(gCol.lBlue[1] + .1, gCol.lBlue[2] + .2, 1)
            end
            if stats.currPPS > 3 and stats.currPPS < 4 then
                lg.setColor(gCol.red[1] + .3, gCol.red[2], gCol.red[3])
            end
            if stats.currPPS > 4 then
                lg.setColor(gCol.purple[1] + .4, gCol.purple[2] - .1, gCol.purple[3] + 0.1)
            end
            if stats.currPPS < 1.55 then
                lg.setColor(1, 1, 1, 1)
            end
        else
            local tCol = 0.35
            lg.setColor(gCol.gray[1] + tCol, gCol.gray[2] + tCol, gCol.gray[3] + tCol)
        end
    end
end

return gStyle
