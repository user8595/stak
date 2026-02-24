-- table values
local tables = {
    grav = {
        -- level 1 to 5
        1, 0.8, 0.65, 0.53, 0.32,

        -- level 5 to 10
        0.25, 0.18, 0.10, 0.05, 0.03,

        -- level 11
        0.01

        -- level 12+ == 0s
    },
    --TODO: Implement gravity multipliers?
    gravMult = {
        -- < level 12
        0,

        -- level 12 to 15
        0, 1, 2, 2, 3,

        -- level 15 to 20+
        4, 6, 8, 9, 20
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
                    { "L", 0, 0 }, { "L", "L", "L" }, { 0, 0, 0 },
                },
                {
                    { 0, "L", "L" }, { 0, "L", 0 }, { 0, "L", 0 },
                },
                {
                    { 0, 0, 0 }, { "L", "L", "L" }, { 0, 0, "L" },
                },
                {
                    { 0, "L", 0 }, { 0, "L", 0 }, { "L", "L", 0 },
                },
            },
            {
                {
                    { 0, 0, "J" }, { "J", "J", "J" }, { 0, 0, 0 },
                },
                {
                    { 0, "J", 0 }, { 0, "J", 0 }, { 0, "J", "J" },
                },
                {
                    { 0, 0, 0 }, { "J", "J", "J" }, { "J", 0, 0 },
                },
                {
                    { "J", "J", 0 }, { 0, "J", 0 }, { 0, "J", 0 },
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
    --TODO: Implement modern wall kicks
    wKicks = {
        {
            -- I
            { 1, 0 }, { -1, 0 }
        },
        {
            -- Z
            { 1, 0 }, { -1, 0 }
        },
        {
            -- S
            { 1, 0 }, { -1, 0 }
        },
        {
            -- L
            { 1, 0 }, { -1, 0 }
        },
        {
            -- J
            { 1, 0 }, { -1, 0 }
        },
        {
            -- O
            { 1, 0 }, { -1, 0 }
        },
        {
            -- T
            { 1, 0 }, { -1, 0 }
        },
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
                    gCol.green,
                    gCol.red,
                    gCol.orange,
                    gCol.blue,
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
                    gColD.green,
                    gColD.red,
                    gColD.orange,
                    gColD.blue,
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
                    gColD.green,
                    gColD.purple,
                    gColD.orange,
                    gColD.blue,
                    gColD.yellow,
                    gColD.purple,
                    C = cFAC.col[cFAC.index],
                    T = cFSpn.col[cFSpn.index]
                }
            end,
            modernD = function(gCol, cFAC, cFSpn)
                return {
                    { gCol.lBlue[1] - .2,  gCol.lBlue[2] - .2,  gCol.lBlue[3] - .2 },
                    { gCol.green[1] - .2,  gCol.green[2] - .2,  gCol.green[3] - .2 },
                    { gCol.red[1] - .2,    gCol.red[2] - .2,    gCol.red[3] - .2 },
                    { gCol.orange[1] - .2, gCol.orange[2] - .2, gCol.orange[3] - .2 },
                    { gCol.blue[1] - .2,   gCol.blue[2] - .2,   gCol.blue[3] - .2 },
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
