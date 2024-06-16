local SolidElm = {}
SolidElm.__index = SolidElm

local ActiveSolidElms = {}
local DestructionQueue = {}

function SolidElm.removeAll()
    for i,v in ipairs(ActiveSolidElms) do
        v.physics.body:destroy()
    end

    ActiveSolidElms = {}
end

function SolidElm:returnTable()
    return ActiveSolidElms 
end

function SolidElm:remove()
    for i, instance in ipairs(ActiveSolidElms) do
        if instance == self then
            self.physics.body:destroy()
            table.remove(ActiveSolidElms, i)
        end
    end
end

function SolidElm.new(x, y, width, height, img, callbackFunction, physicsType)
    instance = setmetatable({}, SolidElm)
    instance.x = x 
    instance.y = y
    instance.width = width
    instance.height = height
    instance.img = (img ~= nil) and (love.graphics.newImage("assets/tiles/objects/"..img..".png")) or (nil)
    instance.callback = callbackFunction
    instance.removable = false

    instance.physics = {}
    instance.physics.body = love.physics.newBody(World, instance.x + width * 0.5, instance.y + height * 0.5, physicsType)
    instance.physics.shape = love.physics.newRectangleShape(instance.width, instance.height)
    instance.physics.fixture = love.physics.newFixture(instance.physics.body, instance.physics.shape)

    table.insert(ActiveSolidElms, instance)

    return instance
end

function SolidElm:returnNbEntities()
    return #ActiveSolidElms
end

function SolidElm:update(dt)
    if self.checkRemove then
        self:remove()
    end
end

function SolidElm:syncPhysics()
    self.x, self.y = self.physics.body:getPosition()
end

function SolidElm:draw()
    if self.img ~= nil then
        love.graphics.draw(self.img, self.x, self.y)
    end

    self:drawHitbox()
end

function SolidElm:drawHitbox()
    love.graphics.setColor(1, 0, 0)
    love.graphics.polygon("line", self.physics.fixture:getBody():getWorldPoints(self.physics.fixture:getShape():getPoints()))
    love.graphics.setColor(1, 1, 1)
end

function SolidElm.updateAll(dt)
    for i,instance in ipairs(ActiveSolidElms) do
        instance:update(dt)
    end

    for i, instance in ipairs(DestructionQueue) do
        instance.callback()
        table.remove(DestructionQueue, i)
        instance.checkRemove = true
    end
end

function SolidElm.drawAll()
    for i,instance in ipairs(ActiveSolidElms) do
        instance:draw()
    end
end

function SolidElm.beginContact(a, b, collision)
    for i,instance in ipairs(ActiveSolidElms) do
        if a == instance.physics.fixture or b == instance.physics.fixture then
            if a == Player.physics.fixture or b == Player.physics.fixture then
                table.insert(DestructionQueue, instance)
                -- instance:remove()
            end
        end
    end
end

return SolidElm