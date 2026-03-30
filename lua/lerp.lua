-- for animation, where a = initial value, b = target value, t = time
local lerp = {
    --- Linear interpolation
    ---@param a number
    ---@param b number
    ---@param t number
    ---@return number
    linear = function(a, b, t)
        return a + t * (b - a)
    end,
    --- Quartic ease-out interpolation
    ---@param a number
    ---@param b number
    ---@param t number
    ---@return number
    easeOutQuart = function(a, b, t)
        return a + 1 - math.pow(1 - t, 4) * (b - a)
    end,
    ---Cubic ease-in interpolation
    ---@param a number
    ---@param b number
    ---@param t number
    ---@return number
    easeInCubic = function(a, b, t)
        return a + (t ^ 3) * (b - a)
    end,
    --- Cubic ease-out interpolation
    ---@param a number
    ---@param b number
    ---@param t number
    ---@return number
    easeOutCubic = function(a, b, t)
        return a + 1 - math.pow(1 - t, 3) * (b - a)
    end,
    --- Quadratic ease-out interpolation
    ---@param a number
    ---@param b number
    ---@param t number
    ---@return number
    easeOutQuad = function(a, b, t)
        return a + (1 - (1 - t) * (1 - t)) * (b - a)
    end
}

return lerp
