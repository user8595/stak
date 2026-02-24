local lerp = require "lua.lerp"
local lg, lm = love.graphics, love.mouse
local mX, mY = lm.getPosition()

local button = {
    new = function(str, font, x, y, w, h, func, col, colActive, colTxt, colTxtActive, isCenter)
        if assert(type(col) == "table" and type(colTxt) == "table", "color value must be table") and assert(type(func) == "function", "func value must be function") then
            -- most optimized code of All Time /j
            if colTxtActive ~= nil then
                if colActive == nil then
                    return {
                        str = str,
                        font = font,
                        x = x,
                        y = y,
                        w = w,
                        h = h,
                        func = func,
                        col = col,
                        colActive = col,
                        colTxt = colTxt,
                        colTxtActive = colTxtActive,
                        t = 0,
                        isCenter = isCenter,
                    }
                elseif colActive ~= nil then
                    return {
                        str = str,
                        font = font,
                        x = x,
                        y = y,
                        w = w,
                        h = h,
                        func = func,
                        col = col,
                        colActive = colActive,
                        colTxt = colTxt,
                        colTxtActive = colTxtActive,
                        t = 0,
                        isCenter = isCenter
                    }
                end
            elseif colTxtActive == nil then
                if colActive == nil then
                    return {
                        str = str,
                        font = font,
                        x = x,
                        y = y,
                        w = w,
                        h = h,
                        func = func,
                        col = col,
                        colActive = col,
                        colTxt = colTxt,
                        colTxtActive = colTxt,
                        t = 0,
                        isCenter = isCenter
                    }
                elseif colActive ~= nil then
                    return {
                        str = str,
                        font = font,
                        x = x,
                        y = y,
                        w = w,
                        h = h,
                        func = func,
                        col = col,
                        colActive = colActive,
                        colTxt = colTxt,
                        colTxtActive = colTxt,
                        t = 0,
                        isCenter = isCenter
                    }
                end
            end
        end
    end,
    update = function(buttonTab, dt)
        mX, mY = lm.getPosition()
        for _, btn in ipairs(buttonTab) do
            if btn.isCenter then
                if mX > ((lg.getWidth() - btn.w) / 2) + btn.x and mX < ((lg.getWidth() - btn.w) / 2) + (btn.x + btn.w) and
                    mY > ((lg.getHeight() - btn.h) / 2) + btn.y and mY < ((lg.getHeight() - btn.h) / 2) + (btn.y + btn.h) then
                    if btn.t < 1 then
                        btn.t = btn.t + dt * 8
                    end
                else
                    if btn.t > 0 then
                        btn.t = btn.t - dt * 12
                    end
                end
            else
                if mX > btn.x and mX < btn.x + btn.w and
                    mY > btn.y and mY < btn.y + btn.h then
                    if btn.t < 1 then
                        btn.t = btn.t + dt * 8
                    end
                else
                    if btn.t > 0 then
                        btn.t = btn.t - dt * 12
                    end
                end
            end
        end
    end,
    mUpd = function(x, y, b, buttonTab)
        for _, btn in ipairs(buttonTab) do
            if btn.isCenter then
                if x > ((lg.getWidth() - btn.w) / 2) + btn.x and x < ((lg.getWidth() - btn.w) / 2) + (btn.x + btn.w) and
                    y > ((lg.getHeight() - btn.h) / 2) + btn.y and y < ((lg.getHeight() - btn.h) / 2) + (btn.y + btn.h) then
                    if b == 1 then
                        btn.func()
                    end
                end
            else
                if x > btn.x and x < btn.x + btn.w and
                    y > btn.y and y < btn.y + btn.h then
                    if b == 1 then
                        btn.func()
                    end
                end
            end
            btn.t = 0
        end
    end,
    draw = function(buttonTab)
        lg.setColor(1, 1, 1, 1)
        for _, btn in ipairs(buttonTab) do
            if btn.isCenter then
                lg.setColor(btn.col)
                lg.rectangle("fill", ((lg.getWidth() - btn.w) / 2) + btn.x, ((lg.getHeight() - btn.h) / 2) + btn.y, btn
                    .w,
                    btn.h)
                -- active overlay
                lg.setColor(btn.colActive[1], btn.colActive[2], btn.colActive[3], btn.t)
                lg.rectangle("fill", ((lg.getWidth() - btn.w) / 2) + btn.x, ((lg.getHeight() - btn.h) / 2) + btn.y, btn
                    .w,
                    btn.h)

                lg.setColor(btn.colTxt)
                lg.printf(btn.str, btn.font, ((lg.getWidth() - btn.w) / 2) + btn.x,
                    ((lg.getHeight() - btn.h) / 2) + btn.y,
                    btn.w, "center")

                lg.setColor(btn.colTxtActive[1], btn.colTxtActive[2], btn.colTxtActive[3], btn.t)
                lg.printf(btn.str, btn.font, ((lg.getWidth() - btn.w) / 2) + btn.x,
                    ((lg.getHeight() - btn.h) / 2) + btn.y,
                    btn.w, "center")
            else
                lg.setColor(btn.col)
                lg.rectangle("fill", btn.x, btn.y, btn.w, btn.h)
                -- active overlay
                lg.setColor(btn.colActive[1], btn.colActive[2], btn.colActive[3], btn.t)
                lg.rectangle("fill", btn.x, btn.y, btn.w, btn.h)

                lg.setColor(btn.colTxt)
                lg.printf(btn.str, btn.font, btn.x, btn.y, btn.w, "center")

                lg.setColor(btn.colTxtActive[1], btn.colTxtActive[2], btn.colTxtActive[3], btn.t)
                lg.printf(btn.str, btn.font, btn.x, btn.y, btn.w, "center")
            end
        end
        lg.setColor(1, 1, 1, 1)
    end
}

return button
