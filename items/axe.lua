
local Axe = {img = love.graphics.newImage("assets/items/tools/axe.png"), name = "Axe"}
Axe.__index = Axe

Axe.width = Axe.img:getWidth()
Axe.height = Axe.img:getHeight()

local FLOATING_AMPLITUDE = 5
local FLOATING_SPEED = 2.5

local ActiveAxes = {}

function Axe.removeAll()
    for i,v in ipairs(ActiveAxes) do
        v.physics.body:destroy()
    end

    ActiveAxes = {}
end

function Axe:remove()
    for i, instance in ipairs(ActiveAxes) do
        if instance == self then
            self.physics.body:destroy()
            table.remove(ActiveAxes, i)
        end
    end
end

function Axe.new(x, y)
    instance = setmetatable({}, Axe)
    instance.x = x 
    instance.y = y
    instance.r = 0
    instance.scale = 2.5
    instance.itemType = ItemTypes.TOOL

    local Harvestable = require("harvestable")
    instance.harvestTable = {Harvestable.Tree}
    instance.durability = 25

    instance.physics = {}
    instance.physics.body = love.physics.newBody(World, instance.x, instance.y, "static")
    instance.physics.shape = love.physics.newRectangleShape(instance.width * instance.scale, instance.height * instance.scale)
    instance.physics.fixture = love.physics.newFixture(instance.physics.body, instance.physics.shape)
    instance.physics.fixture:setSensor(true)
    table.insert(ActiveAxes, instance)
end

function Axe:returnNbEntities()
    return #ActiveAxes
end

function Axe:update(dt)
    -- self:syncPhysics()
end

function Axe:syncPhysics()
    self.x, self.y = self.physics.body:getPosition()
end

function Axe:draw()
    local offsetY = FLOATING_AMPLITUDE * math.sin(love.timer.getTime() * FLOATING_SPEED)
    local drawY = self.y + offsetY

    love.graphics.draw(self.img, self.x, drawY, self.r, self.scale, self.scale, self.width / 2, self.height / 2)

    -- self:drawHitbox()
end

function Axe:drawHitbox()
    love.graphics.setColor(1, 0, 0)
    love.graphics.polygon("line", self.physics.fixture:getBody():getWorldPoints(self.physics.fixture:getShape():getPoints()))
    love.graphics.setColor(1, 1, 1)
end

function Axe.updateAll(dt)
    for i,instance in ipairs(ActiveAxes) do
        instance:update(dt)
    end
end

function Axe.drawAll()
    for i,instance in ipairs(ActiveAxes) do
        instance:draw()
    end
end

function Axe.beginContact(a, b, collision)
    for i,instance in ipairs(ActiveAxes) do
        if a == instance.physics.fixture or b == instance.physics.fixture then
            if a == Player.physics.fixture or b == Player.physics.fixture then
                Inventory:giveToInventory(instance.name, instance)
                instance:remove()
            end
        end
    end
end

return Axe