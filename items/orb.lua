
local Orb = {img = love.graphics.newImage("assets/items/ressources/orb.png"), name = "Orb"}
Orb.__index = Orb

local Particles = require("particles")

Orb.width = Orb.img:getWidth()
Orb.height = Orb.img:getHeight()

local FLOATING_AMPLITUDE = 5
local FLOATING_SPEED = 2.5

local ActiveOrbs = {}

function Orb.removeAll()
    for i,v in ipairs(ActiveOrbs) do
        v.physics.body:destroy()
    end

    ActiveOrbs = {}
end

function Orb:remove()
    for i, instance in ipairs(ActiveOrbs) do
        if instance == self then
            self.physics.body:destroy()
            table.remove(ActiveOrbs, i)
        end
    end
end

function Orb.new(x,y)
    instance = setmetatable({}, Orb)
    instance.x = x 
    instance.y = y
    instance.r = 0
    instance.scale = 2
    instance.itemType = ItemTypes.CONSUMABLE

    instance.particleSystem = Particles:new(x, y)

    instance.physics = {}
    instance.physics.body = love.physics.newBody(World, instance.x, instance.y, "static")
    instance.physics.shape = love.physics.newRectangleShape(instance.width * instance.scale, instance.height * instance.scale)
    instance.physics.fixture = love.physics.newFixture(instance.physics.body, instance.physics.shape)
    instance.physics.fixture:setSensor(true)
    table.insert(ActiveOrbs, instance)
end

function Orb:update(dt)
    Particles:update(dt, self.particleSystem)
end

function Orb:syncPhysics()
    self.x, self.y = self.physics.body:getPosition()
end

function Orb:draw()
    local offsetY = FLOATING_AMPLITUDE * math.sin(love.timer.getTime() * FLOATING_SPEED)
    local drawY = self.y + offsetY

    Particles:draw(self.particleSystem)
    love.graphics.draw(self.img, self.x, drawY, self.r, self.scale, self.scale, self.width / 2, self.height / 2)
    -- self:drawHitbox()
end

function Orb:drawHitbox()
    love.graphics.setColor(1, 0, 0)
    love.graphics.polygon("line", self.physics.fixture:getBody():getWorldPoints(self.physics.fixture:getShape():getPoints()))
    love.graphics.setColor(1, 1, 1)
end

function Orb.updateAll(dt)
    for i,instance in ipairs(ActiveOrbs) do
        instance:update(dt)
    end
end

function Orb.drawAll()
    for i,instance in ipairs(ActiveOrbs) do
        instance:draw()
    end
end

function Orb.beginContact(a, b, collision)
    for i,instance in ipairs(ActiveOrbs) do
        if a == instance.physics.fixture or b == instance.physics.fixture then
            if a == Player.physics.fixture or b == Player.physics.fixture then
                Inventory:giveToInventory(instance.name, instance, 1)
                instance:remove()
            end
        end
    end
end

return Orb