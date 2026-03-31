---@return table
local game = {
    isPaused = false,
    isPauseDelay = false,
    
    -- incomplete for now
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

    statsIndex = 0, -- 0, 1, 2

    -- for 40 lines (txt for now)
    is40LClr = false,
    target = 40,
}

return game