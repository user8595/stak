local lg, lw, lk, lm = love.graphics, love.window, love.keyboard, love.mouse
local lt, le = love.timer, love.event

local wWd, wHg = lg.getWidth(), lg.getHeight()

local fonts = {
    ui = lg.newFont("/assets/fonts/PixeloidSans.ttf", 18),
    time = lg.newFont("/assets/fonts/monogram-extended.TTF", 42),
    othr = lg.newFont("/assets/fonts/Picopixel.ttf", 14)
}

local settings = {
    showGrid = true,
    isDebug = function()
        if arg[2] == "debug" then
            return true
        else
            return false
        end
    end
}

local keys = {
    hDrop = "w",
    sDrop = "s",
    left = "a",
    right = "d",
    cw = "l",
    ccw = "k",
    hold = "space"
}

local gMtrx = {}
local gBoard = {
    x = 0,
    y = 0,
    -- block size
    w = 20,
    h = 20,
    gH = 21,
    -- placeholder value
    visW = 20,
    visH = 20
}

local ply = {
    x = 0,
    y = 0,
    currBlk = 1,
    bRot = 1,
    next = {},
    hold = 0,

    -- in seconds
    -- delay before autorepeat
    das = 102 / 1000,
    dasTimer = 0,
    -- auto repeat duration delay
    arr = 9 / 1000,
    arrTimer = 0,
    -- soft drop speed
    sdr = 5 / 1000,
    sdrTimer = 0,

    -- lock delay
    lDelay = 500 / 1000,

    -- gravity
    gTimer = 0,
    grav = 1000 / 1000

    -- use two separate values for current block & placed blocks
    -- if block > height or active block > placed block = add block to placed blocks
    -- check for each block individually as a table
    -- how to convert milliseconds to seconds for das?
    -- 1 ms = 1/1000th a second, that means 120ms = 0.12s
    -- absolute cinema
}

local stats = {
    scr = 0,
    lv = 0,
    line = 0,
    time = 0,
    timeDisp = 0
}

for i = 1, gBoard.gH, 1 do
    table.insert(gMtrx, { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 })
end

local blocks = {
    -- TODO: Implement modern rotation (low priority)
    -- TODO: Implement ARS wall kicks
    -- use on currBlk
    {
        -- use on bRot
        {
            { 0,   0,   0,   0 },
            { "I", "I", "I", "I" },
        },
        {
            { 0, 0, "I" },
            { 0, 0, "I" },
            { 0, 0, "I" },
            { 0, 0, "I" }
        },
    },
    {
        {
            { 0,   0,   0 },
            { "Z", "Z", 0, },
            { 0,   "Z", "Z" }
        },
        {
            { 0,   "Z" },
            { "Z", "Z" },
            { "Z", 0 },
        }
    },
    {
        {
            { 0,   0,   0 },
            { 0,   "S", "S" },
            { "S", "S", 0 }
        },
        {
            { "S", 0 },
            { "S", "S" },
            { 0,   "S" },
        }
    },
    {
        {
            { 0,   0,   0 },
            { "L", "L", "L" },
            { "L", 0,   0 }
        },
        {
            { "L", "L", 0 },
            { 0,   "L", 0 },
            { 0,   "L", 0 }
        },
        {
            { 0,   0,   0 },
            { 0,   0,   "L" },
            { "L", "L", "L" }
        },
        {
            { 0, "L", 0 },
            { 0, "L", 0 },
            { 0, "L", "L" }
        },
    },
    {
        {
            { 0,   0,   0 },
            { "J", "J", "J" },
            { 0,   0,   "J" }
        },
        {
            { 0,   "J", 0 },
            { 0,   "J", 0 },
            { "J", "J", 0 }
        },
        {
            { 0,   0,   0 },
            { "J", 0,   0 },
            { "J", "J", "J" }
        },
        {
            { 0, "J", "J" },
            { 0, "J", 0 },
            { 0, "J", 0 }
        }
    },
    {
        {
            { 0, 0,   0 },
            { 0, "O", "O" },
            { 0, "O", "O" },
        }
    },
    {
        {
            { 0,   0,   0 },
            { 0,   "T", 0 },
            { "T", "T", "T" },
        },
        {
            { 0, "T", 0 },
            { 0, "T", "T" },
            { 0, "T", 0 }
        },
        {
            { 0,   0,   0 },
            { "T", "T", "T" },
            { 0,   "T", 0 },
        },
        {
            { 0,   "T", 0 },
            { "T", "T", 0 },
            { 0,   "T", 0 }
        },
    },
}

