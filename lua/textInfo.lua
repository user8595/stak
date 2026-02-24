local lg = love.graphics
local fontInfo = lg.newFont("/assets/fonts/Picopixel.ttf", 14)
fontInfo:setFilter("nearest", "nearest")

local textInfo = {
    new = function(txtTab, str, x, y, isCenter, col, a, fadeTime)
        if type(col) == "table" and
            assert(type(isCenter) == "boolean", "isCenter must be boolean") and
            type(str) ~= "table" then
            table.insert(txtTab, {
                str = str,
                x = x,
                y = y,
                isCenter = isCenter,
                col = col,
                a = a,
                timer = 0,
                fadeTime = fadeTime,
            })
        elseif type(str) == "table" and type(col) == "nil" then
            table.insert(txtTab, {
                str = str,
                x = x,
                y = y,
                isCenter = isCenter,
                col = { 1, 1, 1, 1 },
                a = a,
                timer = 0,
                fadeTime = fadeTime,
            })
        end
    end,
    update = function(txtTab, dt, scale)
        for i, txt in ipairs(txtTab) do
            if txt.timer < txt.fadeTime then
                txt.timer = txt.timer + dt
            else
                if txt.a > 0 then
                    txt.a = txt.a - dt
                else
                    table.remove(txtTab, i)
                end
            end

            if scale > 0.75 then
                fontInfo:release()
                fontInfo = lg.newFont("/assets/fonts/Picopixel.ttf", 14 * scale)
            end
        end
    end,
    draw = function(txtTab)
        for i, txt in ipairs(txtTab) do
            lg.setColor(txt.col[1], txt.col[2], txt.col[3], txt.a)
            if txt.isCenter then
                lg.printf(txt.str, fontInfo, 0, txt.y - (fontInfo:getHeight() * (i - 1)), lg.getWidth(), "center")
            else
                lg.print(txt.str, fontInfo, txt.x, txt.y - (fontInfo:getHeight() * (i - 1)))
            end
        end
    end
}

return textInfo
