local lg = love.graphics
local states = require "lua.game.states"
local initvars = require "lua.game.initvars"
local gCol = require "lua.gCol"
local countdown = {}

--- updates countdown values from 'game' table
---@param ply any
---@param blkTab any
---@param settings any
---@param game any
---@param keys any
---@param dt any
function countdown.update(ply, blkTab, settings, game, keys, dt)
    if not game.isPaused and not game.isPauseDelay then
        if game.isCountdown then
            if game.cTimer < game.cTarget then
                game.cTimer = game.cTimer + dt
            else
                states.initBlk(ply, settings)
                initvars.checkIRS(ply, blkTab, settings, game, keys)
                game.isCountdown = false
            end
            game.countA = 1 - game.cTimer % 1
        else
            if game.countA > 0 then
                game.countA = game.countA - dt
            end
        end
    end
end

--- draws countdown text
---@param gBoard table
---@param fonts table
---@param game table
---@param isBackdrop boolean
function countdown.draw(gBoard, gColD, fonts, game, isBackdrop)
    if not isBackdrop then
        if game.cTimer < game.cTarget then
            lg.setColor(1, 1, 1, game.countA)
        else
            lg.setColor(gCol.yellow[1], gCol.yellow[2], gCol.yellow[3], game.countA)
        end
    else
        if game.cTimer < game.cTarget then
            lg.setColor(.5, .5, .5, game.countA)
        else
            lg.setColor(gColD.yellow[1] - .2, gColD.yellow[2] - .2, gColD.yellow[3] - .2, game.countA)
        end
    end
    -- beeg
    if game.cTimer < game.cTarget then
        lg.printf(math.floor(game.cTarget - game.cTimer) + 1, fonts.time, 0, (gBoard.h * gBoard.visH) / 2.14,
            gBoard.w * gBoard.visW, "center")
    else
        lg.printf("GO", fonts.beeg, 0, (gBoard.h * gBoard.visH) / 2.14,
            gBoard.w * gBoard.visW, "center")
    end
end

return countdown
