
local Door = {}
Door.__index = Door
local ActiveDoors = {}

function Door.removeAll()
    for i,v in ipairs(ActiveDoors) do
        v.physics.body:destroy()
    end

    ActiveDoors = {}
end

function Door:returnTable()
    return ActiveDoors
end

function Door:remove()
    for i, instance in ipairs(ActiveDoors) do
        if instance == self then
            self.physics.body:destroy()
            table.remove(ActiveDoors, i)
        end
    end
end

function Door.new(x, y, img, id, salle)
    instance = setmetatable({}, Door)
    instance.x = x
    instance.y = y
    instance.id = id
    instance.salle = salle

    instance.img = love.graphics.newImage("assets/tiles/objects/"..img..".png")
    instance.width = instance.img:getWidth()
    instance.height = instance.img:getHeight()

    instance.physics = {}
    instance.physics.body = love.physics.newBody(World, instance.x + instance.width * 0.5, instance.y + instance.height * 0.5, "static")
    instance.physics.shape = love.physics.newRectangleShape(instance.width, instance.height)
    instance.physics.fixture = love.physics.newFixture(instance.physics.body, instance.physics.shape)

    table.insert(ActiveDoors, instance)

    return instance
end

function Door.returnTable()
    return ActiveDoors
end

function Door:update(dt)
    -- self:syncPhysics()
end

function Door:syncPhysics()
    self.x, self.y = self.physics.body:getPosition()
end

function Door:draw()
    love.graphics.draw(self.img, self.x, self.y)

    -- self:drawHitbox()
end

function Door:drawHitbox()
    love.graphics.setColor(1, 0, 0)
    love.graphics.polygon("line", self.physics.fixture:getBody():getWorldPoints(self.physics.fixture:getShape():getPoints()))
    love.graphics.setColor(1, 1, 1)
end

function Door.updateAll(dt)
    for i,instance in ipairs(ActiveDoors) do
        instance:update(dt)
    end
end

function Door.drawAll()
    for i,instance in ipairs(ActiveDoors) do
        instance:draw()
    end
end

function Door.beginContact(a, b, collision)
    for i,instance in ipairs(ActiveDoors) do
        if a == instance.physics.fixture or b == instance.physics.fixture then
            if a == Player.physics.fixture or b == Player.physics.fixture then
            end
        end
    end
end

function Door.endContact(a, b, collision)
    for i, instance in ipairs(ActiveDoors) do
        if a == instance.physics.fixture or b == instance.physics.fixture then
        end
    end
end

return Door