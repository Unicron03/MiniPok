
local Portal = {}
Portal.__index = Portal
local ActivePortals = {}

local MsgUI = require("msgUI")

function Portal.removeAll()
    for i,v in ipairs(ActivePortals) do
        v.physics.body:destroy()
    end

    ActivePortals = {}
end

function Portal:returnTable()
    return ActivePortals 
end

function Portal:remove()
    for i, instance in ipairs(ActivePortals) do
        if instance == self then
            self.physics.body:destroy()
            table.remove(ActivePortals, i)
        end
    end
end

function Portal.new(x, y, width, height, destination, callback)
    instance = setmetatable({}, Portal)
    instance.x = x
    instance.y = y
    instance.destination = destination
    instance.callback = callback or false

    instance.msgUI = nil

    instance.physics = {}
    instance.physics.body = love.physics.newBody(World, instance.x + width * 0.5, instance.y + height * 0.5, "static")
    instance.physics.shape = love.physics.newRectangleShape(width, height)
    instance.physics.fixture = love.physics.newFixture(instance.physics.body, instance.physics.shape)

    instance.physics.fixture:setSensor(true)

    table.insert(ActivePortals, instance)

    return instance
end

function Portal.returnTable()
    return ActivePortals
end

function Portal:update(dt)
end

function Portal:draw()
    -- self:drawHitbox()
end

function Portal:drawHitbox()
    love.graphics.setColor(1, 0, 0)
    love.graphics.polygon("line", self.physics.fixture:getBody():getWorldPoints(self.physics.fixture:getShape():getPoints()))
    love.graphics.setColor(1, 1, 1)
end

function Portal.updateAll(dt)
    for i,instance in ipairs(ActivePortals) do
        instance:update(dt)
    end
end

function Portal.drawAll()
    for i,instance in ipairs(ActivePortals) do
        instance:draw()
    end
end

function Portal.beginContact(a, b, collision)
    for i,instance in ipairs(ActivePortals) do
        if a == instance.physics.fixture or b == instance.physics.fixture then
            if a == Player.physics.fixture or b == Player.physics.fixture then
                instance.msgUI = MsgUI.new(nil, nil, "Take the portal", true, nil,
                    function()
                        Map:switchMap(instance.destination)
                        instance:remove()

                        if instance.callback then
                            instance.callback()
                        end
                    end)
            end
        end
    end
end

function Portal.endContact(a, b, collision)
    for i, instance in ipairs(ActivePortals) do
        if a == instance.physics.fixture or b == instance.physics.fixture then
            if instance.msgUI ~= nil then
                instance.msgUI:remove()
            end

            instance.msgUI = nil
        end
    end
end

return Portal