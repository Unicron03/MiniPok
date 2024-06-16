
local Trader = {}
Trader.__index = Trader
local ActiveTraders = {}

local MsgUI = require("msgUI")

function Trader.removeAll()
    for i,v in ipairs(ActiveTraders) do
        v.physics.body:destroy()
    end

    ActiveTraders = {}
end

function Trader:returnTable()
    return ActiveTraders 
end

function Trader:remove()
    for i, instance in ipairs(ActiveTraders) do
        if instance == self then
            self.physics.body:destroy()
            table.remove(ActiveTraders, i)
        end
    end
end

function Trader.new(x, y, width, height)
    instance = setmetatable({}, Trader)
    instance.x = x
    instance.y = y

    instance.msgUI = nil

    instance.physics = {}
    instance.physics.body = love.physics.newBody(World, instance.x + width * 0.5, instance.y + height * 0.5, "static")
    instance.physics.shape = love.physics.newRectangleShape(width, height)
    instance.physics.fixture = love.physics.newFixture(instance.physics.body, instance.physics.shape)

    instance.physics.fixture:setSensor(true)

    table.insert(ActiveTraders, instance)

    return instance
end

function Trader.returnTable()
    return ActiveTraders
end

function Trader:update(dt)
end

function Trader:draw()
    -- self:drawHitbox()
end

function Trader:drawHitbox()
    love.graphics.setColor(1, 0, 0)
    love.graphics.polygon("line", self.physics.fixture:getBody():getWorldPoints(self.physics.fixture:getShape():getPoints()))
    love.graphics.setColor(1, 1, 1)
end

function Trader.updateAll(dt)
    for i,instance in ipairs(ActiveTraders) do
        instance:update(dt)
    end
end

function Trader.drawAll()
    for i,instance in ipairs(ActiveTraders) do
        instance:draw()
    end
end

function Trader.beginContact(a, b, collision)
    for i,instance in ipairs(ActiveTraders) do
        if a == instance.physics.fixture or b == instance.physics.fixture then
            if a == Player.physics.fixture or b == Player.physics.fixture then
                instance.msgUI = MsgUI.new(nil, nil, "Open Trader panel", true, nil, function() Shop:changeState() end)
            end
        end
    end
end

function Trader.endContact(a, b, collision)
    for i, instance in ipairs(ActiveTraders) do
        if a == instance.physics.fixture or b == instance.physics.fixture then
            if instance.msgUI ~= nil then
                instance.msgUI:remove()
            end

            instance.msgUI = nil
            Shop.affPanel = true
            Shop:changeState()
        end
    end
end

return Trader