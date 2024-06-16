local Tree = require("harvestables/tree")
local Rock = require("harvestables/rock")
local Bush = require("harvestables/bush")
local Water = require("harvestables/water")
local Dirt = require("harvestables/dirt")
local FertilizedDirt = require("harvestables/fertilizedDirt")

local harvestables = {
    Tree = Tree,
    Rock = Rock,
    Bush = Bush,
    Water = Water,
    Dirt = Dirt,
    FertilizedDirt = FertilizedDirt,
}

function harvestables.returnTable()
    local harvestablesTable = {}

    for _, harvestable in pairs(harvestables) do
        if type(harvestable) == "table" and harvestable.returnTable then
            for _, instance in ipairs(harvestable.returnTable()) do
                table.insert(harvestablesTable, instance)
            end
        end
    end

    return harvestablesTable
end

function harvestables.removeAll()
    for _, harvestable in pairs(harvestables) do
        if type(harvestable) == "table" and harvestable.removeAll then
            harvestable.removeAll()
        end
    end
end

function harvestables.loadAssets()
    for _, harvestable in pairs(harvestables) do
        if type(harvestable) == "table" and harvestable.loadAssets then
            harvestable.loadAssets()
        end
    end
end

function harvestables.updateAll(dt)
    for _, harvestable in pairs(harvestables) do
        if type(harvestable) == "table" and harvestable.update then
            harvestable.updateAll(dt)
        end
    end
end

function harvestables.drawAll()
    for _, harvestable in pairs(harvestables) do
        if type(harvestable) == "table" and harvestable.draw then
            harvestable.drawAll()
        end
    end
end

function harvestables.beginContactAll(a, b, collision)
    for _, harvestable in pairs(harvestables) do
        if type(harvestable) == "table" and harvestable.beginContact then
            harvestable.beginContact(a, b, collision)
        end
    end
end

function harvestables.endContactAll(a, b, collision)
    for _, harvestable in pairs(harvestables) do
        if type(harvestable) == "table" and harvestable.endContact then
            harvestable.endContact(a, b, collision)
        end
    end
end

return harvestables