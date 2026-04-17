---@return function
if pcall(require, "table.clear") then
    return require "table.clear"
else
    print("-------### using fallback for tClear ###-------")
    ---@param tab table
    return function(tab)
        for k, _ in pairs(tab) do
            tab[k] = nil
        end
    end
end