local function dBlocks(bl, x, y)
    local colors = {
        I = { .54, .86, .92 },
        J = { .54, .71, .98 },
        L = { .98, .70, .53 },
        S = { .65, .89, .63 },
        Z = { .95, .55, .66 },
        T = { .80, .55, .66 },
        O = { .98, .89, .69 },
    }
    if bl == 0 then
        if settings.showGrid then
            lg.setColor(.80 * .3, .84 * .3, .96 * .3)
            lg.rectangle("fill", gBoard.x + gBoard.w * (x - 1), gBoard.y + gBoard.h * (y - 1), gBoard.w - (gBoard.w - 3),
                gBoard.h - (gBoard.h - 3))
        end
    end
    if bl ~= 0 then
        lg.setColor(colors[bl])
        lg.rectangle("line", gBoard.x + gBoard.w * (x - 1), gBoard.y + gBoard.h * (y - 1), gBoard.w, gBoard.h)
        lg.rectangle("fill", gBoard.x + gBoard.w * (x - 1), gBoard.y + gBoard.h * (y - 1), gBoard.w, gBoard.h)
    end
end

-- draw active blocks based on player x and y positions
-- x + 1, x - 1, y + 1, y - 1

function love.load(args)
    lg.setBackgroundColor(0.1, 0.1, 0.18)
    lm.setVisible(false)
end

function love.keypressed(k)
    if k == "escape" then
        le.quit(0)
    end

    if k == "f11" then
        if not lw.getFullscreen() then
            lw.setFullscreen(true)
        else
            lw.setFullscreen(false)
        end
    end

    if lk.isDown(keys.left) then
        ply.x = ply.x - 1
        ply.dasTimer = 0
        ply.arrTimer = 0
    end

    if lk.isDown(keys.right) then
        ply.x = ply.x + 1
        ply.dasTimer = 0
        ply.arrTimer = 0
    end

    if lk.isDown(keys.ccw) then
        if ply.bRot > 1 then
            ply.bRot = ply.bRot - 1
        else
            ply.bRot = #blocks[ply.currBlk]
        end
    end

    if lk.isDown(keys.cw) then
        if ply.bRot < #blocks[ply.currBlk] then
            ply.bRot = ply.bRot + 1
        else
            ply.bRot = 1
        end
    end

    if lk.isDown(keys.sDrop) then
        ply.sdrTimer = 0
        ply.y = ply.y + 1
    end

    if lk.isDown("r") then
        ply.x = 0
        ply.y = 0
    end

    if lk.isDown("o") then
        if ply.currBlk < #blocks then
            ply.currBlk = ply.currBlk + 1
        else
            ply.currBlk = 1
        end
    end

    if k == "f4" then
        if not settings.isDebug then
            settings.isDebug = true
        else
            settings.isDebug = false
        end
    end
end

function love.resize(w, h)
    wWd, wHg = w, h
end

