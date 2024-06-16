
local Dirt = {}
Dirt.__index = Dirt
local ActiveDirts = {}

local MsgUI = require("msgUI")

function Dirt.removeAll()
    for i,v in ipairs(ActiveDirts) do
        v.physics.body:destroy()
    end

    ActiveDirts = {}
end

function Dirt:remove()
    for i, instance in ipairs(ActiveDirts) do
        if instance == self then
            self.physics.body:destroy()
            table.remove(ActiveDirts, i)
        end
    end
end

function Dirt.returnTable()
    return ActiveDirts
end

function Dirt.new(x, y, width, height)
    instance = setmetatable({}, Dirt)
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
    instance.physics.fixture:setUserData("dirt")

    table.insert(ActiveDirts, instance)
end

function Dirt.loadAssets()
end

function Dirt:update(dt)
    if self.toBeRemoved then
        self:remove()
    end
end

function Dirt:syncPhysics()
    self.x, self.y = self.physics.body:getPosition()
end

function Dirt:draw()
    -- self:drawHitBox()
end

function Dirt:drawHitBox()
    love.graphics.setColor(1, 0, 0)
    love.graphics.polygon("line", self.physics.fixture:getBody():getWorldPoints(self.physics.fixture:getShape():getPoints()))
    love.graphics.setColor(1, 1, 1)
end

function Dirt:callbackAction()
    Items.FertilizedDirt.new(self.x, self.y + self.height * 0.5 + 30)
    Inventory:descreaseToolDurability(Dirt)
    -- tree_hit:play()

    if(Inventory:enableToHarvest(Dirt)) then
        self:affMsgWhenPlayerIn()
    else
        self.msgUI = MsgUI.new(nil, nil, "You dont have a tool to recolt this dirt")
    end
end

function Dirt:affMsgWhenPlayerIn()
    self.msgUI = MsgUI.new(nil, nil, "Recolt", true, nil, function() self:callbackAction() end)
end

function Dirt.updateAll(dt)
    for i,instance in ipairs(ActiveDirts) do
        instance:update(dt)
    end
end

function Dirt.drawAll()
    for i,instance in ipairs(ActiveDirts) do
        instance:draw()
    end
end

function Dirt.beginContact(a, b, collision)
    for i, instance in ipairs(ActiveDirts) do
        if a == instance.physics.fixture or b == instance.physics.fixture then
            if a == Player.physics.fixture or b == Player.physics.fixture then
                if(Inventory:enableToHarvest(Dirt)) then
                    if(instance.msgUI == nil) then
                        instance:affMsgWhenPlayerIn()
                    end
                else
                    instance.msgUI = MsgUI.new(nil, nil, "You dont have a tool to recolt this dirt")
                end
            end
        end
    end
end

function Dirt.endContact(a, b, collision)
    for i, instance in ipairs(ActiveDirts) do
        if a == instance.physics.fixture or b == instance.physics.fixture then
            if(instance.msgUI ~= nil) then
                instance.msgUI:remove()
                instance.msgUI = nil
            end
        end
    end
end

return Dirt