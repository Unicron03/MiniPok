
local Chest = {}
Chest.__index = Chest
local ActiveChests = {}

local Particles = require("particles")

local lootTable = {
    basic = {
        [1] = {
            item = Items.Log,
            maxQuantity = 16,
        },
        [2] = {
            item = Items.Stone,
            maxQuantity = 16,
        },
        [3] = {
            item = Items.Water,
            maxQuantity = 16,
        },
        [4] = {
            item = Items.FertilizedDirt,
            maxQuantity = 12,
        },
        [5] = {
            item = Items.CarrotBag,
            maxQuantity = 5,
        },
        [6] = {
            item = Items.StrawberryBag,
            maxQuantity = 3,
        },
        [7] = {
            item = Items.CornBag,
            maxQuantity = 7,
        },
        [8] = {
            item = Items.Carrot,
            maxQuantity = 3,
        },
        [9] = {
            item = Items.Strawberry,
            maxQuantity = 2,
        },
        [10] = {
            item = Items.Corn,
            maxQuantity = 5,
        },
    },
    big = {
        [1] = {
            item = Items.Hoe,
            maxQuantity = 1,
        },
        [2] = {
            item = Items.Shovel,
            maxQuantity = 1,
        },
        [3] = {
            item = Items.Pickaxe,
            maxQuantity = 1,
        },
        [4] = {
            item = Items.Workbench,
            maxQuantity = 1,
        },
        [5] = {
            item = Items.Orb,
            maxQuantity = 1
        }
    }
}

local objectCreationQueue = {}

function Chest.removeAll()
    for i,v in ipairs(ActiveChests) do
        v.physics.body:destroy()
    end

    ActiveChests = {}
end

function Chest.returnTable()
    return ActiveChests 
end

function Chest:remove()
    for i, instance in ipairs(ActiveChests) do
        if instance == self then
            self.physics.body:destroy()
            table.remove(ActiveChests, i)

            if instance.linkedChest ~= nil then
                instance.linkedChest:remove()
            end
        end
    end
end

function Chest.new(x, y, id, obj, typeChest)
    instance = setmetatable({}, Chest)
    instance.id = id
    instance.type = typeChest
    instance.linkedChestId = (obj ~= nil) and (obj) or (nil)
    instance.linkedChest = nil

    instance.img = love.graphics.newImage("assets/tiles/objects/chest.png")
    instance.width = instance.img:getWidth()
    instance.height = instance.img:getHeight()

    instance.x = x - instance.width * 0.5
    instance.y = y - instance.height * 0.5

    instance.physics = {}
    instance.physics.body = love.physics.newBody(World, instance.x + instance.width * 0.5, instance.y + instance.height * 0.5, "static")
    instance.physics.shape = love.physics.newRectangleShape(instance.width, instance.height)
    instance.physics.fixture = love.physics.newFixture(instance.physics.body, instance.physics.shape)

    if instance.type == "big" then
        particleSystem = Particles:new(x, y)
    end

    table.insert(ActiveChests, instance)

    return instance
end

function Chest:returnNbEntities()
    return #ActiveChests
end

function Chest:giveLoot()
    local rdIndex = math.random(1, #lootTable[self.type])
    local rdQuantity = math.random(math.ceil(lootTable[self.type][rdIndex].maxQuantity * 0.5), lootTable[self.type][rdIndex].maxQuantity)

    for i=1, rdQuantity do
        table.insert(objectCreationQueue, lootTable[self.type][rdIndex].item)
    end
end

function Chest:update(dt)
    if self.type == "big" then
        Particles:update(dt, particleSystem)
    end
end

function Chest:draw()
    self:drawParticles()

    if self.img ~= nil then
        love.graphics.draw(self.img, self.x, self.y)
        love.graphics.setColor(1, 1, 1)
    end

    -- self:drawHitbox()
end

function Chest:drawHitbox()
    love.graphics.setColor(1, 0, 0)
    love.graphics.polygon("line", self.physics.fixture:getBody():getWorldPoints(self.physics.fixture:getShape():getPoints()))
    love.graphics.setColor(1, 1, 1)
end

function Chest:drawParticles()
    if self.type == "big" then
        Particles:draw(particleSystem)
        love.graphics.setColor(Player.color.shiny.r, Player.color.shiny.g, Player.color.shiny.b)
    end
end

function Chest.updateAll(dt)
    for i,instance in ipairs(ActiveChests) do
        instance:update(dt)
    end

    for i, item in ipairs(objectCreationQueue) do
        item.new(Player.x, Player.y)
        table.remove(objectCreationQueue, i)
    end
end

function Chest.drawAll()
    for i,instance in ipairs(ActiveChests) do
        instance:draw()
    end
end

function Chest.beginContact(a, b, collision)
    for i,instance in ipairs(ActiveChests) do
        if a == instance.physics.fixture or b == instance.physics.fixture then
            if a == Player.physics.fixture or b == Player.physics.fixture then
                instance:giveLoot()
                instance:remove()
            end
        end
    end
end

return Chest