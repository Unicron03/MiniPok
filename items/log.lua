
local Log = {img = love.graphics.newImage("assets/items/ressources/log.png"), name = "Log"}
Log.__index = Log

Log.width = Log.img:getWidth()
Log.height = Log.img:getHeight()

local FLOATING_AMPLITUDE = 5
local FLOATING_SPEED = 2.5

local ActiveLogs = {}

function Log.removeAll()
    for i,v in ipairs(ActiveLogs) do
        v.physics.body:destroy()
    end

    ActiveLogs = {}
end

function Log:remove()
    for i, instance in ipairs(ActiveLogs) do
        if instance == self then
            self.physics.body:destroy()
            table.remove(ActiveLogs, i)
        end
    end
end

function Log.new(x, y)
    instance = setmetatable({}, Log)
    instance.x = x 
    instance.y = y
    instance.r = 0
    instance.scale = 2
    instance.itemType = ItemTypes.RESSOURCE

    instance.physics = {}
    instance.physics.body = love.physics.newBody(World, instance.x, instance.y, "static")
    instance.physics.shape = love.physics.newRectangleShape(instance.width * instance.scale, instance.height * instance.scale)
    instance.physics.fixture = love.physics.newFixture(instance.physics.body, instance.physics.shape)
    instance.physics.fixture:setSensor(true)
    table.insert(ActiveLogs, instance)
end

function Log:returnNbEntities()
    return #ActiveLogs
end

function Log:update(dt)
    -- self:syncPhysics()
end

function Log:syncPhysics()
    self.x, self.y = self.physics.body:getPosition()
end

function Log:draw()
    local offsetY = FLOATING_AMPLITUDE * math.sin(love.timer.getTime() * FLOATING_SPEED)
    local drawY = self.y + offsetY

    love.graphics.draw(self.img, self.x, drawY, self.r, self.scale, self.scale, self.width / 2, self.height / 2)

    -- self:drawHitbox()
end

function Log:drawHitbox()
    love.graphics.setColor(1, 0, 0)
    love.graphics.polygon("line", self.physics.fixture:getBody():getWorldPoints(self.physics.fixture:getShape():getPoints()))
    love.graphics.setColor(1, 1, 1)
end

function Log.updateAll(dt)
    for i,instance in ipairs(ActiveLogs) do
        instance:update(dt)
    end
end

function Log.drawAll()
    for i,instance in ipairs(ActiveLogs) do
        instance:draw()
    end
end

function Log.beginContact(a, b, collision)
    for i,instance in ipairs(ActiveLogs) do
        if a == instance.physics.fixture or b == instance.physics.fixture then
            if a == Player.physics.fixture or b == Player.physics.fixture then
                Inventory:giveToInventory(instance.name, instance)
                instance:remove()
            end
        end
    end
end

return Log