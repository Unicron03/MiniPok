
local FertilizedDirt = {img = love.graphics.newImage("assets/items/ressources/fertilizedDirt.png"), name = "Fertilized Dirt"}
FertilizedDirt.__index = FertilizedDirt

FertilizedDirt.width = FertilizedDirt.img:getWidth()
FertilizedDirt.height = FertilizedDirt.img:getHeight()
FertilizedDirt.scale = 2.5

local FLOATING_AMPLITUDE = 5
local FLOATING_SPEED = 2.5

local ActiveFertilizedDirts = {}

function FertilizedDirt.removeAll()
    for i,v in ipairs(ActiveFertilizedDirts) do
        v.physics.body:destroy()
    end

    ActiveFertilizedDirts = {}
end

function FertilizedDirt:remove()
    for i, instance in ipairs(ActiveFertilizedDirts) do
        if instance == self then
            self.physics.body:destroy()
            table.remove(ActiveFertilizedDirts, i)
        end
    end
end

function FertilizedDirt.new(x,y)
    instance = setmetatable({}, FertilizedDirt)
    instance.x = x 
    instance.y = y
    instance.r = 0
    instance.itemType = ItemTypes.PLOTTABLE

    local Harvestable = require("harvestable")
    instance.plot = Harvestable.FertilizedDirt

    instance.physics = {}
    instance.physics.body = love.physics.newBody(World, instance.x, instance.y, "static")
    instance.physics.shape = love.physics.newRectangleShape(instance.width * instance.scale, instance.height * instance.scale)
    instance.physics.fixture = love.physics.newFixture(instance.physics.body, instance.physics.shape)
    instance.physics.fixture:setSensor(true)
    table.insert(ActiveFertilizedDirts, instance)
end

function FertilizedDirt:update(dt)
    -- self:syncPhysics()
end

function FertilizedDirt:syncPhysics()
    self.x, self.y = self.physics.body:getPosition()
end

function FertilizedDirt:draw()
    local offsetY = FLOATING_AMPLITUDE * math.sin(love.timer.getTime() * FLOATING_SPEED)
    local drawY = self.y + offsetY

    love.graphics.draw(self.img, self.x, drawY, self.r, self.scale, self.scale, self.width / 2, self.height / 2)

    -- self:drawHitbox()
end

function FertilizedDirt:drawHitbox()
    love.graphics.setColor(1, 0, 0)
    love.graphics.polygon("line", self.physics.fixture:getBody():getWorldPoints(self.physics.fixture:getShape():getPoints()))
    love.graphics.setColor(1, 1, 1)
end

function FertilizedDirt.updateAll(dt)
    for i,instance in ipairs(ActiveFertilizedDirts) do
        instance:update(dt)
    end
end

function FertilizedDirt.drawAll()
    for i,instance in ipairs(ActiveFertilizedDirts) do
        instance:draw()
    end
end

function FertilizedDirt.beginContact(a, b, collision)
    for i,instance in ipairs(ActiveFertilizedDirts) do
        if a == instance.physics.fixture or b == instance.physics.fixture then
            if a == Player.physics.fixture or b == Player.physics.fixture then
                Inventory:giveToInventory(instance.name, instance)
                instance:remove()
            end
        end
    end
end

return FertilizedDirt