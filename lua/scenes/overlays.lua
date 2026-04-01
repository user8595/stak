local settings = require "lua.default.settings"
local keys = require "lua.default.keys"
local kOver = require "lua.kOver"
local gCol = require "lua.gCol"

return {
    {
        kOver.newKey(20, 40, keys.left, "L", gCol.gOutline, gCol.white),
        kOver.newKey(60, 40, keys.right, "R", gCol.gOutline, gCol.white),
        kOver.newKey(40, 60, keys.hDrop, "U", gCol.gOutline, gCol.white),
        kOver.newKey(40, 40, keys.sDrop, "D", gCol.gOutline, gCol.white),

        kOver.newKey(85, 60, keys.ccw, "C", gCol.gOutline, gCol.white),
        kOver.newKey(105, 60, keys.cw, "W", gCol.gOutline, gCol.white),
        kOver.newKey(95, 40, keys.hold, "H", gCol.gOutline, gCol.white),
        kOver.newKey(115, 40, keys.flip, "F", gCol.gOutline, gCol.white),
        (settings.isDebug) and kOver.newKey(125, 60, "e", "E", gCol.gOutline, gCol.white) or nil,
        (settings.isDebug) and kOver.newKey(135, 40, "r", "S", gCol.gOutline, gCol.white) or nil,
    },
    {
        kOver.newKey(20, 60, keys.left, "L", gCol.gOutline, gCol.white),
        kOver.newKey(60, 60, keys.right, "R", gCol.gOutline, gCol.white),
        kOver.newKey(40, 40, keys.hDrop, "U", gCol.gOutline, gCol.white),
        kOver.newKey(40, 60, keys.sDrop, "D", gCol.gOutline, gCol.white),

        kOver.newKey(85, 40, keys.ccw, "C", gCol.gOutline, gCol.white),
        kOver.newKey(105, 40, keys.cw, "W", gCol.gOutline, gCol.white),
        kOver.newKey(95, 60, keys.hold, "H", gCol.gOutline, gCol.white),
        kOver.newKey(115, 60, keys.flip, "F", gCol.gOutline, gCol.white),
        (settings.isDebug) and kOver.newKey(125, 40, "e", "E", gCol.gOutline, gCol.white) or nil,
        (settings.isDebug) and kOver.newKey(135, 60, "r", "S", gCol.gOutline, gCol.white) or nil,
    }
}
