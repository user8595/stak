-- for animation, where a = initial value, b = target value, t = time
local lerp = {
    easeOutCubic = function(a, b, t)
        return a + 1 - math.pow(1 - t, 3) * (b - a)
    end,
    easeOutQuart = function(a, b, t)
        return a + 1 - math.pow(1 - t, 4) * (b - a)
    end
}

return lerp
