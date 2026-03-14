local lf = love.filesystem
local json = require "libs.json"

local function readFile(file, data)
    if type(file) == "string" then
        if lf.read(file) == "" or lf.read(file) == nil then
            lf.write(file, json.encode(data))
        end
        return json.decode(lf.read(file))
    else
        error("save file name in read must be string", 1)
    end
end

local function writeFile(file, data)
    if type(file) == "string" and type(data) ~= "nil" then
        lf.write(file, json.encode(data))
    else
        if type(file) ~= "string" then
            error("save file name in write must be string", 1)
        end
        if type(data) == "nil" then
            error("save data in write cannot be empty/nil", 1)
        end
    end
end

local save = {
    writeScores = function(data)
        print("-- written scores save file --")
        return writeFile("records.json", data)
    end,
    readScores = function(data)
        return readFile("records.json", data)
    end
}

return save
