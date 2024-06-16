
local Workbench = {img = love.graphics.newImage("assets/harvestables/workbench.png"), name = "Workbench"}
Workbench.__index = Workbench

Workbench.width = Workbench.img:getWidth()
Workbench.height = Workbench.img:getHeight()
Workbench.scale = 0.75

local FLOATING_AMPLITUDE = 5
local FLOATING_SPEED = 2.5

local ActiveWorkbenchs = {}

function Workbench.removeAll()
    for i,v in ipairs(ActiveWorkbenchs) do
        v.physics.body:destroy()
    end

    ActiveWorkbenchs = {}
end

function Workbench:remove()
    for i, instance in ipairs(ActiveWorkbenchs) do
        if instance == self then
            self.physics.body:destroy()
            table.remove(ActiveWorkbenchs, i)
        end
    end
end

function Workbench.new(x, y)
    instance = setmetatable({}, Workbench)
    instance.x = x 
    instance.y = y
    instance.r = 0
    instance.itemType = ItemTypes.PLOTTABLE

    local Objects = require("objects")
    instance.plot = Objects.Workbench

    instance.physics = {}
    instance.physics.body = love.physics.newBody(World, instance.x, instance.y, "static")
    instance.physics.shape = love.physics.newRectangleShape(instance.width * instance.scale, instance.height * instance.scale)
    instance.physics.fixture = love.physics.newFixture(instance.physics.body, instance.physics.shape)
    instance.physics.fixture:setSensor(true)
    table.insert(ActiveWorkbenchs, instance)
end

function Workbench:update(dt)
    -- self:syncPhysics()
end

function Workbench:syncPhysics()
    self.x, self.y = self.physics.body:getPosition()
end

function Workbench:draw()
    local offsetY = FLOATING_AMPLITUDE * math.sin(love.timer.getTime() * FLOATING_SPEED)
    local drawY = self.y + offsetY

    love.graphics.draw(self.img, self.x, drawY, self.r, self.scale, self.scale, self.width / 2, self.height / 2)

    -- self:drawHitbox()
end

function Workbench:drawHitbox()
    love.graphics.setColor(1, 0, 0)
    love.graphics.polygon("line", self.physics.fixture:getBody():getWorldPoints(self.physics.fixture:getShape():getPoints()))
    love.graphics.setColor(1, 1, 1)
end

function Workbench.updateAll(dt)
    for i,instance in ipairs(ActiveWorkbenchs) do
        instance:update(dt)
    end
end

function Workbench.drawAll()
    for i,instance in ipairs(ActiveWorkbenchs) do
        instance:draw()
    end
end

function Workbench.beginContact(a, b, collision)
    for i,instance in ipairs(ActiveWorkbenchs) do
        if a == instance.physics.fixture or b == instance.physics.fixture then
            if a == Player.physics.fixture or b == Player.physics.fixture then
                Inventory:giveToInventory(instance.name, instance)
                instance:remove()
            end
        end
    end
end

return Workbench