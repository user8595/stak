if pcall(require, "table.clear") then
    return require "table.clear"
else
    print("-------### using fallback for tClear ###-------")
    return function(tab)
        for k, _ in pairs(tab) do
            tab[k] = nil
        end
    end
end