local colFlash = {
    new = function(col1, col2, time)
        return {
            index = 1,
            cTime = 0,
            time = time,
            col = {
                col1,
                col2
            }
        }
    end,
    upd = function(colVar, dt)
        colVar.cTime = colVar.cTime + dt
        if colVar.cTime > colVar.time then
            if colVar.index < #colVar.col then
                colVar.index = colVar.index + 1
            else
                colVar.index = 1
            end
            colVar.cTime = 0
        end
    end
}

return colFlash