function love.update(dt)
    local _, tMs = math.modf(stats.time)
    stats.time = stats.time + dt
    stats.timeDisp = string.format("%02d", math.floor(stats.time / 60)) ..
        ":" .. string.format("%02d", stats.time % 60) .. "." .. string.format("%.2f", tMs):sub(3, -1)

    -- das & arr implemented
    if lk.isDown(keys.left) or lk.isDown(keys.right) then
        if ply.dasTimer > ply.das then
            if ply.arrTimer > ply.arr then
                if lk.isDown(keys.left) then
                    ply.x = ply.x - 1
                end
                if lk.isDown(keys.right) then
                    ply.x = ply.x + 1
                end
            else
                ply.arrTimer = ply.arrTimer + dt
            end
        else
            ply.dasTimer = ply.dasTimer + dt
        end
    else
        ply.dasTimer = 0
        ply.arrTimer = 0
    end

    if lk.isDown(keys.sDrop) then
        if ply.sdrTimer < ply.sdr then
            ply.sdrTimer = ply.sdrTimer + dt
        else
            ply.y = ply.y + 1
            ply.sdrTimer = 0
        end
    else
        ply.sdrTimer = 0
    end

    if ply.gTimer < ply.grav then
        ply.gTimer = ply.gTimer + dt
    else
        ply.gTimer = 0
        ply.y = ply.y + 1
    end

    for _, blk in ipairs(gMtrx) do
        gBoard.visW = #blk
    end
    gBoard.visH = #gMtrx

    -- workaround for test
    if ply.bRot > #blocks[ply.currBlk] then
        ply.bRot = 1
    end
end

function love.draw()
    -- board matrix
    lg.push()
    lg.translate((wWd - (gBoard.w * gBoard.visW)) / 2, (wHg - (gBoard.h * gBoard.visH)) / 2)
    lg.setColor(.06, .06, .12, 1)
    lg.rectangle("fill", gBoard.x, gBoard.y + gBoard.h, gBoard.w * 10, gBoard.h * gBoard.gH - gBoard.h)
    for y, _ in ipairs(gMtrx) do
        for x, br in ipairs(gMtrx[y]) do
            if y ~= 1 then
                dBlocks(br, x, y)
            end
        end
    end

    for y, _ in ipairs(blocks[ply.currBlk][ply.bRot]) do
        for x, blk in ipairs(blocks[ply.currBlk][ply.bRot][y]) do
            if y == 1 then
                if blk ~= 0 then
                    dBlocks(blk, x + ply.x, y + ply.y)
                end
            else
                if blk ~= 0 then
                    dBlocks(blk, x + ply.x, y + ply.y)
                end
            end
        end
    end

    lg.setColor(1, 1, 1, 1)
    lg.printf("SCORE\n", fonts.othr, -60, gBoard.h * (gBoard.visH - 2.5), 40, "right")
    lg.printf(stats.scr, fonts.ui, -60, gBoard.h * (gBoard.visH - 1.85), 40, "right")

    lg.printf("LV.\n", fonts.othr, gBoard.w * (gBoard.visW + 0.85), gBoard.h * (gBoard.visH - 5), 40, "left")
    lg.printf(stats.lv, fonts.ui, gBoard.w * (gBoard.visW + 0.85), gBoard.h * (gBoard.visH - 4.35), 40, "left")

    lg.printf("LINES\n", fonts.othr, gBoard.w * (gBoard.visW + 0.85), gBoard.h * (gBoard.visH - 2.5), 40, "left")
    lg.printf(stats.line, fonts.ui, gBoard.w * (gBoard.visW + 0.85), gBoard.h * (gBoard.visH - 1.85), 40, "left")

    lg.printf(stats.timeDisp, fonts.time, gBoard.x,
        gBoard.h * (gBoard.visH + 0.35), gBoard.w * gBoard.visW, "center")

    --TODO: Change border color to last block used for line clear
    lg.setColor(0.7, 0.7, 0.7, 1)
    lg.rectangle("line", gBoard.x, gBoard.y + gBoard.h, gBoard.w * 10, gBoard.h * gBoard.gH - gBoard.gH)
    lg.pop()

    lg.setColor(1, 1, 1, 1)
    if settings.isDebug then
        lg.print(lt.getFPS() .. " FPS\n" .. wWd .. "x" .. wHg, fonts.othr, 10, 10)
        lg.printf(
            "x: " ..
            ply.x ..
            "\ny: " ..
            ply.y ..
            "\nbRot: " ..
            ply.bRot ..
            "\ncurrBlk: " ..
            ply.currBlk ..
            "\ndasTimer: " ..
            ply.dasTimer ..
            "\narrTimer: " .. ply.arrTimer .. "\nsdrTimer: " .. ply.sdrTimer .. "\ngTimer: " .. ply.gTimer,
            fonts.othr, 0, 10, wWd - 10, "right")
    end
end
