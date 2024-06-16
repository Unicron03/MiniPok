

local Mage = {}
Mage.__index = Mage 
local ActiveMage = {}

function Mage.new(x, y, id)
    instance = setmetatable({}, Mage)
    instance.x = x
    instance.y = y
    instance.id = id
    instance.r = 0
    instance.scale = 2.5
    instance.scaleRatio = 1
    instance.damage = 8
    instance.toBeRemoved = false

    instance.color = {
        red = 1,
        green = 1,
        blue = 1,
        speed = 3
    }

    instance.xVel = 0
    instance.yVel = 0
    instance.life = {current = 10, total = 10}

    instance.cooldownMin = 2 -- base 7
    instance.cooldownMax = 3 -- base 15

    instance.cooldown = {current = 0, rate = math.random(instance.cooldownMin, instance.cooldownMax)}

    instance.state = "idle"
    instance.animation = instance:loadAssets()
    instance.timer = {current = 0, rate = instance.animation[instance.state].rate}

    instance.physics = {}
    instance.physics.body = love.physics.newBody(World, instance.x, instance.y, "dynamic")
    instance.physics.shape = love.physics.newRectangleShape(instance.animation.width * instance.scale, instance.animation.height * instance.scale)
    instance.physics.fixture = love.physics.newFixture(instance.physics.body, instance.physics.shape)

    instance.physics.fixture:setSensor(true)
    instance.physics.fixture:setUserData({type = "mage", damage = instance.damage})
    
    table.insert(ActiveMage, instance)
end

function Mage.returnTable()
    return ActiveMage
end

function Mage:loadAssets()
    local animation = {}

    animation.idle = {total = 4, current = 1, img = {}, rate = 0.1}
    for i=1, animation.idle.total do
        animation.idle.img[i] = love.graphics.newImage("assets/mobs/mage/idle/"..i..".png")        
    end

    animation.attack = {total = 2, current = 1, img = {}, rate = 1}
    for i=1, animation.attack.total do
        animation.attack.img[i] = love.graphics.newImage("assets/mobs/mage/attack/"..i..".png")        
    end

    animation.draw = animation.idle.img[1]
    animation.width = animation.draw:getWidth()
    animation.height = animation.draw:getHeight()

    return animation
end

function Mage.removeAll()
    for i,v in ipairs(ActiveMage) do
        v.physics.body:destroy()
    end

    ActiveMage = {}
end

function Mage:remove()
    for i,instance in ipairs(ActiveMage) do
        if instance == self then
            self.physics.body:destroy()
            table.remove(ActiveMage, i)
        end
    end
end

function Mage:tintRed()
    self.color.green = 0
    self.color.blue = 0
end

function Mage:takeDamage(damage)
    self.life.current = self.life.current - damage
    self:tintRed()
    Sound:play("hit")
    
    if self.life.current <= 0 then
        self.toBeRemoved = true
    end
end

function Mage:update(dt)
    self:animate(dt)
    self:syncPhysics()
    self:checkRemove()
    self:rotateTowardsPlayer()
    self:unTint(dt)
end

function Mage:unTint(dt)
    self.color.red = math.min(self.color.red + self.color.speed * dt, 1)
    self.color.green = math.min(self.color.green + self.color.speed * dt, 1)
    self.color.blue = math.min(self.color.blue + self.color.speed * dt, 1)
end

function Mage:sendAttack()
    local Projectile = require("projectile")
    Projectile.new(self.x, self.y, Player.x, Player.y, 5)
end

function Mage:animate(dt)
    self.timer.current = self.timer.current + dt

    if self.state == "idle" then
        self.cooldown.current = self.cooldown.current + dt
    end

    if self.timer.current > self.timer.rate then
        self.timer.current = 0
        self:setNewFrame()     
    end 
end

function Mage:setNewFrame()
    local anim = self.animation[self.state]

    if anim.current < anim.total then
        anim.current = anim.current + 1

        if self.state == "attack" and anim.current == anim.total then
            self:sendAttack()
        end
    else
        anim.current = 1

        if self.state == "attack" then
            self.state = "idle"
            self.cooldown.rate = math.random(self.cooldownMin, self.cooldownMax)
        elseif self.cooldown.current > self.cooldown.rate then
            self.state = "attack"
            self.cooldown.current = 0
        end

        self.timer.rate = self.animation[self.state].rate
    end

    self.animation.draw = self.animation[self.state].img[anim.current]
end

function Mage:checkRemove()
    if self.toBeRemoved then
        self:remove()
    end
end

function Mage:rotateTowardsPlayer()
    if Player.x >= self.x then
        self.scaleRatio = -1
    else
        self.scaleRatio = 1
    end
end

function Mage:syncPhysics()
    self.x, self.y = self.physics.body:getPosition()
    self.physics.body:setLinearVelocity(self.xVel, self.yVel)
end

function Mage:draw()
    love.graphics.setColor(self.color.red,self.color.green, self.color.blue)
    love.graphics.draw(self.animation.draw, self.x, self.y, self.r, self.scale * self.scaleRatio, self.scale, self.animation.width / 2, self.animation.height / 2)
    love.graphics.setColor(1,1,1,1)

    self:drawHitbox()
end

function Mage:drawHitbox()
    love.graphics.setColor(1, 0, 0)
    love.graphics.polygon("line", self.physics.fixture:getBody():getWorldPoints(self.physics.fixture:getShape():getPoints()))
    love.graphics.setColor(1, 1, 1)
end

function Mage.updateAll(dt)
    for i,instance in ipairs(ActiveMage) do
        instance:update(dt)
    end
end

function Mage.drawAll()
    for i,instance in ipairs(ActiveMage) do
        instance:draw()
    end
end

function Mage.beginContact(a, b, collision)
    for i,instance in ipairs(ActiveMage) do
        if a == instance.physics.fixture or b == instance.physics.fixture then
            if a == Player.physics.fixture or b == Player.physics.fixture then
                Player:takeDamageInFight(instance.damage)
            elseif a:getUserData().type == "projectilePlayer" or b:getUserData().type == "projectilePlayer" then
                local damage = (a:getUserData().damage) and (a:getUserData().damage) or (b:getUserData().damage)
                instance:takeDamage(damage)
            end
        end
    end
end

return Mage