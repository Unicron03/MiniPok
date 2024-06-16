
local CarrotBag = {img = love.graphics.newImage("assets/items/plants/carrot/bag.png"), name = "Carrot Bag"}
CarrotBag.__index = CarrotBag

CarrotBag.width = CarrotBag.img:getWidth()
CarrotBag.height = CarrotBag.img:getHeight()

local FLOATING_AMPLITUDE = 5
local FLOATING_SPEED = 2.5

local ActiveCarrotBags = {}

function CarrotBag.removeAll()
    for i,v in ipairs(ActiveCarrotBags) do
        v.physics.body:destroy()
    end

    ActiveCarrotBags = {}
end

function CarrotBag:remove()
    for i, instance in ipairs(ActiveCarrotBags) do
        if instance == self then
            self.physics.body:destroy()
            table.remove(ActiveCarrotBags, i)
        end
    end
end

function CarrotBag.new(x, y)
    instance = setmetatable({}, CarrotBag)
    instance.x = x
    instance.y = y
    instance.r = 0
    instance.scale = 2.5
    instance.itemType = ItemTypes.PLANT

    instance.durability = 1
    instance.imgPlant = {img = instance.loadAssets(), current = 1, total = #instance.loadAssets()}

    local Items = require("items")
    instance.lootTable = {Items.Carrot}

    instance.physics = {}
    instance.physics.body = love.physics.newBody(World, instance.x, instance.y, "static")
    instance.physics.shape = love.physics.newRectangleShape(instance.width * instance.scale, instance.height * instance.scale)
    instance.physics.fixture = love.physics.newFixture(instance.physics.body, instance.physics.shape)
    instance.physics.fixture:setSensor(true)

    table.insert(ActiveCarrotBags, instance)
end

function CarrotBag.loadAssets()
    local assetsPlant = {} 

    for i=1,3 do
        assetsPlant[i] = love.graphics.newImage("assets/items/plants/carrot/"..i..".png")
    end

    return assetsPlant
end

function CarrotBag:giveLoot()
    for i, item in ipairs(self.lootTable) do
        for i=0, math.random(1, 3) do
            item.new(Player.x, Player.y)
        end
    end
end

function CarrotBag:returnNbEntities()
    return #ActiveCarrotBags
end

function CarrotBag:update(dt)
    -- self:syncPhysics()
end

function CarrotBag:syncPhysics()
    self.x, self.y = self.physics.body:getPosition()
end

function CarrotBag:draw()
    local offsetY = FLOATING_AMPLITUDE * math.sin(love.timer.getTime() * FLOATING_SPEED)
    local drawY = self.y + offsetY

    love.graphics.draw(self.img, self.x, drawY, self.r, self.scale, self.scale, self.width / 2, self.height / 2)

    -- self:drawHitbox()
end

function CarrotBag:drawHitbox()
    love.graphics.setColor(1, 0, 0)
    love.graphics.polygon("line", self.physics.fixture:getBody():getWorldPoints(self.physics.fixture:getShape():getPoints()))
    love.graphics.setColor(1, 1, 1)
end

function CarrotBag.updateAll(dt)
    for i,instance in ipairs(ActiveCarrotBags) do
        instance:update(dt)
    end
end

function CarrotBag.drawAll()
    for i,instance in ipairs(ActiveCarrotBags) do
        instance:draw()
    end
end

function CarrotBag.beginContact(a, b, collision)
    for i,instance in ipairs(ActiveCarrotBags) do
        if a == instance.physics.fixture or b == instance.physics.fixture then
            if a == Player.physics.fixture or b == Player.physics.fixture then
                Inventory:giveToInventory(instance.name, instance)
                instance:remove()
            end
        end
    end
end

return CarrotBag