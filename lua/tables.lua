-- tablevalues
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
}

return tables
