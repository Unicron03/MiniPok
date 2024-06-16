
local Carrot = {img = love.graphics.newImage("assets/items/ressources/carrot.png"), name = "Carrot"}
Carrot.__index = Carrot

Carrot.width = Carrot.img:getWidth()
Carrot.height = Carrot.img:getHeight()

local FLOATING_AMPLITUDE = 5
local FLOATING_SPEED = 2.5

local ActiveCarrots = {}

function Carrot.removeAll()
    for i,v in ipairs(ActiveCarrots) do
        v.physics.body:destroy()
    end

    ActiveCarrots = {}
end

function Carrot:remove()
    for i, instance in ipairs(ActiveCarrots) do
        if instance == self then
            self.physics.body:destroy()
            table.remove(ActiveCarrots, i)
        end
    end
end

function Carrot.new(x, y)
    instance = setmetatable({}, Carrot)
    instance.x = x 
    instance.y = y
    instance.r = 0
    instance.scale = 2
    instance.itemType = ItemTypes.CONSUMABLE
    
    instance.givable = {
        type = "hunger",
        value = 15
    }

    instance.physics = {}
    instance.physics.body = love.physics.newBody(World, instance.x, instance.y, "static")
    instance.physics.shape = love.physics.newRectangleShape(instance.width * instance.scale, instance.height * instance.scale)
    instance.physics.fixture = love.physics.newFixture(instance.physics.body, instance.physics.shape)
    instance.physics.fixture:setSensor(true)
    table.insert(ActiveCarrots, instance)
end

function Carrot:returnNbEntities()
    return #ActiveCarrots
end

function Carrot:update(dt)
    -- self:syncPhysics()
end

function Carrot:syncPhysics()
    self.x, self.y = self.physics.body:getPosition()
end

function Carrot:draw()
    local offsetY = FLOATING_AMPLITUDE * math.sin(love.timer.getTime() * FLOATING_SPEED)
    local drawY = self.y + offsetY

    love.graphics.draw(self.img, self.x, drawY, self.r, self.scale, self.scale, self.width / 2, self.height / 2)

    -- self:drawHitbox()
end

function Carrot:drawHitbox()
    love.graphics.setColor(1, 0, 0)
    love.graphics.polygon("line", self.physics.fixture:getBody():getWorldPoints(self.physics.fixture:getShape():getPoints()))
    love.graphics.setColor(1, 1, 1)
end

function Carrot.updateAll(dt)
    for i,instance in ipairs(ActiveCarrots) do
        instance:update(dt)
    end
end

function Carrot.drawAll()
    for i,instance in ipairs(ActiveCarrots) do
        instance:draw()
    end
end

function Carrot.beginContact(a, b, collision)
    for i,instance in ipairs(ActiveCarrots) do
        if a == instance.physics.fixture or b == instance.physics.fixture then
            if a == Player.physics.fixture or b == Player.physics.fixture then
                Inventory:giveToInventory(instance.name, instance)
                instance:remove()
            end
        end
    end
end

return Carrot