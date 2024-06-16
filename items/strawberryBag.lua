
local StrawberryBag = {img = love.graphics.newImage("assets/items/plants/strawberry/bag.png"), name = "Strawberry Bag"}
StrawberryBag.__index = StrawberryBag

StrawberryBag.width = StrawberryBag.img:getWidth()
StrawberryBag.height = StrawberryBag.img:getHeight()

local FLOATING_AMPLITUDE = 5
local FLOATING_SPEED = 2.5

local ActiveStrawberryBags = {}

function StrawberryBag.removeAll()
    for i,v in ipairs(ActiveStrawberryBags) do
        v.physics.body:destroy()
    end

    ActiveStrawberryBags = {}
end

function StrawberryBag:remove()
    for i, instance in ipairs(ActiveStrawberryBags) do
        if instance == self then
            self.physics.body:destroy()
            table.remove(ActiveStrawberryBags, i)
        end
    end
end

function StrawberryBag.new(x, y)
    instance = setmetatable({}, StrawberryBag)
    instance.x = x
    instance.y = y
    instance.r = 0
    instance.scale = 2.5
    instance.itemType = ItemTypes.PLANT

    instance.durability = 1
    instance.imgPlant = {img = instance.loadAssets(), current = 1, total = #instance.loadAssets()}

    local Items = require("items")
    instance.lootTable = {Items.Strawberry}

    instance.physics = {}
    instance.physics.body = love.physics.newBody(World, instance.x, instance.y, "static")
    instance.physics.shape = love.physics.newRectangleShape(instance.width * instance.scale, instance.height * instance.scale)
    instance.physics.fixture = love.physics.newFixture(instance.physics.body, instance.physics.shape)
    instance.physics.fixture:setSensor(true)

    table.insert(ActiveStrawberryBags, instance)
end

function StrawberryBag.loadAssets()
    local assetsPlant = {} 

    for i=1,3 do
        assetsPlant[i] = love.graphics.newImage("assets/items/plants/strawberry/"..i..".png")
    end

    return assetsPlant
end

function StrawberryBag:giveLoot()
    for i, item in ipairs(self.lootTable) do
        for i=0, math.random(1, 3) do
            item.new(Player.x, Player.y)
        end
    end
end

function StrawberryBag:returnNbEntities()
    return #ActiveStrawberryBags
end

function StrawberryBag:update(dt)
    -- self:syncPhysics()
end

function StrawberryBag:syncPhysics()
    self.x, self.y = self.physics.body:getPosition()
end

function StrawberryBag:draw()
    local offsetY = FLOATING_AMPLITUDE * math.sin(love.timer.getTime() * FLOATING_SPEED)
    local drawY = self.y + offsetY

    love.graphics.draw(self.img, self.x, drawY, self.r, self.scale, self.scale, self.width / 2, self.height / 2)

    -- self:drawHitbox()
end

function StrawberryBag:drawHitbox()
    love.graphics.setColor(1, 0, 0)
    love.graphics.polygon("line", self.physics.fixture:getBody():getWorldPoints(self.physics.fixture:getShape():getPoints()))
    love.graphics.setColor(1, 1, 1)
end

function StrawberryBag.updateAll(dt)
    for i,instance in ipairs(ActiveStrawberryBags) do
        instance:update(dt)
    end
end

function StrawberryBag.drawAll()
    for i,instance in ipairs(ActiveStrawberryBags) do
        instance:draw()
    end
end

function StrawberryBag.beginContact(a, b, collision)
    for i,instance in ipairs(ActiveStrawberryBags) do
        if a == instance.physics.fixture or b == instance.physics.fixture then
            if a == Player.physics.fixture or b == Player.physics.fixture then
                Inventory:giveToInventory(instance.name, instance)
                instance:remove()
            end
        end
    end
end

return StrawberryBag