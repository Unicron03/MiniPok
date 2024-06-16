local Peaks = require("objects/peaks")
local Door = require("objects/door")
local Chest = require("objects/chest")
local Portal = require("objects/portal")
local PokBush = require("objects/pokBush")
local Workbench = require("objects/workbench")
local Trader = require("objects/trader")

local objects = {
    Peaks = Peaks,
    Door = Door,
    Chest = Chest,
    Portal = Portal,
    PokBush = PokBush,
    Workbench = Workbench,
    Trader = Trader
}

function objects.returnTable()
    local objectsTable = {}

    for _, object in pairs(objects) do
        if type(object) == "table" and object.returnTable then
            for _, instance in ipairs(object.returnTable()) do
                table.insert(objectsTable, instance)
            end
        end
    end

    return objectsTable
end

function objects.removeAll()
    for _, object in pairs(objects) do
        if type(object) == "table" and object.removeAll then
            object.removeAll()
        end
    end
end

function objects.loadAssets()
    for _, object in pairs(objects) do
        if type(object) == "table" and object.loadAssets then
            object.loadAssets()
        end
    end
end

function objects.updateAll(dt)
    for _, object in pairs(objects) do
        if type(object) == "table" and object.update then
            object.updateAll(dt)
        end
    end
end

function objects.drawAll()
    for _, object in pairs(objects) do
        if type(object) == "table" and object.draw then
            object.drawAll()
        end
    end
end

function objects.beginContactAll(a, b, collision)
    for _, object in pairs(objects) do
        if type(object) == "table" and object.beginContact then
            object.beginContact(a, b, collision)
        end
    end
end

function objects.endContactAll(a, b, collision)
    for _, object in pairs(objects) do
        if type(object) == "table" and object.endContact then
            object.endContact(a, b, collision)
        end
    end
end

return objects