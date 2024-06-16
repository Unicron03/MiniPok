

local Projectile = {}
Projectile.__index = Projectile 
local ActiveProjectiles = {}

function Projectile:remove()
    for i,instance in ipairs(ActiveProjectiles) do
        if instance == self then
            self.physics.body:destroy()
            table.remove(ActiveProjectiles, i)
        end
    end
end

function Projectile.removeAll()
    for i,v in ipairs(ActiveProjectiles) do
        v.physics.body:destroy()
    end

    ActiveProjectiles = {}
end

function Projectile.new(x, y, xGoal, yGoal, damage, from)
    instance = setmetatable({}, Projectile)
    instance.x = x
    instance.y = y
    instance.damage = damage
    instance.from = (from == nil) and ("projectile") or ("projectile"..from)

    instance.scale = 2
    instance.toBeRemoved = false

    instance.xVel, instance.yVel = instance:getVelocity(xGoal, yGoal)
    instance.r = instance:getRotationAngle(xGoal, yGoal)

    instance.state = "basic"
    instance.animation = instance:loadAssets()
    instance.timer = {current = 0, rate = instance.animation[instance.state].rate}

    instance.physics = {}
    instance.physics.body = love.physics.newBody(World, instance.x, instance.y, "dynamic")
    instance.physics.shape = love.physics.newRectangleShape(instance.animation.width * instance.scale, instance.animation.height * instance.scale)
    instance.physics.fixture = love.physics.newFixture(instance.physics.body, instance.physics.shape)

    instance.physics.fixture:setSensor(true)
    instance.physics.fixture:setUserData({type = instance.from, damage = instance.damage})

    table.insert(ActiveProjectiles, instance)
end

function Projectile:loadAssets()
    local animation = {}

    animation.basic = {total = 4, current = 1, img = {}, rate = 0.1}
    for i=1,animation.basic.total do
        animation.basic.img[i] = love.graphics.newImage("assets/projectile/"..i..".png")
    end

    animation.draw = animation.basic.img[1]
    animation.width = animation.draw:getWidth()
    animation.height = animation.draw:getHeight()

    return animation
end

function Projectile:returnNbEntities()
    return #ActiveProjectiles
end

function Projectile:getVelocity(x, y)
    if(x ~= nil and y ~= nil) then
        local speed = 500 -- Vitesse des projectiles
        local angle = math.atan2(y - self.y, x - self.x)

        local xVel = speed * math.cos(angle)
        local yVel = speed * math.sin(angle)

        return xVel, yVel
    end
end

function Projectile:getRotationAngle(x, y)
    local xDist = x - self.x
    local yDist = y - self.y
    local rad = math.atan2(yDist, xDist)

    return rad
end

function Projectile:update(dt)
    self:syncPhysics()
    self:checkRemove()
    self:animate(dt)
end

function Projectile:animate(dt)
    self.timer.current = self.timer.current + dt

    if self.timer.current > self.timer.rate then
        self.timer.current = 0
        self:setNewFrame()     
    end 
end

function Projectile:setNewFrame()
    local anim = self.animation[self.state]

    if anim.current < anim.total then
        anim.current = anim.current + 1 
    else
        anim.current = 1
    end

    self.animation.draw = anim.img[anim.current]
end

function Projectile:leaveWindow()
    return (self.x > Camera.x + love.graphics:getWidth()) or (self.y > Camera.y + love.graphics:getHeight()) or
            (self.x < Camera.x) or (self.y < Camera.y)
end

function Projectile:checkRemove()
    if self.toBeRemoved or self:leaveWindow() then
        self:remove()
    end
end

function Projectile:syncPhysics()
    self.x, self.y = self.physics.body:getPosition()
    self.physics.body:setLinearVelocity(self.xVel, self.yVel)
end

function Projectile:draw()
    love.graphics.draw(self.animation.draw, self.x, self.y, self.r, -self.scale, -self.scale, self.animation.width / 2, self.animation.height / 2)

    self:drawHitbox()
end

function Projectile:drawHitbox()
    love.graphics.setColor(1, 0, 0)
    love.graphics.polygon("line", self.physics.fixture:getBody():getWorldPoints(self.physics.fixture:getShape():getPoints()))
    love.graphics.setColor(1, 1, 1)
end

function Projectile.updateAll(dt)
    for i,instance in ipairs(ActiveProjectiles) do
        instance:update(dt)
    end
end

function Projectile.drawAll()
    for i,instance in ipairs(ActiveProjectiles) do
        instance:draw()
    end
end

function Projectile.beginContact(a, b, collision)
    for i,instance in ipairs(ActiveProjectiles) do
        if a == instance.physics.fixture or b == instance.physics.fixture then
            if instance.from ~= "projectilePlayer" then
                if a == Player.physics.fixture or b == Player.physics.fixture then
                    Player:takeDamageInFight(instance.damage)
                    instance.toBeRemoved = true
                elseif not (a:getUserData().type == "mage" or b:getUserData().type == "mage") then
                    instance.toBeRemoved = true
                end
            else
                if not (a == Player.physics.fixture or b == Player.physics.fixture) then
                    instance.toBeRemoved = true
                end
            end
        end
    end
end

return Projectile