

local Skull = {}
Skull.__index = Skull 
local ActiveSkull = {}

function Skull.new(x, y, id)
    instance = setmetatable({}, Skull)
    instance.x = x
    instance.y = y
    instance.id = id
    instance.r = 0
    instance.scale = 2.5
    instance.scaleRatio = 1
    instance.damage = 2
    instance.toBeRemoved = false

    instance.color = {
        red = 1,
        green = 1,
        blue = 1,
        speed = 3
    }

    instance.xVel = 0
    instance.yVel = 0
    instance.maxSpeed = 60
    instance.life = {current = 8, total = 8}
    
    instance.state = "idle"
    instance.animation = instance:loadAssets()
    instance.timer = {current = 0, rate = 0.1}

    instance.physics = {}
    instance.physics.body = love.physics.newBody(World, instance.x, instance.y, "dynamic")
    instance.physics.shape = love.physics.newRectangleShape(instance.animation.width * instance.scale, instance.animation.height * instance.scale)
    instance.physics.fixture = love.physics.newFixture(instance.physics.body, instance.physics.shape)

    instance.physics.fixture:setSensor(true)
    instance.physics.fixture:setUserData("skull")
    
    table.insert(ActiveSkull, instance)
end

function Skull.returnTable()
    return ActiveSkull
end

function Skull:loadAssets()
    local animation = {}

    animation.idle = {total = 4, current = 1, img = {}, rate = 0.2}
    for i=1, animation.idle.total do
        animation.idle.img[i] = love.graphics.newImage("assets/mobs/skull/"..i..".png")        
    end

    animation.draw = animation.idle.img[1]
    animation.width = animation.draw:getWidth()
    animation.height = animation.draw:getHeight()

    return animation
end

function Skull.removeAll()
    for i,v in ipairs(ActiveSkull) do
        v.physics.body:destroy()
    end

    ActiveSkull = {}
end

function Skull:remove()
    for i,instance in ipairs(ActiveSkull) do
        if instance == self then
            self.physics.body:destroy()
            table.remove(ActiveSkull, i)
        end
    end
end

function Skull:tintRed()
    self.color.green = 0
    self.color.blue = 0
end

function Skull:takeDamage(damage)
    self.life.current = self.life.current - damage
    self:tintRed()
    Sound:play("hit")
    
    if self.life.current <= 0 then
        self.toBeRemoved = true
    end
end

function Skull:update(dt)
    self:animate(dt)
    self:syncPhysics()
    self:checkRemove()
    self:rotateTowardsPlayer()
    self:unTint(dt)

    self:goto(Player.x, Player.y)
end

function Skull:unTint(dt)
    self.color.red = math.min(self.color.red + self.color.speed * dt, 1)
    self.color.green = math.min(self.color.green + self.color.speed * dt, 1)
    self.color.blue = math.min(self.color.blue + self.color.speed * dt, 1)
end

function Skull:animate(dt)
    self.timer.current = self.timer.current + dt

    if self.timer.current > self.timer.rate then
        self.timer.current = 0
        self:setNewFrame()     
    end 
end

function Skull:setNewFrame()
    local anim = self.animation[self.state]

    if anim.current < anim.total then
        anim.current = anim.current + 1 
    else
        anim.current = 1
    end

    self.animation.draw = anim.img[anim.current]
end

function Skull:checkRemove()
    if self.toBeRemoved then
        self:remove()
    end
end

function Skull:rotateTowardsPlayer()
    -- local angle = math.atan2(Player.y - self.y, Player.x - self.x)
    -- self.r = angle + 14.9
    -- if self.physics.body:isDestroyed() == false then
    --     self.physics.body:setAngle(angle)
    -- end

    if Player.x >= self.x then
        self.scaleRatio = 1
    else
        self.scaleRatio = -1
    end
end

function Skull:goto(x, y)
    local angle = math.atan2(y - self.y, x - self.x)
    self.xVel = self.maxSpeed * math.cos(angle)
    self.yVel = self.maxSpeed * math.sin(angle)
end

function Skull:syncPhysics()
    self.x, self.y = self.physics.body:getPosition()
    self.physics.body:setLinearVelocity(self.xVel, self.yVel)
end

function Skull:draw()
    love.graphics.setColor(self.color.red,self.color.green, self.color.blue)
    love.graphics.draw(self.animation.draw, self.x, self.y, self.r, self.scale * self.scaleRatio, self.scale, self.animation.width / 2, self.animation.height / 2)
    love.graphics.setColor(1,1,1,1)

    self:drawHitbox()
end

function Skull:drawHitbox()
    love.graphics.setColor(1, 0, 0)
    love.graphics.polygon("line", self.physics.fixture:getBody():getWorldPoints(self.physics.fixture:getShape():getPoints()))
    love.graphics.setColor(1, 1, 1)
end

function Skull.updateAll(dt)
    for i,instance in ipairs(ActiveSkull) do
        instance:update(dt)
    end
end

function Skull.drawAll()
    for i,instance in ipairs(ActiveSkull) do
        instance:draw()
    end
end

function Skull.beginContact(a, b, collision)
    for i,instance in ipairs(ActiveSkull) do
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

return Skull