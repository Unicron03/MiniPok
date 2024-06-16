local Machoc = {name = "Machoc"}

local stats = {
    isShiny = false
}

function Machoc:new()
    local newMachoc = {}
    setmetatable(newMachoc, self)
    self.__index = self
    return newMachoc
end

function Machoc:load(state)
    self.evolution = "Machopeur"
    self.pv = 100
    self.maxSpeed = 175
    self.type = PokemonTypes.GROUND
    self.animation = self:loadAssets((state ~= null and state or "idle"))
    self.icon = love.graphics.newImage("assets/pok/machoc/icon.png")

    self.attack = {
        [1] = {
            name = "Balayage",
            damage = 10
        },
        [2] = {
            name = "Koud'poing",
            damage = 20
        },
        [3] = {
            name = "Double Baffe",
            damage = 30
        }
    }
end

function Machoc:loadAssets(state)
    -- Gère le chargement des assets du Pokémon

    animation = {timer = 0, rate = 0.2}

    animation.idle = {total = 1, current = 1, img = {}, rate = 0.2}
    for i=1,animation.idle.total do
        animation.idle.img[i] = love.graphics.newImage("assets/pok/machoc/idle/"..i..".png")        
    end

    animation.right = {total = 4, current = 1, img = {}, rate = 0.15}
    for i=1,animation.right.total do
        animation.right.img[i] = love.graphics.newImage("assets/pok/machoc/right/"..i..".png")        
    end

    animation.left = {total = 4, current = 1, img = {}, rate = 0.15}
    for i=1,animation.left.total do
        animation.left.img[i] = love.graphics.newImage("assets/pok/machoc/left/"..i..".png")        
    end

    animation.bottom = {total = 4, current = 1, img = {}, rate = 0.15}
    for i=1,animation.bottom.total do
        animation.bottom.img[i] = love.graphics.newImage("assets/pok/machoc/bottom/"..i..".png")        
    end

    animation.top = {total = 4, current = 1, img = {}, rate = 0.15}
    for i=1,animation.top.total do
        animation.top.img[i] = love.graphics.newImage("assets/pok/machoc/top/"..i..".png")        
    end

    animation.draw = animation[state].img[1]
    animation.width = animation.draw:getWidth()
    animation.height = animation.draw:getHeight()

    return animation
end

function Machoc:GetStats(stat)
    -- Renvoie la veleur d'une stat

    return stats[stat]
end

function Machoc:SetStats(stat, value)
    -- Mets la valeur d'une stat sur une valeur donné

    stats[stat] = value
end

return Machoc