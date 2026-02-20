--TODO: Implement mini key overlay
local lk, lg = love.keyboard, love.graphics
local kFont = lg.newFont("/assets/fonts/monogram-extended.TTF", 24)

local kOver = {
    newKey = function(x, y, k, col, colTxt, colAct, colTxtAct)
        if assert(type(col) == "table" and type(colTxt) == "table" and type(colTxtAct) == "table" and type(colTxtAct) == "table", "overlay color must be table and rgb values") then
            return {
                x = x,
                y = y,
                k = k,
                col = col,
                colTxt = colTxt,
                colAct = colAct,
                colTxtAct = colTxtAct,
                isDown = false,
            }
        end
    end,
    updKey = function(keyTab)
        for _, kOv in ipairs(keyTab) do
            if lk.isDown(kOv.k) then
                kOv.isDown = true
            else
                kOv.isDown = false
            end
        end
    end,
    drwKey = function(keyTab)
        for _, kOv in ipairs(keyTab) do
            -- outline colors
            if kOv.isDown then
                lg.setColor(kOv.colAct[1], kOv.colAct[2], kOv.colAct[3], 1)
            else
                lg.setColor(kOv.col[1], kOv.col[2], kOv.col[3], 1)
            end
            lg.rectangle("line", kOv.x, lg.getHeight() - kOv.y, 20, 20)

            -- keys bg color
            if kOv.isDown then
                lg.setColor(kOv.colAct[1], kOv.colAct[2], kOv.colAct[3], 1)
                lg.rectangle("fill", kOv.x, lg.getHeight() - kOv.y, 20, 20)
            end

            -- text colors
            if kOv.isDown then
                lg.setColor(kOv.colTxtAct[1], kOv.colTxtAct[2], kOv.colTxtAct[3], 1)
            else
                lg.setColor(kOv.colTxt[1], kOv.colTxt[2], kOv.colTxt[3], 1)
            end

            if string.len(kOv.k) < 2 then
                lg.printf(kOv.k:gsub("^%l", string.upper), kFont, kOv.x, (lg.getHeight() - kOv.y), 20, "center")
            end
        end
    end
}

return kOver
