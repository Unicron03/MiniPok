
local Water = {}
Water.__index = Water
local ActiveWaters = {}

local MsgUI = require("msgUI")

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

function Water.returnTable()
    return ActiveWaters
end

function Water.new(x, y, width, height)
    instance = setmetatable({}, Water)
    instance.x = x + width * 0.5
    instance.y = y + height * 0.5
    instance.width = width
    instance.height = height

    instance.msgUI = nil

    instance.physics = {}
    instance.physics.body = love.physics.newBody(World, instance.x, instance.y, "static")
    instance.physics.shape = love.physics.newRectangleShape(instance.width, instance.height)
    instance.physics.fixture = love.physics.newFixture(instance.physics.body, instance.physics.shape)
    instance.physics.fixture:setSensor(true)

    table.insert(ActiveWaters, instance)
end

function Water.loadAssets()
end

function Water:update(dt)
    if self.toBeRemoved then
        self:remove()
    end
end

function Water:syncPhysics()
    self.x, self.y = self.physics.body:getPosition()
end

function Water:draw()
    -- self:drawHitBox()
end

function Water:drawHitBox()
    love.graphics.setColor(1, 0, 0)
    love.graphics.polygon("line", self.physics.fixture:getBody():getWorldPoints(self.physics.fixture:getShape():getPoints()))
    love.graphics.setColor(1, 1, 1)
end

function Water:callbackAction()
    if Inventory:enableToHarvest(Water) then
        self:affMsgWhenPlayerIn()
        Items.Water.new(Player.x, Player.y)
        Inventory:descreaseToolDurability(Water)
    end
end

function Water:affMsgWhenPlayerIn()
    self.msgUI = MsgUI.new(nil, nil, "Recolt", true, nil, function() self:callbackAction() end)
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
    for i, instance in ipairs(ActiveWaters) do
        if a == instance.physics.fixture or b == instance.physics.fixture then
            if a == Player.physics.fixture or b == Player.physics.fixture then
                if(instance.msgUI == nil and Inventory:enableToHarvest(Water)) then
                    instance:affMsgWhenPlayerIn()
                else
                    instance.msgUI = MsgUI.new(nil, nil, "You dont have a tool to recolt water")
                end
            end
        end
    end
end

function Water.endContact(a, b, collision)
    for i, instance in ipairs(ActiveWaters) do
        if a == instance.physics.fixture or b == instance.physics.fixture then
            if(instance.msgUI ~= nil) then
                instance.msgUI:remove()
                instance.msgUI = nil
            end
        end
    end
end

return Water