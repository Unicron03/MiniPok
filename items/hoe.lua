
local Hoe = {img = love.graphics.newImage("assets/items/tools/hoe.png"), name = "Hoe"}
Hoe.__index = Hoe

Hoe.width = Hoe.img:getWidth()
Hoe.height = Hoe.img:getHeight()

local FLOATING_AMPLITUDE = 5
local FLOATING_SPEED = 2.5

local ActiveHoes = {}

function Hoe.removeAll()
    for i,v in ipairs(ActiveHoes) do
        v.physics.body:destroy()
    end

    ActiveHoes = {}
end

function Hoe:remove()
    for i, instance in ipairs(ActiveHoes) do
        if instance == self then
            self.physics.body:destroy()
            table.remove(ActiveHoes, i)
        end
    end
end

function Hoe.new(x, y)
    instance = setmetatable({}, Hoe)
    instance.x = x 
    instance.y = y
    instance.r = 0
    instance.scale = 2.5
    instance.itemType = ItemTypes.TOOL

    local Harvestable = require("harvestable")
    instance.harvestTable = {Harvestable.Dirt}
    instance.durability = 20

    instance.physics = {}
    instance.physics.body = love.physics.newBody(World, instance.x, instance.y, "static")
    instance.physics.shape = love.physics.newRectangleShape(instance.width * instance.scale, instance.height * instance.scale)
    instance.physics.fixture = love.physics.newFixture(instance.physics.body, instance.physics.shape)
    instance.physics.fixture:setSensor(true)
    table.insert(ActiveHoes, instance)
end

function Hoe:returnNbEntities()
    return #ActiveHoes
end

function Hoe:update(dt)
    -- self:syncPhysics()
end

function Hoe:syncPhysics()
    self.x, self.y = self.physics.body:getPosition()
end

function Hoe:draw()
    local offsetY = FLOATING_AMPLITUDE * math.sin(love.timer.getTime() * FLOATING_SPEED)
    local drawY = self.y + offsetY

    love.graphics.draw(self.img, self.x, drawY, self.r, self.scale, self.scale, self.width / 2, self.height / 2)

    -- self:drawHitbox()
end

function Hoe:drawHitbox()
    love.graphics.setColor(1, 0, 0)
    love.graphics.polygon("line", self.physics.fixture:getBody():getWorldPoints(self.physics.fixture:getShape():getPoints()))
    love.graphics.setColor(1, 1, 1)
end

function Hoe.updateAll(dt)
    for i,instance in ipairs(ActiveHoes) do
        instance:update(dt)
    end
end

function Hoe.drawAll()
    for i,instance in ipairs(ActiveHoes) do
        instance:draw()
    end
end

function Hoe.beginContact(a, b, collision)
    for i,instance in ipairs(ActiveHoes) do
        if a == instance.physics.fixture or b == instance.physics.fixture then
            if a == Player.physics.fixture or b == Player.physics.fixture then
                Inventory:giveToInventory(instance.name, instance)
                instance:remove()
            end
        end
    end
end

return Hoe