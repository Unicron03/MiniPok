
local Water = {img = love.graphics.newImage("assets/items/ressources/water.png"), name = "Water"}
Water.__index = Water

Water.width = Water.img:getWidth()
Water.height = Water.img:getHeight()

local FLOATING_AMPLITUDE = 5
local FLOATING_SPEED = 2.5

local ActiveWaters = {}

function Water.removeAll()
    for i,v in ipairs(ActiveWaters) do
        v.physics.body:destroy()
    end

    ActiveWaters = {}
end

function Water:remove()
    for i, instance in ipairs(ActiveWaters) do
        if instance == self then
            self.physics.body:destroy()
            table.remove(ActiveWaters, i)
        end
    end
end

function Water.new(x,y)
    instance = setmetatable({}, Water)
    instance.x = x 
    instance.y = y
    instance.r = 0
    instance.scale = 2
    instance.itemType = ItemTypes.CONSUMABLE
    
    instance.givable = {
        type = "thirst",
        value = 15
    }

    instance.physics = {}
    instance.physics.body = love.physics.newBody(World, instance.x, instance.y, "static")
    instance.physics.shape = love.physics.newRectangleShape(instance.width * instance.scale, instance.height * instance.scale)
    instance.physics.fixture = love.physics.newFixture(instance.physics.body, instance.physics.shape)
    instance.physics.fixture:setSensor(true)
    table.insert(ActiveWaters, instance)
end

function Water:update(dt)
    -- self:syncPhysics()
end

function Water:syncPhysics()
    self.x, self.y = self.physics.body:getPosition()
end

function Water:draw()
    local offsetY = FLOATING_AMPLITUDE * math.sin(love.timer.getTime() * FLOATING_SPEED)
    local drawY = self.y + offsetY

    love.graphics.draw(self.img, self.x, drawY, self.r, self.scale, self.scale, self.width / 2, self.height / 2)

    -- self:drawHitbox()
end

function Water:drawHitbox()
    love.graphics.setColor(1, 0, 0)
    love.graphics.polygon("line", self.physics.fixture:getBody():getWorldPoints(self.physics.fixture:getShape():getPoints()))
    love.graphics.setColor(1, 1, 1)
end

function Water.updateAll(dt)
    for i,instance in ipairs(ActiveWaters) do
        instance:update(dt)
    end
end

function Water.drawAll()
    for i,instance in ipairs(ActiveWaters) do
        instance:draw()
    end
end

function Water.beginContact(a, b, collision)
    for i,instance in ipairs(ActiveWaters) do
        if a == instance.physics.fixture or b == instance.physics.fixture then
            if a == Player.physics.fixture or b == Player.physics.fixture then
                Inventory:giveToInventory(instance.name, instance)
                instance:remove()
            end
        end
    end
end

return Water