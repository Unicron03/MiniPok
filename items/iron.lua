
local Iron = {img = love.graphics.newImage("assets/items/ressources/iron.png"), name = "Iron"}
Iron.__index = Iron

Iron.width = Iron.img:getWidth()
Iron.height = Iron.img:getHeight()

local FLOATING_AMPLITUDE = 5
local FLOATING_SPEED = 2.5

local ActiveIrons = {}

function Iron.removeAll()
    for i,v in ipairs(ActiveIrons) do
        v.physics.body:destroy()
    end

    ActiveIrons = {}
end

function Iron:remove()
    for i, instance in ipairs(ActiveIrons) do
        if instance == self then
            self.physics.body:destroy()
            table.remove(ActiveIrons, i)
        end
    end
end

function Iron.new(x, y)
    instance = setmetatable({}, Iron)
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
    table.insert(ActiveIrons, instance)
end

function Iron:returnNbEntities()
    return #ActiveIrons
end

function Iron:update(dt)
    -- self:syncPhysics()
end

function Iron:syncPhysics()
    self.x, self.y = self.physics.body:getPosition()
end

function Iron:draw()
    local offsetY = FLOATING_AMPLITUDE * math.sin(love.timer.getTime() * FLOATING_SPEED)
    local drawY = self.y + offsetY

    love.graphics.draw(self.img, self.x, drawY, self.r, self.scale, self.scale, self.width / 2, self.height / 2)

    -- self:drawHitbox()
end

function Iron:drawHitbox()
    love.graphics.setColor(1, 0, 0)
    love.graphics.polygon("line", self.physics.fixture:getBody():getWorldPoints(self.physics.fixture:getShape():getPoints()))
    love.graphics.setColor(1, 1, 1)
end

function Iron.updateAll(dt)
    for i,instance in ipairs(ActiveIrons) do
        instance:update(dt)
    end
end

function Iron.drawAll()
    for i,instance in ipairs(ActiveIrons) do
        instance:draw()
    end
end

function Iron.beginContact(a, b, collision)
    for i,instance in ipairs(ActiveIrons) do
        if a == instance.physics.fixture or b == instance.physics.fixture then
            if a == Player.physics.fixture or b == Player.physics.fixture then
                Inventory:giveToInventory(instance.name, instance)
                instance:remove()
            end
        end
    end
end

return Iron