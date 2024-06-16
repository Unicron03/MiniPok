
local Stone = {img = love.graphics.newImage("assets/items/ressources/stone.png"), name = "Stone"}
Stone.__index = Stone

Stone.width = Stone.img:getWidth()
Stone.height = Stone.img:getHeight()

local FLOATING_AMPLITUDE = 5
local FLOATING_SPEED = 2.5

local ActiveStones = {}

function Stone.removeAll()
    for i,v in ipairs(ActiveStones) do
        v.physics.body:destroy()
    end

    ActiveStones = {}
end

function Stone:remove()
    for i, instance in ipairs(ActiveStones) do
        if instance == self then
            self.physics.body:destroy()
            table.remove(ActiveStones, i)
        end
    end
end

function Stone.new(x,y)
    instance = setmetatable({}, Stone)
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
    table.insert(ActiveStones, instance)
end

function Stone:update(dt)
    -- self:syncPhysics()
end

function Stone:syncPhysics()
    self.x, self.y = self.physics.body:getPosition()
end

function Stone:draw()
    local offsetY = FLOATING_AMPLITUDE * math.sin(love.timer.getTime() * FLOATING_SPEED)
    local drawY = self.y + offsetY

    love.graphics.draw(self.img, self.x, drawY, self.r, self.scale, self.scale, self.width / 2, self.height / 2)

    -- self:drawHitbox()
end

function Stone:drawHitbox()
    love.graphics.setColor(1, 0, 0)
    love.graphics.polygon("line", self.physics.fixture:getBody():getWorldPoints(self.physics.fixture:getShape():getPoints()))
    love.graphics.setColor(1, 1, 1)
end

function Stone.updateAll(dt)
    for i,instance in ipairs(ActiveStones) do
        instance:update(dt)
    end
end

function Stone.drawAll()
    for i,instance in ipairs(ActiveStones) do
        instance:draw()
    end
end

function Stone.beginContact(a, b, collision)
    for i,instance in ipairs(ActiveStones) do
        if a == instance.physics.fixture or b == instance.physics.fixture then
            if a == Player.physics.fixture or b == Player.physics.fixture then
                Inventory:giveToInventory(instance.name, instance, 1)
                instance:remove()
            end
        end
    end
end

return Stone