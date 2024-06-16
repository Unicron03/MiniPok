
local Corn = {img = love.graphics.newImage("assets/items/ressources/corn.png"), name = "Corn"}
Corn.__index = Corn

Corn.width = Corn.img:getWidth()
Corn.height = Corn.img:getHeight()

local FLOATING_AMPLITUDE = 5
local FLOATING_SPEED = 2.5

local ActiveCorns = {}

function Corn.removeAll()
    for i,v in ipairs(ActiveCorns) do
        v.physics.body:destroy()
    end

    ActiveCorns = {}
end

function Corn:remove()
    for i, instance in ipairs(ActiveCorns) do
        if instance == self then
            self.physics.body:destroy()
            table.remove(ActiveCorns, i)
        end
    end
end

function Corn.new(x, y)
    instance = setmetatable({}, Corn)
    instance.x = x 
    instance.y = y
    instance.r = 0
    instance.scale = 2
    instance.itemType = ItemTypes.CONSUMABLE
    
    instance.givable = {
        type = "hunger",
        value = 10
    }

    instance.physics = {}
    instance.physics.body = love.physics.newBody(World, instance.x, instance.y, "static")
    instance.physics.shape = love.physics.newRectangleShape(instance.width * instance.scale, instance.height * instance.scale)
    instance.physics.fixture = love.physics.newFixture(instance.physics.body, instance.physics.shape)
    instance.physics.fixture:setSensor(true)
    table.insert(ActiveCorns, instance)
end

function Corn:returnNbEntities()
    return #ActiveCorns
end

function Corn:update(dt)
    -- self:syncPhysics()
end

function Corn:syncPhysics()
    self.x, self.y = self.physics.body:getPosition()
end

function Corn:draw()
    local offsetY = FLOATING_AMPLITUDE * math.sin(love.timer.getTime() * FLOATING_SPEED)
    local drawY = self.y + offsetY

    love.graphics.draw(self.img, self.x, drawY, self.r, self.scale, self.scale, self.width / 2, self.height / 2)

    -- self:drawHitbox()
end

function Corn:drawHitbox()
    love.graphics.setColor(1, 0, 0)
    love.graphics.polygon("line", self.physics.fixture:getBody():getWorldPoints(self.physics.fixture:getShape():getPoints()))
    love.graphics.setColor(1, 1, 1)
end

function Corn.updateAll(dt)
    for i,instance in ipairs(ActiveCorns) do
        instance:update(dt)
    end
end

function Corn.drawAll()
    for i,instance in ipairs(ActiveCorns) do
        instance:draw()
    end
end

function Corn.beginContact(a, b, collision)
    for i,instance in ipairs(ActiveCorns) do
        if a == instance.physics.fixture or b == instance.physics.fixture then
            if a == Player.physics.fixture or b == Player.physics.fixture then
                Inventory:giveToInventory(instance.name, instance)
                instance:remove()
            end
        end
    end
end

return Corn