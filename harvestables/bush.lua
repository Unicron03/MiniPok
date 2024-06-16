
local Bush = {}
Bush.__index = Bush
local ActiveBushs = {}

local MsgUI = require("msgUI")

function Bush.removeAll()
    for i,v in ipairs(ActiveBushs) do
        v.physics.body:destroy()
    end

    ActiveBushs = {}
end

function Bush:remove()
    for i, instance in ipairs(ActiveBushs) do
        if instance == self then
            self.physics.body:destroy()
            table.remove(ActiveBushs, i)
        end
    end
end

function Bush.returnTable()
    return ActiveBushs
end

function Bush.new(x, y)
    instance = setmetatable({}, Bush)
    instance.x = x
    instance.y = y
    instance.scale = 4

    instance.nbTimesCanBeHit = {current = 3, max = 3}
    instance.state = "basic"
    instance.msgUI = nil
    instance.cooldownRevive = {timer = 0, rate = 20}

    instance.img = {
        basic = love.graphics.newImage("assets/harvestables/bush/basic.png"),
        death = love.graphics.newImage("assets/harvestables/bush/death.png")
    }
    instance.img.draw = instance.img[instance.state]

    instance.width = instance.img.draw:getWidth()
    instance.height = instance.img.draw:getHeight()

    instance.physics = {}
    instance.physics.body = love.physics.newBody(World, instance.x, instance.y, "static")
    instance.physics.shape = love.physics.newRectangleShape(instance.width * instance.scale, instance.height * instance.scale)
    instance.physics.fixture = love.physics.newFixture(instance.physics.body, instance.physics.shape)
    instance.physics.fixture:setSensor(true)

    table.insert(ActiveBushs, instance)
end

function Bush.loadAssets()
end

function Bush:update(dt)
    if self.toBeRemoved then
        self:remove()
    end

    if(self.state == "death") then
        self:inReviveState(dt)
    end
end

function Bush:inReviveState(dt)
    self.cooldownRevive.timer = self.cooldownRevive.timer + dt
    if(self.cooldownRevive.timer > self.cooldownRevive.rate) then
        self.cooldownRevive.timer = 0
        self.state = "basic"
        self.nbTimesCanBeHit.current = self.nbTimesCanBeHit.max
        self.img.draw = self.img.basic

        if(self.msgUI) then
            self.msgUI:remove()
            self:affMsgWhenPlayerIn()
        end
    else
        self:affMsgUI()
    end
end

function Bush:syncPhysics()
    self.x, self.y = self.physics.body:getPosition()
end

function Bush:draw()
    love.graphics.draw(self.img.draw, self.x, self.y, 0, self.scale, self.scale, self.width / 2, self.height / 2)

    -- self:drawHitBox()
end

function Bush:drawHitBox()
    love.graphics.setColor(1, 0, 0)
    love.graphics.polygon("line", self.physics.fixture:getBody():getWorldPoints(self.physics.fixture:getShape():getPoints()))
    love.graphics.setColor(1, 1, 1)
end

function Bush:callbackAction()
    if(self.nbTimesCanBeHit.current > 0) then
        self.nbTimesCanBeHit.current = self.nbTimesCanBeHit.current - 1
        self.state = "hit"
        self:affMsgWhenPlayerIn()
    else
        self.state = "death"
        self.img.draw = self.img.death
        self.msgUI = MsgUI.new(nil, nil, "Harvestable in "..self.cooldownRevive.rate.."sec")
    end
    
    Items.Branch.new(self.x, self.y + self.height * 3.2)
    -- tree_hit:play()
end

function Bush:affMsgUI()
    if(self.msgUI ~= nil) then
        local cooldownRest = math.floor(self.cooldownRevive.rate - self.cooldownRevive.timer)

        if(cooldownRest ~= self.msgUI.timer) then
            self.msgUI:remove()
            self.msgUI = MsgUI.new(nil, nil, "Harvestable in "..cooldownRest.."sec")
        end
    end
end

function Bush:affMsgWhenPlayerIn()
    self.msgUI = MsgUI.new(nil, nil, "Recolt", true, nil, function() self:callbackAction() end)
end

function Bush.updateAll(dt)
    for i,instance in ipairs(ActiveBushs) do
        instance:update(dt)
    end
end

function Bush.drawAll()
    for i,instance in ipairs(ActiveBushs) do
        instance:draw()
    end
end

function Bush.beginContact(a, b, collision)
    for i, instance in ipairs(ActiveBushs) do
        if a == instance.physics.fixture or b == instance.physics.fixture then
            if a == Player.physics.fixture or b == Player.physics.fixture then
                if(instance.msgUI == nil and instance.state ~= "death") then
                    instance:affMsgWhenPlayerIn()
                elseif(instance.msgUI == nil and instance.state == "death") then
                    instance.msgUI = MsgUI.new(nil, nil, "Harvestable in "..math.floor(instance.cooldownRevive.rate - instance.cooldownRevive.timer).."sec")
                end
            end
        end
    end
end

function Bush.endContact(a, b, collision)
    for i, instance in ipairs(ActiveBushs) do
        if a == instance.physics.fixture or b == instance.physics.fixture then
            if(instance.msgUI ~= nil) then
                instance.msgUI:remove()
                instance.msgUI = nil
            end
        end
    end
end

return Bush