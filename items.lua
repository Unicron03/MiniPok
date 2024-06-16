local Log = require("items/log")
local Stone = require("items/stone")
local Axe = require("items/axe")
local Hoe = require("items/hoe")
local Branch = require("items/branch")
local Water = require("items/water")
local FertilizedDirt = require("items/fertilizedDirt")
local Shovel = require("items/shovel")
local CornBag = require("items/cornBag")
local Corn = require("items/corn")
local CarrotBag = require("items/carrotBag")
local Carrot = require("items/carrot")
local StrawberryBag = require("items/strawberryBag")
local Strawberry = require("items/strawberry")
local Workbench = require("items/workbench")
local Pickaxe = require("items/pickaxe")
local Bucket = require("items/bucket")
local Orb = require("items/orb")
local Iron = require("items/iron")

local items = {
    Log = Log,
    Stone = Stone,
    Axe = Axe,
    Hoe = Hoe,
    Branch = Branch,
    Water = Water,
    FertilizedDirt = FertilizedDirt,
    Shovel = Shovel,
    CornBag = CornBag,
    Corn = Corn,
    CarrotBag = CarrotBag,
    Carrot = Carrot,
    StrawberryBag = StrawberryBag,
    Strawberry = Strawberry,
    Workbench = Workbench,
    Pickaxe = Pickaxe,
    Bucket = Bucket,
    Orb = Orb,
    Iron = Iron,
}

function items.updateAll(dt)
    for _, item in pairs(items) do
        if type(item) == "table" and item.update then
            item.updateAll(dt)
        end
    end
end

function items.drawAll()
    for _, item in pairs(items) do
        if type(item) == "table" and item.draw then
            item.drawAll()
        end
    end
end

function items.beginContactAll(a, b, collision)
    for _, item in pairs(items) do
        if type(item) == "table" and item.beginContact then
            item.beginContact(a, b, collision)
        end
    end
end

return items