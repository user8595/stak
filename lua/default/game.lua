---@return table
local game = {
    isPaused = false,
    isPauseDelay = false,
    --TODO: Implement game countdown system
    isCountdown = false,
    isFail = false,
    isHScore = false,
    isLoading = false,
    useHold = true,
    useSonicDrop = false,
    useMoveReset = true,
    showFailColors = false,
    isGravityInc = true,
    isInstantGrav = false,
    noGrav = false,

    statsIndex = 0, -- 0, 1, 2

    -- for 40 lines (txt for now)
    --TODO: Implement game end lines indicator
    is40LClr = false,
}

return game