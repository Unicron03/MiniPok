
local Strawberry = {img = love.graphics.newImage("assets/items/ressources/strawberry.png"), name = "Strawberry"}
Strawberry.__index = Strawberry

Strawberry.width = Strawberry.img:getWidth()
Strawberry.height = Strawberry.img:getHeight()

local FLOATING_AMPLITUDE = 5
local FLOATING_SPEED = 2.5

local ActiveStrawberrys = {}

function Strawberry.removeAll()
    for i,v in ipairs(ActiveStrawberrys) do
        v.physics.body:destroy()
    end

    ActiveStrawberrys = {}
end

function Strawberry:remove()
    for i, instance in ipairs(ActiveStrawberrys) do
        if instance == self then
            self.physics.body:destroy()
            table.remove(ActiveStrawberrys, i)
        end
    end
end

function Strawberry.new(x, y)
    instance = setmetatable({}, Strawberry)
    instance.x = x 
    instance.y = y
    instance.r = 0
    instance.scale = 2
    instance.itemType = ItemTypes.CONSUMABLE
    
    instance.givable = {
        type = "hunger",
        value = 30
    }

    instance.physics = {}
    instance.physics.body = love.physics.newBody(World, instance.x, instance.y, "static")
    instance.physics.shape = love.physics.newRectangleShape(instance.width * instance.scale, instance.height * instance.scale)
    instance.physics.fixture = love.physics.newFixture(instance.physics.body, instance.physics.shape)
    instance.physics.fixture:setSensor(true)
    table.insert(ActiveStrawberrys, instance)
end

function Strawberry:returnNbEntities()
    return #ActiveStrawberrys
end

function Strawberry:update(dt)
    -- self:syncPhysics()
end

function Strawberry:syncPhysics()
    self.x, self.y = self.physics.body:getPosition()
end

function Strawberry:draw()
    local offsetY = FLOATING_AMPLITUDE * math.sin(love.timer.getTime() * FLOATING_SPEED)
    local drawY = self.y + offsetY

    love.graphics.draw(self.img, self.x, drawY, self.r, self.scale, self.scale, self.width / 2, self.height / 2)

    -- self:drawHitbox()
end

function Strawberry:drawHitbox()
    love.graphics.setColor(1, 0, 0)
    love.graphics.polygon("line", self.physics.fixture:getBody():getWorldPoints(self.physics.fixture:getShape():getPoints()))
    love.graphics.setColor(1, 1, 1)
end

function Strawberry.updateAll(dt)
    for i,instance in ipairs(ActiveStrawberrys) do
        instance:update(dt)
    end
end

function Strawberry.drawAll()
    for i,instance in ipairs(ActiveStrawberrys) do
        instance:draw()
    end
end

function Strawberry.beginContact(a, b, collision)
    for i,instance in ipairs(ActiveStrawberrys) do
        if a == instance.physics.fixture or b == instance.physics.fixture then
            if a == Player.physics.fixture or b == Player.physics.fixture then
                Inventory:giveToInventory(instance.name, instance)
                instance:remove()
            end
        end
    end
end

return Strawberry