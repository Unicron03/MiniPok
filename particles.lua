local Particles = {}

function Particles:new(x, y)
    local image = love.graphics.newImage("assets/particles.png")
    local particleSystem = love.graphics.newParticleSystem(image, 32)
    particleSystem:setPosition(x, y)
    particleSystem:setParticleLifetime(2.5, 4) -- Vie de x a xsec
    particleSystem:setEmissionRate(15)
    particleSystem:setSizeVariation(1)
    particleSystem:setSizes(2, 3) -- Tailles des particules (de 2 a 3)
    particleSystem:setLinearAcceleration(-20, -20, 20, 20) -- s'accélèrent entre ces deux limites
    particleSystem:setColors(1, 1, 1, 1, 1, 1, 1, 0) -- blanc opaque à blanc transparent au cours de leur vie.

    return particleSystem
end

function Particles:setPosition(particleSystem, x, y)
    particleSystem:setPosition(x, y)
end

function Particles:update(dt, particleSystem)
    particleSystem:update(dt)
end

function Particles:draw(particleSystem)
    love.graphics.draw(particleSystem)
end

return Particles