
local Pickaxe = {img = love.graphics.newImage("assets/items/tools/pickaxe.png"), name = "Pickaxe"}
Pickaxe.__index = Pickaxe

Pickaxe.width = Pickaxe.img:getWidth()
Pickaxe.height = Pickaxe.img:getHeight()

local FLOATING_AMPLITUDE = 5
local FLOATING_SPEED = 2.5

local ActivePickaxes = {}

function Pickaxe.removeAll()
    for i,v in ipairs(ActivePickaxes) do
        v.physics.body:destroy()
    end

    ActivePickaxes = {}
end

function Pickaxe:remove()
    for i, instance in ipairs(ActivePickaxes) do
        if instance == self then
            self.physics.body:destroy()
            table.remove(ActivePickaxes, i)
        end
    end
end

function Pickaxe.new(x, y)
    instance = setmetatable({}, Pickaxe)
    instance.x = x 
    instance.y = y
    instance.r = 0
    instance.scale = 2.5
    instance.itemType = ItemTypes.TOOL

    local Harvestable = require("harvestable")
    instance.harvestTable = {Harvestable.Rock}
    instance.durability = 25

    instance.physics = {}
    instance.physics.body = love.physics.newBody(World, instance.x, instance.y, "static")
    instance.physics.shape = love.physics.newRectangleShape(instance.width * instance.scale, instance.height * instance.scale)
    instance.physics.fixture = love.physics.newFixture(instance.physics.body, instance.physics.shape)
    instance.physics.fixture:setSensor(true)
    table.insert(ActivePickaxes, instance)
end

function Pickaxe:returnNbEntities()
    return #ActivePickaxes
end

function Pickaxe:update(dt)
    -- self:syncPhysics()
end

function Pickaxe:syncPhysics()
    self.x, self.y = self.physics.body:getPosition()
end

function Pickaxe:draw()
    local offsetY = FLOATING_AMPLITUDE * math.sin(love.timer.getTime() * FLOATING_SPEED)
    local drawY = self.y + offsetY

    love.graphics.draw(self.img, self.x, drawY, self.r, self.scale, self.scale, self.width / 2, self.height / 2)

    -- self:drawHitbox()
end

function Pickaxe:drawHitbox()
    love.graphics.setColor(1, 0, 0)
    love.graphics.polygon("line", self.physics.fixture:getBody():getWorldPoints(self.physics.fixture:getShape():getPoints()))
    love.graphics.setColor(1, 1, 1)
end

function Pickaxe.updateAll(dt)
    for i,instance in ipairs(ActivePickaxes) do
        instance:update(dt)
    end
end

function Pickaxe.drawAll()
    for i,instance in ipairs(ActivePickaxes) do
        instance:draw()
    end
end

function Pickaxe.beginContact(a, b, collision)
    for i,instance in ipairs(ActivePickaxes) do
        if a == instance.physics.fixture or b == instance.physics.fixture then
            if a == Player.physics.fixture or b == Player.physics.fixture then
                Inventory:giveToInventory(instance.name, instance)
                instance:remove()
            end
        end
    end
end

return Pickaxe