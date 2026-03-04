-- table values
local tables = {
    grav = {
        -- level 1 to 5
        1, 0.8, 0.65, 0.53, 0.32,

        -- level 5 to 10
        0.25, 0.18, 0.10, 0.05, 0.03,

        -- level 11 to 13
        0.025, 0.015, 0.001

        -- level 13+ == 0s
    },
    gravMult = {
        -- < level 13
        0,

        -- level 13 to 15
        0, 1, 2,

        -- level 15 to 20+
        4, 7, 8, 12, 30
    },
    --TODO: Implement secret grade values
    sGrade = {
        9, 8, 7, 6, 5, 4, 3, 2, 1,
        "S1", "S2", "S3", "S4", "S5",
        "S6", "S7", "S8", "S9", "GM"
    },
    blocks =
    {
        ars = {
            -- use on currBlk
            {
                -- use on bRot
                {
                    { 0, 0, 0, 0 }, { "I", "I", "I", "I" },
                },
                {
                    { 0, 0, "I" }, { 0, 0, "I" }, { 0, 0, "I" }, { 0, 0, "I" }
                },
            },
            {
                {
                    { 0, 0, 0 }, { "Z", "Z", 0, }, { 0, "Z", "Z" }
                },
                {
                    { 0, "Z", 0 }, { "Z", "Z", 0 }, { "Z", 0, 0 },
                }
            },
            {
                {
                    { 0, 0, 0 }, { 0, "S", "S" }, { "S", "S", 0 }
                },
                {
                    { "S", 0, 0 }, { "S", "S", 0 }, { 0, "S", 0 },
                }
            },
            {
                {
                    { 0, 0, 0 }, { "L", "L", "L" }, { "L", 0, 0 }
                },
                {
                    { "L", "L", 0 }, { 0, "L", 0 }, { 0, "L", 0 }
                },
                {
                    { 0, 0, 0 }, { 0, 0, "L" }, { "L", "L", "L" }
                },
                {
                    { 0, "L", 0 }, { 0, "L", 0 }, { 0, "L", "L" }
                },
            },
            {
                {
                    { 0, 0, 0 }, { "J", "J", "J" }, { 0, 0, "J" }
                },
                {
                    { 0, "J", 0 }, { 0, "J", 0 }, { "J", "J", 0 }
                },
                {
                    { 0, 0, 0 }, { "J", 0, 0 }, { "J", "J", "J" }
                },
                {
                    { 0, "J", "J" }, { 0, "J", 0 }, { 0, "J", 0 }
                }
            },
            {
                {
                    { 0, 0, 0 }, { 0, "O", "O" }, { 0, "O", "O" },
                }
            },
            {
                {
                    { 0, 0, 0 }, { "T", "T", "T" }, { 0, "T", 0 },
                },
                {
                    { 0, "T", 0 }, { "T", "T", 0 }, { 0, "T", 0 }
                },
                {
                    { 0, 0, 0 }, { 0, "T", 0 }, { "T", "T", "T" },
                },
                {
                    { 0, "T", 0 }, { 0, "T", "T" }, { 0, "T", 0 }
                },
            },
        },
        srs = {
            {
                {
                    { 0, 0, 0, 0 }, { "I", "I", "I", "I" }, { 0, 0, 0, 0 }, { 0, 0, 0, 0 },
                },
                {
                    { 0, 0, "I", 0 }, { 0, 0, "I", 0 }, { 0, 0, "I", 0 }, { 0, 0, "I", 0 },
                },
                {
                    { 0, 0, 0, 0 }, { 0, 0, 0, 0 }, { "I", "I", "I", "I" }, { 0, 0, 0, 0 },
                },
                {
                    { 0, "I", 0, 0 }, { 0, "I", 0, 0 }, { 0, "I", 0, 0 }, { 0, "I", 0, 0 },
                },
            },
            {
                {
                    { "Z", "Z", 0 }, { 0, "Z", "Z" }, { 0, 0, 0 }
                },
                {
                    { 0, 0, "Z" }, { 0, "Z", "Z" }, { 0, "Z", 0 },
                },
                {
                    { 0, 0, 0 }, { "Z", "Z", 0 }, { 0, "Z", "Z" },
                },
                {
                    { 0, "Z", 0 }, { "Z", "Z", 0 }, { "Z", 0, 0 },
                },
            },
            {
                {
                    { 0, "S", "S" }, { "S", "S", 0 }, { 0, 0, 0 },
                },
                {
                    { 0, "S", 0 }, { 0, "S", "S" }, { 0, 0, "S" },
                },
                {
                    { 0, 0, 0 }, { 0, "S", "S" }, { "S", "S", 0 },
                },
                {
                    { "S", 0, 0 }, { "S", "S", 0 }, { 0, "S", 0 },
                },
            },
            {
                {
                    { "J", 0, 0 }, { "J", "J", "J" }, { 0, 0, 0 },
                },
                {
                    { 0, "J", "J" }, { 0, "J", 0 }, { 0, "J", 0 },
                },
                {
                    { 0, 0, 0 }, { "J", "J", "J" }, { 0, 0, "J" },
                },
                {
                    { 0, "J", 0 }, { 0, "J", 0 }, { "J", "J", 0 },
                },
            },
            {
                {
                    { 0, 0, "L" }, { "L", "L", "L" }, { 0, 0, 0 },
                },
                {
                    { 0, "L", 0 }, { 0, "L", 0 }, { 0, "L", "L" },
                },
                {
                    { 0, 0, 0 }, { "L", "L", "L" }, { "L", 0, 0 },
                },
                {
                    { "L", "L", 0 }, { 0, "L", 0 }, { 0, "L", 0 },
                },
            },
            {
                {
                    { 0, "O", "O" }, { 0, "O", "O" }, { 0, 0, 0 },
                },
                {
                    { 0, "O", "O" }, { 0, "O", "O" }, { 0, 0, 0 },
                },
                {
                    { 0, "O", "O" }, { 0, "O", "O" }, { 0, 0, 0 },
                },
                {
                    { 0, "O", "O" }, { 0, "O", "O" }, { 0, 0, 0 },
                },
            },
            {
                {
                    { 0, "T", 0 }, { "T", "T", "T" }, { 0, 0, 0 },
                },
                {
                    { 0, "T", 0 }, { 0, "T", "T" }, { 0, "T", 0 },
                },
                {
                    { 0, 0, 0 }, { "T", "T", "T" }, { 0, "T", 0 },
                },
                {
                    { 0, "T", 0 }, { "T", "T", 0 }, { 0, "T", 0 },
                },
            }
        },
    },
    wKicks = {
        -- J, L, S, T, Z
        {
            { { 0, 0 }, { 0, 0 },  { 0, 0 },   { 0, 0 }, { 0, 0 } },
            { { 0, 0 }, { 1, 0 },  { 1, -1 },  { 0, 2 }, { 1, 2 } },
            { { 0, 0 }, { 0, 0 },  { 0, 0 },   { 0, 0 }, { 0, 0 } },
            { { 0, 0 }, { -1, 0 }, { -1, -1 }, { 0, 2 }, { -1, 2 } },
        },
        -- I
        {
            ---@format disable
            -- ccw
            {
                { {0, 0}, {2, 0}, {-1, 0}, {2, 1}, {-1, -2} }, -- R>0
                { {0, 0}, {1, 0}, {-2, 0}, {1, -2}, {-2, 1} }, -- 2>R
                { {0, 0}, {-2, 0}, {1, 0}, {-2, -1}, {1, 2} }, -- L>2
                { {0, 0}, {-1, 0}, {2, 0}, {-1, 2}, {2, -1} }, -- 0>L
            },
            -- cw
            {
                { {0, 0}, {1, 0}, {-2, 0}, {1, -2}, {-2, 1} }, -- L>0
                { {0, 0}, {-2, 0}, {1, 0}, {-2, -1}, {1, 2} }, -- 0>R
                { {0, 0}, {-1, 0}, {2, 0}, {-1, 2}, {2, -1} }, -- R>2
                { {0, 0}, {2, 0}, {-1, 0}, {2, 1}, {-1, -2} }, -- 2>L
            }
        },
        -- O
        {
            { { 0, 0 } },
            { { 0, 0 } },
            { { 0, 0 } },
            { { 0, 0 } }
        }
    },

    colTab = {
        nxtCol = {
            classic = function(gCol)
                return {
                    gray = gCol.gOutline,
                    gCol.red,
                    gCol.green,
                    gCol.purple,
                    gCol.orange,
                    gCol.blue,
                    gCol.yellow,
                    gCol.lBlue,
                }
            end,
            modern = function(gCol)
                return
                {
                    gray = gCol.gOutline,
                    gCol.lBlue,
                    gCol.red,
                    gCol.green,
                    gCol.blue,
                    gCol.orange,
                    gCol.yellow,
                    gCol.purple,
                }
            end,
            clD = function(gCol, gColD)
                return {
                    gray = gCol.gOutline,
                    gColD.red,
                    gColD.green,
                    gColD.purple,
                    gColD.orange,
                    gColD.blue,
                    gColD.yellow,
                    gColD.lBlue,
                }
            end,
            mdD = function(gCol, gColD)
                return
                {
                    gray = gCol.gOutline,
                    gColD.lBlue,
                    gColD.red,
                    gColD.green,
                    gColD.blue,
                    gColD.orange,
                    gColD.yellow,
                    gColD.purple,
                }
            end,
        },
        lClearUI = {
            classic = function(gColD, cFAC, cFSpn)
                return {
                    gColD.red,
                    gColD.green,
                    gColD.purple,
                    gColD.orange,
                    gColD.blue,
                    gColD.yellow,
                    gColD.lBlue,
                    C = cFAC.col[cFAC.index],
                    T = cFSpn.col[cFSpn.index]
                }
            end,
            classicD = function(gCol, cFAC, cFSpn)
                return {
                    -- duct tape
                    { gCol.red[1] - .2,    gCol.red[2] - .2,    gCol.red[3] - .2 },
                    { gCol.green[1] - .2,  gCol.green[2] - .2,  gCol.green[3] - .2 },
                    { gCol.purple[1] - .2, gCol.purple[2] - .2, gCol.purple[3] - .2 },
                    { gCol.orange[1] - .2, gCol.orange[2] - .2, gCol.orange[3] - .2 },
                    { gCol.blue[1] - .2,   gCol.blue[2] - .2,   gCol.blue[3] - .2 },
                    { gCol.yellow[1] - .2, gCol.yellow[2] - .2, gCol.yellow[3] - .2 },
                    { gCol.lBlue[1] - .2,  gCol.lBlue[2] - .2,  gCol.lBlue[3] - .2 },
                    C = cFAC.col[cFAC.index],
                    T = cFSpn.col[cFSpn.index]
                }
            end,
            modern = function(gColD, cFAC, cFSpn)
                return {
                    gColD.lBlue,
                    gColD.red,
                    gColD.green,
                    gColD.blue,
                    gColD.orange,
                    gColD.yellow,
                    gColD.purple,
                    C = cFAC.col[cFAC.index],
                    T = cFSpn.col[cFSpn.index]
                }
            end,
            modernD = function(gCol, cFAC, cFSpn)
                return {
                    { gCol.lBlue[1] - .2,  gCol.lBlue[2] - .2,  gCol.lBlue[3] - .2 },
                    { gCol.red[1] - .2,    gCol.red[2] - .2,    gCol.red[3] - .2 },
                    { gCol.green[1] - .2,  gCol.green[2] - .2,  gCol.green[3] - .2 },
                    { gCol.blue[1] - .2,   gCol.blue[2] - .2,   gCol.blue[3] - .2 },
                    { gCol.orange[1] - .2, gCol.orange[2] - .2, gCol.orange[3] - .2 },
                    { gCol.yellow[1] - .2, gCol.yellow[2] - .2, gCol.yellow[3] - .2 },
                    { gCol.purple[1] - .2, gCol.purple[2] - .2, gCol.purple[3] - .2 },
                    C = cFAC.col[cFAC.index],
                    T = cFSpn.col[cFSpn.index]
                }
            end
        }
    }
}

return tables
