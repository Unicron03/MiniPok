
local Workbench = {img = love.graphics.newImage("assets/harvestables/workbench.png")}
Workbench.__index = Workbench
local ActiveWorkbenchs = {}

local MsgUI = require("msgUI")

function Workbench.removeAll()
    for i,v in ipairs(ActiveWorkbenchs) do
        v.physics.body:destroy()
    end

    ActiveWorkbenchs = {}
end

function Workbench:remove()
    for i, instance in ipairs(ActiveWorkbenchs) do
        if instance == self then
            self.physics.body:destroy()
            table.remove(ActiveWorkbenchs, i)
        end
    end
end

function Workbench.returnTable()
    return ActiveWorkbenchs
end

function Workbench.new(x, y)
    instance = setmetatable({}, Workbench)
    instance.x = x
    instance.y = y
    instance.scale = 0.75

    instance.msgUI = nil

    instance.width = instance.img:getWidth()
    instance.height = instance.img:getHeight()

    instance.physics = {}
    instance.physics.body = love.physics.newBody(World, instance.x, instance.y, "static")
    instance.physics.shape = love.physics.newRectangleShape(instance.width * instance.scale, instance.height * instance.scale)
    instance.physics.fixture = love.physics.newFixture(instance.physics.body, instance.physics.shape)
    instance.physics.fixture:setSensor(true)

    table.insert(ActiveWorkbenchs, instance)
end

function Workbench.loadAssets()
end

function Workbench:update(dt)
    if self.toBeRemoved then
        self:remove()
    end
end

function Workbench:syncPhysics()
    self.x, self.y = self.physics.body:getPosition()
end

function Workbench:draw()
    love.graphics.draw(self.img, self.x, self.y, 0, self.scale, self.scale, self.width / 2, self.height / 2)

    -- self:drawHitBox()
end

function Workbench:drawHitBox()
    love.graphics.setColor(1, 0, 0)
    love.graphics.polygon("line", self.physics.fixture:getBody():getWorldPoints(self.physics.fixture:getShape():getPoints()))
    love.graphics.setColor(1, 1, 1)
end

function Workbench:callbackAction()
    GUI:desactivePanels()
    GUI.affPanel.craft = true
end

function Workbench:affMsgUI()
    if(self.msgUI ~= nil) then
        local cooldownRest = math.floor(self.cooldownRevive.rate - self.cooldownRevive.timer)

        if(cooldownRest ~= self.msgUI.timer) then
            self.msgUI:remove()
            self.msgUI = MsgUI.new(nil, nil, "Harvestable in "..cooldownRest.."sec")
        end
    end
end

function Workbench:affMsgWhenPlayerIn()
    if GUI.enablePanel.craft then
        self.msgUI = MsgUI.new(nil, nil, "Open craft panel", true, nil, function() self:callbackAction() end)
    end
end

function Workbench.updateAll(dt)
    for i,instance in ipairs(ActiveWorkbenchs) do
        instance:update(dt)
    end
end

function Workbench.drawAll()
    for i,instance in ipairs(ActiveWorkbenchs) do
        instance:draw()
    end
end

function Workbench.beginContact(a, b, collision)
    for i, instance in ipairs(ActiveWorkbenchs) do
        if a == instance.physics.fixture or b == instance.physics.fixture then
            if a == Player.physics.fixture or b == Player.physics.fixture then
                instance:affMsgWhenPlayerIn()
            end
        end
    end
end

function Workbench.endContact(a, b, collision)
    for i, instance in ipairs(ActiveWorkbenchs) do
        if a == instance.physics.fixture or b == instance.physics.fixture then
            if(instance.msgUI ~= nil) then
                instance.msgUI:remove()
                instance.msgUI = nil

                GUI.affPanel.craft = false
                GUI:clearPopup()
            end

            for i=1, #CraftableItems do
                if CraftableItems[i].button ~= nil then
                    CraftableItems[i].button.canClick = false
                end
            end
        end
    end
end

return Workbench