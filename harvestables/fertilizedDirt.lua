
local FertilizedDirt = {img = love.graphics.newImage("assets/items/ressources/fertilizedDirt.png")}
FertilizedDirt.__index = FertilizedDirt
local ActiveFertilizedDirts = {}

FertilizedDirt.width = FertilizedDirt.img:getWidth()
FertilizedDirt.height = FertilizedDirt.img:getHeight()

local MsgUI = require("msgUI")

function FertilizedDirt.removeAll()
    for i,v in ipairs(ActiveFertilizedDirts) do
        v.physics.body:destroy()
    end

    ActiveFertilizedDirts = {}
end

function FertilizedDirt:remove()
    for i, instance in ipairs(ActiveFertilizedDirts) do
        if instance == self then
            self.physics.body:destroy()
            table.remove(ActiveFertilizedDirts, i)
        end
    end
end

function FertilizedDirt.returnTable()
    return ActiveFertilizedDirts
end

function FertilizedDirt.new(x, y)
    instance = setmetatable({}, FertilizedDirt)
    instance.x = x
    instance.y = y
    instance.scale = 2.5

    instance.msgUI = nil
    instance.plant = nil
    instance.cooldown = {rate = 120, timer = 0}

    instance.physics = {}
    instance.physics.body = love.physics.newBody(World, instance.x, instance.y, "static")
    instance.physics.shape = love.physics.newRectangleShape(instance.width * instance.scale, instance.height * instance.scale)
    instance.physics.fixture = love.physics.newFixture(instance.physics.body, instance.physics.shape)
    
    instance.physics.fixture:setSensor(true)

    table.insert(ActiveFertilizedDirts, instance)
end

function FertilizedDirt.loadAssets()
end

function FertilizedDirt:update(dt)
    if self.toBeRemoved then
        self:remove()
    end

    if(self.plant ~= nil) then
        self:growPlant(dt)
    end
end

function FertilizedDirt:growPlant(dt)
    if(self.plant.imgPlant.current < self.plant.imgPlant.total) then
        self.cooldown.timer = self.cooldown.timer + dt

        if self.cooldown.timer > self.cooldown.rate then
            self.plant.imgPlant.current = self.plant.imgPlant.current + 1
            self.cooldown.timer = 0
        end
    end
end

function FertilizedDirt:syncPhysics()
    self.x, self.y = self.physics.body:getPosition()
end

function FertilizedDirt:draw()
    love.graphics.draw(self.img, self.x, self.y, self.r, self.scale, self.scale, self.width / 2, self.height / 2)

    if(self.plant ~= nil) then
        local plant = self.plant.imgPlant
        local x = self.x + (self.width * self.scale) * 0.5 - plant.img[plant.current]:getWidth()    
        love.graphics.draw(plant.img[plant.current], x, self.y - 7, self.r, self.scale, self.scale, self.width / 2, self.height / 2)
    end

    -- self:drawHitBox()
end

function FertilizedDirt:drawHitBox()
    love.graphics.setColor(1, 0, 0)
    love.graphics.polygon("line", self.physics.fixture:getBody():getWorldPoints(self.physics.fixture:getShape():getPoints()))
    love.graphics.setColor(1, 1, 1)
end

function FertilizedDirt:callbackAction()
    slotPlant = Inventory.slotPlant

    self.plant = slotPlant.item

    slotPlant.quantity = slotPlant.quantity - 1
    if(slotPlant.quantity <= 0) then
        slotPlant.id = nil
        slotPlant.quantity = 0
        slotPlant.icon = nil
        slotPlant.item = nil
    end
    -- tree_hit:play()

    if(slotPlant.id ~= nil) then
        self.msgUI = MsgUI.new(nil, nil, "Cultive "..slotPlant.id, true, nil, function() self:callbackAction() end)
    else
        self.msgUI = MsgUI.new(nil, nil, "You dont have plants to cultive")
    end
end

function FertilizedDirt:callbackActionPlant()
    self.plant:giveLoot()
    self.plant = nil
end

function FertilizedDirt.updateAll(dt)
    for i,instance in ipairs(ActiveFertilizedDirts) do
        instance:update(dt)
    end
end

function FertilizedDirt.drawAll()
    for i,instance in ipairs(ActiveFertilizedDirts) do
        instance:draw()
    end
end

function FertilizedDirt.beginContact(a, b, collision)
    for i, instance in ipairs(ActiveFertilizedDirts) do
        if a == instance.physics.fixture or b == instance.physics.fixture then
            if a == Player.physics.fixture or b == Player.physics.fixture then
                if(instance.plant ~= nil) then
                    if(instance.plant.imgPlant.current == instance.plant.imgPlant.total) then
                        instance.msgUI = MsgUI.new(nil, nil, "Recolt", true, nil, function() instance:callbackActionPlant() end)
                        return
                    end
                end

                if(Inventory.slotPlant.id ~= nil) then
                    if(instance.msgUI == nil) then
                        instance.msgUI = MsgUI.new(nil, nil, "Cultive "..Inventory.slotPlant.id, true, nil, function() instance:callbackAction() end)
                    end
                else
                    instance.msgUI = MsgUI.new(nil, nil, "You dont have plants to cultive")
                end
            end
        end
    end
end

function FertilizedDirt.endContact(a, b, collision)
    for i, instance in ipairs(ActiveFertilizedDirts) do
        if a == instance.physics.fixture or b == instance.physics.fixture then
            if(instance.msgUI ~= nil) then
                instance.msgUI:remove()
                instance.msgUI = nil
            end
        end
    end
end

return FertilizedDirt