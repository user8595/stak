---@return table
local game = {
    isPaused = false,
    isPauseDelay = false,

    isCountdown = true,
    cTimer = 0,
    -- countdown length
    cTarget = 3,
    countA = 1,

    --TODO: Use corutines for saving function?
    loadingTxt = "loading..",

    isQRestart = false,
    isFail = false,
    isHScore = false,
    isLoading = false,
    useHold = true,
    useSonicDrop = false,
    useMoveReset = true,
    showFailColors = false,
    isGravityInc = true,
    isInstantGrav = false,
    showGoalLines = true,
    noGrav = false,

    -- leave unchanged
    isScreenShake = false,
    sTimer = 0,
    sTLen = 0,

    -- shake intensity
    shakeInt = 2,
    prevShake = 0,

    statsIndex = 0, -- 0, 1, 2

    -- for 40 lines (txt for now)
    is40LClr = false,
    target = 40,
}

return game
