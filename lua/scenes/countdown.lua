local lg = love.graphics
local initvars = require "lua.game.initvars"
local gCol = require "lua.gCol"
local countdown = {}

function countdown.update(ply, blkTab, settings, game, keys, dt)
    if game.isCountdown then
        if game.cTimer < game.cTarget then
            game.cTimer = game.cTimer + dt
        else
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

function countdown.draw(gBoard, fonts, game)
    if game.cTimer < game.cTarget then
        -- tempoary
        lg.setColor(1, 1, 1, 0)
    else
        lg.setColor(gCol.yellow[1], gCol.yellow[2], gCol.yellow[3], game.countA)
    end
    -- beeg
    if game.cTimer < game.cTarget then
        lg.printf(math.floor(game.cTarget - game.cTimer) + 1, fonts.beeg, 0, (gBoard.h * gBoard.visH) / 2.14,
            gBoard.w * gBoard.visW, "center")
    else
        lg.printf("GO", fonts.beeg, 0, (gBoard.h * gBoard.visH) / 2.14,
            gBoard.w * gBoard.visW, "center")
    end
end

return countdown
