
local Rock = {}
Rock.__index = Rock
local ActiveRocks = {}

local MsgUI = require("msgUI")

function Rock.removeAll()
    for i,v in ipairs(ActiveRocks) do
        v.physics.body:destroy()
    end

    ActiveRocks = {}
end

function Rock:remove()
    for i, instance in ipairs(ActiveRocks) do
        if instance == self then
            self.physics.body:destroy()
            table.remove(ActiveRocks, i)
        end
    end
end

function Rock.returnTable()
    return ActiveRocks
end

function Rock.new(x, y)
    instance = setmetatable({}, Rock)
    instance.x = x
    instance.y = y
    instance.scale = 1.5

    instance.nbTimesCanBeHit = 3
    instance.state = "basic"
    instance.msgUI = nil
    instance.cooldownRevive = {timer = 0, rate = 20}

    instance.choosenImg = math.random(1, 2) == 1 and (1) or (3)
    instance.img = {sprite = Rock.imgSprite}
    instance.img.draw = instance.img.sprite[instance.choosenImg]

    instance.width = instance.img.draw:getWidth()
    instance.height = instance.img.draw:getHeight()

    instance.physics = {}
    instance.physics.body = love.physics.newBody(World, instance.x, instance.y, "static")
    instance.physics.shape = love.physics.newRectangleShape(instance.width * instance.scale, instance.height * instance.scale)
    instance.physics.fixture = love.physics.newFixture(instance.physics.body, instance.physics.shape)
    instance.physics.fixture:setSensor(true)

    table.insert(ActiveRocks, instance)
end

function Rock.loadAssets()
    Rock.imgSprite = {}
    for i=1,4 do
        Rock.imgSprite[i] = love.graphics.newImage("assets/harvestables/rock/"..i..".png")
    end
end

function Rock:update(dt)
    if self.toBeRemoved then
        self:remove()
    end

    if(self.state == "death") then
        self:inReviveState(dt)
    end
end

function Rock:inReviveState(dt)
    self.cooldownRevive.timer = self.cooldownRevive.timer + dt
    if(self.cooldownRevive.timer > self.cooldownRevive.rate) then
        self.cooldownRevive.timer = 0
        self.state = "basic"
        self.nbTimesCanBeHit = 3
        self.img.draw = self.img.sprite[self.choosenImg]

        if(self.msgUI) then
            self.msgUI:remove()
            self:affMsgWhenPlayerIn()
        end
    else
        self:affMsgUI()
    end
end

function Rock:syncPhysics()
    self.x, self.y = self.physics.body:getPosition()
end

function Rock:draw()
    love.graphics.draw(self.img.draw, self.x, self.y, 0, self.scale, self.scale, self.width / 2, self.height / 2)

    -- self:drawHitBox()
end

function Rock:drawHitBox()
    love.graphics.setColor(1, 0, 0)
    love.graphics.polygon("line", self.physics.fixture:getBody():getWorldPoints(self.physics.fixture:getShape():getPoints()))
    love.graphics.setColor(1, 1, 1)
end

function Rock:callbackAction()
    if(self.nbTimesCanBeHit > 0) then
        self.nbTimesCanBeHit = self.nbTimesCanBeHit - 1
        self.state = "hit"
        self:affMsgWhenPlayerIn()
    else
        self.state = "death"
        self.img.draw = self.img.sprite[self.choosenImg + 1]
        self.msgUI = MsgUI.new(nil, nil, "Harvestable in "..self.cooldownRevive.rate.."sec")
    end
    
    Items.Stone.new(self.x, self.y + self.height * 1.3)
    Inventory:descreaseToolDurability(Rock)
end

function Rock:affMsgUI()
    if(self.msgUI ~= nil) then
        local cooldownRest = math.floor(self.cooldownRevive.rate - self.cooldownRevive.timer)

        if(cooldownRest ~= self.msgUI.timer) then
            self.msgUI:remove()
            self.msgUI = MsgUI.new(nil, nil, "Harvestable in "..cooldownRest.."sec")
        end
    end
end

function Rock:affMsgWhenPlayerIn()
    self.msgUI = MsgUI.new(nil, nil, "Recolt", true, nil, function() self:callbackAction() end)
end

function Rock.updateAll(dt)
    for i,instance in ipairs(ActiveRocks) do
        instance:update(dt)
    end
end

function Rock.drawAll()
    for i,instance in ipairs(ActiveRocks) do
        instance:draw()
    end
end

function Rock.beginContact(a, b, collision)
    for i, instance in ipairs(ActiveRocks) do
        if a == instance.physics.fixture or b == instance.physics.fixture then
            if a == Player.physics.fixture or b == Player.physics.fixture then
                if(Inventory:enableToHarvest(Rock)) then
                    if(instance.msgUI == nil and instance.state ~= "death") then
                        instance:affMsgWhenPlayerIn()
                    elseif(instance.msgUI == nil and instance.state == "death") then
                        instance.msgUI = MsgUI.new(nil, nil, "Harvestable in "..math.floor(instance.cooldownRevive.rate - instance.cooldownRevive.timer).."sec")
                    end
                else
                    instance.msgUI = MsgUI.new(nil, nil, "You dont have a tool to break this rock")
                end
            end
        end
    end
end

function Rock.endContact(a, b, collision)
    for i, instance in ipairs(ActiveRocks) do
        if a == instance.physics.fixture or b == instance.physics.fixture then
            if(instance.msgUI ~= nil) then
                instance.msgUI:remove()
                instance.msgUI = nil
            end
        end
    end
end

return Rock