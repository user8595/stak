local lk, lg = love.keyboard, love.graphics
local ipairs = ipairs
local icon = lg.newImageFont("/assets/img/key_overlay.png", "UDLRCWHFES")
icon:setFilter("nearest", "nearest")

local kOver = {
    ---creates and returns a new key overlay object as a table
    ---@param x number
    ---@param y number
    ---@param k love.KeyConstant
    ---@param txt string
    ---@param col table
    ---@param colTxt table
    ---@param colAct nil | table
    ---@param colTxtAct nil | table
    ---@return table
    newKey = function(x, y, k, txt, col, colTxt, colAct, colTxtAct)
        if assert(txt ~= nil, "text label must not be empty") then
            if assert(type(col) == "table" and type(colTxt) == "table", "overlay color must be table and rgb values") and
                colAct ~= nil and
                colTxtAct ~= nil
            then
                return {
                    x = x,
                    y = y,
                    k = k,
                    txt = txt,
                    col = col,
                    colTxt = colTxt,
                    colAct = colAct,
                    colTxtAct = colTxtAct,
                    isDown = false,
                }
            end
            -- use base colors if active colors are ommited
            if assert(type(col) == "table" and type(colTxt) == "table" and colAct == nil and colTxtAct == nil, "overlay color must be table and rgb values") then
                return {
                    x = x,
                    y = y,
                    k = k,
                    txt = txt,
                    col = col,
                    colTxt = colTxt,
                    colAct = col,
                    colTxtAct = colTxt,
                    isDown = false,
                }
            end
        end
        return {}
    end,
    ---updates key overlay sprites
    ---@param keyTab table
    updKey = function(keyTab)
        for _, kOv in ipairs(keyTab) do
            if lk.isDown(kOv.k) then
                kOv.isDown = true
            else
                kOv.isDown = false
            end
        end
    end,
    ---draws key overlay sprites
    ---@param keyTab table
    ---@param isAlt boolean
    drwKey = function(keyTab, isAlt)
        for _, kOv in ipairs(keyTab) do
            local yPos = (not isAlt) and lg.getHeight() - kOv.y or kOv.y
            -- outline colors
            if kOv.isDown then
                lg.setColor(kOv.colAct[1], kOv.colAct[2], kOv.colAct[3], 1)
            else
                lg.setColor(kOv.col[1], kOv.col[2], kOv.col[3], 1)
            end
            lg.rectangle("line", kOv.x, yPos, 20, 20)

            -- keys bg color
            if kOv.isDown then
                lg.setColor(kOv.colAct[1], kOv.colAct[2], kOv.colAct[3], 1)
                lg.rectangle("fill", kOv.x, yPos, 20, 20)
            end

            -- text colors
            if kOv.isDown then
                lg.setColor(kOv.colTxtAct[1], kOv.colTxtAct[2], kOv.colTxtAct[3], 1)
            else
                lg.setColor(kOv.colTxt[1], kOv.colTxt[2], kOv.colTxt[3], 1)
            end

            lg.printf(kOv.txt, icon, kOv.x, yPos, 20, "center")
        end
    end
}

return kOver
