local game = {
    isPaused = false,
    isPauseDelay = false,
    --TODO: Implement game countdown system
    isCountdown = false,
    isFail = false,
    useHold = true,
    useSonicDrop = false,
    useMoveReset = true,
    showFailColors = false,
    isGravityInc = true,

    -- for 40 lines (txt for now)
    --TODO: Implement game end lines indicator
    is40LClr = false,
}

return game