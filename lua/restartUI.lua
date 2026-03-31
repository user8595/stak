local lk, lg = love.keyboard, love.graphics
local settings = require "lua.default.settings"
local stats = require "lua.default.stats"
local keys = require "lua.default.keys"
local lerp = require "lua.lerp"
local gCol = require "lua.gCol"
local font = lg.newFont("/assets/fonts/monogram-extended.TTF", 28)

local function qRCol(isAlpha)
    local t = stats.qrTime / settings.qRestartTime
    local a = function()
        if isAlpha then
            return lerp.easeOutQuad(0, 1, t)
        else
            return 1
        end
    end
    return lerp.linear(gCol.yellow[1], gCol.red[1], t),
        lerp.linear(gCol.yellow[2], gCol.red[2], t),
        lerp.linear(gCol.yellow[3], gCol.red[3], t),
        a()
end

local restartUI = {
    update = function(game, dt)
        if lk.isDown(keys.qRestart) then
            game.isQRestart = true
            if stats.qrTime < settings.qRestartTime then
                stats.qrTime = stats.qrTime + dt
            else
                return true
            end
        else
            game.isQRestart = false
            if stats.qrTime > 0 then
                stats.qrTime = stats.qrTime - dt * (4 * settings.qRestartTime)
            else
                stats.qrTime = 0
            end
        end
    end,
    draw = function()
        if stats.qrTime > 0 then
            local s = 1
            if settings.scale > 1 and settings.scale < 3.5 then
                s = settings.scale
            elseif settings.scale < 1 then
                s = 1
            elseif settings.scale > 3.5 then
                s = 3.5
            end
            lg.setColor(qRCol(true))
            lg.printf("HOLD TO RESTART", font, 0, lg.getHeight() - (39 + (10 * (s - 1))), lg.getWidth(), "center")
            lg.setColor(qRCol())
            lg.rectangle("fill", lg.getWidth() / 2, lg.getHeight() - (10 * s),
                -(lg.getWidth() / 2) * lerp.linear(0, 1, stats.qrTime / settings.qRestartTime), 10 * s)
            lg.rectangle("fill", lg.getWidth() / 2, lg.getHeight() - (10 * s),
                (lg.getWidth() / 2) * lerp.linear(0, 1, stats.qrTime / settings.qRestartTime), 10 * s)
        end
    end
}

return restartUI
