local gBoard = {
    x = 0,
    y = 0,
    -- block size
    w = 20,
    h = 20,
    gW = 10,
    --TODO: Increase board height to 40
    gH = 21,
    -- placeholder value
    visW = 10,
    visH = 21
}

-- maybe
gBoard.visW, gBoard.visH = gBoard.gW, gBoard.gH

return gBoard