local gCol = require "lua.gCol"
local cFlash = require "lua.colFlash"
local cfObj = {}
function cfObj.col(gColD)
    return {
        cFStrk = cFlash.new(gCol.yellow, gCol.blue, .05),
        cFCb = cFlash.new(gCol.yellow, gCol.white, .05),
        cFGoal = cFlash.new(gCol.red, gCol.yellow, .05),
        cFAC = cFlash.new(gColD.yellow, gColD.lBlue, .1),

        cFSpn = cFlash.new(gColD.lBlue, gColD.purple, .1),

        cFFail = cFlash.new(gCol.red, gCol.orange, .05),
        cFFBG = cFlash.new(gColD.red, gColD.orange, .75)
    }
end

return cfObj