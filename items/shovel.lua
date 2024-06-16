
local Shovel = {img = love.graphics.newImage("assets/items/tools/shovel.png"), name = "Shovel"}
Shovel.__index = Shovel

Shovel.width = Shovel.img:getWidth()
Shovel.height = Shovel.img:getHeight()

local FLOATING_AMPLITUDE = 5
local FLOATING_SPEED = 2.5

local ActiveShovels = {}

function Shovel.removeAll()
    for i,v in ipairs(ActiveShovels) do
        v.physics.body:destroy()
    end

    ActiveShovels = {}
end

function Shovel:remove()
    for i, instance in ipairs(ActiveShovels) do
        if instance == self then
            self.physics.body:destroy()
            table.remove(ActiveShovels, i)
        end
    end
end

function Shovel.new(x, y)
    instance = setmetatable({}, Shovel)
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
    table.insert(ActiveShovels, instance)
end

function Shovel:returnNbEntities()
    return #ActiveShovels
end

function Shovel:update(dt)
    -- self:syncPhysics()
end

function Shovel:syncPhysics()
    self.x, self.y = self.physics.body:getPosition()
end

function Shovel:draw()
    local offsetY = FLOATING_AMPLITUDE * math.sin(love.timer.getTime() * FLOATING_SPEED)
    local drawY = self.y + offsetY

    love.graphics.draw(self.img, self.x, drawY, self.r, self.scale, self.scale, self.width / 2, self.height / 2)

    -- self:drawHitbox()
end

function Shovel:drawHitbox()
    love.graphics.setColor(1, 0, 0)
    love.graphics.polygon("line", self.physics.fixture:getBody():getWorldPoints(self.physics.fixture:getShape():getPoints()))
    love.graphics.setColor(1, 1, 1)
end

function Shovel.updateAll(dt)
    for i,instance in ipairs(ActiveShovels) do
        instance:update(dt)
    end
end

function Shovel.drawAll()
    for i,instance in ipairs(ActiveShovels) do
        instance:draw()
    end
end

function Shovel.beginContact(a, b, collision)
    for i,instance in ipairs(ActiveShovels) do
        if a == instance.physics.fixture or b == instance.physics.fixture then
            if a == Player.physics.fixture or b == Player.physics.fixture then
                Inventory:giveToInventory(instance.name, instance)
                instance:remove()
            end
        end
    end
end

return Shovel