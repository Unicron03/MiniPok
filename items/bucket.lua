
local Bucket = {img = love.graphics.newImage("assets/items/tools/bucket.png"), name = "Bucket"}
Bucket.__index = Bucket

Bucket.width = Bucket.img:getWidth()
Bucket.height = Bucket.img:getHeight()

local FLOATING_AMPLITUDE = 5
local FLOATING_SPEED = 2.5

local ActiveBuckets = {}

function Bucket.removeAll()
    for i,v in ipairs(ActiveBuckets) do
        v.physics.body:destroy()
    end

    ActiveBuckets = {}
end

function Bucket:remove()
    for i, instance in ipairs(ActiveBuckets) do
        if instance == self then
            self.physics.body:destroy()
            table.remove(ActiveBuckets, i)
        end
    end
end

function Bucket.new(x, y)
    instance = setmetatable({}, Bucket)
    instance.x = x 
    instance.y = y
    instance.r = 0
    instance.scale = 1.7
    instance.itemType = ItemTypes.TOOL

    local Harvestable = require("harvestable")
    instance.harvestTable = {Harvestable.Water}
    instance.durability = 25

    instance.physics = {}
    instance.physics.body = love.physics.newBody(World, instance.x, instance.y, "static")
    instance.physics.shape = love.physics.newRectangleShape(instance.width * instance.scale, instance.height * instance.scale)
    instance.physics.fixture = love.physics.newFixture(instance.physics.body, instance.physics.shape)
    instance.physics.fixture:setSensor(true)
    table.insert(ActiveBuckets, instance)
end

function Bucket:returnNbEntities()
    return #ActiveBuckets
end

function Bucket:update(dt)
    -- self:syncPhysics()
end

function Bucket:syncPhysics()
    self.x, self.y = self.physics.body:getPosition()
end

function Bucket:draw()
    local offsetY = FLOATING_AMPLITUDE * math.sin(love.timer.getTime() * FLOATING_SPEED)
    local drawY = self.y + offsetY

    love.graphics.draw(self.img, self.x, drawY, self.r, self.scale, self.scale, self.width / 2, self.height / 2)

    -- self:drawHitbox()
end

function Bucket:drawHitbox()
    love.graphics.setColor(1, 0, 0)
    love.graphics.polygon("line", self.physics.fixture:getBody():getWorldPoints(self.physics.fixture:getShape():getPoints()))
    love.graphics.setColor(1, 1, 1)
end

function Bucket.updateAll(dt)
    for i,instance in ipairs(ActiveBuckets) do
        instance:update(dt)
    end
end

function Bucket.drawAll()
    for i,instance in ipairs(ActiveBuckets) do
        instance:draw()
    end
end

function Bucket.beginContact(a, b, collision)
    for i,instance in ipairs(ActiveBuckets) do
        if a == instance.physics.fixture or b == instance.physics.fixture then
            if a == Player.physics.fixture or b == Player.physics.fixture then
                Inventory:giveToInventory(instance.name, instance)
                instance:remove()
            end
        end
    end
end

return Bucket