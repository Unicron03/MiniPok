
local Peaks = {}
Peaks.__index = Peaks
local ActivePeaks = {}
local needToUpdateType = {}

function Peaks.removeAll()
    for i,v in ipairs(ActivePeaks) do
        v.physics.body:destroy()
    end

    ActivePeaks = {}
end

function Peaks:returnTable()
    return ActivePeaks 
end

function Peaks:remove()
    for i, instance in ipairs(ActivePeaks) do
        if instance == self then
            self.physics.body:destroy()
            table.remove(ActivePeaks, i)
        end
    end
end

function Peaks.new(x, y, width, height, id, orientation, salle, callback)
    instance = setmetatable({}, Peaks)
    instance.x = x
    instance.y = y
    instance.width = width
    instance.height = height
    instance.id = id
    instance.orientation = orientation
    instance.salle = salle
    instance.callback = callback

    instance.img = {
        down = love.graphics.newImage("assets/tiles/objects/peaksDown.png"),
        up = love.graphics.newImage("assets/tiles/objects/peaksUp.png"),
        state = "down"
    }
    instance.img.draw = instance.img[instance.img.state]

    instance.physics = {}
    instance.physics.body = love.physics.newBody(World, instance.x + width * 0.5, instance.y + height * 0.5, "static")
    instance.physics.shape = love.physics.newRectangleShape(instance.width, instance.height)
    instance.physics.fixture = love.physics.newFixture(instance.physics.body, instance.physics.shape)

    instance.physics.fixture:setSensor(true)

    table.insert(ActivePeaks, instance)

    return instance
end

function Peaks.returnTable()
    return ActivePeaks
end

function Peaks:update(dt)
    -- self:syncPhysics()
end

function Peaks:syncPhysics()
    self.x, self.y = self.physics.body:getPosition()
end

function Peaks:draw()
    if self.orientation == "horizontal" then
        for i=0, (self.width/self.img.draw:getWidth() - 1) do
            love.graphics.draw(self.img.draw, self.x + i * self.img.draw:getWidth(), self.y)
        end
    else
        for i=0, (self.height/self.img.draw:getHeight() - 1) do
            love.graphics.draw(self.img.draw, self.x, self.y + i * self.img.draw:getHeight())
        end
    end

    -- self:drawHitbox()
end

function Peaks:drawHitbox()
    love.graphics.setColor(1, 0, 0)
    love.graphics.polygon("line", self.physics.fixture:getBody():getWorldPoints(self.physics.fixture:getShape():getPoints()))
    love.graphics.setColor(1, 1, 1)
end

function Peaks.updateAll(dt)
    for i,instance in ipairs(ActivePeaks) do
        instance:update(dt)
    end

    for i, instance in ipairs(needToUpdateType) do
        instance.img.state = (instance.img.state == "down") and ("up") or ("down")
        instance.img.draw = instance.img[instance.img.state]
        instance.physics.fixture:setSensor(false)
        instance.callback(instance.salle)
    end
    -- print(#needToUpdateType)
    needToUpdateType = {}
end

function Peaks.drawAll()
    for i,instance in ipairs(ActivePeaks) do
        instance:draw()
    end
end

function Peaks.beginContact(a, b, collision)
    for i,instance in ipairs(ActivePeaks) do
        if a == instance.physics.fixture or b == instance.physics.fixture then
            if a == Player.physics.fixture or b == Player.physics.fixture then
            end
        end
    end
end

function Peaks.endContact(a, b, collision)
    for i, instance in ipairs(ActivePeaks) do
        if a == instance.physics.fixture or b == instance.physics.fixture then
            if instance.img.state == "down" then
                if instance.orientation == "horizontal" then
                    if Player.y > instance.y + instance.height then
                        table.insert(needToUpdateType, instance)
                    end
                else
                    if Player.x > instance.x + instance.width then
                        table.insert(needToUpdateType, instance)
                    end
                end
            end
        end
    end
end

return Peaks