
local Tree = {}
Tree.__index = Tree
local ActiveTrees = {}

local MsgUI = require("msgUI")

function Tree.removeAll()
    for i,v in ipairs(ActiveTrees) do
        v.physics.body:destroy()
    end

    ActiveTrees = {}
end

function Tree:remove()
    for i, instance in ipairs(ActiveTrees) do
        if instance == self then
            self.physics.body:destroy()
            table.remove(ActiveTrees, i)
        end
    end
end

function Tree.returnTable()
    return ActiveTrees
end

function Tree.new(x, y)
    instance = setmetatable({}, Tree)
    instance.x = x
    instance.y = y

    instance.nbTimesCanBeHit = 3
    instance.state = "basic"
    instance.msgUI = nil
    instance.cooldownRevive = {timer = 0, rate = 20}

    instance.animation = {timer = 0, rate = 0.1}
    instance.animation.basic = {total = #Tree.basicAnim, current = 1, img = Tree.basicAnim}
    instance.animation.hit = {total = #Tree.hitAnim, current = 1, img = Tree.hitAnim}
    instance.animation.death = love.graphics.newImage("assets/harvestables/tree/death.png")
    instance.animation.draw = instance.animation.basic.img[1]

    instance.physics = {}
    instance.physics.body = love.physics.newBody(World, instance.x, instance.y, "static")
    instance.physics.shape = love.physics.newRectangleShape(instance.width, instance.height)
    instance.physics.fixture = love.physics.newFixture(instance.physics.body, instance.physics.shape)
    instance.physics.fixture:setSensor(true)

    table.insert(ActiveTrees, instance)
end

function Tree.loadAssets()
    Tree.basicAnim = {}
    for i=1,4 do
        Tree.basicAnim[i] = love.graphics.newImage("assets/harvestables/tree/basic/"..i..".png")
    end

    Tree.hitAnim = {}
    for i=1,3 do
        Tree.hitAnim[i] = love.graphics.newImage("assets/harvestables/tree/hit/"..i..".png")
    end

    Tree.width = Tree.basicAnim[1]:getWidth()
    Tree.height = Tree.basicAnim[1]:getHeight()
end

function Tree:update(dt)
    if self.toBeRemoved then
        self:remove()
    end

    self:animate(dt)

    if(love.keyboard.isDown("l")) then
        self.state = "hit"
    end
end

function Tree:inReviveState(dt)
    self.cooldownRevive.timer = self.cooldownRevive.timer + dt
    if(self.cooldownRevive.timer > self.cooldownRevive.rate) then
        self.cooldownRevive.timer = 0
        self.state = "basic"
        self.nbTimesCanBeHit = 3
        self.animation.draw = self.animation[self.state].img[1]

        if(self.msgUI) then
            self.msgUI:remove()
            self:affMsgWhenPlayerIn()
        end
    else
        self:affMsgUI()
    end
end

function Tree:animate(dt)
    if(self.state ~= "death") then
        self.animation.timer = self.animation.timer + dt
        if self.animation.timer > self.animation.rate then
            self.animation.timer = 0
            self:setNewFrame()
        end
    else
        self:inReviveState(dt)
    end
end

function Tree:setNewFrame()
    local anim = self.animation[self.state]
    if anim.current < anim.total then
        anim.current = anim.current + 1 
    else
        anim.current = 1

        if(self.state == "hit") then
            self.state = "basic"
        end
    end

    self.animation.draw = anim.img[anim.current]
end

function Tree:syncPhysics()
    self.x, self.y = self.physics.body:getPosition()
end

function Tree:draw()
    love.graphics.draw(self.animation.draw, self.x, self.y, 0, 1, 1, self.width / 2, self.height / 2)

    -- self:drawHitBox()
end

function Tree:drawHitBox()
    love.graphics.setColor(1, 0, 0)
    love.graphics.polygon("line", self.physics.fixture:getBody():getWorldPoints(self.physics.fixture:getShape():getPoints()))
    love.graphics.setColor(1, 1, 1)
end

function Tree:callbackAction()
    if(self.nbTimesCanBeHit > 0) then
        self.nbTimesCanBeHit = self.nbTimesCanBeHit - 1
        self.state = "hit"
        self:affMsgWhenPlayerIn()
    else
        self.state = "death"
        self.animation.draw = self.animation[self.state]
        self.msgUI = MsgUI.new(nil, nil, "Harvestable in "..self.cooldownRevive.rate.."sec")
    end
    
    Items.Log.new(self.x, self.y + self.height * 0.6)
    Inventory:descreaseToolDurability(Tree)
    Sound:play("tree_hit")
end

function Tree:affMsgUI()
    if(self.msgUI ~= nil) then
        local cooldownRest = math.floor(self.cooldownRevive.rate - self.cooldownRevive.timer)

        if(cooldownRest ~= self.msgUI.timer) then
            self.msgUI:remove()
            self.msgUI = MsgUI.new(nil, nil, "Harvestable in "..cooldownRest.."sec")
        end
    end
end

function Tree:affMsgWhenPlayerIn()
    self.msgUI = MsgUI.new(nil, nil, "Recolt", true, nil, function() self:callbackAction() end)
end

function Tree.updateAll(dt)
    for i,instance in ipairs(ActiveTrees) do
        instance:update(dt)
    end
end

function Tree.drawAll()
    for i,instance in ipairs(ActiveTrees) do
        instance:draw()
    end
end

function Tree.beginContact(a, b, collision)
    for i, instance in ipairs(ActiveTrees) do
        if a == instance.physics.fixture or b == instance.physics.fixture then
            if a == Player.physics.fixture or b == Player.physics.fixture then
                if(Inventory:enableToHarvest(Tree)) then
                    if(instance.msgUI == nil and instance.state ~= "death") then
                        instance:affMsgWhenPlayerIn()
                    elseif(instance.msgUI == nil and instance.state == "death") then
                        instance.msgUI = MsgUI.new(nil, nil, "Harvestable in "..math.floor(instance.cooldownRevive.rate - instance.cooldownRevive.timer).."sec")
                    end
                else
                    instance.msgUI = MsgUI.new(nil, nil, "You dont have a tool to cut this tree")
                end
            end
        end
    end
end

function Tree.endContact(a, b, collision)
    for i, instance in ipairs(ActiveTrees) do
        if a == instance.physics.fixture or b == instance.physics.fixture then
            if(instance.msgUI ~= nil) then
                instance.msgUI:remove()
                instance.msgUI = nil
            end
        end
    end
end

return Tree