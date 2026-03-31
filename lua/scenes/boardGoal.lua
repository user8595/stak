local lg = love.graphics
local gCol = require "lua.gCol"
local boardGoal = {}

--- draws goal lines
---@param game table
---@param lines number
---@param gBoard table
---@param col table
---@param colNearEnd table
function boardGoal.draw(game, lines, gBoard, col, colNearEnd)
    local goal = game.target - 20
    local lWidth = 2
    if game.showGoalLines then
        if lines >= goal and lines < goal + 20 then
            if not game.isFail then
                if lines < goal + 10 then
                    lg.setColor(col[1], col[2], col[3], 0.75)
                else
                    lg.setColor(colNearEnd[1], colNearEnd[2], colNearEnd[3], 0.85)
                end
            else
                lg.setColor(gCol.gray[1], gCol.gray[2], gCol.gray[3], 0.35)
            end
            lg.rectangle("fill", gBoard.x, (gBoard.y - lWidth) + (gBoard.h * (lines - goal + (gBoard.visH - 20))),
                gBoard.w * gBoard.visW, lWidth)
        end
    end
end

return boardGoal
